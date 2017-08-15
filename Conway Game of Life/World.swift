//
//  World.swift
//  Conway Game of Life
//
//  Created by Shannon on 4/28/16.
//  Copyright © 2016 Elena Ariza and Shannon Shih. All rights reserved.
//

import SpriteKit

class World {
    var board: [[Cell]]
 
    let width: Int
    let height: Int
 
    var numP1Cells: Int
    var numP2Cells: Int
    
    var numP1Lives: Int
    var numP2Lives: Int
    
    var mode: Int = 1
    var currentGeneration: Int = 0
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
 
    /*
    * Creates an array of dead cells
    */
    init (widthIn: Int, heightIn: Int)
    {
        width = widthIn;
        height = heightIn;
        numP1Cells = 0;
        numP2Cells = 0;
        numP1Lives = 5;
        numP2Lives = 5;
        
        board = Array(count: width, repeatedValue: Array(count: height, repeatedValue: Cell(xIn: 0, yIn: 0)));
    }
    
    //optimization for later: "A cell that did not change at the last time step, and none of whose neighbours changed, is guaranteed not to change at the current time step as well. So, a program that keeps track of which areas are active can save time by not updating the inactive zones." (from Wikipedia) -> Cell needs a last updated variable (units, turns/generations?)
    /*
    * updates the board for the next generation
    * Conway's Game of Life logic implemented here
    */
    func nextGeneration() {
        var newBoard = board

        for row in 0...width-1 {
            for col in 0...height-1 {

                let neighbors = countNeighbors(row, y: col) // counts neighbors in board (NOT newBoard)
                let totalNeighbors = neighbors.0 + neighbors.1
                
                if (board[row][col].state > 0) {         // conditions for death of live cell
                    if(totalNeighbors < 2 ||    // if less than 2 or more than 3 neighbors, cell dies
                        totalNeighbors > 3)
                    {
                        newBoard[row][col].updateState(DEAD)
                        if(board[row][col].state == 1) {numP1Cells -= 1}
                        if(board[row][col].state == 2) {numP2Cells -= 1}
                    }
                    else if totalNeighbors == 2 || totalNeighbors == 3
                    {
                        let currentState = board[row][col].state
                        newBoard[row][col].updateState(currentState)
                    }
                }
                else {
                    if(totalNeighbors == 3) {   // conditions of revival for dead cell
                        if(neighbors.0 > neighbors.1) { // if exactly 3 neighbors, cell revives
                            newBoard[row][col].updateState(P1)
                            numP1Cells += 1
                        }
                        else {
                            newBoard[row][col].updateState(P2)
                            numP2Cells += 1
                        }
                    }
                }
            }
        }
        currentGeneration += 1
        board = newBoard
    }
    
    func gridTouched(gridX: CGFloat, gridY: CGFloat, player: Int)
    {
        var col = 0
        var row = 0
        
        if gridX < 0 {
            col = -1
        }
        else {
            col = Int(gridX)
        }
        
        if gridY < 0 {
            row = -1
        }
        else {
            row = Int(gridY)
        }
        
        if (col >= 0 && row >= 0 &&
            col < board[0].count && row < board.count)
        {
            let state = board[row][col].state
            
            if player == P1 {
                if (state == P1) {
                    board[row][col].updateState(DEAD)
                    numP1Cells -= 1
                    numP1Lives += 1
                }
                else if state == DEAD && numP1Lives > 0 {
                    if(numP1Lives > 0) {
                        board[row][col].updateState(P1)
                        numP1Cells += 1
                        numP1Lives -= 1
                    }
                    else if(numP1Lives == 0) {
                        board[row][col].updateState(P1)
                        numP1Cells += 1
                    }
                }
            }
            else if player == P2 {
                if state == P2 {
                    board[row][col].updateState(DEAD)
                    numP2Cells -= 1
                    numP2Lives += 1
                }
                else if state == DEAD && numP2Lives > 0 {
                    if(numP2Lives > 0) {
                        board[row][col].updateState(P2)
                        numP2Cells += 1
                        numP2Lives -= 1
                    }
                    else if(numP2Lives == 0) {
                        board[row][col].updateState(P2)
                        numP2Cells += 1
                    }
                }

            }
        }
    }
    
    /*
    * Counts number of cells owned by player 1 and 2 that are neighboring
    * a certain cell and returns result as a tuple
    * x: x coordinate of the cell
    * y: y coordinate of the cell
    */
    func countNeighbors(x: Int, y: Int) -> (Int, Int) {
        var count = (0,0);
        
        // subtract center cell from total count
        if(board[x][y].state == 1) {count.0 -= 1}
        else if(board[x][y].state == 2) {count.1 -= 1}
        
        
        for row in x-1...x+1 {
            for col in y-1...y+1 {
                if(row >= 0 && row < board.count && col >= 0 && col < board[0].count) {
                    let neighborCellState = board[row][col].state
                    if(neighborCellState == 1) {count.0 += 1}
                    else if(neighborCellState == 2) {count.1 += 1}
                }
            }
        }
        
        return count
    }
}
