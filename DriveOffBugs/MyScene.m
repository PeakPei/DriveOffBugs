//
//  MyScene.m
//  DriveOffBugs
//
//  Created by Itou Yousei on 11/21/13.
//  Copyright (c) 2013 LumberMill, Inc. All rights reserved.
//

#import "MyScene.h"
#import "GameScene.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Drive off bugs!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [self addChild:myLabel];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    GameScene *scene = [[GameScene alloc] initWithSize:self.frame.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    SKTransition *tr = [SKTransition fadeWithDuration:0.5];
    [self.view presentScene:scene transition:tr];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
