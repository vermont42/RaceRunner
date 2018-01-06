//
//  GameOverScene.swift
//  RaceRunner
//
//  Based on Tutorial by Riccardo D'Antoni
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {
  private var contentCreated = false
  private let oldHighScore: Int
  private let adjustedScore: Int
  private let gameOverText = "Game Over"
  private let newHighScoreString = "New high score: "
  private let notNewHighScoreString = "Score: "
  private let tapPrompt = "Tap to play again."
  private let largeFontSize: CGFloat = 50.0
  private let smallFontSize: CGFloat = 25.0
  private let gameOverYOffset: CGFloat = 2.0 / 3.0
  private let labelYOffset: CGFloat = 40.0
  
  init(size: CGSize, adjustedScore: Int, oldHighScore: Int) {
    self.oldHighScore = oldHighScore
    self.adjustedScore = adjustedScore
    super.init(size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    if (!self.contentCreated) {
      createContent()
      contentCreated = true
    }
  }
    
  private func createContent() {
    let gameOverLabel = SKLabelNode(fontNamed: UiConstants.globalFont)
    gameOverLabel.fontSize = largeFontSize
    gameOverLabel.fontColor = UiConstants.intermediate2Color
    gameOverLabel.text = gameOverText
    gameOverLabel.position = CGPoint(x: self.size.width/2, y: gameOverYOffset * self.size.height);
    self.addChild(gameOverLabel)
  
    let highScoreLabel = SKLabelNode(fontNamed: UiConstants.globalFont)
    highScoreLabel.fontSize = smallFontSize
    highScoreLabel.fontColor = UiConstants.intermediate1Color
  
    let highScoreText: String
    if adjustedScore > oldHighScore {
      highScoreText = newHighScoreString + "\(adjustedScore)"
    }
    else {
      highScoreText = notNewHighScoreString + "\(adjustedScore)"
    }
    highScoreLabel.text = highScoreText
    highScoreLabel.position = CGPoint(x: self.size.width/2, y: gameOverLabel.frame.origin.y - gameOverLabel.frame.size.height - labelYOffset);
    self.addChild(highScoreLabel)
  
    let tapLabel = SKLabelNode(fontNamed: UiConstants.globalFont)
    tapLabel.fontSize = smallFontSize
    tapLabel.fontColor = UiConstants.intermediate3Color
    tapLabel.text = tapPrompt
    tapLabel.position = CGPoint(x: self.size.width/2, y: highScoreLabel.frame.origin.y - highScoreLabel.frame.size.height - labelYOffset);
    self.addChild(tapLabel)
    
    self.backgroundColor = UiConstants.darkColor

  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)  {}

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)  {
    let gameScene = GameScene(size: self.size)
    gameScene.scaleMode = .aspectFill
    self.view?.presentScene(gameScene, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.0))
  }
}
