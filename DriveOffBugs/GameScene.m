//
//  GameScene.m
//  DriveOffBugs
//
//  Created by Itou Yousei on 11/21/13.
//  Copyright (c) 2013 LumberMill, Inc. All rights reserved.
//

#import "GameScene.h"

#define BULLET  @"bullet"
#define KILLER  @"killer"
#define BUG     @"bug"
#define APPLE   @"apple"
#define BREAD   @"bread"

static const uint32_t mask_bullet = 1; // 0x1 << 0
static const uint32_t mask_killer = 2;
static const uint32_t mask_bread = 4;
static const uint32_t mask_bug = 8;
static const uint32_t mask_apple = 16;

@implementation GameScene{
    SKTexture *tx_bullet,*tx_bug;
    CGFloat killer_rotate;
    BOOL killer_is_rotating;
    SKEmitterNode *pt_fire,*pt_spark,*pt_bom,*pt_smoke;
    SKLabelNode *scoreNode;
    BOOL gameover;
    
    SKEmitterNode*	_particleFire;			//炎のパーティクル
	SKEmitterNode*	_particleSpark;			//スパークのパーティクル
	SKEmitterNode*	_particleBom;			//ボムのパーティクル
	SKEmitterNode*	_particleSmoke;			//スモークのパーティクル
}

@synthesize score;

-(void)didMoveToView:(SKView *)view
{
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background.png"];
    background.position = CGPointMake(self.size.width/2, self.size.height/2);
    background.name = @"background";
    [self addChild:background];
    
    SKSpriteNode *bread = [SKSpriteNode spriteNodeWithImageNamed:@"bread.png"];
    bread.position = CGPointMake(self.size.width/2, bread.size.height/2);
    bread.name = BREAD;
    [self addChild:bread];
    
    SKSpriteNode *killer = [SKSpriteNode spriteNodeWithImageNamed:@"insectkiller.png"];
    killer.position = CGPointMake(self.size.width/2, killer.size.height);
    killer.name = KILLER;
    [self addChild:killer];
    
    tx_bug = [SKTexture textureWithImageNamed:@"fly.png"];
    SKAction *makeBugs = [SKAction sequence:@[
                                              [SKAction performSelector:@selector(addBug) onTarget:self],
                                              [SKAction waitForDuration:1.8 withRange:1.6]]];
    [self runAction: [SKAction repeatActionForever:makeBugs]];
    
    bread.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bread.size.width, bread.size.height)];
    bread.physicsBody.dynamic = NO;
    
    killer.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:killer.size.width/2];
    killer.physicsBody.dynamic = NO;
    
    self.physicsWorld.gravity = CGVectorMake(0, -9.8*0.02);

    tx_bullet = [SKTexture textureWithImageNamed:@"bullet.png"];
    
    bread.physicsBody.categoryBitMask = mask_bread;
    bread.physicsBody.collisionBitMask = 0;
    
    killer.physicsBody.categoryBitMask = mask_killer;
    killer.physicsBody.collisionBitMask = 0;
    
    self.physicsWorld.contactDelegate = self;
    
    SKLabelNode *scoreTitleNode = [SKLabelNode labelNodeWithFontNamed:@"Baskerville-Bold"];
    scoreTitleNode.fontSize = 20;
    scoreTitleNode.fontColor = [SKColor colorWithWhite:0.0 alpha:1.0];
    scoreTitleNode.text = @"SCORE";
    scoreTitleNode.position = CGPointMake((scoreTitleNode.frame.size.width/2)+20, self.frame.size.height-30);
    [self addChild:scoreTitleNode];
    
    scoreNode = [SKLabelNode labelNodeWithFontNamed:@"Baskerville-Bold"];
    scoreNode.fontSize = 20;
    scoreNode.fontColor = [SKColor colorWithWhite:0.0 alpha:.8];
    scoreNode.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height-30);
    [self addChild:scoreNode];
    
    self.score = 0;
}

-(void)makeFireParticle:(CGPoint)point
{
	if(_particleFire==nil){
		NSString *path = [[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"sks"];
		_particleFire = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
		_particleFire.numParticlesToEmit = 50;
		[self addChild:_particleFire];
	}
	else{
		[_particleFire resetSimulation];
	}
	_particleFire.position = point;
}

-(void)makeSparkParticle:(CGPoint)point
{
	if(_particleSpark==nil){
		NSString *path = [[NSBundle mainBundle] pathForResource:@"Spark" ofType:@"sks"];
		_particleSpark = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
		_particleSpark.numParticlesToEmit = 50;
		[self addChild:_particleSpark];
	}
	else{
		[_particleSpark resetSimulation];
	}
	_particleSpark.position = point;
}


-(void)makeImpactParticle:(CGPoint)point
{
	if(_particleBom==nil){
		NSString *path = [[NSBundle mainBundle] pathForResource:@"Bom" ofType:@"sks"];
		_particleBom = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
		_particleBom.numParticlesToEmit = 350;
		[self addChild:_particleBom];
	}
	else{
		[_particleBom resetSimulation];
	}
	_particleBom.position = point;
}
-(void)makeImpactEndParticle:(CGPoint)point
{
	if(_particleSmoke==nil){
		NSString *path = [[NSBundle mainBundle] pathForResource:@"Smoke" ofType:@"sks"];
		_particleSmoke = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
		_particleSmoke.numParticlesToEmit = 100;
		[self addChild:_particleSmoke];
	}
	else{
		[_particleBom resetSimulation];
	}
	_particleSmoke.position = point;
}

-(void)addBug
{
    if (gameover) {
        return;
    }
    
    SKSpriteNode *bug = [SKSpriteNode spriteNodeWithTexture:tx_bug];
    
    CGFloat rx = (rand()/(CGFloat)RAND_MAX) * ((self.size.width - 40.0) - 20.0) + 20.0;
    bug.position = CGPointMake(rx, self.size.height+10);
    bug.name = BUG;
    
    bug.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bug.size.width/2];
    [self addChild:bug];
    
    bug.physicsBody.categoryBitMask = mask_bug;
    bug.physicsBody.contactTestBitMask = mask_killer|mask_bread;
    bug.physicsBody.collisionBitMask = mask_bullet|mask_killer|mask_bread;
    
    // Spark! 派手過ぎ？
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Spark" ofType:@"sks"];
	SKEmitterNode	*fireSpark = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	fireSpark.position = CGPointMake(0, 0);
	fireSpark.particleLifetime = 0.3;
	fireSpark.particleBirthRate = 500;
	fireSpark.emissionAngle = (M_PI/2);
	fireSpark.emissionAngleRange = 0;
	fireSpark.particlePositionRange = CGVectorMake(10, 10);
	fireSpark.particleAlpha = 0.4;
	fireSpark.particleAlphaRange = 0.0;
	fireSpark.particleAlphaSpeed = -0.3;
	[bug addChild:fireSpark];
	fireSpark.targetNode = self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(gameover) return;
    if(killer_is_rotating) return;
    
    SKNode *killer = [self childNodeWithName:KILLER];
    CGPoint location = [[touches anyObject] locationInNode:self];
    CGPoint killerLocation = killer.position;
    
    CGFloat r = -(atan2f(location.x - killerLocation.x, location.y - killerLocation.y));
    CGFloat d = fabsf(killer.zPosition-r);
    NSTimeInterval t = d * 0.3;
    
    killer_is_rotating = YES;
    SKAction *rotate = [SKAction rotateToAngle:r duration:t];
    [killer runAction:rotate completion:^{
        killer_is_rotating = NO;
        
        SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithTexture:tx_bullet];
        bullet.position  = killerLocation;
        bullet.name = BULLET;
        [self addChild:bullet];
        
        bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.size];
        bullet.zRotation = r;
        bullet.physicsBody.velocity = CGVectorMake(-400*sin(r), 400*cos(r));
        
        bullet.physicsBody.categoryBitMask = mask_bullet;
        bullet.physicsBody.contactTestBitMask = mask_bug;
        bullet.physicsBody.collisionBitMask = mask_bug;
        
        // Spark!
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Spark" ofType:@"sks"];
        SKEmitterNode *fireSpark = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        fireSpark.position = CGPointMake((bullet.size.width/2)-7, -(bullet.size.height/2));
        fireSpark.particleLifetime = 0.1;
        fireSpark.numParticlesToEmit = 50;
        fireSpark.particleBirthRate = 200;
        fireSpark.emissionAngle = -(M_PI/2);
        fireSpark.emissionAngleRange = 0;
        fireSpark.particlePositionRange = CGVectorMake(0, 0);
        
        [bullet addChild:fireSpark];
    }];
}

-(void)didSimulatePhysics
{
    // Remove outranged nodes. Is it needed?
    [self enumerateChildNodesWithName:BUG usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0 || node.position.x < 0 || node.position.x > 320) {
            [node removeFromParent];
        }
    }];

    [self enumerateChildNodesWithName:BULLET usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y > self.frame.size.height || node.position.y < 0 || node.position.x < 0 || node.position.x > 320) {
            [node removeFromParent];
        }
    }];

}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    NSString *a = contact.bodyA.node.name;
    
    if ([a isEqualToString:BREAD]) {
        // ハエがパンに！
        
        [self makeImpactParticle:contact.contactPoint];
        [self makeImpactEndParticle:contact.contactPoint];
        
        [self showGameOver];
    } else if([a isEqualToString:KILLER]){
        // ハエが殺虫剤に！
        [contact.bodyA.node removeFromParent];
        
        [self makeImpactParticle:contact.contactPoint];
        [self makeImpactEndParticle:contact.contactPoint];
        
        [self showGameOver];
    }else if([a isEqualToString:BULLET]){
        // ヒット！
        [contact.bodyA.node removeFromParent];
        
		[self makeFireParticle:contact.contactPoint];
		[self makeSparkParticle:contact.contactPoint];
        
        self.score += 10;
        scoreNode.text = [NSString stringWithFormat:@"%d",self.score];
    }
    
    [contact.bodyB.node removeFromParent];
    
}

-(void)showGameOver
{
    if (gameover) return;
    gameover = YES;
    SKLabelNode *gameoverLabel = [SKLabelNode labelNodeWithFontNamed:@"Baskerville-Bold"];
    gameoverLabel.text = @"GAME OVER";
    gameoverLabel.fontSize = 40;
    gameoverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+50);
    [self addChild:gameoverLabel];
}

@end
