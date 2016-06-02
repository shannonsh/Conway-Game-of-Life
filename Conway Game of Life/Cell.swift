//
//  Cell.swift
//  Conway Game of Life
//
//  Created by Shannon on 4/28/16.
//  Copyright © 2016 Elena Ariza and Shannon Shih. All rights reserved.
//

import SpriteKit

let DEAD = 0;
let P1 = 1; // cell is owned by player 1
let P2 = 2; // cell is owned by player 2

struct Cell {
    // possible states of the cell
    
    var xCoord: CGFloat;
    var yCoord: CGFloat;
    var state: Int;
    var sprite: SKSpriteNode
    /*
    * x0: initial x location of cell
    * y0: initial y location of cell
    */
    init(xIn: CGFloat, yIn: CGFloat) {
        xCoord = xIn;
        yCoord = yIn;
        state = DEAD;
        sprite = SKSpriteNode(imageNamed: "dead") // dead by default
    }
    
    /* updated init that incorporates SKSpriteNode */
    /*
    * positionX: x location of cell on screen
    * positionY: y location of cell on screen
    * cellSize: width and height of (square) cell
    */
//    init(row: CGFloat, col: CGFloat, cellSize: CGFloat) {
//        state = DEAD;
//        sprite = SKSpriteNode(imageNamed: "dead")
//        sprite.size = CGSize(width: cellSize, height: cellSize)
//        sprite.position = CGPointMake(row, col)
//        sprite.anchorPoint = CGPoint(x: 0, y: 1.0)
//    } 
    
    
    mutating func updateState(newState: Int) {
        state = newState;
        if (state == 0) {
            sprite.texture = SKTexture(imageNamed: "dead")
        }
        else if (state == 1) {
            sprite.texture = SKTexture(imageNamed: "player 1")
        }
        else if (state == 2) {
            sprite.texture = SKTexture(imageNamed: "player 2")
        }
        else {
//            print("ERROR: invalid state for Cell.swift > updateState() function")
        }
    }
 
}
