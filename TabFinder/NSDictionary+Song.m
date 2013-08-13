//
//  NSDictionary+Song.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 11/05/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "NSDictionary+Song.h"

@implementation NSDictionary (Song)

-(NSMutableArray *)versions {
    return [self objectForKey:@"versions"];
}

-(NSString *)type {
    return self[@"type"];
}

-(NSString *)artist {
    return self[@"artist"];
}

-(NSString *)name {
    return self[@"name"];
}

-(NSURL *)url {
    return [NSURL URLWithString:[@"/show/" stringByAppendingString:self[@"id"]] relativeToURL:BASE_URL];
}

-(NSString *)versionNumber {
    return self[@"version"];
}

-(NSNumber *)rating {
    return @([self[@"rating"] floatValue]);
}

-(NSNumber *)votes {
    return self[@"votes"];
}

-(NSString *)type2 {
    return self[@"type_2"];
}

-(NSString *)fullVersionTitle {
    NSString *type2 = self.type2.length > 0 ? [[self.type2 stringByAppendingString:@" "] capitalizedString] : @"";
    return [NSString stringWithFormat:@"%@%@, Version %@",type2,self.type.capitalizedString,self.versionNumber];
}

-(NSString *)shortVersionTitle {
    NSString *type2 = self.type2.length > 0 ? [[self.type2 stringByAppendingString:@" "] capitalizedString] : @"";
    return [NSString stringWithFormat:@"%@%@ v.%@",type2,self.type.capitalizedString,self.versionNumber];
}

-(NSDictionary *)bestVersion {
    NSDictionary *bestVersion = self.versions[0];
    for (NSDictionary *version in self.versions) {
        if (version.rating.floatValue * version.votes.integerValue > bestVersion.rating.floatValue * bestVersion.votes.integerValue) {
            bestVersion = version;
        }
    }
    return bestVersion;
}

-(UIActionSheet *)versionsActionSheetWithCurrentVersionIndex:(NSInteger)currentVersionIndex {
    NSDictionary *currentVersion = self.versions[currentVersionIndex];
    NSString *title = [NSString stringWithFormat:@"Currently showing: %@",currentVersion.fullVersionTitle];
    UIActionSheet *versionsSheet = [[UIActionSheet alloc] initWithTitle:title delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    for (NSDictionary *version in self.versions) {
        if (version != currentVersion) {
            [versionsSheet addButtonWithTitle:version.fullVersionTitle];
        }
    }
    if (versionsSheet.numberOfButtons == 0) {
        versionsSheet = nil;
    } else {
        [versionsSheet addButtonWithTitle:@"Cancel"];
        [versionsSheet setCancelButtonIndex:self.versions.count-1];
    }
    return versionsSheet;
}

@end
