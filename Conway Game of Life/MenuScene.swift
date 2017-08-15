//
//  MenuScene.swift
//  Conway Game of Life
//
//  Created by Shannon on 8/14/17.
//  Copyright © 2017 GGDragonStudios. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    let playButton = SKLabelNode()
    var gameScene: GameScene!
    
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor.whiteColor()
        playButton.fontColor = SKColor.blackColor()
        playButton.text = "Play"
        
        playButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        addChild(playButton)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let touchLocation = touch.locationInNode(self)
        
        if playButton.containsPoint(touchLocation) {
            let skView = view as SKView!
            skView.multipleTouchEnabled = false
            
            gameScene = GameScene(size: skView.bounds.size)
            gameScene.scaleMode = .AspectFit
            self.view?.presentScene(gameScene)
            
        }
        
    }
    
}
