//
//  World.swift
//  Conway Game of Life
//
//  Created by Shannon on 4/28/16.
//  Copyright © 2016 Elena Ariza. All rights reserved.
//

import Foundation
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
        
        var arr: [Cell];

        board = Array(count: height, repeatedValue: Array(count: width, repeatedValue: Cell()));
//        for x in 0...width - 1 {
//            board.append(arr);
//            for y in 0...height - 1 {
//                
//            }
//        }
    }
}