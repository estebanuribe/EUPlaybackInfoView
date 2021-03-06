//
//  EUPlaybackInfoViewController.m
//  EUPlaybackInfoView
//
//  Created by Esteban Uribe on 6/27/13.
//  Copyright (c) 2013 Esteban Uribe. All rights reserved.
//

#import "EUPlaybackInfoViewController.h"

@interface EUPlaybackInfoViewController ()

@end

@implementation EUPlaybackInfoViewController

- (id)init {
    self = [super init];
    if (self) {
        currentTime = 0.0;
        totalTime = 3600.0;
        remainingTime = totalTime;
    }
    return self;
}

- (void)loadView {
//    [super loadView];
//    self.view.backgroundColor = [UIColor whiteColor];
//    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    _playbackView = [[EUPlaybackInfoView alloc] init];
    _playbackView.translatesAutoresizingMaskIntoConstraints = NO;
    _playbackView.delegate = self;
    _playbackView.hidden = YES;
    
    [self setView:_playbackView];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [parent.view addSubview:self.view];
    [parent.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:parent.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [parent.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom     relatedBy:NSLayoutRelationEqual toItem:parent.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [parent.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth  relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.view.frame.size.width]];
    [parent.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight  relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.view.frame.size.height]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)timeElapsed:(NSDictionary *)userInfo {
    remainingTime = remainingTime - 1.0;
    currentTime = totalTime - remainingTime;
    [_playbackView refresh];
}

#pragma mark - EUPlyabackInfoView delegate
- (NSTimeInterval)remainingTime {
    return remainingTime;
}

- (NSTimeInterval)currentTime {
    return currentTime;
}

- (void)setCurrentTime:(float)time {
    currentTime = time;
    remainingTime = totalTime - currentTime;
}

- (void)startScrubbing {
    if (repeatingTimer) {
        [repeatingTimer invalidate];
        repeatingTimer = nil;
    }
}

- (void)endScrubbing {
    if(!repeatingTimer) {
        repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeElapsed:) userInfo:nil repeats:YES];
    }
}

- (BOOL)playing {
    return (repeatingTimer && [repeatingTimer isValid]);
}

- (void)animatePlayViewSlideOut {
    if (_playbackView.hidden) {
        CGRect frame = _playbackView.frame;
        CGRect overshotFrame = frame;
        frame.origin.y += CGRectGetMaxY(frame);
        
        overshotFrame.origin.y -= 10;
        overshotFrame.size.height += 10;
        _playbackView.frame = frame;
        _playbackView.hidden = NO;
        
        [UIView animateWithDuration:0.5 animations:^{
            _playbackView.frame = overshotFrame;
        } completion:^(BOOL finished) {
            CGRect reconstructed = _playbackView.frame;
            
            reconstructed.origin.y += 10;
            reconstructed.size.height -= 10;
            [UIView animateWithDuration:0.1 animations:^{
                _playbackView.frame = reconstructed;
            }];
        }];
    }
}

- (void)setPlaying:(BOOL)playing {
    [self animatePlayViewSlideOut];
    
    if (!playing) {
        [repeatingTimer invalidate];
        repeatingTimer = nil;
    } else if (!repeatingTimer) {
        repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeElapsed:) userInfo:nil repeats:YES];
    }
}

- (NSString *)podcastInfo {
    return @"Cool podcast";
}

@end
