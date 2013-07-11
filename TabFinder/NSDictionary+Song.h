//
//  NSDictionary+Song.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 11/05/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Song)

-(NSMutableArray *)versions;
-(NSString *)name;
-(NSString *)artist;
-(NSURL *)url;
-(NSString *)type;
-(NSString *)type2;
-(NSString *)versionNumber;
-(NSString *)fullVersionTitle;
-(NSString *)shortVersionTitle;
-(NSNumber *)rating;
-(NSNumber *)votes;
-(NSDictionary *)bestVersion;

-(UIActionSheet *)versionsActionSheetWithCurrentVersionIndex:(NSInteger)currentVersionIndex;

@end
