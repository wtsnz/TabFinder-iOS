//
//  Song.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 14/05/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Song : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * tab;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * ugid;
@property (nonatomic, retain) NSString * type2;
@property (nonatomic, retain) NSData * artistImage;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSDate * dateOfCreation;
@property (nonatomic, retain) NSString * favoritesSectionTitle;
@property (nonatomic, retain) NSString * historySectionTitle;


-(NSString *)fullVersionTitle;
-(NSString *)shortVersionTitle;

+(Song *)addToDatabase:(NSDictionary *)version withContent:(NSString *)tab;
+(void)removeOlderThanDays:(NSInteger)numberOfDays;

@end
