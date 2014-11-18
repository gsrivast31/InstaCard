//
//  ICCardDetailViewController.m
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 16/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "ICCardDetailViewController.h"
#import "ICCard.h"
#import "ICCoreDataStack.h"

@interface ICCardDetailViewController () <UIActionSheetDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
    BOOL _editingBackImage;
    BOOL _editingFrontImage;
    ICCardType _cardType;
}

@end

@implementation ICCardDetailViewController

static NSString *kCardEntity = @"ICCard";

@synthesize card = _card;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _editingBackImage = _editingFrontImage = FALSE;
    
    if (self.card != nil) {
        _cardType = self.card.type;
        self.title = self.card.cardName;
        
        self.cardNumbeTextField.text = self.card.number;
        self.cardTextField.text = self.card.cardName;
        self.personTextField.text = self.card.name;
        
        if (self.card.frontImage) {
            [self.frontImageView setImage:[UIImage imageWithData:self.card.frontImage]];
        }
        if (self.card.backImage) {
            [self.endImageView setImage:[UIImage imageWithData:self.card.backImage]];
        }
        if (self.card.startDate) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.card.startDate];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
            NSInteger day = [components day];
            NSInteger month = [components month];
            NSInteger year = [components year];
            self.startDDTextField.text = [@(day) stringValue];
            self.startMMTextField.text = [@(month) stringValue];
            self.startYYTextField.text = [@(year) stringValue];
        }
        if (self.card.endDate) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.card.endDate];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
            NSInteger day = [components day];
            NSInteger month = [components month];
            NSInteger year = [components year];
            self.endDDTextField.text = [@(day) stringValue];
            self.endMMTextField.text = [@(month) stringValue];
            self.endYYTextField.text = [@(year) stringValue];
        }
    } else {
        self.title = @"Add New Card";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismissSelf {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setCardType:(ICCardType)type {
    _cardType = type;
}

- (void)addCard{
    ICCoreDataStack* coreDataStack = [ICCoreDataStack defaultStack];
    ICCard *newCard = [NSEntityDescription insertNewObjectForEntityForName:kCardEntity inManagedObjectContext:coreDataStack.managedObjectContext];
    
    newCard.name = self.personTextField.text;
    newCard.cardName = self.cardTextField.text;
    newCard.number = self.cardNumbeTextField.text;
    newCard.type = _cardType;
    if (self.frontImageView.image) {
        newCard.frontImage = UIImageJPEGRepresentation(self.frontImageView.image, 0.75);
    }
    if (self.endImageView.image) {
        newCard.backImage = UIImageJPEGRepresentation(self.endImageView.image, 0.75);
    }
    
    if (self.startDDTextField.text && self.startMMTextField.text && self.startYYTextField.text) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:[self.startDDTextField.text integerValue]];
        [components setMonth:[self.startMMTextField.text integerValue]];
        [components setYear:[self.startYYTextField.text integerValue]];
        
        NSDate* date = [calendar dateFromComponents:components];
        newCard.startDate = [date timeIntervalSince1970];
    }
    if (self.endDDTextField.text && self.endMMTextField.text && self.endYYTextField.text) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:[self.endDDTextField.text integerValue]];
        [components setMonth:[self.endMMTextField.text integerValue]];
        [components setYear:[self.endYYTextField.text integerValue]];
        
        NSDate* date = [calendar dateFromComponents:components];
        newCard.endDate = [date timeIntervalSince1970];
    }
    
    newCard.createdAt = [[NSDate date] timeIntervalSince1970];
    [coreDataStack saveContext];
}

- (void)updateCard {
    self.card.name = self.personTextField.text;
    self.card.cardName = self.cardTextField.text;
    self.card.number = self.cardNumbeTextField.text;
    
    if (self.frontImageView.image) {
        self.card.frontImage = UIImageJPEGRepresentation(self.frontImageView.image, 0.75);
    }
    if (self.endImageView.image) {
        self.card.backImage = UIImageJPEGRepresentation(self.endImageView.image, 0.75);
    }

    if (self.startDDTextField.text && self.startMMTextField.text && self.startYYTextField.text) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:[self.startDDTextField.text integerValue]];
        [components setMonth:[self.startMMTextField.text integerValue]];
        [components setYear:[self.startYYTextField.text integerValue]];
        
        NSDate* date = [calendar dateFromComponents:components];
        self.card.startDate = [date timeIntervalSince1970];
    }
    if (self.endDDTextField.text && self.endMMTextField.text && self.endYYTextField.text) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:[self.endDDTextField.text integerValue]];
        [components setMonth:[self.endMMTextField.text integerValue]];
        [components setYear:[self.endYYTextField.text integerValue]];
        
        NSDate* date = [calendar dateFromComponents:components];
        self.card.endDate = [date timeIntervalSince1970];
    }
    
    [[ICCoreDataStack defaultStack] saveContext];
}

- (IBAction)saveCard:(id)sender {
    
    if (self.cardTextField.text == nil || [self.cardTextField.text isEqualToString:@""] ) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Missing Name" message:@"Card Name must not be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (self.card != nil) {
        [self updateCard];
    } else {
        [self addCard];
    }
    [self dismissSelf];
}

- (void)promptForSource {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Image Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Roll", nil];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self promptForCamera];
        } else {
            [self promptForPhotoRoll];
        }
    }
}

- (void)promptForCamera {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)promptForPhotoRoll {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)promptForImage {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self promptForSource];
    } else {
        [self promptForPhotoRoll];
    }
}

- (IBAction)editBackImage:(id)sender {
    _editingFrontImage = FALSE;
    _editingBackImage = TRUE;
    [self promptForImage];
}

- (IBAction)editFrontImage:(id)sender {
    _editingFrontImage = TRUE;
    _editingBackImage = FALSE;
    [self promptForImage];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    if (_editingFrontImage == TRUE) {
        [self.frontImageView setImage:image];
    } else if (_editingBackImage == TRUE) {
        [self.endImageView setImage:image];
    }
    
    _editingFrontImage = _editingBackImage = FALSE;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
