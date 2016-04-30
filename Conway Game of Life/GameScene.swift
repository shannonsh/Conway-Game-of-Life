//
//  GameScene.swift
//  Conway Game of Life
//
//  Created by Elena Ariza on 3/11/16.
//  Copyright (c) 2016 Elena Ariza. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var world: World = World(widthIn: 0, heightIn: 0)
    var gridCoord = [[CGPointMake(0,0)]]
    var gridNodes = [[SKSpriteNode()]]
    
    let margin: CGFloat = 20
    let upperSpace: CGFloat = 100
    let spaceBetwCells: CGFloat = 1.4
    var cellSize: CGFloat = 0
    
    let greyBlock = SKSpriteNode(imageNamed: "grey block")
    let redBlock = SKSpriteNode(imageNamed: "red block")
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize)
    {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        addChild(background)
    }
    
    override func didMoveToView(view: SKView) {
//        /* Setup your scene here */
        
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!";
//        myLabel.fontSize = 65;
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
//        
//        self.addChild(myLabel)
//        var world: World(numRows, numCols)
        
        // initialize the 2d array of tiles
        
        
        let numRows = 15
        let numCols = 10
        world = World(widthIn: numCols, heightIn: numRows)
        gridCoord = Array(count: numRows, repeatedValue: Array(count: numCols, repeatedValue: CGPointMake(0,0)))
        gridNodes = Array(count: numRows, repeatedValue: Array(count: numCols, repeatedValue: greyBlock))
        
        
        for row in 0...numRows-1 {
            for col in 0...numCols-1 {
                
                let leftCornerCell = margin + CGFloat(col) * (cellSize + spaceBetwCells)
                let upperCornerCell = upperSpace + CGFloat(row) * (cellSize + spaceBetwCells)
                gridCoord[row][col] = CGPointMake(leftCornerCell, -upperCornerCell)
                
                var cell = SKSpriteNode()
                if world.board[row][col].state == DEAD {
                    cell = SKSpriteNode(imageNamed: "dead")
                }
                else if world.board[row][col].state == P1 {
                    cell = SKSpriteNode(imageNamed: "player 1")
                }
                cell.size = CGSize(width: cellSize, height: cellSize)
                cell.position = CGPointMake(leftCornerCell, -upperCornerCell)
                cell.anchorPoint = CGPoint(x: 0, y: 1.0)
        
                gridNodes[row][col] = cell
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        print("size: \(touches.count)")
        var col = 0
        var row = 0
        for touch in touches {

            print("touched")
            let location = touch.locationInNode(self)
            
//            while currentRow < gridCoord.count &&
//                gridCoord[currentRow][0].y > location.y
//            {
//                currentRow += 1
//            }
            print("location.x: \(location.x)")
            if (location.x - margin) / (cellSize + spaceBetwCells) < 0
            {
                col = -1
            }
            else {
                col = Int((location.x - margin) / (cellSize + spaceBetwCells))
            }
            
            if (abs(location.y) - upperSpace) / (cellSize + spaceBetwCells) < 0
            {
                row = -1
            }
            else {
                row = Int((abs(location.y) - upperSpace) / (cellSize + spaceBetwCells))
            }
            
            print("col: \(col)")
//            currentRow -= 1
//
//            currentCol = 0
//            print("location x: \(location.x)")
//            while currentCol < gridCoord[0].count &&
//                gridCoord[0][currentCol].x < location.x
//            {
//                currentCol += 1
//            }
//            currentCol -= 1
            

//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
            
        }
        
        if (col >= 0 && row >= 0 &&
            col < world.board[0].count && row < world.board.count)
        {
            
            world.board[row][col].state = P1
//            gridNodes[row][col].removeFromParent()

            gridNodes[row][col] = redBlock
            if(world.board[row][col].state == P1) {
                world.board[row][col].state = DEAD
            }
            else {
                world.board[row][col].state = P1
            }
            
        }
        
    }
    
    
   
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
        let numRows = world.height
        let numCols = world.width
        
        let bounds = UIScreen.mainScreen().bounds
        let widthScreen = bounds.size.width
        
        let gridWidth: CGFloat = widthScreen - margin*2
        cellSize = (gridWidth - CGFloat(numCols-1)*spaceBetwCells) * 1.0 / CGFloat(numCols)
        
        
        for row in 0...numRows-1 {
            for col in 0...numCols-1 {
                
                let cell = gridNodes[row][col]
                
//                let leftCornerCell = margin + CGFloat(col) * (cellSize + spaceBetwCells)
//                let upperCornerCell = upperSpace + CGFloat(row) * (cellSize + spaceBetwCells)
//                gridCoord[row][col] = CGPointMake(leftCornerCell, -upperCornerCell)
//                
//                var cell = SKSpriteNode()
//                if world.board[row][col].state == DEAD {
//                    cell = SKSpriteNode(imageNamed: "grey block")
//                }
//                else if world.board[row][col].state == P1 {
//                    cell = SKSpriteNode(imageNamed: "red block")
//                }
//                cell.size = CGSize(width: cellSize, height: cellSize)
//                cell.position = CGPointMake(leftCornerCell, -upperCornerCell)
//                cell.anchorPoint = CGPoint(x: 0, y: 1.0)
                
                if cell.parent != nil {
                    cell.removeFromParent()
                }
                
                addChild(cell)
                
            }
        }
    }
}
