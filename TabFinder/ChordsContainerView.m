//
//  ChordsContainerView.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 20/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "ChordsContainerView.h"
#import <QuartzCore/QuartzCore.h>
#import "ChordView.h"
#import "UIView+Popup.h"
#import "iPadMasterViewController.h"

@interface ChordsContainerView ()

@property CGPoint lastTouch;
@property BOOL whiteBackground;

@end

@implementation ChordsContainerView

static NSMutableArray *_containerViews;

static BOOL isPanning;

+(void)addChordViewWithName:(NSString *)name variations:(NSArray *)variations toView:(UIView *)view {
    ChordsContainerView *ccv;
    if (!_containerViews) _containerViews = [NSMutableArray array];
    for (ChordsContainerView *eccv in _containerViews) {
        if ([eccv.chordLabel.text isEqualToString:name]) {
            ccv = eccv;
        }
    }
    if (!ccv) {
        ccv = [[ChordsContainerView alloc] initWithChordName:name variations:variations];
        [view addSubview:ccv];
    } else {
        [view bringSubviewToFront:ccv];
        [_containerViews removeObject:ccv];
    }
    CGPoint center = view.center;
    center.y -= 60;
    ccv.center = center;
    if (_containerViews.lastObject != ccv) {
        ChordsContainerView *last = _containerViews.lastObject;
        if (CGRectIntersectsRect(last.frame, ccv.frame)) {
            ccv.center = CGPointMake(last.center.x + 15, last.center.y + 15);
        }
    }
    [_containerViews addObject:ccv];
}

-(id)initWithChordName:(NSString *)name variations:(NSArray *)variations {
    isPanning = NO;
    self = [[NSBundle mainBundle] loadNibNamed:@"ChordsContainerView" owner:self options:nil].lastObject;
    [self configureForChord:name variations:variations];
    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [self addGestureRecognizer:panGestureRecognizer];
    self.layer.cornerRadius = 10;
    _whiteBackground = NO;
    return self;
}

-(void)configureForChord:(NSString *)name variations:(NSArray *)variations {
    _chords = variations;
    _chordLabel.text = name;
    _dragIconImageVIew.image = [_dragIconImageVIew.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _dragIconImageVIew.tintColor = [UIColor whiteColor];
    _pageControl.numberOfPages = MIN(_chords.count, 9);
    _pageControl.currentPage = 0;
    [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_swipeView reloadData];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    _dragIconImageVIew.hidden = YES;
    _closeButton.hidden = YES;
    self.layer.cornerRadius = 10;
    _whiteBackground = NO;
    _chordLabel.textColor = [UIColor blackColor];
    return self;
}

-(NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return _chords.count;
}

-(void)swipeViewWillBeginDragging:(SwipeView *)swipeView {
    isPanning = YES;
}

-(void)swipeViewDidEndDragging:(SwipeView *)swipeView willDecelerate:(BOOL)decelerate {
    isPanning = NO;
}

-(UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    ChordView *chordView = _whiteBackground ? [[ChordView alloc] initWithWhiteBackground] : [[ChordView alloc] init];
    NSDictionary *currentVariation = _chords[index];
    [chordView configureWithNotes:currentVariation[@"txt"] fingering:currentVariation[@"app"] baseFret:[currentVariation[@"fret"] integerValue]];
    return chordView;
}

-(void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    [_pageControl setCurrentPage:swipeView.currentItemIndex];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    isPanning = YES;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    isPanning = NO;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    isPanning = NO;
}

+(BOOL)isPanning {
    return isPanning;
}

-(void)handlePanFrom:(UIPanGestureRecognizer*)gesture {
    static CGPoint lastTranslate;   // the last value
    static CGPoint prevTranslate;   // the value before that one
    static NSTimeInterval lastTime;
    static NSTimeInterval prevTime;
    
    CGPoint translate = [gesture translationInView:self.superview];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        lastTime = [NSDate timeIntervalSinceReferenceDate];
        lastTranslate = translate;
        prevTime = lastTime;
        prevTranslate = lastTranslate;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        prevTime = lastTime;
        prevTranslate = lastTranslate;
        lastTime = [NSDate timeIntervalSinceReferenceDate];
        lastTranslate = translate;
        CGPoint offset = CGPointMake(translate.x - prevTranslate.x, translate.y - prevTranslate.y);
        self.center = CGPointMake(self.center.x + offset.x, self.center.y + offset.y);
        [self.superview bringSubviewToFront:self];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.center.x > self.superview.frame.size.width || self.center.y > self.superview.frame.size.height) {
            [self dismissAnimated:YES];
        }
    }
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissAnimated:YES];
}

-(void)dismissAnimated:(BOOL)animated {
    [_containerViews removeObject:self];
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
}

@end
