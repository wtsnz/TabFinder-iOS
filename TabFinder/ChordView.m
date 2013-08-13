//
//  ChordView.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 19/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "ChordView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ChordView

static const float STRING_DISTANCE = 24;
static const float FRET_DISTANCE = 24;

static const float FIRST_STRING_X = 40;
static const float FRET_0_Y = 10;

-(id)init {
    self = [[NSBundle mainBundle] loadNibNamed:@"ChordView" owner:self options:nil].lastObject;
    _fretboardImageView.image = [_fretboardImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _fretboardImageView.tintColor = [UIColor lightGrayColor];
    return self;
}

-(UIView *)fretBoardSignForFinger:(NSString *)finger {
    if ([finger isEqualToString:@"capo"]) {
        UIView *capoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 5)];
        capoView.layer.cornerRadius = 2.5;
        capoView.backgroundColor = [self tintColor];
        return capoView;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    BOOL isFinger = !([finger isEqualToString:@"x"] || [finger isEqualToString:@"0"]);
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:isFinger ? 13 : 8]];
    [label setBackgroundColor:isFinger ? [self tintColor] : [UIColor clearColor]];
    [label setTextColor:isFinger ? [UIColor whiteColor] : [self tintColor]];
    [label setText:[finger isEqualToString:@"0"] ? @"o" : finger];
    [label.layer setCornerRadius:10];
    [label.layer setMasksToBounds:YES];
    return label;
}

-(CGFloat)fretboardLabelYPositionForNote:(NSString *)note baseFret:(NSInteger)baseFret {
    if ([note isEqualToString:@"x"] || [note isEqualToString:@"0"]) {
        return FRET_0_Y+4;
    }
    int modifier = 0;
    if (baseFret == 1) modifier = FRET_DISTANCE;
    if (baseFret >= 2) modifier = FRET_DISTANCE*2;
    return FRET_0_Y + (note.integerValue-baseFret)*FRET_DISTANCE + modifier;
}

-(CGFloat)fretboardLabelXPositionForString:(NSInteger)stringIndex {
    return FIRST_STRING_X + stringIndex*STRING_DISTANCE;
}

-(void)configureWithNotes:(NSString *)notes fingering:(NSString *)fingers baseFret:(NSInteger)baseFret {
    _fretZero.hidden = baseFret != 0;
    _fretIndicatorLabel.hidden = baseFret <= 2;
    
    NSString *baseFretOrdinal;
    if (baseFret%10 == 0 || baseFret%10 > 3) {
        baseFretOrdinal = @"th";
    } else {
        if (baseFret%10 == 1) baseFretOrdinal = @"st";
        if (baseFret%10 == 2) baseFretOrdinal = @"nd";
        if (baseFret%10 == 3) baseFretOrdinal = @"rd";
    }
    
    _fretIndicatorLabel.text = [NSString stringWithFormat:@"%i%@",baseFret,baseFretOrdinal];
    
    NSArray *notesArray = [[notes componentsSeparatedByString:@" "] subarrayWithRange:NSMakeRange(1, 6)];
    NSArray *fingersArray = [[fingers componentsSeparatedByString:@" "] subarrayWithRange:NSMakeRange(1, 6)];
    BOOL hasCapo = [fingersArray indexOfObject:@"capo"] != NSNotFound;
    int firstCapo = 0;
    int lastCapo = 0;
    int capoFret = 0;
    if (hasCapo) {
        firstCapo = [fingersArray indexOfObject:@"capo"];
        for (int string=0;string<6;string++) {
            lastCapo = [fingersArray[string] isEqualToString:@"capo"] ? string : lastCapo;
        }
        capoFret = [notesArray[firstCapo] integerValue];
    }
    for (int guitarString=0; guitarString<6; guitarString++) {
        NSString *note = notesArray[guitarString];
        NSString *finger = fingersArray[guitarString];
        if ([note isEqualToString:@"x"]) finger = @"x";
        UIView *fingerView = [self fretBoardSignForFinger:finger];
        CGFloat frameXModifier = 0;
        if (hasCapo && guitarString == firstCapo) {
            frameXModifier = 7;
        }
        if (hasCapo && guitarString == lastCapo) {
            frameXModifier = -7;
        }
        fingerView.center = CGPointMake([self fretboardLabelXPositionForString:guitarString] + frameXModifier, [self fretboardLabelYPositionForNote:note baseFret:baseFret]);
        if (![finger isEqualToString:@"capo"] && hasCapo) {
            if (guitarString > firstCapo && guitarString < lastCapo) {
                UIView *capoView = [self fretBoardSignForFinger:@"capo"];
                [self addSubview:capoView];
                capoView.center = CGPointMake([self fretboardLabelXPositionForString:guitarString], [self fretboardLabelYPositionForNote:notesArray[firstCapo] baseFret:baseFret]);
            }

        }
        [self addSubview:fingerView];
    }
}

@end
