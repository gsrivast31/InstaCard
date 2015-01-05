//
//  ICFont.m
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 30/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "ICFont.h"

@implementation ICFont

+ (UIFont *)standardRegularFontWithSize:(CGFloat)size {
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)standardMediumFontWithSize:(CGFloat)size {
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)standardDemiBoldFontWithSize:(CGFloat)size {
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)standardBoldFontWithSize:(CGFloat)size {
    return [UIFont boldSystemFontOfSize:size];
}

+ (UIFont *)standardUltraLightFontWithSize:(CGFloat)size {
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)standardUltraLightItalicFontWithSize:(CGFloat)size {
    return [UIFont italicSystemFontOfSize:size];
}

+ (UIFont *)standardItalicFontWithSize:(CGFloat)size {
    return [UIFont italicSystemFontOfSize:size];
}

@end
