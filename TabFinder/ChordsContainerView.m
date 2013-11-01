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

@interface ChordsContainerView ()

@property CGPoint lastTouch;

@end

@implementation ChordsContainerView

+(void)addChordViewWithName:(NSString *)name variations:(NSArray *)variations toView:(UIView *)view {
    ChordsContainerView *ccv = [[ChordsContainerView alloc] initWithChordName:name variations:variations];
    CGPoint center = view.center;
    center.y -= 60;
    ccv.center = center;
    [view addSubview:ccv];
}

-(id)initWithChordName:(NSString *)name variations:(NSArray *)variations {
    self = [[NSBundle mainBundle] loadNibNamed:@"ChordsContainerView" owner:self options:nil].lastObject;
    _chords = variations;
    _chordLabel.text = name;
    _pageControl.numberOfPages = _chords.count;
    _pageControl.currentPage = 0;
    [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [self addGestureRecognizer:panGestureRecognizer];
    self.backgroundColor = [UIColor defaultColor];
    self.layer.cornerRadius = 10;
    return self;
}

-(NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return _chords.count;
}

-(UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    ChordView *chordView = [[ChordView alloc] init];
    NSDictionary *currentVariation = _chords[index];
    [chordView configureWithNotes:currentVariation[@"txt"] fingering:currentVariation[@"app"] baseFret:[currentVariation[@"fret"] integerValue]];
    return chordView;
}

-(void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    [_pageControl setCurrentPage:swipeView.currentItemIndex];
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
            [self dismiss];
        }
    }
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismiss];
}

-(void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
