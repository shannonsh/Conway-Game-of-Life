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
        
        board = Array(count: width, repeatedValue: Array(count: height, repeatedValue: Cell(xIn: 0, yIn: 0)));

    }
    
    /*
    * For debugging purposes only: prints out entire board in ascii
    * _ = dead cell, 1 = player 1 cell, 2 = player 2 cell
    */
    func printBoard() {
        for row in 0...width-1 {
            
            var rowText = ""
            for col in 0...height-1{
                let theCell = board[row][col]
                
                if(theCell.state == DEAD) {
                    rowText += "_"
                }
                else if(theCell.state == P1) {
                    rowText += "1"
                }
                else if(theCell.state == P2) {
                    rowText += "2"
                }
            }
            print(rowText)
        }
        print("********************")
    }
    
    
    //optimization for later: "A cell that did not change at the last time step, and none of whose neighbours changed, is guaranteed not to change at the current time step as well. So, a program that keeps track of which areas are active can save time by not updating the inactive zones." (from Wikipedia) -> Cell needs a last updated variable (units, turns/generations?)
    /*
    * Determines the state of each cell on the board for the next generation
    */
    func nextGeneration() {
        for row in 0...width-1 {
            for col in 0...height-1 {
                var theCell: Cell = board[row][col]
                let neighbors = countNeighbors(row, y: col)
                let totalNeighbors = neighbors.0 + neighbors.1
                
                if(theCell.state > 0) {         // conditions for death of live cell
                    if(totalNeighbors < 2 ||    // if less than 2 or more than 3 neighbors, cell dies
                        totalNeighbors > 3)
                    {
                        theCell.updateState(DEAD)
                    }
                }
                else {
                    if(totalNeighbors == 3) {   // conditions of revival for dead cell
                        if(neighbors.0 > neighbors.1) { // if exactly 3 neighbors, cell revives
                            theCell.updateState(P1)
                        }
                        else {
                            theCell.updateState(P2)
                        }
                    }
                }
            }
        }
    }
    
    /*
    * Changes the state of the cell at the specified location
    */
    func changeState(row: Int, col: Int, newState: Int) {
        board[row][col].updateState(newState)
        
    }
    
    func gridTouched(gridX: CGFloat, gridY: CGFloat)
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
            
            if (state == P1) {
                board[row][col].updateState(P2)
                numP2Cells += 1
                numP1Cells -= 1
            }
            else if state == DEAD {
                board[row][col].updateState(P1)
                numP1Cells += 1
            }
            else if state == P2 {
                board[row][col].updateState(DEAD)
                numP2Cells -= 1
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
        
        for row in x-1..<x+1 {
            for col in y-1..<y+1 {
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