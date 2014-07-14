//
//  EUPlaybackInfoView.h
//  EUPlaybackInfoView
//
//  Created by Esteban Uribe on 6/27/13.
//  Copyright (c) 2013 Esteban Uribe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EUPlaybackInfoViewDelegate <NSObject>
- (NSTimeInterval)currentTime;
- (void)setCurrentTime:(float)time;
- (NSTimeInterval)remainingTime;
- (BOOL)playing;
- (void)setPlaying:(BOOL)playing;
@optional
- (NSString *)podcastInfo;
- (void)startScrubbing;
- (void)endScrubbing;
@end

typedef enum EUPlaybackState {
    EUPlaybackStatePlaying,
    EUPlaybackStatePaused
} EUPlaybackState;

@interface EUPlaybackInfoView:UIView<EUPlaybackInfoViewDelegate> {
    EUPlaybackState playbackState;
    UILabel *currentTimeLabel;
    UILabel *remainingTimeLabel;
    UILabel *podcastInfoLabel;
    UISlider *playtimeSlider;
    UIButton *playbackButton;
}

@property (nonatomic, weak) id<EUPlaybackInfoViewDelegate>delegate;

- (void)refresh;

@end