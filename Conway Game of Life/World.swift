//
//  World.swift
//  Conway Game of Life
//
//  Created by Shannon on 4/28/16.
//  Copyright © 2016 Elena Ariza. All rights reserved.
//

import Foundation

class World {
    var world: [[Cell]];
    
    let width: Int;
    let height: Int;
    
    var numP1Cells: Int;
    var numP2Cells: Int;
    
    /*
    * Creates an array of dead cells
    */
    init (width: Int, height: Int) {
        world = [[Cell]]();
        for x in 0...width - 1 {
            for y in 0...height - 1 {
                world[x][y] = Cell(x0: x, y0: y);
            }
        }
        
        self.width = width;
        self.height = height;
        
        numP1Cells = 0;
        numP2Cells = 0;
    }
    
}