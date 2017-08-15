//
//  GameViewController.swift
//  Conway Game of Life
//
//  Created by Elena Ariza on 3/11/16.
//  Copyright (c) 2016 Elena Ariza and Shannon Shih. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController {

    

    override func viewDidLoad() {
        super.viewDidLoad()
        let menuScene = MenuScene(size: view.bounds.size)
        
        let skView = view as! SKView
//        skView.ignoresSiblingOrder = true
        menuScene.scaleMode = .AspectFit
        skView.presentScene(menuScene)
//        
//        // Configure the view.
//        let skView = view as! SKView
//        skView.multipleTouchEnabled = false
//        
//        // Create and configure the scene.
//        scene = GameScene(size: skView.bounds.size)
//        scene.scaleMode = .AspectFit
//        
//        // Present the scene.
//        skView.presentScene(scene)
        
    }
    

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}
