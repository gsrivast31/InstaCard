//
//  ICCardDetailViewController.m
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 19/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "ICCardDetailViewController.h"
#import "ICCard.h"
#import "ICCardEditViewController.h"
#import "ICImageViewController.h"
#import "ICCoreDataStack.h"

#import <MessageUI/MessageUI.h>

#define kPadding 20

@interface ICCardDetailViewController ()
@end

@implementation ICCardDetailViewController

static NSString *kCardEditViewControllerStoryBoardID = @"cardEditViewController";

@synthesize card = _card;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fillCardDetails];
    [self setRightBarButtonItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCard:) name:@"updateCardDetails" object:nil];
    
    UITapGestureRecognizer* frontTouchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openFrontImage:)];
    [frontTouchGesture setNumberOfTapsRequired:1];
    [self.frontImageView setUserInteractionEnabled:YES];
    [self.frontImageView addGestureRecognizer:frontTouchGesture];
    UITapGestureRecognizer* backTouchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openBackImage:)];
    [backTouchGesture setNumberOfTapsRequired:1];
    [self.backImageView setUserInteractionEnabled:YES];
    [self.backImageView addGestureRecognizer:backTouchGesture];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setRightBarButtonItems {
    UIBarButtonItem* editButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStylePlain target:self action:@selector(editCard)];
    
    UIBarButtonItem* shareButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareCard)];
    
    UIBarButtonItem* deleteButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteCard)];
    
    NSArray* rightButtons = @[shareButtonItem, editButtonItem, deleteButtonItem];
    self.navigationItem.rightBarButtonItems = rightButtons;
}

- (void)fillCardDetails {
    if (self.card != nil) {
        self.title = self.card.cardName;
        
        if (self.card.number) {
            self.cardNumberLabel.text = self.card.number;
        }
        
        if (self.card.cardName) {
            self.cardNameLabel.text = self.card.cardName;
        }
        
        if (self.card.name) {
            self.personLabel.text = self.card.name;
        }
        
        if (self.card.frontImage) {
            [self.frontImageView setImage:[UIImage imageWithData:self.card.frontImage]];
        }
        if (self.card.backImage) {
            [self.backImageView setImage:[UIImage imageWithData:self.card.backImage]];
        }
        if (self.card.startDate) {
            self.startDateLabel.text = [self getStartDateString];
        }
        if (self.card.endDate) {
            self.endDateLabel.text = [self getEndDateString];
        }
    }
}

- (void)updateCard:(NSNotification *)notification {
    NSDictionary* dictionary = [notification userInfo];
    self.card = [dictionary valueForKey:@"card"];
    [self fillCardDetails];
}
   
- (void)editCard {
    ICCardEditViewController* addCardController = [self.storyboard instantiateViewControllerWithIdentifier:kCardEditViewControllerStoryBoardID];
    addCardController.card = self.card;
    [addCardController setCardType:self.card.type];
    [self.navigationController pushViewController:addCardController animated:YES];
}

- (void) deleteCard {
    [[[ICCoreDataStack defaultStack] managedObjectContext] deleteObject:self.card];
    [[ICCoreDataStack defaultStack] saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareCard {
    NSString* message = [NSString stringWithFormat:@"\n Name: %@\n"
                           "\n Number: %@\n"
                           "\n Issued on: %@\n"
                           "\n Expiry on: %@\n", self.card.name, self.card.number, self.startDateLabel.text, self.endDateLabel.text];
    NSArray* objectsToShare = @[message, [UIImage imageWithData:self.card.frontImage], [UIImage imageWithData:self.card.backImage]];
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo, UIActivityTypeAssignToContact,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    controller.excludedActivityTypes = excludedActivities;
                                
    [self presentViewController:controller animated:YES completion:nil];
}

- (NSString*)getStartDateString {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.card.startDate];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    
    return [NSString stringWithFormat:@"%@ - %@ - %@",[@(day) stringValue], [@(month) stringValue], [@(year) stringValue]];

}

- (NSString*)getEndDateString {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.card.endDate];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    
    return [NSString stringWithFormat:@"%@ - %@ - %@",[@(day) stringValue], [@(month) stringValue], [@(year) stringValue]];
}

- (void)openBackImage:(UITapGestureRecognizer*)gesture {
    if (self.card.backImage) {
        ICImageViewController* backImageViewController = [[ICImageViewController alloc] init];
        backImageViewController.image = [UIImage imageWithData:self.card.backImage];
        
        [self.navigationController pushViewController:backImageViewController animated:YES];
    }
}

- (void)openFrontImage:(UITapGestureRecognizer*)gesture {
    if (self.card.frontImage) {
        ICImageViewController* frontImageViewController = [[ICImageViewController alloc] init];
        frontImageViewController.image = [UIImage imageWithData:self.card.frontImage];
    
        [self.navigationController pushViewController:frontImageViewController animated:YES];
    }
}

@end
