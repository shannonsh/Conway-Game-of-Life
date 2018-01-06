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
        menuScene.scaleMode = .aspectFit
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
    

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
}
