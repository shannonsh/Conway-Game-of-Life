# Two player Conway's Game of Life iPhone app
A 2-player iPhone game based on [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life). Now with online play support! Still an unfinished product, bugs and unimplemented features guaranteed. 

[Demo of Online mode](https://youtu.be/tTqzkoVzniI)

# How to play
Each player is assigned a color and take turns placing cells of their color on the board. 

At the start, each player is given 5 cells to place, and for each turn thereafter they are given 3 more cells to place. The players do not need to place all their cells, and all unused cells will remain available for the player to use in future turns.

Every time the players switch turns, a generation passes, where all the cells present on the board behave according to the following rules:
1. Any live cell with fewer than two live neighbours dies, as if caused by underpopulation.
2. Any live cell with two or three live neighbours lives on to the next generation.
3. Any live cell with more than three live neighbours dies, as if by overpopulation.
4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
    * the live cell takes on the color of the majority of its neighbors

The objective of the game is to make all the other players' cells die out. 

### Restarting the game
Game restart functionality has not been implemented. To restart, simply quit the app and relaunch
  
# How to Run
- Clone or download this repo
- Choose one of the modes below (Online or Pass and Play mode) 

## Online mode (two players on two separate iPhones)
### Run the server
- in the repo directory, run `make server`
- run `./server.out`

### Run the iOS app on two simulators
- Open `Conway Game of Life.xcodeproj`
- Choose one of the methods below depending on your XCode version

#### Method 1 (XCode 9 or later)
- Build and run the app on two different iOS 9.3 or 10.0 iPhone 6 simulators, or any two iPhones (5 or later) of the same screen size

#### Method 2 (XCode 8 or earlier)
- In `Conway Game of Life/NetworkComm.swift`, change the IP in the line
  * `CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "127.0.0.1" as CFString, 22000,     &readStream, &writeStream)`
  * to 
  * `CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "YOUR_COMPUTER_IP_HERE" as CFString, 22000,     &readStream, &writeStream)`
- Build and run the app on a a physical iPhone running iOS 9.3 or 10.0
- Build and run the app on an iPhone simulator. Make sure to choose a model that has the same screen size as the physical iPhone

## Pass and Play mode (two players sharing one iPhone)
- In `Conway Game of Life/GameScene.swift`, change the line
  * `let passNplay = false; // change game mode here`
  * to 
  * `let passNplay = true; // change game mode here`
- Then run the game on an iPhone (simulator or physical) running iOS 9.3 or 10.0

# Compatibility
- This app has been tested on iOS 9.3 and 10.0. It is not guaranteed to work on any other iOS version. 
- The graphics were formatted to look best on an iPhone 6 screen. 
