//
//  ChordsContainerView.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 20/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeView.h"

@interface ChordsContainerView : UIView <SwipeViewDataSource, SwipeViewDelegate>

@property NSArray *chords;

+(void)addChordViewWithName:(NSString *)name variations:(NSArray *)variations toView:(UIView *)view;

@property (weak, nonatomic) IBOutlet UILabel *chordLabel;
@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)closeButtonPressed:(id)sender;
-(void)configureForChord:(NSString *)name variations:(NSArray *)variations;

@property (weak, nonatomic) IBOutlet UIImageView *dragIconImageVIew;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

+(BOOL)isPanning;

@end
