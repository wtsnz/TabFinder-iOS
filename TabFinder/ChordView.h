//
//  ChordView.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 19/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChordView : UIView

@property (nonatomic) BOOL isBackgroundWhite;
@property (weak, nonatomic) IBOutlet UIView *fretZero;
@property (weak, nonatomic) IBOutlet UILabel *fretIndicatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *chordNameLabel;
-(id)initWithWhiteBackground;
-(void)configureWithNotes:(NSString *)notes fingering:(NSString *)fingers baseFret:(NSInteger)baseFret;
@property (weak, nonatomic) IBOutlet UIImageView *fretboardImageView;

@end
