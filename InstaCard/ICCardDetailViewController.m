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

#define kPadding 20

@interface ICCardDetailViewController ()
@end

@implementation ICCardDetailViewController

static NSString *kCardEditViewControllerStoryBoardID = @"cardEditViewController";

@synthesize card = _card;

#pragma mark View lifecycle
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
    
    if(!self.navigationItem.leftBarButtonItem && [self.navigationController.viewControllers count] > 1) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [backButton setImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [backButton setTitle:self.navigationItem.backBarButtonItem.title forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10.0f, 0, 0)];
        [backButton setAdjustsImageWhenHighlighted:NO];
        
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismissSelf {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setRightBarButtonItems {
    UIBarButtonItem* editButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStylePlain target:self action:@selector(editCard)];
    
    UIBarButtonItem* shareButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareCard)];
    
    UIBarButtonItem* deleteButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteCard)];
    
    editButtonItem.tintColor = shareButtonItem.tintColor = deleteButtonItem.tintColor = [UIColor blackColor];
    
    self.navigationItem.backBarButtonItem.tintColor = [UIColor blackColor];
    NSArray* rightButtons = @[shareButtonItem, editButtonItem, deleteButtonItem];
    self.navigationItem.rightBarButtonItems = rightButtons;
    
    NSLog(@"%f %f", editButtonItem.image.size.width, editButtonItem.image.size.height);
}

#pragma mark Utilities
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

- (BOOL)isValid:(NSString*)string {
    return string && ![string isEqualToString:@""];
}

#pragma mark Responders, Events
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
    NSString* message = @"";
    if ([self isValid:self.card.name]) message = [message stringByAppendingFormat:@"\n Name: %@\n", self.card.name];
    if ([self isValid:self.card.number]) message = [message stringByAppendingFormat:@"\n Number: %@\n", self.card.name];
    if (self.card.startDate) message = [message stringByAppendingFormat:@"\n Issued on: %@\n", self.startDateLabel.text];
    if (self.card.endDate) message = [message stringByAppendingFormat:@"\n Expiry on: %@\n", self.endDateLabel.text];
    
    NSMutableArray *objectsToShare = [[NSMutableArray alloc] init];
    if ([self isValid:message]) [objectsToShare addObject:message];
    if (self.card.frontImage) [objectsToShare addObject:[UIImage imageWithData:self.card.frontImage]];
    if (self.card.backImage) [objectsToShare addObject:[UIImage imageWithData:self.card.backImage]];
    
    if ([objectsToShare count]) {
        NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                        UIActivityTypePostToWeibo, UIActivityTypeAssignToContact,
                                        UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                        UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        controller.excludedActivityTypes = excludedActivities;
        
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        UIAlertView* alerView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Nothing to share!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alerView show];
    }
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
