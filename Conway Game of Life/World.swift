//
//  World.swift
//  Conway Game of Life
//
//  Created by Shannon on 4/28/16.
//  Copyright © 2016 Elena Ariza and Shannon Shih. All rights reserved.
//

import SpriteKit

class World {
    var board: [[Cell]];
 
    let width: Int;
    let height: Int;
 
    var numP1Cells: Int;
    var numP2Cells: Int;
 
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
 
    /*
    * Creates an array of dead cells
    */
    init (widthIn: Int, heightIn: Int)
    {
        board = [[Cell]]()
        width = widthIn;
        height = heightIn;
        numP1Cells = 0;
        numP2Cells = 0;
        

        board = Array(count: height, repeatedValue: Array(count: width, repeatedValue: Cell()));
//        for x in 0...width - 1 {
//            board.append(arr);
//            for y in 0...height - 1 {
//                
//            }
//        }
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
    
    /* 
    * Counts number of cells owned by player 1 and 2 that are neighboring
    * a certain cell and returns result as a tuple
    * x: x coordinate of the cell
    * y: y coordinate of the cell
    */
    func countNeighbors(x: Int, y: Int) -> (Int, Int) {
        var count = (0,0);
        
        if(board[x+1][y].state == 1) {count.0 += 1} // check upper right cell
        else if(board[x+1][y].state == 2) {count.1 += 1}
        
        if(board[x+1][y].state == 1) {count.0 += 1} // check right cell
        else if(board[x+1][y].state == 2) {count.1 += 1}
        
        if(board[x+1][y-1].state == 1) {count.0 += 1} // check lower right cell
        else if(board[x+1][y-1].state == 2) {count.1 += 1}
        
        if(board[x][y-1].state == 1) {count.0 += 1} // check bottom cell
        else if(board[x][y-1].state == 2) {count.1 += 1}
        
        if(board[x-1][y+1].state == 1) {count.0 += 1} // check lower left cell
        else if(board[x-1][y+1].state == 2) {count.1 += 1}
        
        if(board[x-1][y].state == 1) {count.0 += 1} // check left cell
        else if(board[x-1][y].state == 2) {count.1 += 1}
        
        if(board[x-1][y-1].state == 1) {count.0 += 1} // check upper left cell
        else if(board[x-1][y-1].state == 2) {count.1 += 1}
        
        if(board[x][y-1].state == 1) {count.0 += 1} // check bottom cell
        else if(board[x][y-1].state == 2) {count.1 += 1}
        
        print(count)
        
        return count
    }
}