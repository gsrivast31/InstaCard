//
//  ICCard.h
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 19/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ICCard : NSManagedObject

@property (nonatomic, retain) NSData * backImage;
@property (nonatomic, retain) NSString * cardName;
@property (nonatomic) NSTimeInterval endDate;
@property (nonatomic, retain) NSData * frontImage;
@property (nonatomic, retain) NSString * iconName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * number;
@property (nonatomic) NSTimeInterval startDate;
@property (nonatomic) int16_t type;
@property (nonatomic) NSTimeInterval createdAt;

@end
