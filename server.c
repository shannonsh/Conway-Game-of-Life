/*
* This server aims to service multiple games of varying numbers of players at the 
* same time. Moves by any player in the game are broadcast to all players in the game.
* 
* How the server works
* - Uses TCP protocol
* - Creates a thread (ac_thread) to listen for and accept new 
*   connections from clients. Writes client fds to shared
*   shared array sockfds
* - Main thread delegates player roles, manages game status, and replies
*   to clients
* 
* Communication protocol:
* 	Message format: [header (3 characters)]:[content of message]
* 	  Example: dsg:0
*     TODO: include sender and recipient of message for games with > 2 players
*   Headers:
* 	  dsg (server only) - assigns role of player
*       Example: dsg:0
* 	  iam (client only) - sets the identity of the player. Server currently does not do 
*       anything with this information
* 		Example: iam:John
* 	  mov - contains move of other player; broadcasted to all other players in the 
* 		game. Format of content is dependent on game.
* 		Example: mov:5.5650313322478, 8.8272921108742
					5.5650313322478, 7.54797441364606
					5.52238740900686, 5.863539445629
					5.52238740900686, 6.33262260127932
*	  cmd - a generic signal to all clients
* 		Example: cmd:1 signals to all clients to start the game
*     err - generic error, message contained in content of packet
*		Example: err:There are too many games in progress. Please try again later
* 
*/
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <pthread.h>
#include <unistd.h>
#include <errno.h>
#include <arpa/inet.h>

#define MAX_CONNECTIONS 100
#define CLIENT_PORT 22000

#define MSG_SIZE 1024
#define HEADER_SIZE 3

#define MAX_PLAYERS 2 // max number of players per game

/*
* waiting: players have joined the game but there are not enough players to start playing
* started: game is started and in progress
* done: game has concluded
* errored: player has disconnected in the middle of the game, other unforeseen errors
*/
enum statustype { waiting, started, done, errored };
enum msgtype { id, mov, bad }; // types of messages received from client

struct GameGroup {
	int players[MAX_PLAYERS];
	int num_players;
	enum statustype status;
};

int max_sockfd = 0;
int sockfds[MAX_CONNECTIONS]; // list of connections
int num_connections = 0;
struct GameGroup* games[MAX_CONNECTIONS/MAX_PLAYERS];
unsigned int num_games = 0;

// file descriptors to be used
int listen_fd, comm_fd;

char* getHeader(char* data) {
	char* head;
	head = (char*) malloc(sizeof(char) * (HEADER_SIZE+1));
	strncpy(head, data, HEADER_SIZE+1);
	head[HEADER_SIZE] = '\0';
	return head;
}

enum msgtype getMsgType(char* header) {
	if (strcmp(header, "iam") == 0)
		return id;
	if (strcmp(header, "mov") == 0) 
		return mov;
	else
		return bad; // invalid header
}
	
struct GameGroup* makeGame(int fd) {
	struct GameGroup* gg = (struct GameGroup*) malloc(sizeof(struct GameGroup));
	gg->players[0] = fd;
	gg->num_players = 1;
	gg->status = waiting;
	return gg;
}

int beginGame(struct GameGroup* gg) {
	const char message[] = "cmd:1";
	for(int i = 0; i < gg->num_players; i++) {
		// TODO: send message to all players to start
		printf("Signalled begin game to fd: %d\n", gg->players[i]);
		send(gg->players[i], message, sizeof(message), 0);
	}
	gg->status = started;
	return 1; // success
}

int addPlayer(struct GameGroup* gg, int player_fd) {
	if (num_connections >= MAX_CONNECTIONS) {
		gg->status = started;
		return -1; // unsuccessful
	}
	int id = gg->num_players;
	gg->players[gg->num_players] = player_fd;
	gg->num_players++;
	return id;
}

struct GameGroup* findGameByfd(int fd) {
	for (int i = 0; i < num_games; i++) {
		for (int j = 0; j < games[i]->num_players; j++) {
			if (games[i]->players[j] == fd) {
				return games[i];
			}
		}
	}
	return 0;
}

// designation of player is the index of the player 
// in the list of players
int assignGame(int new_fd, struct GameGroup** gameref) {
	// find first waiting game
	for (int i = 0; i < num_games; i++) {
		if (games[i]->status == waiting) {
			*gameref = games[i];
			return addPlayer(games[i], new_fd);
		}
	}
	// make new game if no waiting games
	if (num_games < MAX_CONNECTIONS/MAX_PLAYERS) {
		printf("Making new game\n");
		games[num_games] = makeGame(new_fd);
		*gameref = games[num_games];
		num_games++;
		return 0; // designation of first player in game
	} else {
		// notify client too many games
		fprintf(stderr, "Overloaded with games. Rejecting clients\n");
		const char message[] = "err:There are too many games in progress. Please try again later\n";
		send(new_fd, message, sizeof(message), 0);
		return -1; // too many games going on
	}
}



const char* fdtoIP(int fd, char ip[], unsigned int ip_size, int* client_port) {
	struct sockaddr_in client_addr;
	socklen_t addr_size = sizeof(struct sockaddr_in);
	int result = getpeername(fd, (struct sockaddr*) &client_addr, &addr_size);
	if (result < 0) {
		fprintf(stderr, "Cannot translate fd %d to ip address. Reason: %s", fd, strerror(errno));
	}
	*client_port = (int) client_addr.sin_port;
	return inet_ntop(client_addr.sin_family, &client_addr.sin_addr, ip, ip_size);
}	

// removes fds in sockfds marked for removal (i.e. < 0)
int close_fds() {
    unsigned int skip = 0;
    unsigned int num_remain = 0;
    for (int i = 0; i < MAX_CONNECTIONS; i++) {
        if (sockfds[i] < 1) {
            skip = i;
            while(sockfds[skip] < 1 && skip < MAX_CONNECTIONS) {
			  sockfds[skip] = 0;
              skip++;
            }
            if (skip >= MAX_CONNECTIONS) {
              num_remain = i;
              break;
            }
            sockfds[i] = sockfds[skip];
            sockfds[skip] = 0;
        }
        num_remain = i;
    }
    return num_remain;
}

void* accept_connections(void* threadarg) {
	char client_IP[INET_ADDRSTRLEN];
	struct sockaddr_in client_addr;
	unsigned int sin_size = sizeof(client_addr);
	
	fprintf(stderr, "Accepting connections at port %d\n", CLIENT_PORT);

	while(1) {
		// accepts waiting connection request and writes info to client_addr
		int client_fd = accept(listen_fd, (struct sockaddr*) &client_addr, &sin_size);
		if(client_fd < 0) {
			fprintf(stderr, "Error making new connection to client");
		}

		// adds client to list of connections
		if (num_connections < MAX_CONNECTIONS) {
			sockfds[num_connections] = client_fd;
			num_connections++;
			if (client_fd > max_sockfd) {
				max_sockfd = client_fd;
			}
		} else {
			fprintf(stderr, "Too many connections; cannot connect to new client");
		}

		// converts hex representation of client's IP address to string
		// result in client_IP as string
		const char* inet_error = inet_ntop(client_addr.sin_family, &client_addr.sin_addr, client_IP, sizeof client_IP);
		if (inet_error == 0) {
			fprintf(stderr, "failed to convert address to string (errno=%s)\n",strerror(errno));
		}
		
		struct GameGroup* gg = 0;
		int id = assignGame(client_fd, &gg);
		char message[4+MAX_PLAYERS]; // should be log(MAX_PLAYERS) but that's too sucky for C to handle
		sprintf(message, "dsg:%d", id);
		send(client_fd, message, sizeof(message), 0);
		printf("Successfully created connection %d with fd %d, ip %s at port %d\n", num_connections,client_fd, client_IP, client_addr.sin_port);
		printf("Assigned desgination %d\n", id);
		if (gg == 0) {
			fprintf(stderr, "Bad game reference\n");
		}
		if (gg->num_players == MAX_PLAYERS) {
			beginGame(gg);
		}
	}
	return threadarg;
}
 
void* respond_client(void* threadarg) {
	char buffer[MSG_SIZE];
	struct timeval tv; 
	fd_set fd_flags;

	tv.tv_sec = 1;
	tv.tv_usec = 1000;

	while(1) {
		int rsp_fd = select(max_sockfd+1, &fd_flags, NULL, NULL, &tv);
		if (rsp_fd < 0) {
			fprintf(stderr, "Could not select connection. Reason: %s\n", strerror(errno));
			printf("max_sockfd: %d\n", max_sockfd);
		} 
		// if no one is saying anything, update the set of flags with the latest
		// active connections (I think)
		else if (rsp_fd == 0) {
			// clear fd_flags
			FD_ZERO(&fd_flags);
			// loop through all connections and add them to the fd_flags set
			for (int i = 0; i < num_connections; i++) {
				FD_SET(sockfds[i], &fd_flags);
			}
			continue;
		}
		// loop through all active connections and check if 
		// they have sent anything
		// If so, reply to them
		for (int i = 0; i < num_connections; i++) {
			if (FD_ISSET(sockfds[i], &fd_flags)) {
				int numbytes = recv(sockfds[i], buffer, MSG_SIZE, 0);
				if (numbytes < 0) {
					char client_IP[INET_ADDRSTRLEN];
					int client_port;
					fdtoIP(sockfds[i], client_IP, INET_ADDRSTRLEN, &client_port);
					fprintf(stderr, "Error receiving data from host %s at port %d\n", client_IP, client_port);
					exit(1);
				} else if (numbytes == 0) {
					char client_IP[INET_ADDRSTRLEN];
					int client_port;
					fdtoIP(sockfds[i], client_IP, INET_ADDRSTRLEN, &client_port);
					int close_result = close(sockfds[i]);
					if (close_result < 0) {
						fprintf(stderr, "Error closing connection. Reason: %s\n", strerror(errno));
					}
					FD_CLR(sockfds[i], &fd_flags);
					sockfds[i] = 0; // mark for deletion at end of iteration;
					fprintf(stderr, "0 bytes received from host %s at port %d. Closing connection\n", client_IP, client_port);
				} else {
					char* header = getHeader(buffer);
					enum msgtype type = getMsgType(header);
					enum msgtype m = mov;
					if (type == mov) {
						printf("mov message received\n");
						struct GameGroup* gg = findGameByfd(sockfds[i]);
						if (gg->status == started) {
							printf("talked player: %d\n", sockfds[i]);
							for (int j = 0; j < gg->num_players; j++) {
								printf("player fd: %d\n", gg->players[j]);
								if (gg->players[j] != sockfds[i]) {
									fprintf(stderr, "Player %d moved. Notifying all players of game\n", sockfds[i]);
									send(gg->players[j], buffer, numbytes, 0);
								}
							}
						}
					}
				}
			}
		}
		num_connections = close_fds();
	}
}

pthread_t ac_thread; // ac = accept_connection

void terminate_server() {
	printf("goodbye\n");
	close(CLIENT_PORT);
	pthread_kill(ac_thread, SIGALRM);
	exit(1);
}

int main()
{
	// Ctrl-C behavior
	struct sigaction sa;
    memset( &sa, 0, sizeof(sa) );
    sa.sa_handler = terminate_server;
    sigemptyset(&sa.sa_mask);
    sigaction(SIGINT,&sa,NULL);
	
	// tells server to "listen" for connections
	// creates a socket with AF_INET (IP addressing)
	// type SOCK_STREAM
	// data from all devices that want to connect to this socket
	// will be redirected to listen_fd
    listen_fd = socket(AF_INET, SOCK_STREAM, 0);
 	if (listen_fd < 0) {
		fprintf(stderr, "Error creating TCP socket (err: %s)\n", strerror(errno));
	} else { 
		fprintf(stderr, "created socket\n");
	}
 
 	// struct to hold IP address and port numbers
    struct sockaddr_in servaddr;
 
	// clear servaddr (Mandatory)
    bzero( &servaddr, sizeof(servaddr));
 
	// Set addressing scheme to AF_INET (IP)
	// Allow any IP to connect (INADDR_ANY)
	// Listen on port 22000
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htons(INADDR_ANY);
    servaddr.sin_port = htons(CLIENT_PORT);
 
	// prepare to listen for connections from the address and port
	// specified in the servaddr struct, which means every IP connecting
	// on port CLIENT_PORT
    int bind_result = bind(listen_fd, (struct sockaddr *) &servaddr, sizeof(servaddr));
	if (bind_result < 0) {
		fprintf(stderr, "Could not bind to TCP socket (errno=%s)\n", strerror(errno));
		exit(0);
	} else { 
		fprintf(stderr, "Successfully bound TCP socket\n");
	}
 
	// start listening for connections, and keep at most 10 connection requests
	// waiting. If there are more, then they fail to connect
    int listen_result = listen(listen_fd, 10);
	if (listen_result < 0) {
		fprintf(stderr, "Failed to listen to socket %d (err: %s)\n", CLIENT_PORT, strerror(errno));
		exit(1);
	} else { 
		fprintf(stderr, "Listening to port %d\n", CLIENT_PORT);
	}
 
	// accept_connections(NULL);
	// create thread to handle new connections
	int ac_fd;

	ac_fd = pthread_create(&ac_thread, NULL, accept_connections, (void*) &ac_fd);
	if (ac_fd) {
		fprintf(stderr, "Could not create thread to accept connections (err: %s)\n", strerror(errno));
		exit(-1);
	} else { 
		fprintf(stderr, "Created thread to accept connections\n");
	}

	respond_client(NULL);
	/*
	// create thread to handle messages sent by clients
	pthread_t resp_thread; 
	int resp_fd;
	resp_fd = pthread_create(&resp_thread, NULL, respond_client, (void*) &resp_fd);
	if (resp_fd) {
		fprintf(stderr, "Error: unable to create response thread (err: %s)\n", strerror(errno));
		exit(-1);
	}
	*/




}

