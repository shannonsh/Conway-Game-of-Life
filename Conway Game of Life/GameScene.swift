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
    var gridCoord = [[CGPoint(x: 0,y: 0)]]
    
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
    
    var theView = SKView();
    let activityInd = UIActivityIndicatorView()
    var myDsg = -1;
    let passNplay = false;
    let netComm = NetworkComm()
    var currentMoves = [String]()
    let moveDelimiter = "\n"
    
    let statusView = UIView()
    var statusText: UILabel? = nil;
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize)
    {
        super.init(size: size)
        
        screenMidX = frame.midX
        screenMidY = frame.midY

        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        backgroundNode.position = CGPoint(x: 0, y: 0)
        backgroundNode.anchorPoint = CGPoint(x: 0.0, y: 1.0)
        addChild(backgroundNode)
    
        runButton = SKShapeNode(path: CGPath(
            roundedRect: CGRect(x: screenMidX, y: -screenMidY,width: 100,height: 40), cornerWidth: 8, cornerHeight: 8, transform: nil), centered: true)
    }
    
    func createStatus(status: String, viewDim: CGRect) {
        
        //            var viewRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 100, height: 100)
        statusView.backgroundColor = UIColor.init(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
        statusView.layer.cornerRadius = 5
        statusView.frame.size.height = 50
        statusView.frame.size.width = 200
        statusView.isOpaque = false
        statusView.center = CGPoint(x: viewDim.width/2, y: viewDim.height/2)
        
        let padding = statusView.frame.width * CGFloat(0.1)
        activityInd.center = CGPoint(x: padding, y: statusView.frame.height/2)
        activityInd.color = UIColor.black
        activityInd.hidesWhenStopped = true
        activityInd.startAnimating()
        statusView.addSubview(activityInd)
        scene!.view?.addSubview(statusView)
        
        statusText = UILabel(frame: CGRect(x: 0, y: 0, width: statusView.frame.width, height: statusView.frame.height))
        statusText?.center = CGPoint(x: (statusText?.frame.width)!/2 + padding, y: statusView.frame.height/2)
        statusText?.textAlignment = .center
        statusText?.text = "Finding opponent"
        statusView.addSubview(statusText!)
    }
    func showStatus(message: String) {
        statusText?.text = message
        activityInd.startAnimating()
        statusView.isHidden = false
    }
    func hideStatus() {
        activityInd.stopAnimating() // hide activity indicator
        statusView.isHidden = true
    }
    
    override func didMove(to view: SKView)
    {
        /* Setup your scene here */
        theView = view
        let numRows = 16
        let numCols = 12
        
        /* If playing online, issues join request to server (server response handled elsewhere) */
        if (!passNplay) {
            // display activity indicator while waiting for designation assignment from server
            createStatus(status: "Finding opponent", viewDim: view.frame)
            
            netComm.delegate = self
            netComm.setupNetworkCommunication()
            netComm.joinChat(username: "placeholder")
        }
        
        addSpritesForCells(numRows, numCols: numCols)
        addTopGraphics()
        addBottomText()
        
        addChild(cellLayer)
    }
    
    func handleMessage(message: Message) {
        print("message received: \(message.message)")
        switch message.header {
        case "dsg":  // dsg = designation
            // server designation is 0-indexed; locally it's 1-indexed. Sorry; will fix when have time
            print("received num: \((message.message as NSString).integerValue)")
            myDsg = (message.message as NSString).integerValue + 1
            print("Designation: \(myDsg)")
            
            hideStatus()
        case "mov":
            if world.mode == myDsg {
                print("Error: message received when not supposed to. Gotta deal with it somehow")
                break
            }
            // update board with opponent's moves
            let moves = message.message.components(separatedBy: moveDelimiter)
            for move in moves {
                let coords = move.components(separatedBy: ",")
                let gridX = (coords.first! as NSString).floatValue
                let gridY = (coords.last! as NSString).floatValue
                world.gridTouched(gridX: CGFloat(gridX), gridY: CGFloat(gridY), player: world.mode)
            }
            nextTurn() // switch to my turn
        default :
            print("Unexpected message format: header: \(message.header), content: \(message.message)")
        }
    }
    
    func addSpritesForCells(_ numRows: Int, numCols: Int)
    {
        world = World(widthIn: numRows, heightIn: numCols)
        gridCoord = Array(repeating: Array(repeating: CGPoint(x: 0,y: 0), count: numCols), count: numRows)
        
        let bounds = UIScreen.main.bounds
        let widthScreen = bounds.size.width
        
        let gridWidth: CGFloat = widthScreen - margin*2
        cellSize = (gridWidth - CGFloat(numCols-1)*spaceBetwCells) * 1.0 / CGFloat(numCols)
        
        for row in 0...numRows-1 {
            for col in 0...numCols-1 {
                
                let leftCornerCell = margin + CGFloat(col) * (cellSize + spaceBetwCells)
                let upperCornerCell = upperSpace + CGFloat(row) * (cellSize + spaceBetwCells)
                gridCoord[row][col] = CGPoint(x: leftCornerCell, y: -upperCornerCell)
                
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
                cell.position = CGPoint(x: leftCornerCell, y: -upperCornerCell)
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
        numP1Label.position = CGPoint(x: screenMidX - 70, y: -upperSpace*2/3)
        numP1Label.fontColor = SKColor.red
        numP1Label.fontSize = 50
        numP1Label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        numP1Label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        
        numP2Label.text = "0"
        numP2Label.position = CGPoint(x: screenMidX + 70, y: -upperSpace*2/3)
        numP2Label.fontColor = SKColor.blue
        numP2Label.fontSize = 50
        numP2Label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        numP2Label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        
        runButton.fillColor = SKColor.init(hue: 0, saturation: 0, brightness: 0.88, alpha: 1)
        runButton.position = CGPoint(x: screenMidX, y: -upperSpace*2/3)
        
        // feel free to edit my lame graphics and make it awesome. I'm bad with colors.
        runButtonText.text = "Switch"
        runButtonText.fontColor = SKColor.black
        runButtonText.fontSize = 25
        runButtonText.position = CGPoint(x: 0, y: 0)
        runButtonText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        runButtonText.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        
        modeText.text = "Player 1"
        modeText.fontColor = SKColor.red
        modeText.fontSize = 40
        modeText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        modeText.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
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
        livesP1Label.position = CGPoint(x: margin,
            y: -upperSpace + gridCoord[world.height - 1][0].y - margin)
        livesP1Label.fontColor = SKColor.red
        livesP1Label.fontSize = 30
        livesP1Label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        livesP1Label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        
        livesP2Label.text = String(world.numP1Lives) + " cells left"
        livesP2Label.position = CGPoint(x: frame.maxX - margin,
            y: -upperSpace + gridCoord[world.height - 1][0].y - margin)
        livesP2Label.fontColor = SKColor.blue
        livesP2Label.fontSize = 30
        livesP2Label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesP2Label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        
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
    
    func nextTurn() {
        print("mode: \(world.mode) dsg: \(myDsg) num moves: \(currentMoves.count)")
        if (world.mode == myDsg) {
            print("waiting for opponent")
            showStatus(message: "Waiting for opponent")
            let message = currentMoves.map({ String(describing: $0) }).joined(separator: moveDelimiter)
            netComm.sendMessage(header: "mov", message: message)
            currentMoves.removeAll()
        } else {
            hideStatus()
        }
        
        if world.mode == 1 {
            // PLAYER 1'S TURN > PLAYER 2'S TURN
            world.mode += 1
            world.nextGeneration()
            world.numP1Lives += 3
            
            modeText.text = "Player 2"
            modeText.fontColor = SKColor.blue
            
        }
        else if world.mode == 2 {
            // PLAYER 2'S TURN > PLAYER 1'S TURN
            world.mode -= 1
            world.nextGeneration()
            world.numP2Lives += 3
            
            modeText.text = "Player 1"
            modeText.fontColor = SKColor.red
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {

            let location = touch.location(in: self)
            let gridX = (location.x - margin) / (cellSize + spaceBetwCells)
            let gridY = (abs(location.y) - upperSpace) / (cellSize + spaceBetwCells)
            
            
            if runButton.contains(location) && world.mode == myDsg {
                nextTurn()
                
                if (world.numP1Cells == 0 && world.currentGeneration > 0)
                    || (world.numP2Cells == 0 && world.currentGeneration > 1) {
                    
                    displayGameOverScreen()
                }
                
                
            }
            else if world.mode == myDsg {
                world.gridTouched(gridX: gridX, gridY: gridY, player: world.mode)
                currentMoves.append("\(gridX),\(gridY)")
                print("recorded move")
            }

            updateText()

        }

    }
    
    func displayGameOverScreen()
    {
        removeAllChildren()
        addChild(backgroundNode)
        let gameOverLabel = SKLabelNode(text: "GAME OVER!")
        gameOverLabel.fontColor = SKColor.black
        gameOverLabel.fontSize = 50
        gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        gameOverLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        gameOverLabel.position = CGPoint(x: screenMidX, y: -screenMidY + 50)

        
        let winner = SKLabelNode()
        if world.numP1Cells == 0 {
            winner.text = "PLAYER 2 WINS!"
            winner.fontColor = SKColor.blue
        }
        else if world.numP2Cells == 0 {
            winner.text = "PLAYER 1 WINS!"
            winner.fontColor = SKColor.red
        }
        
        winner.fontSize = 50
        winner.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        winner.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        winner.position = CGPoint(x: screenMidX, y: -screenMidY)

        addChild(gameOverLabel)
        addChild(winner)
        
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        /* Called before each frame is rendered */
        
        // -> AKA DON'T PUT ANYTHING IN HERE! :P
    }
}


// conforms to Message Delegate protocol
extension GameScene: NetworkCommDelegate {
    func receivedMessage(message: Message) {
        self.handleMessage(message: message)
    }
}
