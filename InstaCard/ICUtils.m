//
//  ICUtils.m
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 17/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "ICUtils.h"

@implementation ICUtils

+ (UIColor*) getColor:(NSUInteger)index {
    static NSMutableArray* _colorsArray = nil;
    @synchronized([ICUtils class])
    {
        if (_colorsArray == nil) {
            _colorsArray = [[NSMutableArray alloc] init];
            [_colorsArray addObject:[UIColor colorWithRed:0.125 green:0.137 blue:0.161 alpha:1]];
            [_colorsArray addObject:[UIColor colorWithRed:0.325 green:0.345 blue:0.38 alpha:1]];
            [_colorsArray addObject:[UIColor colorWithRed:0.216 green:0.231 blue:0.263 alpha:1]];
            [_colorsArray addObject:[UIColor colorWithRed:0.239 green:0.259 blue:0.286 alpha:1]];
            [_colorsArray addObject:[UIColor colorWithRed:0.439 green:0.471 blue:0.51 alpha:1]];
            [_colorsArray addObject:[UIColor colorWithRed:0.784 green:0.816 blue:0.843 alpha:1]];
            [_colorsArray addObject:[UIColor colorWithRed:0.667 green:0.69 blue:0.722 alpha:1]];
        }
    }
    
    NSUInteger size = [_colorsArray count];
    return [_colorsArray objectAtIndex:(index%size)];
}

@end
