//
//  AppDelegate.h
//  GLBlender2
//
//  Reference: Created by RRC on 7/5/13.
//  Copyright (c) 2013 Ricardo Rendon Cepeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    AVAudioPlayer *audioPlayer;
}

@property (strong, nonatomic) UIWindow *window;

@end
