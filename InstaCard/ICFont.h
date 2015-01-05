//
//  ICFont.h
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 30/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICFont : NSObject

+ (UIFont *)standardRegularFontWithSize:(CGFloat)size;
+ (UIFont *)standardMediumFontWithSize:(CGFloat)size;
+ (UIFont *)standardDemiBoldFontWithSize:(CGFloat)size;
+ (UIFont *)standardBoldFontWithSize:(CGFloat)size;
+ (UIFont *)standardUltraLightFontWithSize:(CGFloat)size;
+ (UIFont *)standardUltraLightItalicFontWithSize:(CGFloat)size;
+ (UIFont *)standardItalicFontWithSize:(CGFloat)size;

@end
