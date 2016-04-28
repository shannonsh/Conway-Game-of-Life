//
//  World.swift
//  Conway Game of Life
//
//  Created by Shannon on 4/28/16.
//  Copyright © 2016 Elena Ariza. All rights reserved.
//

import Foundation
import SpriteKit

class World: SKScene {
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
    init (width: Int, height: Int)
    {
        self.board = [[Cell]]()
        self.width = width;
        self.height = height;
        numP1Cells = 0;
        numP2Cells = 0;
        
        super.init(size: self.size)
        
        for x in 0...width - 1 {
            for y in 0...height - 1 {
                board[x][y] = Cell(x0: x, y0: y);
            }
        }
    }
    
    func drawBoard()
    {
        let greyBlock = SKSpriteNode(imageNamed: "grey block")

        for row in 0...height-1
        {
            for col in 0...width-1
            {
                if board[col][row].state == DEAD
                {
                    
                }
            }
        }
    }
}