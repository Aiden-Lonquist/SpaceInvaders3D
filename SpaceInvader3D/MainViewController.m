//
//  MainViewController.m
//  GLBlender2
//
//  Reference: Created by RRC on 7/5/13.
//  Copyright (c) 2013 Ricardo Rendon Cepeda. All rights reserved.
//

#import "MainViewController.h"
#import "Ship.h"
#import "Alien.h"
#import "Bullet.h"
//Import header file for model to use here
const int numAliens = 10;
const int numBullets = 5;

@interface MainViewController ()
{
    Alien alienArray[numAliens];
//    NSMutableArray *bulletArray;
    Bullet bulletArray[numBullets];
    
    //Audio player
//    AVAudioPlayer *player;
    AVAudioPlayer *bulletSoundPlayer[numBullets];
    AVAudioPlayer *hitSoundPlayer[numAliens];
    
    // Player ship variables
    bool    _drawShip;
    float   _shipXPosition;
    float   _shipYPosition;
    float   _shipZPosition;
    float   _shipXRotation;
    float   _shipYRotation;
    float   _shipZRotation;
    float   _shipXScale;
    float   _shipYScale;
    float   _shipZScale;
    
    // Alien variables for one alien
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
    
    // Alien wave variables
//    NSMutableArray *aliens;
    
    // Bullet variables for one bullet
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
    
    // Score label variables;
    int     _score;
    int     _highScore;
    float   _difficultyMultiplier;
    float   _timer;
    bool    _isGameOver;
    
    // Swipe variables
    float firstX;


}

@property (strong, nonatomic) GLKBaseEffect* effect;

@end

@implementation MainViewController

-(void)setUpBullets
{
    for (int newBullet = 0; newBullet < numBullets; newBullet++) {
        Bullet initBullet = {
                ._drawBullet = false,
                ._bulletXPosition = 0.0f,
                ._bulletYPosition = -5.0f,
                ._bulletZPosition = -5.1f,
                ._bulletXRotation = 90.0f,
                ._bulletYRotation = 0.0f,
                ._bulletZRotation = 0.0f,
                ._bulletXScale = 0.15f,
                ._bulletYScale = 0.15f,
                ._bulletZScale = 0.15f
        };
//        [bulletArray addObject:&initBullet];
        bulletArray[newBullet] = initBullet;
    }
}

-(void)setUpAliens
{
    int currentRow = 0;
    float rowIncrement = 1.0f;
    for (int newAlien = 0; newAlien < numAliens; newAlien++) {
        if (newAlien % 5 == 0 && newAlien != 0) {
            currentRow++;
        }
        Alien initAlien = {
            ._drawAlien = true,
            ._alienXPosition = -2.0f + (1.0f * newAlien),
            ._alienYPosition = 4.2f + (rowIncrement * currentRow),
            ._alienZPosition = -5.0f,
            ._alienXRotation = 80.0f, //was 90
            ._alienYRotation = 180.0f,
            ._alienZRotation = 0.0f,
            ._alienXScale = 0.06f, //was 0.1
            ._alienYScale = 0.06f, //was 0.1
            ._alienZScale = 0.06f, //was 0.1
            ._alienMovingRight = true
        };
        alienArray[newAlien] = initAlien;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpAliens];

    [self setUpBullets];
    
    // Player ship variables
    _drawShip = true;
    _shipXPosition = 0.0f;
    _shipYPosition = -3.0f;
    _shipZPosition = -5.0f;
    _shipXRotation = 50.0f; //was 90
    _shipYRotation = 0.0f;
    _shipZRotation = 0.0f;
    _shipXScale = 0.1f;
    _shipYScale = 0.1f;
    _shipZScale = 0.1f;
    
    // Score at start
    _score = 0;
    _difficultyMultiplier = 1.0f;
    _timer = 0;
    
    _isGameOver = false;
    _btnRestart.enabled = false;
    _btnRestart.hidden = true;
    [_btnRestart addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
    
    // High score retrieval
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *stringHighScore = [prefs stringForKey:@"highScore"];
    _highScore = [stringHighScore intValue];
    
    // Set up context
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    // Set up view
    GLKView* glkView = (GLKView *) self.view;
    glkView.context = context;
    
    // OpenGL ES Settings
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glEnable(GL_CULL_FACE);
    
    // Create effect
    [self createEffect];
    
    //create pan gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self  action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
    
}

- (void)createEffect
{
    // Initialize
    self.effect = [[GLKBaseEffect alloc] init];
    
    // Light (Use to change position of light)
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.position = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.effect.lightingType = GLKLightingTypePerPixel;
    
    // Use to change light specular and diffuse color
    self.effect.light0.specularColor = GLKVector4Make(0.25f, 0.25f, 0.25f, 1.0f);
    self.effect.light0.diffuseColor = GLKVector4Make(0.75f, 0.75f, 0.75f, 1.0f);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Player ship
    if (_drawShip) {
        [self drawShip: _shipXPosition: _shipYPosition: _shipZPosition: _shipXRotation: _shipYRotation: _shipZRotation: _shipXScale: _shipYScale: _shipZScale];
    }
    
    for (int a = 0; a < numAliens; a++) {
        if (alienArray[a]._drawAlien) {
            [self drawAlien:alienArray[a]._alienXPosition :alienArray[a]._alienYPosition :alienArray[a]._alienZPosition :alienArray[a]._alienXRotation :alienArray[a]._alienYRotation :alienArray[a]._alienZRotation :alienArray[a]._alienXScale :alienArray[a]._alienYScale :alienArray[a]._alienZScale];
        }
    }
    
    for (int b = 0; b < numBullets; b++) {
        if (bulletArray[b]._drawBullet) {
            [self drawBullet:bulletArray[b]._bulletXPosition :bulletArray[b]._bulletYPosition :bulletArray[b]._bulletZPosition :bulletArray[b]._bulletXRotation :bulletArray[b]._bulletYRotation :bulletArray[b]._bulletZRotation :bulletArray[b]._bulletXScale :bulletArray[b]._bulletYScale :bulletArray[b]._bulletZScale];
        }
    }
}

- (void)drawBullet: (float)xPos: (float)yPos: (float)zPos: (float)xRot: (float)yRot: (float)zRot: (float)x_Scale: (float)y_Scale: (float)z_Scale
{
    // Projection Matrix
    const GLfloat aspectRatio = (GLfloat)(self.view.bounds.size.width) / (GLfloat)(self.view.bounds.size.height);
    const GLfloat fieldView = GLKMathDegreesToRadians(90.0f);
    const GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(fieldView, aspectRatio, 0.1f, 10.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    // ModelView Matrix (Perform functions to change position, rotation and scale here)
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, xPos, yPos, zPos); // For Position, Rotation and Scale use individual variables for each object.
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(xRot));
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(yRot));
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, GLKMathDegreesToRadians(zRot));
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, x_Scale, y_Scale, z_Scale);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    
    // Positions
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, BulletPositions);
    
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, BulletNormals);
    
    for(int i=0; i<BulletMaterials; i++)
    {
        // Set material
        self.effect.material.diffuseColor = GLKVector4Make(BulletDiffuses[i][0], BulletDiffuses[i][1], BulletDiffuses[i][2], 1.0f);
        self.effect.material.specularColor = GLKVector4Make(BulletSpeculars[i][0], BulletSpeculars[i][1], BulletSpeculars[i][2], 1.0f);

        // Prepare effect
        [self.effect prepareToDraw];

        // Draw vertices
        glDrawArrays(GL_TRIANGLES, BulletFirsts[i], BulletCounts[i]);
    }
}

- (void)drawShip: (float)xPos: (float)yPos: (float)zPos: (float)xRot: (float)yRot: (float)zRot: (float)x_Scale: (float)y_Scale: (float)z_Scale
{
    // Projection Matrix
    const GLfloat aspectRatio = (GLfloat)(self.view.bounds.size.width) / (GLfloat)(self.view.bounds.size.height);
    const GLfloat fieldView = GLKMathDegreesToRadians(90.0f);
    const GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(fieldView, aspectRatio, 0.1f, 10.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    // ModelView Matrix (Perform functions to change position, rotation and scale here)
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, xPos, yPos, zPos); // For Position, Rotation and Scale use individual variables for each object.
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(xRot));
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(yRot));
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, GLKMathDegreesToRadians(zRot));
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, x_Scale, y_Scale, z_Scale);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    
    // Positions
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, ShipPositions);
    
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, ShipNormals);
    
    for(int i=0; i<ShipMaterials; i++)
    {
        // Set material
        self.effect.material.diffuseColor = GLKVector4Make(ShipDiffuses[i][0], ShipDiffuses[i][1], ShipDiffuses[i][2], 1.0f);
        self.effect.material.specularColor = GLKVector4Make(ShipSpeculars[i][0], ShipSpeculars[i][1], ShipSpeculars[i][2], 1.0f);

        // Prepare effect
        [self.effect prepareToDraw];

        // Draw vertices
        glDrawArrays(GL_TRIANGLES, ShipFirsts[i], ShipCounts[i]);
    }
}

- (void)drawAlien: (float)xPos: (float)yPos: (float)zPos: (float)xRot: (float)yRot: (float)zRot: (float)x_Scale: (float)y_Scale: (float)z_Scale
{
    // Projection Matrix
    const GLfloat aspectRatio = (GLfloat)(self.view.bounds.size.width) / (GLfloat)(self.view.bounds.size.height);
    const GLfloat fieldView = GLKMathDegreesToRadians(90.0f);
    const GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(fieldView, aspectRatio, 0.1f, 10.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    // ModelView Matrix (Perform functions to change position, rotation and scale here)
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, xPos, yPos, zPos); // For Position, Rotation and Scale use individual variables for each object.
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(xRot));
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(yRot));
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, GLKMathDegreesToRadians(zRot));
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, x_Scale, y_Scale, z_Scale);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    
    // Positions
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, AlienPositions);
    
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, AlienNormals);
    
    for(int i=0; i<AlienMaterials; i++)
    {
        // Set material
        self.effect.material.diffuseColor = GLKVector4Make(AlienDiffuses[i][0], AlienDiffuses[i][1], AlienDiffuses[i][2], 1.0f);
        self.effect.material.specularColor = GLKVector4Make(AlienSpeculars[i][0], AlienSpeculars[i][1], AlienSpeculars[i][2], 1.0f);

        // Prepare effect
        [self.effect prepareToDraw];

        // Draw vertices
        glDrawArrays(GL_TRIANGLES, AlienFirsts[i], AlienCounts[i]);
    }
}


- (IBAction)shoot:(UITapGestureRecognizer *)sender
{
    for (int b = 0; b < numBullets; b++) {
        if (!bulletArray[b]._drawBullet) {
            bulletArray[b]._bulletYPosition = _shipYPosition;
            bulletArray[b]._bulletXPosition = _shipXPosition;
            bulletArray[b]._drawBullet = true;
            //sound effect for shooting
            NSString *path = [[NSBundle mainBundle] pathForResource:@"shoot"ofType:@"wav"];
            NSURL *url = [NSURL URLWithString:path];
            bulletSoundPlayer[b] = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:NULL];
            
            [bulletSoundPlayer[b] play];
            break;
        } else {
            [bulletSoundPlayer[b] stop];
        }
    }
}

-(void)handlePan:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:self.view];
    if (_shipXPosition > 2.5)
    {
        _shipXPosition = 2.5;
    } else if (_shipXPosition < -2.5)
    {
        _shipXPosition = -2.5;
    } else
    {
        _shipXPosition += translation.x/55;
    }
    [sender setTranslation:CGPointZero inView:self.view];
}



- (void)update
{
    if (_isGameOver) {
        return;
    }
    
    if (_score > _highScore) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString* newHighScore = [NSString stringWithFormat:@"%i", _score];
        [prefs setObject:newHighScore forKey:@"highScore"];
        _highScore = _score;
    }
    
    NSString* scoreString = [NSString stringWithFormat:@"Score: %i", _score];
    _scoreLabel.text = scoreString;
    NSString* highScoreString = [NSString stringWithFormat:@"%i :High Score", _highScore];
    _highScoreLabel.text = highScoreString;
    
    for (int bulletToFire = 0; bulletToFire < numBullets; bulletToFire++) {
        if (bulletArray[bulletToFire]._drawBullet) {
            bulletArray[bulletToFire]._bulletYPosition += 0.2f;
            [self collisionCheck];
        }
        if (bulletArray[bulletToFire]._bulletYPosition >= 5.0f) {
            bulletArray[bulletToFire]._drawBullet = false;
        }
    }
    
    for (int alienToMove = 0; alienToMove < numAliens; alienToMove++) {
        if (alienArray[alienToMove]._alienMovingRight) {
            alienArray[alienToMove]._alienXPosition += 0.05f*_difficultyMultiplier;
            if (alienArray[alienToMove]._alienXPosition > 2.5f) {
                alienArray[alienToMove]._alienMovingRight = false;
                alienArray[alienToMove]._alienYPosition -= 0.5f;
//                alienArray[alienToMove]._alienXScale += 0.004;
//                alienArray[alienToMove]._alienYScale += 0.004;
//                alienArray[alienToMove]._alienZScale += 0.004;
            }
        } else if (!alienArray[alienToMove]._alienMovingRight) {
            alienArray[alienToMove]._alienXPosition -= 0.05f*_difficultyMultiplier;
            if (alienArray[alienToMove]._alienXPosition < -2.5f) {
                alienArray[alienToMove]._alienMovingRight = true;
                alienArray[alienToMove]._alienYPosition -= 0.5f;
//                alienArray[alienToMove]._alienXScale += 0.004;
//                alienArray[alienToMove]._alienYScale += 0.004;
//                alienArray[alienToMove]._alienZScale += 0.004;
            }
        }
        if (alienArray[alienToMove]._alienYPosition < -5.0f) {
            // Either reset aliens here or set lose condition.
            alienArray[alienToMove]._alienYPosition = 5.0f;
        }
    }
    
    //linear timer
    if (_difficultyMultiplier < 4)
    {
        _difficultyMultiplier += 0.0005;
    }
    
    //parabolic timer (linear felt better to play)
    //_timer += 0.01;
    //_difficultyMultiplier = -3 * pow((1/(_timer/2 + 1)), 0.1) +4;
    
    //difficulty check
    //NSLog(@"the difficulty: _difficultyMultiplier = %f", _difficultyMultiplier);
    
    // Check if the player lost
    [self collisionCheckLose];
}

- (void)collisionCheck
{
    for (int alienShip = 0; alienShip < numAliens; alienShip++) {
        for (int bulletNumber = 0; bulletNumber < numBullets; bulletNumber++) {
            if (alienArray[alienShip]._drawAlien && bulletArray[bulletNumber]._drawBullet) {
                float distanceX = fabsf(alienArray[alienShip]._alienXPosition-bulletArray[bulletNumber]._bulletXPosition);
                float distanceY = fabsf(alienArray[alienShip]._alienYPosition-bulletArray[bulletNumber]._bulletYPosition);
                
                if (distanceX < 0.3 && distanceY < 0.2) {
                    alienArray[alienShip]._drawAlien = false;
                    bulletArray[bulletNumber]._drawBullet = false;
                    _score += 1;
                    NSString *path = [[NSBundle mainBundle] pathForResource:@"hit"ofType:@"wav"];
                    NSURL *url = [NSURL URLWithString:path];
                    hitSoundPlayer[alienShip] = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:NULL];
                    
                    [hitSoundPlayer[alienShip] play];
                    [self spawnAlien: alienShip];
                }
            }
        }
    }
}

-(void)spawnAlien : (int)shipNumber
{
    NSTimeInterval delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      //NSLog(@"Do some work");
        alienArray[shipNumber]._alienYPosition = 4.2;
        alienArray[shipNumber]._alienXScale = 0.06;
        alienArray[shipNumber]._alienYScale = 0.06;
        alienArray[shipNumber]._alienZScale = 0.06;
        alienArray[shipNumber]._drawAlien = true;
    });
}

- (void)collisionCheckLose
{
    for (int alienShipNumber = 0; alienShipNumber < numAliens; alienShipNumber++) {
        float distanceX = fabsf(alienArray[alienShipNumber]._alienXPosition-_shipXPosition);
        float distanceY = fabsf(alienArray[alienShipNumber]._alienYPosition-_shipYPosition);
        
        if (distanceX < 0.5 && distanceY < 0.2) {
            _drawShip = false;
            for (int clearAlienNumber = 0; clearAlienNumber < numAliens; clearAlienNumber++) {
                alienArray[clearAlienNumber]._drawAlien = false;
            }
//            _drawAlien = false;
            for (int clearBulletNumber = 0; clearBulletNumber < numBullets; clearBulletNumber++) {
                bulletArray[clearBulletNumber]._drawBullet = false;
            }
//            _drawBullet = false;
            
            _isGameOver = true;
            _btnRestart.enabled = true;
            _btnRestart.hidden = false;
            
            NSString* gameOverString = [NSString stringWithFormat:@"Game Over"];
            _gameOverLabel.text = gameOverString;
        }
    }
}

- (void)restartGame
{
    _shipXPosition = 0.0f;
    _shipYPosition = -3.0f;
    _drawShip = true;
    
//    for (int alienToReset = 0; alienToReset < numAliens; alienToReset++) {
//        alienArray[alienToReset] = NULL;
//    }
    
    [self setUpAliens];
    
//    _alienXPosition = 0.0f;
//    _alienYPosition = 4.2f;
//    _drawAlien = true;
    
    _score = 0;
    _difficultyMultiplier = 1.0f;
    _timer = 0;
    _isGameOver = false;
    
    _btnRestart.enabled = false;
    _btnRestart.hidden = true;
    _gameOverLabel.text = @"";
}
@end
