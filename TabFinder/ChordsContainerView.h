//
//  ChordsContainerView.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 20/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeView.h"
#import "AMBlurView.h"

@interface ChordsContainerView : UIView <SwipeViewDataSource, SwipeViewDelegate>

@property NSArray *chords;

+(void)addChordViewWithName:(NSString *)name variations:(NSArray *)variations toView:(UIView *)view;

@property (weak, nonatomic) IBOutlet UILabel *chordLabel;
@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)closeButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *dragIconImageVIew;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet AMBlurView *blurView;

@end
