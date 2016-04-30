//
//  Cell.swift
//  Conway Game of Life
//
//  Created by Shannon on 4/28/16.
//  Copyright © 2016 Elena Ariza. All rights reserved.
//

import SpriteKit

let DEAD = 0;
let P1 = 1; // cell is owned by player 1
let P2 = 2; // cell is owned by player 2

var sprite: SKSpriteNode?

struct Cell {
    // possible states of the cell
    
    var state: Int;
    
    /*
    * x0: initial x location of cell
    * y0: initial y location of cell
    */
    init() {
        state = DEAD;
    }
    
}
