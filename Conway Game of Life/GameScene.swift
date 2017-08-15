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
    let upperSpace: CGFloat = 130
    let spaceBetwCells: CGFloat = 1.4
    var cellSize: CGFloat!
    
    var screenMidX: CGFloat!
    var screenMidY: CGFloat!
    
    let cellLayer = SKNode()
    let backgroundNode = SKSpriteNode(imageNamed: "background")
    let numP1Label = SKLabelNode()
    let numP2Label = SKLabelNode()
    var runButton = SKShapeNode()
    let runButtonText = SKLabelNode()
        
    var modeText = SKLabelNode()
    var isRunning: Bool = false
    
    let livesP1Label = SKLabelNode()
    let livesP2Label = SKLabelNode()
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize)
    {
        super.init(size: size)
        
        screenMidX = CGRectGetMidX(frame)
        screenMidY = CGRectGetMidY(frame)

        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        backgroundNode.position = CGPoint(x: 0, y: 0)
        backgroundNode.anchorPoint = CGPoint(x: 0.0, y: 1.0)
        addChild(backgroundNode)
    
        runButton = SKShapeNode(path: CGPathCreateWithRoundedRect(
            CGRectMake(screenMidX, -screenMidY,100,40), 8, 8, nil), centered: true)
    }
    
    
    
    override func didMoveToView(view: SKView)
    {
        /* Setup your scene here */
        
        let numRows = 16
        let numCols = 12
        
        addSpritesForCells(numRows, numCols: numCols)
        addTopGraphics()
        addBottomText()
        
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
        numP1Label.position = CGPointMake(screenMidX - 70, -upperSpace*2/3)
        numP1Label.fontColor = SKColor.redColor()
        numP1Label.fontSize = 50
        numP1Label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        numP1Label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        
        numP2Label.text = "0"
        numP2Label.position = CGPointMake(screenMidX + 70, -upperSpace*2/3)
        numP2Label.fontColor = SKColor.blueColor()
        numP2Label.fontSize = 50
        numP2Label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        numP2Label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        
        runButton.fillColor = SKColor.init(hue: 0, saturation: 0, brightness: 0.88, alpha: 1)
        runButton.position = CGPoint(x: screenMidX, y: -upperSpace*2/3)
        
        // feel free to edit my lame graphics and make it awesome. I'm bad with colors.
        runButtonText.text = "Switch"
        runButtonText.fontColor = SKColor.blackColor()
        runButtonText.fontSize = 25
        runButtonText.position = CGPoint(x: 0, y: 0)
        runButtonText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        runButtonText.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        
        modeText.text = "Player 1"
        modeText.fontColor = SKColor.redColor()
        modeText.fontSize = 40
        modeText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        modeText.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        modeText.position = CGPoint(x: screenMidX, y: -upperSpace/3)
        
        runButton.addChild(runButtonText)
        
        addChild(numP1Label)
        addChild(numP2Label)
        addChild(runButton)
        addChild(modeText)
    }
    
    func addBottomText()
    {
        livesP1Label.text = String(world.numP1Lives) + " cells left"
        livesP1Label.position = CGPointMake(margin,
            -upperSpace + gridCoord[world.height - 1][0].y - margin)
        livesP1Label.fontColor = SKColor.redColor()
        livesP1Label.fontSize = 30
        livesP1Label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        livesP1Label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        
        livesP2Label.text = String(world.numP1Lives) + " cells left"
        livesP2Label.position = CGPointMake(frame.maxX - margin,
            -upperSpace + gridCoord[world.height - 1][0].y - margin)
        livesP2Label.fontColor = SKColor.blueColor()
        livesP2Label.fontSize = 30
        livesP2Label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        livesP2Label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        
        addChild(livesP1Label)
        addChild(livesP2Label)
    }
    
    func updateText()
    {
        numP1Label.text = String(world.numP1Cells)
        numP2Label.text = String(world.numP2Cells)
        
        livesP1Label.text = String(world.numP1Lives) + " cells left"
        livesP2Label.text = String(world.numP2Lives) + " cells left"
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {

            let location = touch.locationInNode(self)
            let gridX = (location.x - margin) / (cellSize + spaceBetwCells)
            let gridY = (abs(location.y) - upperSpace) / (cellSize + spaceBetwCells)
            
            
            
//            // Starts running game of life when runButton tapped
//            // iffy stuff starts happening when try to add cells 
//            // while running, so need to disable adding cells while running
//            if(runButton.containsPoint(location)) {
//                if(isRunning == false) {
//                    isRunning = true
////                    [UIView animateWithDuration(1.0, animations:^{
////                        runButton.fillColor = SKColor.init(hue: 0.33, saturation: 0.25, brightness: 0.9, alpha: 1)
////                        }];
////                    runButton.runAction(runButtonAnimation)
////                    runButton.fillColor = SKColor.init(hue: 0.33, saturation: 0.25, brightness: 0.9, alpha: 1) // green
////                    runButtonText.text = "Pause"
////                }
////                else {
////                    isRunning = false
////                    runButton.runAction(runButtonAnimation.reversedAction())
////                    runButton.fillColor = SKColor.init(hue: 0, saturation: 0, brightness: 0.88, alpha: 1) // grey
////                    runButtonText.text = "Run"
//                    
//                    
//                    
//                    
//                    
//                    
//                    // ARGH Animations why you no work!!! XP
//                    UIView.animateWithDuration(3.0, animations:{
//                        self.runButton.fillColor = SKColor.init(hue: 0.33, saturation: 0.25, brightness: 0.9, alpha: 1)
//                    })
//                }
//                else {
//                    isRunning = false
//                    runButton.fillColor = SKColor.init(hue: 0, saturation: 0, brightness: 0.88, alpha: 1)
//                }
//            }
            

            
            if runButton.containsPoint(location) {
                if world.mode == 1 {
                    // PLAYER 1'S TURN > PLAYER 2'S TURN
                    world.mode += 1
                    world.nextGeneration()
                    world.numP1Lives += 3
                    
                    modeText.text = "Player 2"
                    modeText.fontColor = SKColor.blueColor()
                    
                }
                else if world.mode == 2 {
                    // PLAYER 2'S TURN > PLAYER 1'S TURN
                    world.mode -= 1
                    world.nextGeneration()
                    world.numP2Lives += 3
                    
                    modeText.text = "Player 1"
                    modeText.fontColor = SKColor.redColor()

                }
                
                if (world.numP1Cells == 0 && world.currentGeneration > 0)
                    || (world.numP2Cells == 0 && world.currentGeneration > 1) {
                    
                    displayGameOverScreen()
                }
                
                
            }
            else {
                world.gridTouched(gridX, gridY: gridY, player: world.mode)
            }
            
            
            
//            if !isRunning
//            {
//                world.gridTouched(gridX, gridY: gridY)
//            }
//            else {
//                world.nextGeneration()
//            }

            
            
            

            updateText()

        }

    }
    
    func displayGameOverScreen()
    {
        removeAllChildren()
        addChild(backgroundNode)
        let gameOverLabel = SKLabelNode(text: "GAME OVER!")
        gameOverLabel.fontColor = SKColor.blackColor()
        gameOverLabel.fontSize = 50
        gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        gameOverLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        gameOverLabel.position = CGPoint(x: screenMidX, y: -screenMidY + 50)

        
        let winner = SKLabelNode()
        if world.numP1Cells == 0 {
            winner.text = "PLAYER 2 WINS!"
            winner.fontColor = SKColor.blueColor()
        }
        else if world.numP2Cells == 0 {
            winner.text = "PLAYER 1 WINS!"
            winner.fontColor = SKColor.redColor()
        }
        
        winner.fontSize = 50
        winner.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        winner.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        winner.position = CGPoint(x: screenMidX, y: -screenMidY)

        addChild(gameOverLabel)
        addChild(winner)
        
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
        
        // -> AKA DON'T PUT ANYTHING IN HERE! :P
    }
}
