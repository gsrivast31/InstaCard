//
//  ICUtils.h
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 17/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int16_t, ICCardType) {
    ICPersonal = 0,
    ICBankCredit = 1,
    ICBankDebit = 2,
    ICLoyalty = 3,
    ICPolicy = 4,
    ICOther = 5
};

@interface ICUtils : NSObject

+ (UIColor*) getColor:(NSUInteger)index;

@end
