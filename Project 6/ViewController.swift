//
//  ViewController.swift
//  Project 6
//
//  Created by Andrew Grossfeld on 11/14/15.
//  Copyright © 2015 Andrew Grossfeld. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {

    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var spaceShip: UIImageView!
    var timerA: NSTimer!
    var timerB: NSTimer!
    var animator: UIDynamicAnimator!
    var gravityBehav: UIGravityBehavior!
    var collisionBehav: UICollisionBehavior!
    var pushBehav: UIPushBehavior!
    var level: Int = 1
    var score: Int = 0
    var end: Bool = false
    var highScore: Int = 0
    var asteroids: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        highScore = NSUserDefaults.standardUserDefaults().objectForKey("HighScore") as? Int ?? highScore
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        gameOverLabel.hidden = true
        playAgainButton.hidden = true
        playAgainButton.enabled = false
        highScoreLabel.text = "High Score: \(highScore)"
    }
    
    
    override func viewDidAppear(animated: Bool) {
        animator = UIDynamicAnimator(referenceView: view)
        timerA = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerAFired:", userInfo: nil, repeats: true)
        timerB = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "timerBFired:", userInfo: nil, repeats: true)
        
        gravityBehav = UIGravityBehavior(items: [])
        animator.addBehavior(gravityBehav)
        
        collisionBehav = UICollisionBehavior(items: [spaceShip])
        collisionBehav.collisionDelegate = self
        collisionBehav.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collisionBehav)
        
        pushBehav = UIPushBehavior(items: [], mode: UIPushBehaviorMode.Continuous)
        pushBehav.pushDirection = CGVector(dx: 0, dy: -3)
        animator.addBehavior(pushBehav)
        
    }
    
    func timerAFired(sender: NSTimer) {
        var randomVar = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        randomVar = randomVar * (self.view.bounds.width - 24)
        
        let newView = UIImageView(frame: CGRect(x: randomVar, y: 10, width: 24, height: 24))
        newView.image = UIImage(named: "asteroid")
        newView.layer.borderColor = UIColor.whiteColor().CGColor
        newView.layer.borderWidth = 1.0
        self.view.addSubview(newView)
        
        gravityBehav.addItem(newView)
        collisionBehav.addItem(newView)
        asteroids.append(newView)
    }
    
    func timerBFired(sender:NSTimer) {
        let old = timerA.timeInterval
        timerA.invalidate()
        timerA = NSTimer.scheduledTimerWithTimeInterval(old * (3/4), target: self, selector: "timerAFired:", userInfo: nil, repeats: true)
        level += 1
        levelLabel.text = "Level: \(level)"
        
        var randomVar = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        randomVar = randomVar * (self.view.bounds.width - 24)
        
        let newView = UIImageView(frame: CGRect(x: randomVar, y: 10, width: 84, height: 84))
        newView.image = UIImage(named: "asteroid")
        newView.layer.borderColor = UIColor.redColor().CGColor
        newView.layer.borderWidth = 1.0
        self.view.addSubview(newView)
        
        gravityBehav.addItem(newView)
        collisionBehav.addItem(newView)
        asteroids.append(newView)

    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        let item = item as! UIView
        if (item != spaceShip && asteroids.contains(item)) {
            item.removeFromSuperview()
            gravityBehav.removeItem(item)
            collisionBehav.removeItem(item)
            if (end == false) {
                score += 1
                scoreLabel.text = "Score: \(score)"
            }
        }
        else if (item != spaceShip && item.backgroundColor == UIColor.redColor()) {
            item.removeFromSuperview()
            pushBehav.removeItem(item)
            collisionBehav.removeItem(item)
        }
        else {
            
        }
        
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        let obj1 = item1 as! UIView
        let obj2 = item2 as! UIView
        if (obj1 == spaceShip || obj2 == spaceShip) && (asteroids.contains(obj1) || asteroids.contains(obj2)) {
            timerA.invalidate()
            collisionBehav.removeItem(item1)
            collisionBehav.removeItem(item2)
            if (obj1 == spaceShip) {
                gravityBehav.removeItem(obj2)
                obj2.removeFromSuperview()
                asteroids.removeAtIndex(asteroids.indexOf(obj2)!)
            }
            else if (obj2 == spaceShip) {
                gravityBehav.removeItem(obj1)
                obj1.removeFromSuperview()
                asteroids.removeAtIndex(asteroids.indexOf(obj1)!)
            }
            end = true
            timerB.invalidate()
            if score > highScore {
                highScore = score
                highScoreLabel.text = "High Score: \(highScore)"
                gameOverLabel.text = "Game Over! New High Score: \(score)"
            }
            else {
                gameOverLabel.text = "Game Over! Score: \(score)"
            }
            gameOverLabel.center = CGPoint(x: view.bounds.width/2, y: view.bounds.height / 2)
            gameOverLabel.hidden = false
            playAgainButton.center = CGPoint(x: view.bounds.width/2, y: view.bounds.height - 100)
            playAgainButton.enabled = true
            playAgainButton.hidden = false
        }
        else if (obj1 != spaceShip && obj2 != spaceShip) {
            if (obj1.backgroundColor == UIColor.redColor()) {
                pushBehav.removeItem(obj1)
                gravityBehav.removeItem(obj2)
                collisionBehav.removeItem(obj1)
                collisionBehav.removeItem(obj2)
            }
            else {
                pushBehav.removeItem(obj2)
                gravityBehav.removeItem(obj1)
                collisionBehav.removeItem(obj1)
                collisionBehav.removeItem(obj2)
            }
            score += 2
            scoreLabel.text = "Score: \(score)"
            obj1.removeFromSuperview()
            obj2.removeFromSuperview()
        }
        else {
            
        }
    }

    
    @IBAction func panSpaceShip(sender: UIPanGestureRecognizer) {
        if  end == false {
            let ss = sender.view!
            let trans = sender.translationInView(view)
            var newX = ss.center.x + trans.x
            
            if (newX - (ss.bounds.width/2) < 0){
                newX = ss.bounds.width / 2
            }
            if (newX + (ss.bounds.width/2) > self.view.bounds.width) {
                newX = self.view.bounds.width - (ss.bounds.width/2)
            }
            
            var newY = ss.center.y + trans.y
            
            if (newY - (ss.bounds.height/2) < 0){
                newY = ss.bounds.height / 2
            }
            if (newY + (ss.bounds.height/2) > self.view.bounds.height) {
                newY = self.view.bounds.height - (ss.bounds.height/2)
            }
            
            ss.center = CGPoint(x: newX, y: newY)
            sender.setTranslation(CGPointZero, inView: view)
            animator.updateItemUsingCurrentState(spaceShip)
        }
    }
    
    @IBAction func shoot(sender: UITapGestureRecognizer) {
        let shot = UIView(frame: CGRect(x: spaceShip.center.x - 2.5, y: spaceShip.center.y - 20 - (spaceShip.bounds.height / 2) , width: 6, height: 15.0))
        shot.backgroundColor = UIColor.redColor()
        self.view.addSubview(shot)
        pushBehav.addItem(shot)
        collisionBehav.addItem(shot)
    }
    
    
    @IBAction func playAgain(sender: UIButton) {
        playAgainButton.hidden = true
        playAgainButton.enabled = false
        gameOverLabel.hidden = true
        scoreLabel.text = "Score: 0"
        levelLabel.text = "Level: 1"
        end = false
        score = 0
        level = 1
        timerA = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerAFired:", userInfo: nil, repeats: true)
        timerB = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "timerBFired:", userInfo: nil, repeats: true)
        collisionBehav.addItem(spaceShip)
    }
    
    func applicationWillTerminate(notif: NSNotification) {
        NSUserDefaults.standardUserDefaults().setObject(highScore, forKey: "HighScore")
    }
    


}

