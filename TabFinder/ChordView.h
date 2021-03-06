//
//  ChordView.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 19/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChordView : UIView

@property (weak, nonatomic) IBOutlet UIView *fretZero;
@property (weak, nonatomic) IBOutlet UILabel *fretIndicatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *chordNameLabel;

-(void)configureWithNotes:(NSString *)notes fingering:(NSString *)fingers baseFret:(NSInteger)baseFret;

@end
