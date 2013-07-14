//
//  EUPlaybackInfoViewController.h
//  EUPlaybackInfoView
//
//  Created by Esteban Uribe on 6/27/13.
//  Copyright (c) 2013 Esteban Uribe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EUPlaybackInfoView.h"

@protocol EUPlaybackInfoViewControllerDelegate <NSObject>
- (void)playStateForEpisode:(NSInteger)index playing:(BOOL)playing;
@end

@interface EUPlaybackInfoViewController : UIViewController<EUPlaybackInfoViewDelegate>{
    EUPlaybackInfoView *_playbackView;
    NSTimeInterval currentTime;
    NSTimeInterval totalTime;
    NSTimeInterval remainingTime;
    
    NSTimer *repeatingTimer;
}

@property (nonatomic, weak) id delegate;
@property (readonly) BOOL scrubbing;

@end
