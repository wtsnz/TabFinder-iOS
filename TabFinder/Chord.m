//
//  Chord.m
//  TabFinder
//
//  Created by Luiz Gustavo on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Chord.h"

@implementation Chord

@synthesize variations = _variations;
@synthesize name = _name;

-(NSMutableArray *)generateFingeringForVariations:(NSMutableArray *)chordVariations {
    NSMutableArray *aux;
    for (NSString *variation in chordVariations) {
        [aux addObject:[self generateFingeringForChord:variation]];
    }
    return aux;
}

-(NSString *)generateFingeringForChord:(NSString *)chord {
    int notes[6];
    NSArray *splitNotes = [chord componentsSeparatedByString:@" "];
    int i=0;
    for (NSString *note in splitNotes) {
        NSString *noteAux = note;
        if ([note hasPrefix:@"P"]) {
            noteAux = [noteAux substringFromIndex:2];
        }
        if ([note isEqualToString:@"X"]) {
            notes[i] = -1;
        }
        else {
            notes[i] = [note intValue];
        }
        i++;
    }
    return nil;
}

@end
