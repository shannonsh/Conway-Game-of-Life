//
//  World.swift
//  Conway Game of Life
//
//  Created by Shannon on 4/28/16.
//  Copyright © 2016 Elena Ariza. All rights reserved.
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
    
    func nextGeneration() {
        for row in 0...width-1 {
            for col in 0...height-1 {
                var theCell: Cell = board[row][col]
                var neighbors = countNeighbors(row, y: col)
                
                if(neighbors.0 + neighbors.1 < 2) {
                    
                }
            }
        }
    }
    
    func changeState(locationX: Int, locationY: Int, newState: Int) {
        board[locationX][locationY].state = newState
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