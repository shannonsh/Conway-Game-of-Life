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
    
    func changeState(locationX: Int, locationY: Int, newState: Int) {
        board[locationX][locationY].state = newState
    }
    
    /* 
    * Counts number of cells owned by player 1 and 2 and returns result as a tuple
    */
    func countNeighbors(x: Int, y: Int) {
        
//        var count = (0,0);
//        if(board[x-1][y-1] != 0) { // check upper left cell
//            // if cell state is 1, increase P1's count, else increase P2's count
////            board[x-1][y-1] == 1 ? count.0 + 1 : count.1 + 1
//            
//        }
////        if(board[x-1][y] != 0) { // check left cell
////            count = board[x-1][y] == 1 ? count.0 + 1 : count.1 + 1
////        }
////        if(board[x-1][y+1] != 0) { // check lower left cell
////            count = board[x-1][y+1] == 1 ? count.0 + 1 : count.1 + 1
////        }
////        if(board[x+1][y-1] != 0) { // check upper right cell
////            count = board[x-1][y+1] == 1 ? count.0 + 1 : count.1 + 1
////        }
//        print(count)

    }
}