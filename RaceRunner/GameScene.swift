//
//  GameScene.swift
//  RaceRunner
//
//  Based on Tutorial by Riccardo D'Antoni
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
  var gameEnding: Bool = false
  var contentCreated = false
  var invaderMovementDirection: InvaderMovementDirection = .right
  var timeOfLastMove: CFTimeInterval = 0.0
  var tapQueue = [Int]()
  var contactQueue = [SKPhysicsContact]()
  var score: Int = 0
  var runnerHealth: Float = 1.0
  var timePerMove: CFTimeInterval = 1.0
  var startTime = Date()
  let eastRunners: [SKTexture]
  let westRunners: [SKTexture]
  let eastHorses: [SKTexture]
  let westHorses: [SKTexture]
  let timePerFrame = 0.1
  let minInvaderBottomHeight: Float = 32.0
  let invaderGridSpacing = CGSize(width: 12, height: 12)
  let invaderRowCount = 6
  let invaderColCount = 6
  let runnerSize = CGSize(width: 30, height: 16)
  let runnerName = "stationary"
  let scoreHudName = "scoreHud"
  let healthHudName = "healthHud"
  let motionManager: CMMotionManager = CMMotionManager()
  let runnerFiredBulletName = "runnerFiredBullet"
  let invaderFiredBulletName = "invaderFiredBullet"
  let bulletSize = CGSize(width:4, height: 8)
  let invaderCategory: UInt32 = 0x1 << 0
  let runnerFiredBulletCategory: UInt32 = 0x1 << 1
  let runnerCategory: UInt32 = 0x1 << 2
  let sceneEdgeCategory: UInt32 = 0x1 << 3
  let invaderFiredBulletCategory: UInt32 = 0x1 << 4
  let invaderOriginWidthDivisor: CGFloat = 3.0
  let invaderOriginHeightDivisor: CGFloat = 2.5
  let healthString = "Health: %.1f%%"
  let scoreString = "Score: %04u"
  let runnerMass: CGFloat = 0.02
  let hudFontSize: CGFloat = 25.0
  let scoreOffset: CGFloat = 40.0
  let healthOffset: CGFloat = 80.0
  let distancePerMove: CGFloat = 10.0
  let minRunnerAcceleration: Double = 0.2
  let runnerForce: CGFloat = 40.0
  let bulletFileName = "Bullet"
  let timePerMoveScalingFactor = 0.95
  let bulletRemovalDelay: TimeInterval = 0.05
  let runnerBulletDuration: TimeInterval = 1.0
  let invaderBulletDuration: TimeInterval = 2.0
  let transitionDuration: TimeInterval = 1.0
  let pointsPerHit = 100
  let healthAdjustment: Float = -0.334
  static let invaderWidth: CGFloat = 24.0 // must be static to be used in enum
  static let invaderHeight: CGFloat = 16.0 // must be static to be used in enum

  enum InvaderType: String {
    case Horse = "Horse"
    case Runner = "Runner"
    
    static var size: CGSize {
      return CGSize(width: GameScene.invaderWidth, height: GameScene.invaderHeight)
    }
  }
  
  enum InvaderMovementDirection {
    case right
    case left
    case downThenRight
    case downThenLeft
    case none
  }
  
  enum BulletType {
    case runnerFired
    case invaderFired
  }

  override init(size: CGSize) {
    eastRunners = [SKTexture(imageNamed: "east1"), SKTexture(imageNamed: "east2"), SKTexture(imageNamed: "east3"), SKTexture(imageNamed: "east4"), SKTexture(imageNamed: "east5"), SKTexture(imageNamed: "east6"), SKTexture(imageNamed: "east7"), SKTexture(imageNamed: "east8"), SKTexture(imageNamed: "east9"), SKTexture(imageNamed: "east10")]
    westRunners = [SKTexture(imageNamed: "west1"), SKTexture(imageNamed: "west2"), SKTexture(imageNamed: "west3"), SKTexture(imageNamed: "west4"), SKTexture(imageNamed: "west5"), SKTexture(imageNamed: "west6"), SKTexture(imageNamed: "west7"), SKTexture(imageNamed: "west8"), SKTexture(imageNamed: "west9"), SKTexture(imageNamed: "west10")]
    eastHorses = [SKTexture(imageNamed: "east1Horse"), SKTexture(imageNamed: "east2Horse"), SKTexture(imageNamed: "east3Horse"), SKTexture(imageNamed: "east4Horse"), SKTexture(imageNamed: "east5Horse"), SKTexture(imageNamed: "east6Horse"), SKTexture(imageNamed: "east7Horse"), SKTexture(imageNamed: "east8Horse"), SKTexture(imageNamed: "east9Horse"), SKTexture(imageNamed: "east10Horse"), SKTexture(imageNamed: "east11Horse")]
    westHorses = [SKTexture(imageNamed: "west1Horse"), SKTexture(imageNamed: "west2Horse"), SKTexture(imageNamed: "west3Horse"), SKTexture(imageNamed: "west4Horse"), SKTexture(imageNamed: "west5Horse"), SKTexture(imageNamed: "west6Horse"), SKTexture(imageNamed: "west7Horse"), SKTexture(imageNamed: "west8Horse"), SKTexture(imageNamed: "west9Horse"), SKTexture(imageNamed: "west10Horse"), SKTexture(imageNamed: "west11Horse")]
    super.init(size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    if (!self.contentCreated) {
      self.createContent()
      self.contentCreated = true
      motionManager.startAccelerometerUpdates()
    }
    startTime = Date()
    physicsWorld.contactDelegate = self
  }
  
  func createContent() {
    setupInvaders()
    physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    physicsBody!.categoryBitMask = sceneEdgeCategory
    setupRunner()
    setupHud()
    self.backgroundColor = UiConstants.lightColor
  }
  
  func makeInvaderOfType(_ invaderType: InvaderType, direction: InvaderMovementDirection) -> SKNode {
    let texture: SKTexture
    switch(invaderType) {
    case .Horse:
      texture = westHorses[0]
    case .Runner:
      texture = westRunners[0]
    }
    let invader = SKSpriteNode(texture: texture)
    invader.name = invaderType.rawValue
    invader.physicsBody = SKPhysicsBody(rectangleOf: invader.frame.size)
    invader.physicsBody!.isDynamic = false
    invader.physicsBody!.categoryBitMask = invaderCategory
    invader.physicsBody!.contactTestBitMask = 0x0
    invader.physicsBody!.collisionBitMask = 0x0
    return invader
  }
  
  func setupInvaders() {
    let baseOrigin = CGPoint(x: size.width / invaderOriginWidthDivisor, y: size.height / invaderOriginHeightDivisor)
    for row in 0 ..< invaderRowCount {
      var invaderType: InvaderType
      if row % 2 == 0 {
        invaderType = .Runner
      } else {
        invaderType = .Horse
      }
      let invaderPositionY = CGFloat(row) * (InvaderType.size.height * 2) + baseOrigin.y
      var invaderPosition = CGPoint(x: baseOrigin.x, y: invaderPositionY)
      for _ in 0 ..< invaderColCount {
        let invader = makeInvaderOfType(invaderType, direction: .left)
        invader.position = invaderPosition
        addChild(invader)
        invaderPosition = CGPoint(x: invaderPosition.x + InvaderType.size.width + invaderGridSpacing.width, y: invaderPositionY)
      }
    }
  }
  
  func setupRunner() {
    let runner = makeRunner()
    runner.position = CGPoint(x: size.width / 2.0, y: runnerSize.height / 2.0)
    addChild(runner)
  }
  
  func makeRunner() -> SKNode {
    let runner = SKSpriteNode(imageNamed: runnerName)
    runner.name = runnerName
    runner.physicsBody = SKPhysicsBody(rectangleOf: runner.frame.size)
    runner.physicsBody!.isDynamic = true
    runner.physicsBody!.affectedByGravity = false
    runner.physicsBody!.mass = runnerMass
    runner.physicsBody!.categoryBitMask = runnerCategory
    runner.physicsBody!.contactTestBitMask = 0x0
    runner.physicsBody!.collisionBitMask = sceneEdgeCategory
    return runner
  }
  
  func setupHud() {
    let scoreLabel = SKLabelNode(fontNamed: UiConstants.globalFont)
    scoreLabel.name = scoreHudName
    scoreLabel.fontSize = hudFontSize
    scoreLabel.fontColor = UiConstants.intermediate3Color
    scoreLabel.text = String(format: scoreString, 0)
    scoreLabel.position = CGPoint(
      x: frame.size.width / 2,
      y: size.height - (scoreOffset + scoreLabel.frame.size.height/2)
    )
    addChild(scoreLabel)
    let healthLabel = SKLabelNode(fontNamed: UiConstants.globalFont)
    healthLabel.name = healthHudName
    healthLabel.fontSize = 25
    healthLabel.fontColor = UiConstants.intermediate1Color
    healthLabel.text = String(format: healthString, runnerHealth * 100.0)
    healthLabel.position = CGPoint(
      x: frame.size.width / 2,
      y: size.height - (healthOffset + healthLabel.frame.size.height/2)
    )
    addChild(healthLabel)
  }
  
  func adjustScoreBy(_ points: Int) {
    score += points
    
    if let score = childNode(withName: scoreHudName) as? SKLabelNode {
      score.text = String(format: scoreString, self.score)
    }
  }
  
  func adjustrunnerHealthBy(_ healthAdjustment: Float) {
    runnerHealth = max(runnerHealth + healthAdjustment, 0)
    if let health = childNode(withName: healthHudName) as? SKLabelNode {
      health.text = String(format: healthString, self.runnerHealth * 100)
    }
  }
  
  override func update(_ currentTime: TimeInterval) {
    if isGameOver() {
      endGame()
    }
    processContactsForUpdate(currentTime)
    processUserTapsForUpdate(currentTime)
    processUserMotionForUpdate(currentTime)
    moveInvadersForUpdate(currentTime)
    fireInvaderBulletsForUpdate(currentTime)
  }
  
  func moveInvadersForUpdate(_ currentTime: CFTimeInterval) {
    if (currentTime - timeOfLastMove < timePerMove) {
      return
    }
    determineInvaderMovementDirection()
    enumerateChildNodes(withName: InvaderType.Horse.rawValue) { node, stop in
      self.updateInvader(node, invaderType: .Horse, currentTime: currentTime)
    }
    enumerateChildNodes(withName: InvaderType.Runner.rawValue) { node, stop in
      self.updateInvader(node, invaderType: .Runner, currentTime: currentTime)
    }
  }
  
  func updateInvader(_ invader: SKNode, invaderType: InvaderType, currentTime: CFTimeInterval) {
    let textures: [SKTexture]
    if invaderMovementDirection == .left || invaderMovementDirection == .downThenLeft {
      if invaderType == .Horse {
        textures = self.westHorses
      } else {
        textures = self.westRunners
      }
    } else /* if invaderMovementDirection == .Right || invaderMovementDirection == .DownThenRight */ {
      if invaderType == .Horse {
        textures = self.eastHorses
      } else {
        textures = self.eastRunners
      }
    }
    invader.removeAllActions()
    invader.run(SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: timePerFrame)))
    switch invaderMovementDirection {
    case .right:
      invader.run(SKAction.move(to: CGPoint(x: invader.position.x + distancePerMove, y: invader.position.y), duration: timePerMove))
    case .left:
      invader.run(SKAction.move(to: CGPoint(x: invader.position.x - distancePerMove, y: invader.position.y), duration: timePerMove))
    case .downThenLeft, .downThenRight:
      invader.run(SKAction.move(to: CGPoint(x: invader.position.x, y: invader.position.y - distancePerMove), duration: timePerMove))
    case .none:
      break
    }
    timeOfLastMove = currentTime
  }

  func adjustInvaderMovementToTimePerMove(_ newTimePerMove: CFTimeInterval) {
    if newTimePerMove <= 0 {
      return
    }
    timePerMove = newTimePerMove
  }
  
  func processUserMotionForUpdate(_ currentTime: CFTimeInterval) {
    if let runner = childNode(withName: runnerName) as? SKSpriteNode {
      if let data = motionManager.accelerometerData {
        if fabs(data.acceleration.x) > minRunnerAcceleration {
          runner.physicsBody!.applyForce(CGVector(dx: runnerForce * CGFloat(data.acceleration.x), dy: 0))
        }
      }
    }
  }
  
  func makeBulletOfType(_ bulletType: BulletType) -> SKNode {
    var bullet: SKNode
    switch bulletType {
    case .runnerFired:
      bullet = SKSpriteNode(color: UiConstants.intermediate1Color, size: bulletSize)
      bullet.name = runnerFiredBulletName
      bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
      bullet.physicsBody!.isDynamic = true
      bullet.physicsBody!.affectedByGravity = false
      bullet.physicsBody!.categoryBitMask = runnerFiredBulletCategory
      bullet.physicsBody!.contactTestBitMask = invaderCategory
      bullet.physicsBody!.collisionBitMask = 0x0
      let trailNode = SKNode()
      trailNode.zPosition = 1
      addChild(trailNode)
      let trail = SKEmitterNode(fileNamed: bulletFileName)!
      trail.targetNode = trailNode
      bullet.addChild(trail)
    case .invaderFired:
      bullet = SKSpriteNode(color: UiConstants.intermediate3Color, size: bulletSize)
      bullet.name = invaderFiredBulletName
      bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
      bullet.physicsBody!.isDynamic = true
      bullet.physicsBody!.affectedByGravity = false
      bullet.physicsBody!.categoryBitMask = invaderFiredBulletCategory
      bullet.physicsBody!.contactTestBitMask = runnerCategory
      bullet.physicsBody!.collisionBitMask = 0x0
    }
    return bullet
  }
  
  func determineInvaderMovementDirection() {
    var proposedMovementDirection: InvaderMovementDirection = invaderMovementDirection
    for invader in enumerateAllInvaders() {
      switch invaderMovementDirection {
      case .right:
        if (invader.frame.maxX >= invader.scene!.size.width - 1.0) {
          proposedMovementDirection = .downThenLeft
          adjustInvaderMovementToTimePerMove(timePerMove * timePerMoveScalingFactor)
          break
        }
      case .left:
        if (invader.frame.minX <= 1.0) {
          proposedMovementDirection = .downThenRight
          adjustInvaderMovementToTimePerMove(timePerMove * timePerMoveScalingFactor)
          break
        }
      case .downThenLeft:
        proposedMovementDirection = .left
        break
      case .downThenRight:
        proposedMovementDirection = .right
        break
      case .none:
        break
      }
    }
    if (proposedMovementDirection != invaderMovementDirection) {
      invaderMovementDirection = proposedMovementDirection
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      if (touch.tapCount == 1) {
        tapQueue.append(1)
      }
    }
  }
  
  func fireBullet(_ bullet: SKNode, toDestination destination: CGPoint, withDuration duration: CFTimeInterval, andSoundFileName soundName: String) {
    let bulletAction = SKAction.sequence([
      SKAction.move(to: destination, duration: duration),
      SKAction.wait(forDuration: bulletRemovalDelay), SKAction.removeFromParent()
      ])
    
    let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
    bullet.run(SKAction.group([bulletAction, soundAction]))
    addChild(bullet)
  }
  
  func fireRunnerBullets() {
    let existingBullet = childNode(withName: runnerFiredBulletName)
    if existingBullet == nil {
      if let runner = childNode(withName: runnerName) {
        let bullet = makeBulletOfType(.runnerFired)
        bullet.position = CGPoint(
          x: runner.position.x,
          y: runner.position.y + runner.frame.size.height - bullet.frame.size.height / 2
        )
        let bulletDestination = CGPoint(
          x: runner.position.x,
          y: frame.size.height + bullet.frame.size.height / 2
        )
        fireBullet(bullet, toDestination: bulletDestination, withDuration: runnerBulletDuration, andSoundFileName: Sound.Gun.rawValue)
      }
    }
  }
  
  func processUserTapsForUpdate(_ currentTime: CFTimeInterval) {
    for tapCount in tapQueue {
      if tapCount == 1 {
        fireRunnerBullets()
      }
      tapQueue.remove(at: 0)
    }
  }
  
  func enumerateAllInvaders() -> [SKNode] {
    var allInvaders: [SKNode] = []
    enumerateChildNodes(withName: InvaderType.Horse.rawValue) {
      node, stop in
      allInvaders.append(node)
    }
    enumerateChildNodes(withName: InvaderType.Runner.rawValue) {
      node, stop in
      allInvaders.append(node)
    }
    return allInvaders
  }
  
  func fireInvaderBulletsForUpdate(_ currentTime: CFTimeInterval) {
    let existingBullet = childNode(withName: invaderFiredBulletName)
    if existingBullet == nil {
      let allInvaders = enumerateAllInvaders()
      if allInvaders.count > 0 {
        let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
        let invader = allInvaders[allInvadersIndex]
        let bullet = makeBulletOfType(.invaderFired)
        bullet.position = CGPoint(
          x: invader.position.x,
          y: invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2
        )
        let bulletDestination = CGPoint(x: invader.position.x, y: -(bullet.frame.size.height / 2))
        fireBullet(bullet, toDestination: bulletDestination, withDuration: invaderBulletDuration, andSoundFileName: Sound.Gun2.rawValue)
      }
    }
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    contactQueue.append(contact)
  }
  
  func handleContact(_ contact: SKPhysicsContact) {
    if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil {
      return
    }
    let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
    if nodeNames.contains(runnerName) && nodeNames.contains(invaderFiredBulletName) {
      run(SKAction.playSoundFileNamed(Sound.Scream1.rawValue, waitForCompletion: false))
      adjustrunnerHealthBy(healthAdjustment)
      if runnerHealth <= 0.0 {
        contact.bodyA.node!.removeFromParent()
        contact.bodyB.node!.removeFromParent()
      } else {
        if let runner = self.childNode(withName: runnerName) {
          runner.alpha = CGFloat(runnerHealth)
          if contact.bodyA.node == runner {
            contact.bodyB.node!.removeFromParent()
          } else {
            contact.bodyA.node!.removeFromParent()
          }
        }
      }
      
    } else if (nodeNames.contains(InvaderType.Horse.rawValue) || nodeNames.contains(InvaderType.Runner.rawValue)) && nodeNames.contains(runnerFiredBulletName) {
      let scream: String
      if nodeNames.contains(InvaderType.Horse.rawValue) {
        scream = Sound.Neigh.rawValue // TODO: credit http://www.orangefreesounds.com/horse-neighing/
      } else {
        scream = Sound.Scream2.rawValue
      }
      run(SKAction.playSoundFileNamed(scream, waitForCompletion: false))
      contact.bodyA.node!.removeFromParent()
      contact.bodyB.node!.removeFromParent()
      adjustScoreBy(pointsPerHit)
    }
  }
  
  func isGameOver() -> Bool {
    var invader = childNode(withName: InvaderType.Horse.rawValue)
    if invader == nil {
      invader = childNode(withName: InvaderType.Runner.rawValue)
    }
    var invaderTooLow = false
    enumerateChildNodes(withName: InvaderType.Runner.rawValue) {
      node, stop in
      
      if (Float(node.frame.minY) <= self.minInvaderBottomHeight)   {
        invaderTooLow = true
        stop.pointee = true
      }
    }
    let runner = childNode(withName: runnerName)
    return invader == nil || invaderTooLow || runner == nil
  }
  
  func endGame() {
    if !gameEnding {
      gameEnding = true
      motionManager.stopAccelerometerUpdates()
      var adjustedScore = Int(Float(score) * (runnerHealth + 1.0) - Float(Date().timeIntervalSince(startTime)))
      if adjustedScore < 0 {
        adjustedScore = 0
      }
      let oldHighScore = SettingsManager.getHighScore()
      if adjustedScore > oldHighScore {
        SettingsManager.setHighScore(adjustedScore)
      }
      let gameOverScene: GameOverScene = GameOverScene(size: size, adjustedScore: adjustedScore, oldHighScore: oldHighScore)
      view?.presentScene(gameOverScene, transition: SKTransition.doorsOpenHorizontal(withDuration: transitionDuration))
    }
  }
  
  func processContactsForUpdate(_ currentTime: CFTimeInterval) {
    for contact in contactQueue {
      handleContact(contact)
      if let index = contactQueue.index(of: contact) {
        contactQueue.remove(at: index)
      }
    }
  }
}
