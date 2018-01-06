//
//  MenuScene.swift
//  Conway Game of Life
//
//  Created by Shannon on 8/14/17.
//  Copyright © 2017 GGDragonStudios. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    let margin: CGFloat = 10
    let smallFont: CGFloat = 30
    let largeFont: CGFloat = 40
    
    let playButton = SKLabelNode()
    let rulesButton = SKLabelNode()
    let settingsButton = SKLabelNode()
    var gameScene: GameScene!
    
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor.white
        
        playButton.fontColor = SKColor.black
        playButton.fontSize = largeFont
        playButton.text = "Start"
        playButton.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        
        settingsButton.fontColor = SKColor.black
        settingsButton.fontSize = smallFont
        settingsButton.text = "Settings"
        settingsButton.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        let prevHeight = settingsButton.frame.height
        
        rulesButton.fontColor = SKColor.black
        rulesButton.fontSize = smallFont
        rulesButton.text = "How to play"
        rulesButton.position = CGPoint(x: size.width / 2, y: size.height * 0.5 + prevHeight + margin)
        
        addChild(playButton)
        addChild(settingsButton)
        addChild(rulesButton)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        
        if playButton.contains(touchLocation) {
            let skView = view as SKView!
            skView?.isMultipleTouchEnabled = false
            
            gameScene = GameScene(size: (skView?.bounds.size)!)
            gameScene.scaleMode = .aspectFit
            self.view?.presentScene(gameScene)
            
        }
        
    }
    
}
