//
//  TableViewHelper.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 30/09/12.
//  Copyright (c) 2012 Luiz Gustavo Faria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewHelper : NSObject

+(NSMutableArray *)getTableViewSectionsArrayForDataArray:(NSArray *)array withKey:(NSString *)key;
+(NSArray *)filterArray:(NSArray *)array usingSections:(NSArray *)sections forSectionIndex:(NSInteger)section usingKey:(NSString *)key;

@end
