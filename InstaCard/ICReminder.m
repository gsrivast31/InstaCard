//
//  ICReminder.m
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 15/12/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "ICReminder.h"
#import "ICReminderController.h"

@implementation ICReminder

@dynamic active;
@dynamic created;
@dynamic date;
@dynamic days;
@dynamic latitude;
@dynamic locationName;
@dynamic longitude;
@dynamic message;
@dynamic trigger;
@dynamic type;
@dynamic guid;

- (void)prepareForDeletion
{
    [super prepareForDeletion];
    [[ICReminderController sharedInstance] deleteNotificationsWithID:self.guid];
}

@end
