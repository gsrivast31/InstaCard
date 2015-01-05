//
//  ICReminderController.m
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 03/03/2014.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "NSDate+Extension.h"
#import "ICReminderController.h"
#import "ICAppDelegate.h"
#import "ICCoreDataStack.h"

@interface ICReminderController ()
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

- (void)cacheReminders;
@end

@implementation ICReminderController
@synthesize reminders = _reminders;
@synthesize ungroupedReminders = _ungroupedReminders;

@synthesize calendar = _calendar;
@synthesize dateFormatter = _dateFormatter;
@synthesize timeFormatter = _timeFormatter;

+ (id)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - Setup
- (id)init {
    self = [super init];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cacheReminders)
                                                     name:kRemindersUpdatedNotification
                                                   object:nil];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf cacheReminders];
                [strongSelf deleteExpiredReminders];
            });
        });
    }
    
    return self;
}

#pragma mark - Reminders
- (void)cacheReminders {
    _reminders = [self fetchAllReminders];
    
    // Stash an ungrouped cache for good measure
    NSMutableArray *reminders = [NSMutableArray array];
    if([self reminders]) {
        [reminders addObjectsFromArray:[_reminders objectAtIndex:kReminderTypeDate]];
        [reminders addObjectsFromArray:[_reminders objectAtIndex:kReminderTypeRepeating]];
        [reminders addObjectsFromArray:[_reminders objectAtIndex:kReminderTypeLocation]];
    }
    _ungroupedReminders = [NSArray arrayWithArray:reminders];
}

- (NSArray *)fetchAllReminders {
    NSManagedObjectContext *moc = [[ICCoreDataStack defaultStack] managedObjectContext];
    if(moc) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMReminder" inManagedObjectContext:moc];
        [request setEntity:entity];
        NSSortDescriptor *sortPredicate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        [request setSortDescriptors:@[sortPredicate]];
        
        NSString* currentUserGuid = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userGuid = %@", currentUserGuid];
        [request setPredicate:predicate];

        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [moc executeFetchRequest:request error:&error];
        if (objects != nil && [objects count] > 0) {
            NSMutableArray *dateReminders = [NSMutableArray array];
            NSMutableArray *repeatingReminders = [NSMutableArray array];
            NSMutableArray *locationReminders = [NSMutableArray array];
            
            for(IMReminder *reminder in objects) {
                if([reminder.type integerValue] == kReminderTypeDate) {
                    [dateReminders addObject:reminder];
                } else if([reminder.type integerValue] == kReminderTypeRepeating) {
                    [repeatingReminders addObject:reminder];
                } else if([reminder.type integerValue] == kReminderTypeLocation) {
                    [locationReminders addObject:reminder];
                }
            }
            return @[repeatingReminders, locationReminders, dateReminders];
        }
    }
    
    return nil;
}

- (void)updateRemindersBasedOnCoreDataNotification:(NSNotification *)note {
    NSManagedObjectContext *moc = [[ICCoreDataStack defaultStack] managedObjectContext];
    if(moc) {
        NSDictionary *userInfo = [note userInfo];
        if(userInfo) {
            BOOL reminderUpdatesPerformed = NO;
            for(NSString *key in userInfo) {
                // Deleted notifications
                if([key isEqualToString:NSDeletedObjectsKey]) {
                    for(NSManagedObjectID *objectID in userInfo[key]) {
                        IMBaseObject *managedObject = (IMBaseObject *)[moc objectWithID:objectID];
                        if(managedObject && [managedObject isKindOfClass:[IMReminder class]]) {
                            reminderUpdatesPerformed = YES;
                        }
                    }
                } else if([key isEqualToString:NSUpdatedObjectsKey] || [key isEqualToString:NSInsertedObjectsKey]) {
                    for(NSManagedObjectID *objectID in userInfo[key]) {
                        IMBaseObject *managedObject = (IMBaseObject *)[moc objectWithID:objectID];
                        if(managedObject && [managedObject isKindOfClass:[IMReminder class]]) {
                            [self setNotificationsForReminder:(IMReminder *)managedObject];
                            reminderUpdatesPerformed = YES;
                        }
                    }
                }
            }
            
            if(reminderUpdatesPerformed) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
            }
        }
    }
}

- (void)deleteExpiredReminders {
    NSArray *reminders = [self fetchAllReminders];
    if(reminders){
        // Expire any date-based reminders
        for(IMReminder *reminder in [reminders objectAtIndex:kReminderTypeDate]) {
            if([reminder.date isEarlierThanDate:[NSDate date]]) {
                NSError *error = nil;
                [self deleteReminderWithID:reminder.guid error:&error];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
}

- (BOOL)deleteReminderWithID:(NSString *)reminderID error:(NSError **)error {
    NSManagedObjectContext *moc = [[ICCoreDataStack defaultStack] managedObjectContext];
    if(moc) {
        IMReminder *reminder = [self fetchReminderWithID:reminderID];
        if(reminder) {
            [moc deleteObject:reminder];
            [moc save:*&error];
            
            if(!*error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
                return YES;
            }
        }
    }
    
    return NO;
}

- (NSString *)detailForReminder:(IMReminder *)aReminder {
    if([aReminder.type integerValue] == kReminderTypeDate) {
        return [self.dateFormatter stringFromDate:aReminder.date];
    } else if([aReminder.type integerValue] == kReminderTypeRepeating) {
        NSString *days = [[IMReminderController sharedInstance] formattedRepeatingDaysWithFlags:[aReminder.days integerValue]];
        return [days stringByAppendingFormat:@", %@", [self.timeFormatter stringFromDate:aReminder.date]];
    } else if([aReminder.type integerValue] == kReminderTypeLocation) {
        return aReminder.locationName;
    }
    
    return nil;
}

#pragma mark - Rules
- (NSArray *)fetchAllReminderRules {
    NSManagedObjectContext *moc = [[ICCoreDataStack defaultStack] managedObjectContext];
    if(moc) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"IMReminderRule" inManagedObjectContext:moc];
        [request setEntity:entity];
        
        NSSortDescriptor *sortPredicate = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [request setSortDescriptors:@[sortPredicate]];
        
        NSString* currentUserGuid = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userGuid = %@", currentUserGuid];
        [request setPredicate:predicate];
        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [moc executeFetchRequest:request error:&error];
        if (objects != nil && [objects count] > 0) {
            return objects;
        }
    }
    
    return nil;
}

- (BOOL)deleteReminderRule:(IMReminderRule *)reminderRule error:(NSError **)error {
    if(reminderRule) {
        NSManagedObjectContext *moc = [[ICCoreDataStack defaultStack] managedObjectContext];
        if(moc) {
            [moc deleteObject:reminderRule];
            [moc save:*&error];
            
            if(!*error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - Notifications
- (void)setNotificationsForReminder:(IMReminder *)aReminder {
    // Cancel all existing registered notifications
    NSArray *notifications = [self notificationsWithID:[aReminder guid]];
    if([notifications count]) {
        for(UILocalNotification *notification in notifications) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    
    // Generate a date-based notification
    if([aReminder.type integerValue] == kReminderTypeDate) {
        // Make sure this date hasn't already passed
        if([aReminder.date isLaterThanDate:[NSDate date]]) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = aReminder.date;
            notification.alertBody = aReminder.message;
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.timeZone = [NSTimeZone defaultTimeZone];
            notification.soundName = @"notification.caf";
            notification.userInfo = @{@"ID": aReminder.guid, @"type": aReminder.type};
            
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    } else {
        int days[7] = {0};
        NSInteger dayFlags = [aReminder.days integerValue];
        if(dayFlags & Everyday) {
            for(int i = 0; i < 7;i ++) {
                days[i] = 1;
            }
        } else {
            if(dayFlags & Sunday) days[0] = 1;
            if(dayFlags & Monday) days[1] = 1;
            if(dayFlags & Tuesday) days[2] = 1;
            if(dayFlags & Wednesday) days[3] = 1;
            if(dayFlags & Thursday) days[4] = 1;
            if(dayFlags & Friday) days[5] = 1;
            if(dayFlags & Saturday) days[6] = 1;
        }
        
        for(int i = 0; i < 7; i++) {
            if(days[i]) {
                NSDateComponents *dateComponents = [self.calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:aReminder.date];
                dateComponents.weekday = i+1;
                
                NSDate *notificationDate = [self.calendar dateFromComponents:dateComponents];
                if(notificationDate) {
                    if([notificationDate isEarlierThanDate:[NSDate date]]) {
                        dateComponents.weekOfMonth++;
                        notificationDate = [self.calendar dateFromComponents:dateComponents];
                    }
                    
                    if(notificationDate)  {
                        UILocalNotification *notification = [[UILocalNotification alloc] init];
                        notification.fireDate = notificationDate;
                        notification.alertBody = aReminder.message;
                        notification.soundName = UILocalNotificationDefaultSoundName;
                        notification.timeZone = [NSTimeZone defaultTimeZone];
                        notification.repeatInterval = NSCalendarUnitWeekOfMonth;
                        notification.soundName = @"notification.caf";
                        notification.userInfo = @{@"ID": aReminder.guid, @"type": aReminder.type};
                        
                        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                    }
                }
            }
        }
    }
}

- (void)deleteNotificationsWithID:(NSString *)reminderID {
    NSArray *notifications = [self notificationsWithID:reminderID];
    if([notifications count]) {
        for(UILocalNotification *notification in notifications) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

- (void)didReceiveLocalNotification:(UILocalNotification *)notification {
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state != UIApplicationStateInactive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Scheduled Reminder", nil)
                                                        message:notification.alertBody
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Thanks", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [self deleteExpiredReminders];
}

#pragma mark - Accessors
- (NSDateFormatter *)dateFormatter {
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    
    return _dateFormatter;
}

- (NSDateFormatter *)timeFormatter {
    if(!_timeFormatter) {
        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    
    return _timeFormatter;
}

- (NSCalendar *)calendar {
    if(!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    
    return _calendar;
}

#pragma mark - Helpers
- (IMReminder *)fetchReminderWithID:(NSString *)reminderID {
    NSManagedObjectContext *moc = [[ICCoreDataStack defaultStack] managedObjectContext];
    if(moc) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"IMReminder"];
        NSString* currentUserGuid = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentProfileKey];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid = %@ && userGuid = %@", reminderID, currentUserGuid];
        [request setPredicate:predicate];
        
        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [moc executeFetchRequest:request error:&error];
        if (objects != nil && [objects count] > 0) {
            return (IMReminder *)[objects objectAtIndex:0];
        }
    }
    
    return nil;
}

- (NSArray *)notificationsWithID:(NSString *)reminderID {
    NSMutableArray *notifications = [NSMutableArray array];
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];

    for (UILocalNotification *notification in localNotifications) {
        NSString *notificationID = [notification.userInfo objectForKey:@"ID"];
        if([notificationID isEqualToString:reminderID]) {
            [notifications addObject:notification];
        }
    }
    
    return [NSArray arrayWithArray:notifications];
}

- (NSString *)generateReminderID {
    return [NSString stringWithFormat:@"%d", (int)[NSDate timeIntervalSinceReferenceDate]];
}

- (NSDate *)generateNotificationDateWithDate:(NSDate *)date {
    NSDateComponents *dateComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:[dateComponents day]];
    [dateComps setMonth:[dateComponents month]];
    [dateComps setYear:[dateComponents year]];
    [dateComps setHour:[dateComponents hour]];
    [dateComps setMinute:[dateComponents minute]];
    [dateComps setSecond:0];
    
    NSDate *notificationDate = [self.calendar dateFromComponents:dateComps];
    
    return notificationDate;
}

- (NSString *)formattedRepeatingDaysWithFlags:(NSInteger)flags {
    NSString *string = @"";
    if(flags & Everyday) {
        string = NSLocalizedString(@"Every day", nil);
    } else {
        if(flags & Monday) string = [string stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Mon", nil)];
        if(flags & Tuesday) string = [string stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Tues", nil)];
        if(flags & Wednesday) string = [string stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Wed", nil)];
        if(flags & Thursday) string = [string stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Thurs", nil)];
        if(flags & Friday) string = [string stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Fri", nil)];
        if(flags & Saturday) string = [string stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Sat", nil)];
        if(flags & Sunday) string = [string stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Sun", nil)];
        
        if([string length]) {
            string = [string substringToIndex:[string length]-2];
        }
    }
    
    return string;
}

@end
