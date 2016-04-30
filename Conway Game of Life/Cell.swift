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



struct Cell {
    // possible states of the cell
    
    var state: Int;
    var sprite: SKSpriteNode
    /*
    * x0: initial x location of cell
    * y0: initial y location of cell
    */
    init() {
        state = DEAD;
        sprite = SKSpriteNode(imageNamed: "grey block")
    }
    
    /* updated init that incorporates SKSpriteNode */
    
    /*
    * positionX: x location of cell on screen
    * positionY: y location of cell on screen
    * cellSize: width and height of (square) cell
    */
//    init(positionX: CGFloat, positionY: CGFloat, cellSize: CGFloat) {
//        state = DEAD;
//        sprite = SKSpriteNode(imageNamed: "grey block")
//        sprite.size = CGSize(width: cellSize, height: cellSize)
//        sprite.position = CGPointMake(positionX, positionY)
//        sprite.anchorPoint = CGPoint(x: 0, y: 1.0)
//    } 
 
 
}
