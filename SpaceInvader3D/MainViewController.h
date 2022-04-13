//
//  MainViewController.h
//  GLBlender2
//
//  Reference: Created by RRC on 7/5/13.
//  Copyright (c) 2013 Ricardo Rendon Cepeda. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MainViewController : GLKViewController

typedef struct Bullet {
    bool    _drawBullet;
    float   _bulletXPosition;
    float   _bulletYPosition;
    float   _bulletZPosition;
    float   _bulletXRotation;
    float   _bulletYRotation;
    float   _bulletZRotation;
    float   _bulletXScale;
    float   _bulletYScale;
    float   _bulletZScale;
} Bullet;

typedef struct Alien {
    bool    _drawAlien;
    float   _alienXPosition;
    float   _alienYPosition;
    float   _alienZPosition;
    float   _alienXRotation;
    float   _alienYRotation;
    float   _alienZRotation;
    float   _alienXScale;
    float   _alienYScale;
    float   _alienZScale;
    bool    _alienMovingRight;
    bool    _alienDestroyed;
} Alien;

@property int aliensToSpawn;

@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *highScoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *gameOverLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnRestart;
@end
