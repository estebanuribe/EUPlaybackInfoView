//
//  EUPlaybackInfoView.m
//  EUPlaybackInfoView
//
//  Created by Esteban Uribe on 6/27/13.
//  Copyright (c) 2013 Esteban Uribe. All rights reserved.
//

#import "EUPlaybackInfoView.h"


#define kPlayingString @"Playing"

#define kViewWidth 320.0
#define kViewHeight 56.0

#define kPlaybackButtonLead 8.0
#define kPlaybackButtonTop 4.0
#define kPlaybackButtonWidth 32.0
#define kPlaybackButtonHeight 32.0

#define kPlaytimeSliderLead 48.0
#define kPlaytimeSliderTop 20.0
#define kPlaytimeSliderWidth 260.0
#define kPlaytimeSliderHeight 14.0

#define kCurrentLabelLead 48.0
#define kCurrentLabelTop 4.0
#define kRemainingLabelLead 244.0
#define kRemainingLabeTop 4.0
#define kLabelWidth 64.0
#define kLabelHeight 16.0

#define kPodcastInfoLabelLead 48.0
#define kPodcastInfoLabelTop 36.0
#define kPodcastInfoLabelWidth 260.0
#define kPodcastInfoLabelHeight 16.0

#define kLabelFontName @"Helvetica-Light"
#define kLabelFontSize 12.0
#define kLabelUIFont [UIFont fontWithName:kLabelFontName size:kLabelFontSize]

//#define CONSTRAINTDEBUG

@interface UIView(PRIVATE)
- (void)addConstraintsForSubView:(UIView *)view bounds:(CGRect)bounds;
@end

@implementation UIView(PRIVATE)
- (void)addConstraintsForSubView:(UIView *)view bounds:(CGRect)bounds {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:view];
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(view);
    NSDictionary *metricDict = @{@"lead": @(bounds.origin.x), @"top":@(bounds.origin.y), @"width":@(bounds.size.width), @"height":@(bounds.size.height)};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-lead-[view(width)]" options:0 metrics:metricDict views:viewsDict];
    [self addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[view(height)]" options:0 metrics:metricDict views:viewsDict];
    [self addConstraints:constraints];
    
#ifdef CONSTRAINTDEBUG
    NSLog(@"constraint: %@", constraints);
#endif
}
@end

@interface NSString(PRIVATE)
+ (NSString *)timeStringFromNSTimeInterval:(NSTimeInterval)time;
@end

@implementation NSString(PRIVATE)
+ (NSString *)timeStringFromNSTimeInterval:(NSTimeInterval)time {
    if (!time) return @"0:00:00";
    NSUInteger hours = 0, minutes = 0, seconds = 0;
    hours = time / 60 / 60;
    minutes = time / 60 - hours * 60;
    seconds = time - (hours * 3600) - (minutes * 60);
    
    return [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
}
@end

@implementation EUPlaybackInfoView
- (id)init {
    CGRect frame = CGRectMake(0, 0, kViewWidth, kViewHeight);
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.backgroundColor = [UIColor darkGrayColor];
        playbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *image = [UIImage imageNamed:@"PlayPodcastButton"];
        [playbackButton setImage:image forState:UIControlStateNormal];
        [playbackButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        [self addConstraintsForSubView:playbackButton bounds:CGRectMake(kPlaybackButtonLead, kPlaybackButtonTop, kPlaybackButtonWidth, kPlaybackButtonHeight)];
        playbackState = EUPlaybackStatePaused;
    
        CGRect bounds = CGRectMake(kPlaytimeSliderLead, kPlaytimeSliderTop, kPlaytimeSliderWidth, kPlaytimeSliderHeight);
        playtimeSlider = [[UISlider alloc] initWithFrame:bounds];
        [playtimeSlider setThumbImage:[UIImage imageNamed:@"PlaybackSliderThumb"] forState:UIControlStateNormal];
        [playtimeSlider setMinimumTrackImage:[UIImage imageNamed:@"PlaybackSliderLine"] forState:UIControlStateNormal];
        [playtimeSlider setMaximumTrackImage:[UIImage imageNamed:@"PlaybackSliderLine"] forState:UIControlStateNormal];
        [playtimeSlider addTarget:self action:@selector(changeTime:) forControlEvents:UIControlEventTouchDragInside];
        playtimeSlider.minimumValue = 0;
        playtimeSlider.maximumValue = 0;
        playtimeSlider.value = 0;
        [self addConstraintsForSubView:playtimeSlider bounds:bounds];
        
        bounds = CGRectMake(kCurrentLabelLead, kCurrentLabelTop, kLabelWidth, kLabelHeight);
        currentTimeLabel = [[UILabel alloc] initWithFrame:bounds];
        currentTimeLabel.text = [@"-" stringByAppendingString:[NSString timeStringFromNSTimeInterval:0]];
        currentTimeLabel.font = kLabelUIFont;
        currentTimeLabel.backgroundColor = [UIColor darkGrayColor];
        currentTimeLabel.textColor = [UIColor whiteColor];
        currentTimeLabel.textAlignment = NSTextAlignmentLeft;
        [self addConstraintsForSubView:currentTimeLabel bounds:bounds];
        
        bounds = CGRectMake(kRemainingLabelLead, kRemainingLabeTop, kLabelWidth, kLabelHeight);
        remainingTimeLabel = [[UILabel alloc] initWithFrame:bounds];
        remainingTimeLabel.text = [NSString timeStringFromNSTimeInterval:0];
        remainingTimeLabel.font = kLabelUIFont;
        remainingTimeLabel.backgroundColor = [UIColor darkGrayColor];
        remainingTimeLabel.textColor = [UIColor whiteColor];
        remainingTimeLabel.textAlignment = NSTextAlignmentRight;
        [self addConstraintsForSubView:remainingTimeLabel bounds:bounds];
        
        bounds = CGRectMake(kPodcastInfoLabelLead, kPodcastInfoLabelTop, kPodcastInfoLabelWidth, kPodcastInfoLabelHeight);
        podcastInfoLabel = [[UILabel alloc] initWithFrame:bounds];
        podcastInfoLabel.text = @"Playing:";
        podcastInfoLabel.font = kLabelUIFont;
        podcastInfoLabel.backgroundColor = [UIColor darkGrayColor];
        podcastInfoLabel.textColor = [UIColor whiteColor];
        podcastInfoLabel.textAlignment = NSTextAlignmentLeft;
        [self addConstraintsForSubView:podcastInfoLabel bounds:bounds];

    }
    return self;
}

- (void)setDelegate:(id<EUPlaybackInfoViewDelegate>)delegate {
    if(!_delegate) _delegate = self;
    _delegate = delegate;
    [self updateControls];
    if ([_delegate respondsToSelector:@selector(podcastInfo)]) {
        podcastInfoLabel.text = [@"Playing: " stringByAppendingString:_delegate.podcastInfo];
    }
    
    if ([_delegate respondsToSelector:@selector(endScrubbing)]) {
        [playtimeSlider addTarget:_delegate action:@selector(endScrubbing) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (_delegate == self) _delegate = nil;
}

- (void)refresh {
    [self updateControls];
}

- (void)updateControls {
    NSTimeInterval currentTimeInterval = 0, remainingTimeInterval = 0;
    
    if ([_delegate respondsToSelector:@selector(currentTime)]) {
        currentTimeInterval = _delegate.currentTime;
        currentTimeLabel.text = [@"-" stringByAppendingString:[NSString timeStringFromNSTimeInterval:_delegate.currentTime]];
        
    }
    
    if ([_delegate respondsToSelector:@selector(remainingTime)]) {
        remainingTimeInterval = _delegate.remainingTime;
        remainingTimeLabel.text = [NSString timeStringFromNSTimeInterval:_delegate.remainingTime];
    }

    playtimeSlider.maximumValue = @(currentTimeInterval + remainingTimeInterval).floatValue;
    playtimeSlider.value = @(currentTimeInterval).floatValue;    
    
    if ([_delegate respondsToSelector:@selector(playing)]) {
        if (_delegate.playing) {
            playbackState = EUPlaybackStatePlaying;
            [playbackButton setImage:[UIImage imageNamed:@"PausedPodcastButton"] forState:UIControlStateNormal];
        } else {
            playbackState = EUPlaybackStatePaused;
            [playbackButton setImage:[UIImage imageNamed:@"PlayPodcastButton"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark -
#pragma mark EUPlaybackInfoView Actions

- (void)play:(id)sender {
    if (playbackState == EUPlaybackStatePaused) {
        playbackState = EUPlaybackStatePlaying;
        [playbackButton setImage:[UIImage imageNamed:@"PausedPodcastButton"] forState:UIControlStateNormal];
        [_delegate setPlaying:YES];
    } else {
        playbackState = EUPlaybackStatePaused;
        [playbackButton setImage:[UIImage imageNamed:@"PlayPodcastButton"] forState:UIControlStateNormal];
        [_delegate setPlaying:NO];
    }
}

- (void)changeTime:(id)sender {
    [_delegate startScrubbing];
    if ([_delegate respondsToSelector:@selector(setCurrentTime:)]) {
        [_delegate setCurrentTime:floorf(playtimeSlider.value)];
    }
    [self updateControls];
}

#pragma mark - EUPlaybackInfoView Dummy Delegate
- (NSTimeInterval)remainingTime {
    return 0;
}

- (NSTimeInterval)currentTime {
    return 0;
}

- (void)setCurrentTime:(float)time {
    ;
}

- (BOOL)playing {
    return NO;
}

- (void)setPlaying:(BOOL)playing {
    ;
}

@end
