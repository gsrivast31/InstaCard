//
//  ICReminderController.h
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 03/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICReminder.h"
#import "ICReminderRule.h"

// TODO: Convert these to enums
#define kReminderTypeRepeating 0
#define kReminderTypeDate 2
#define kReminderTypeRule 3

#define kMinuteIntervalType 0
#define kHourIntervalType 1
#define kDayIntervalType 2

#define kReminderTriggerArriving 0
#define kReminderTriggerDeparting 1
#define kReminderTriggerBoth 2

@interface ICReminderController : NSObject
@property (readonly, strong, nonatomic) NSArray *reminders;
@property (readonly, strong, nonatomic) NSArray *ungroupedReminders;

// Setup
+ (id)sharedInstance;

// Reminders
- (NSArray *)fetchAllReminders;
- (void)deleteExpiredReminders;
- (BOOL)deleteReminderWithID:(NSString *)reminderID error:(NSError **)error;
- (NSString *)detailForReminder:(IMReminder *)aReminder;
- (void)updateRemindersBasedOnCoreDataNotification:(NSNotification *)note;

// Rules
- (NSArray *)fetchAllReminderRules;
- (BOOL)deleteReminderRule:(IMReminderRule *)reminderRule error:(NSError **)error;

// Notifications
- (void)didReceiveLocalNotification:(UILocalNotification *)notification;
- (void)setNotificationsForReminder:(IMReminder *)aReminder;
- (void)deleteNotificationsWithID:(NSString *)reminderID;

// Helpers
- (IMReminder *)fetchReminderWithID:(NSString *)reminderID;
- (NSArray *)notificationsWithID:(NSString *)reminderID;
- (NSString *)generateReminderID;
- (NSDate *)generateNotificationDateWithDate:(NSDate *)date;
- (NSString *)formattedRepeatingDaysWithFlags:(NSInteger)flags;

@end
