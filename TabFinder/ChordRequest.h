//
//  ChordRequest.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 07/08/12.
//
//

#import <Foundation/Foundation.h>

@interface ChordRequest : NSObject

+(NSMutableArray *)chordSuggestionForString:(NSString *)searchText;
+(NSMutableArray *)chordRequest:(NSString *)chordName;

@end
