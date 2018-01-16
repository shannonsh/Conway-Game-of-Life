CC = gcc
CFLAGS = -g -Wall

OBJS = server.out client.out

server: server.c 
	$(CC) $(CFLAGS) -o server.out server.c

client: client.c
	$(CC) $(CFLAGS) -o client.out client.c
