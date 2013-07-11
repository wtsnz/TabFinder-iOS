//
//  TableViewHelper.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 30/09/12.
//  Copyright (c) 2012 Luiz Gustavo Faria. All rights reserved.
//

#import "TableViewHelper.h"

@implementation TableViewHelper

+(NSArray *)sectionsArray {
    return [NSArray arrayWithObjects:@"#",@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@".",@"$",@"!",@"(", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
}

+(NSMutableArray *)getTableViewSectionsArrayForDataArray:(NSArray *)array withKey:(NSString *)key {
    
    NSMutableArray *sectionsArrayResult = [[NSMutableArray alloc] init];
    NSArray *sectionsArray = [self sectionsArray];
    
    if (array.count > 15) {
        for (NSInteger i = 0; i <sectionsArray.count; i++) {
            if ([self filterArray:array usingSections:sectionsArray forSectionIndex:i usingKey:key].count > 0) {
                [sectionsArrayResult addObject:[sectionsArray objectAtIndex:i]];
            }
        }
    } else {
        [sectionsArrayResult addObject:@""];
    }
    return sectionsArrayResult;
}

+(NSArray *)filterArray:(NSArray *)array usingSections:(NSArray *)sections forSectionIndex:(NSInteger)section usingKey:(NSString *)key {
    return [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.%@ beginswith[c] %@",key, [sections objectAtIndex:section]]];
}

@end
