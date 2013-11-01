//
//  UIFont+ProximaNova.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 2/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "UIFont+ProximaNova.h"

@implementation UIFont (ProximaNova)

+(UIFont *)proximaNovaLightSize:(CGFloat)size {
    return [UIFont fontWithName:@"ProximaNova-Light" size:size];
}

+(UIFont *)proximaNovaSize:(CGFloat)size {
    return [UIFont fontWithName:@"ProximaNova-Regular" size:size];
}

+(UIFont *)proximaNovaSemiBoldSize:(CGFloat)size {
    return [UIFont fontWithName:@"ProximaNova-Semibold" size:size];
}

@end
