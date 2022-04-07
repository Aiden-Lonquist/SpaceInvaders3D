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

@interface MainViewController ()
{
    //Audio player
    AVAudioPlayer *player;
    
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
    NSMutableArray *aliens;
    
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
    
    // Swipe variables
    float firstX;

}

@property (strong, nonatomic) GLKBaseEffect* effect;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Player ship variables
    _drawShip = true;
    _shipXPosition = 0.0f;
    _shipYPosition = -3.0f;
    _shipZPosition = -5.0f;
    _shipXRotation = 90.0f;
    _shipYRotation = 0.0f;
    _shipZRotation = 0.0f;
    _shipXScale = 0.1f;
    _shipYScale = 0.1f;
    _shipZScale = 0.1f;
    
    // Alien variables
    _drawAlien = true;
    _alienXPosition = 0.0f;
    _alienYPosition = 4.2f;
    _alienZPosition = -5.0f;
    _alienXRotation = 90.0f;
    _alienYRotation = 180.0f;
    _alienZRotation = 0.0f;
    _alienXScale = 0.1f;
    _alienYScale = 0.1f;
    _alienZScale = 0.1f;
    _alienMovingRight = true;
    
    // Bullet variables
    _drawBullet = false;
    _bulletXPosition = 0.0f;
    _bulletYPosition = -5.0f;
    _bulletZPosition = -5.1f;
    _bulletXRotation = 90.0f;
    _bulletYRotation = 0.0f;
    _bulletZRotation = 0.0f;
    _bulletXScale = 0.15f;
    _bulletYScale = 0.15f;
    _bulletZScale = 0.15f;

    
    // Score at start
    _score = 0;
    
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
    
    // Alien
    if (_drawAlien) {
        [self drawAlien: _alienXPosition: _alienYPosition: _alienZPosition: _alienXRotation: _alienYRotation: _alienZRotation: _alienXScale: _alienYScale: _alienZScale];
    }
    
    // Bullet
    if (_drawBullet) {
        [self drawBullet: _bulletXPosition: _bulletYPosition: _bulletZPosition: _bulletXRotation: _bulletYRotation: _bulletZRotation: _bulletXScale: _bulletYScale: _bulletZScale];
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

//- (void)shoot
//{
//    _drawBullet = true;
//}

- (IBAction)shoot:(UITapGestureRecognizer *)sender
{
    if (!_drawBullet) {
        _bulletYPosition = _shipYPosition;
        _bulletXPosition = _shipXPosition;
        _drawBullet = true;
        //sound effect for shooting
        NSString *path = [[NSBundle mainBundle] pathForResource:@"shoot"ofType:@"wav"];
        NSURL *url = [NSURL URLWithString:path];
        player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:NULL];
        
        [player play];
    } else{
        [player stop];
    }
}

-(void)handlePan:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:self.view];
    _shipXPosition += translation.x/55;
    [sender setTranslation:CGPointZero inView:self.view];
}


//- (IBAction)btn_Audio_play:(id)sender{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"shoot"ofType:@"wav"];
//    NSURL *url = [NSURL URLWithString:path];
//    player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:NULL];
//
//    [player play];
//}


- (void)update
{
    NSString* scoreString = [NSString stringWithFormat:@"Score: %i", _score];
    _scoreLabel.text = scoreString;
    if (_drawBullet) {
        if (_bulletYPosition < 5.0f) {
            _bulletYPosition += 0.2f;
            [self collisionCheck];
        }
        if (_bulletYPosition >= 5.0f) {
            _drawBullet = false;
        }
    }
    
    if (_alienMovingRight) {
        _alienXPosition += 0.05f;
        if (_alienXPosition > 2.5f) {
            _alienMovingRight = false;
            _alienYPosition -= 0.5f;
        }
    } else if (!_alienMovingRight) {
        _alienXPosition -= 0.05f;
        if (_alienXPosition < -2.5f) {
            _alienMovingRight = true;
            _alienYPosition -= 0.5f;
        }
    }
    
//    _xRotation += 1.0f;
//    _yRotation += 1.0f;
//    _zRotation += 1.0f;
}

- (void)collisionCheck
{
    float distanceX = fabsf(_alienXPosition-_bulletXPosition);
    float distanceY = fabsf(_alienYPosition-_bulletYPosition);
    
    if (distanceX < 0.5 && distanceY < 0.2) {
        _drawAlien = false;
        _drawBullet = false;
        _score += 1;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"hit"ofType:@"wav"];
        NSURL *url = [NSURL URLWithString:path];
        player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:NULL];
        
        [player play];
        [self spawnAlien];
    }
}

-(void)spawnAlien
{
    NSTimeInterval delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      //NSLog(@"Do some work");
        _drawAlien = true;
    });
}

@end
