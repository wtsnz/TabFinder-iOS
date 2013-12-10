//
//  DictViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 25/11/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChordCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) UIView *bgView;

@end

@interface DictViewController : UIViewController

- (IBAction)didChangeBaseChordSegment:(id)sender;
- (IBAction)didPressDone:(id)sender;

@end
