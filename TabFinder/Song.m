//
//  Song.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 14/05/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "Song.h"


@implementation Song

@dynamic artist;
@dynamic name;
@dynamic tab;
@dynamic version;
@dynamic type;
@dynamic ugid;
@dynamic type2;
@dynamic artistImage;
@dynamic isFavorite;
@dynamic dateOfCreation;

-(NSString *)fullVersionTitle {
    NSString *type2 = self.type2.length > 0 ? [[self.type2 stringByAppendingString:@" "] capitalizedString] : @"";
    return [NSString stringWithFormat:@"%@%@, Version %@",type2,self.type.capitalizedString,self.version.stringValue];
}

-(NSString *)shortVersionTitle {
    NSString *type2 = self.type2.length > 0 ? [[self.type2 stringByAppendingString:@" "] capitalizedString] : @"";
    return [NSString stringWithFormat:@"%@%@, v. %@",type2,self.type.capitalizedString,self.version.stringValue];
}

@end
