//
//  GameScene.h
//  DriveOffBugs
//
//  Created by Itou Yousei on 11/21/13.
//  Copyright (c) 2013 LumberMill, Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene <SKPhysicsContactDelegate>
@property (assign, nonatomic) int score;
@end
