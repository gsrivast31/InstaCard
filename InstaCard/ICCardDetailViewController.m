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
#import "ICCoreDataStack.h"

@interface ICCardDetailViewController () <UIActionSheetDelegate>

@end

@implementation ICCardDetailViewController

static NSString *kCardEditViewControllerStoryBoardID = @"cardEditViewController";

@synthesize card = _card;

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.card.startDate];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
            NSInteger day = [components day];
            NSInteger month = [components month];
            NSInteger year = [components year];
            
            self.startDateLabel.text = [NSString stringWithFormat:@"%@ - %@ - %@",[@(day) stringValue], [@(month) stringValue], [@(year) stringValue]];
        }
        if (self.card.endDate) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.card.endDate];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
            NSInteger day = [components day];
            NSInteger month = [components month];
            NSInteger year = [components year];
            
            self.endDateLabel.text = [NSString stringWithFormat:@"%@ - %@ - %@",[@(day) stringValue], [@(month) stringValue], [@(year) stringValue]];
        }
    }
    
    [self setRightBarButtonItems];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRightBarButtonItems {
    UIBarButtonItem* editButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStylePlain target:self action:@selector(editCard)];
    
    UIBarButtonItem* shareButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareCard)];
    
    UIBarButtonItem* deleteButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteCard)];
    
    NSArray* rightButtons = @[shareButtonItem, editButtonItem, deleteButtonItem];
    self.navigationItem.rightBarButtonItems = rightButtons;
}

- (void)editCard {
    ICCardEditViewController* addCardController = [self.storyboard instantiateViewControllerWithIdentifier:kCardEditViewControllerStoryBoardID];
//    addCardController.modalPresentationStyle = UIModalPresentationCustom;
//    addCardController.transitioningDelegate = self;
    addCardController.card = self.card;
    [addCardController setCardType:self.card.type];
    [self.navigationController pushViewController:addCardController animated:YES];
//    [self presentViewController:addCardController animated:YES completion:nil];
}

- (void) deleteCard {
    [[[ICCoreDataStack defaultStack] managedObjectContext] deleteObject:self.card];
    [[ICCoreDataStack defaultStack] saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareCard {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Export to PDF", @"Email Card", nil];
    
    [actionSheet showInView:self.view];
}

- (void)exportToPDF {
    
}

- (void)emailCard {
    
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self exportToPDF];
        } else {
            [self emailCard];
        }
    }
}

@end
