//
//  GameScene.swift
//  Conway Game of Life
//
//  Created by Elena Ariza on 3/11/16.
//  Copyright (c) 2016 Elena Ariza and Shannon Shih. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var world: World!
    var gridCoord = [[CGPointMake(0,0)]]
    
    let margin: CGFloat = 20
    let upperSpace: CGFloat = 150
    let spaceBetwCells: CGFloat = 1.4
    var cellSize: CGFloat = 0
    
    let cellLayer = SKNode()
    let numP1Label = SKLabelNode()
    let numP2Label = SKLabelNode()

    var isRunning: Bool = false
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize)
    {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0.0, y: 1.0)
        addChild(background)
    }
    
    
    override func didMoveToView(view: SKView)
    {
        /* Setup your scene here */
        
        let numRows = 14
        let numCols = 10
        
        addSpritesForCells(numRows, numCols: numCols)
        addTopGraphics()
        
        addChild(cellLayer)
    }
    
    func addSpritesForCells(numRows: Int, numCols: Int)
    {
        world = World(widthIn: numRows, heightIn: numCols)
        gridCoord = Array(count: numRows, repeatedValue: Array(count: numCols, repeatedValue: CGPointMake(0,0)))
        
        let bounds = UIScreen.mainScreen().bounds
        let widthScreen = bounds.size.width
        
        let gridWidth: CGFloat = widthScreen - margin*2
        cellSize = (gridWidth - CGFloat(numCols-1)*spaceBetwCells) * 1.0 / CGFloat(numCols)
        
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
                else if world.board[row][col].state == P2 {
                    cell = SKSpriteNode(imageNamed: "player 2")
                }
                cell.size = CGSize(width: cellSize, height: cellSize)
                cell.position = CGPointMake(leftCornerCell, -upperCornerCell)
                cell.anchorPoint = CGPoint(x: 0, y: 1.0)
                
                world.board[row][col].sprite = cell
                world.board[row][col].xCoord = leftCornerCell
                world.board[row][col].yCoord = upperCornerCell
                
                cellLayer.addChild(cell)
            }
        }
    }
    
    func addTopGraphics()
    {
        numP1Label.text = "0"
        numP1Label.position = CGPointMake(CGRectGetMidX(frame) - 50, -upperSpace/2)
        numP1Label.fontColor = SKColor.redColor()
        numP1Label.fontSize = 50
        numP1Label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        numP1Label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        
        numP2Label.text = "0"
        numP2Label.position = CGPointMake(CGRectGetMidX(frame) + 50, -upperSpace/2)
        numP2Label.fontColor = SKColor.blueColor()
        numP2Label.fontSize = 50
        numP2Label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        numP2Label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        
        addChild(numP1Label)
        addChild(numP2Label)
    }
    
    func updateTopGraphics()
    {
        numP1Label.text = String(world.numP1Cells)
        numP2Label.text = String(world.numP2Cells)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {

            let location = touch.locationInNode(self)
            let gridX = (location.x - margin) / (cellSize + spaceBetwCells)
            let gridY = (abs(location.y) - upperSpace) / (cellSize + spaceBetwCells)
            
            world.gridTouched(gridX, gridY: gridY)
            updateTopGraphics()
            world.printBoard()
            
            if(isRunning) {
                world.nextGeneration()
            }
        }

    }
    
    
   
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
        // –> AKA DON'T PUT ANYTHING IN HERE! :P
    }
}
