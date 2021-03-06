//
//  ICCardEditViewController.m
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 16/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "ICCardEditViewController.h"
#import "ICCard.h"
#import "ICCoreDataStack.h"

#define kOFFSET_FOR_KEYBOARD 80.0

@interface ICCardEditViewController () <UIActionSheetDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextFieldDelegate> {
    BOOL _editingBackImage;
    BOOL _editingFrontImage;
}

@end

@implementation ICCardEditViewController

static NSString *kCardEntity = @"ICCard";

@synthesize card = _card;
@synthesize cardType = _cardType;
@synthesize frontImage = _frontImage;
@synthesize backImage = _backImage;

#pragma mark View lifecycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initializeViewsBeneathView:self.view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _editingBackImage = _editingFrontImage = FALSE;
    
    if (self.card != nil) {
        self.cardType = self.card.type;
        self.title = self.card.cardName;
        
        self.cardNumbeTextField.text = self.card.number;
        self.cardTextField.text = self.card.cardName;
        self.personTextField.text = self.card.name;
        
        if (self.card.frontImage) {
            self.frontImage = [UIImage imageWithData:self.card.frontImage];
            [self.frontImageView setImage:self.frontImage];
        } else {
            [self.frontImageView setImage:[UIImage imageNamed:@"placeholder"]];
        }
        if (self.card.backImage) {
            self.backImage = [UIImage imageWithData:self.card.backImage];
            [self.backImageView setImage:self.backImage];
        } else {
            [self.backImageView setImage:[UIImage imageNamed:@"placeholder"]];
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
        [self.frontImageView setImage:[UIImage imageNamed:@"placeholder"]];
        [self.backImageView setImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    UITapGestureRecognizer* frontTouchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editFrontImage:)];
    [frontTouchGesture setNumberOfTapsRequired:1];
    [self.frontImageView setUserInteractionEnabled:YES];
    [self.frontImageView addGestureRecognizer:frontTouchGesture];
    UITapGestureRecognizer* backTouchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editBackImage:)];
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
    
    self.view.backgroundColor = [UIColor colorWithRed:0.667 green:0.69 blue:0.722 alpha:1];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismissSelf {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Utilities
- (NSString*)getIconName:(ICCardType)type {
    NSString* iconName;
    switch (type) {
        case ICBankCredit:
            iconName = @"credit";
            break;
        case ICBankDebit:
            iconName = @"debit";
            break;
        case ICLoyalty:
            iconName = @"loyalty";
            break;
        case ICPolicy:
            iconName = @"policies";
            break;
        default:
            iconName = @"default";
            break;
    }
    return iconName;
}

- (BOOL)isEmpty:(NSString*)string {
    return (string == nil || (string && [string isEqualToString:@""]));
}

- (BOOL)isStartDateValid {
    return ![self isEmpty:self.startDDTextField.text] && ![self isEmpty:self.startMMTextField.text] && ![self isEmpty:self.startYYTextField.text];
}

- (BOOL)isEndDateValid {
    return ![self isEmpty:self.endDDTextField.text] && ![self isEmpty:self.endMMTextField.text] && ![self isEmpty:self.endYYTextField.text];
}

#pragma mark
- (void)addCard{
    ICCoreDataStack* coreDataStack = [ICCoreDataStack defaultStack];
    ICCard *newCard = [NSEntityDescription insertNewObjectForEntityForName:kCardEntity inManagedObjectContext:coreDataStack.managedObjectContext];
    
    newCard.name = self.personTextField.text;
    newCard.cardName = self.cardTextField.text;
    newCard.number = self.cardNumbeTextField.text;
    newCard.type = _cardType;
    if (self.frontImage) {
        newCard.frontImage = UIImageJPEGRepresentation(self.frontImage, 0.75);
    }
    if (self.backImage) {
        newCard.backImage = UIImageJPEGRepresentation(self.backImage, 0.75);
    }
    
    if ([self isStartDateValid]) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:[self.startDDTextField.text integerValue]];
        [components setMonth:[self.startMMTextField.text integerValue]];
        [components setYear:[self.startYYTextField.text integerValue]];
        
        NSDate* date = [calendar dateFromComponents:components];
        newCard.startDate = [date timeIntervalSince1970];
    }
    if ([self isEndDateValid]) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:[self.endDDTextField.text integerValue]];
        [components setMonth:[self.endMMTextField.text integerValue]];
        [components setYear:[self.endYYTextField.text integerValue]];
        
        NSDate* date = [calendar dateFromComponents:components];
        newCard.endDate = [date timeIntervalSince1970];
    }
    
    newCard.iconName = [self getIconName:self.card.type];
    newCard.createdAt = [[NSDate date] timeIntervalSince1970];
    [coreDataStack saveContext];
}

- (void)updateCard {
    self.card.name = self.personTextField.text;
    self.card.cardName = self.cardTextField.text;
    self.card.number = self.cardNumbeTextField.text;
    
    if (self.frontImage) {
        self.card.frontImage = UIImageJPEGRepresentation(self.frontImage, 0.75);
    }
    if (self.backImage) {
        self.card.backImage = UIImageJPEGRepresentation(self.backImage, 0.75);
    }
    
    if ([self isStartDateValid]) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:[self.startDDTextField.text integerValue]];
        [components setMonth:[self.startMMTextField.text integerValue]];
        [components setYear:[self.startYYTextField.text integerValue]];
        
        NSDate* date = [calendar dateFromComponents:components];
        self.card.startDate = [date timeIntervalSince1970];
    }
    if ([self isEndDateValid]) {
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

- (void)promptForSource {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Change Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Roll", nil];
    
    [actionSheet showInView:self.view];
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

#pragma mark Responders, Events
- (void)updateCardDetailView {
    NSDictionary* dictionary = [NSDictionary dictionaryWithObject:self.card forKey:@"card"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCardDetails" object:nil userInfo:dictionary];
}

- (IBAction)saveCard:(id)sender {
    if ([self isEmpty:self.cardTextField.text]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Missing Name" message:@"Card Name must not be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (self.card != nil) {
        [self updateCard];
        [self updateCardDetailView];
    } else {
        [self addCard];
    }
    [self dismissSelf];
}

- (void)editBackImage:(UITapGestureRecognizer*)gesture {
    _editingFrontImage = FALSE;
    _editingBackImage = TRUE;
    [self promptForImage];
}

- (void)editFrontImage:(UITapGestureRecognizer*)gesture {
    _editingFrontImage = TRUE;
    _editingBackImage = FALSE;
    [self promptForImage];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self promptForCamera];
        } else {
            [self promptForPhotoRoll];
        }
    }
}

#pragma mark Keyboard View

- (void)initializeViewsBeneathView:(UIView*)view {
    for ( UIView *childView in view.subviews ) {
        if ( ([childView isKindOfClass:[UITextField class]] || [childView isKindOfClass:[UITextView class]]) ) {
            [self initializeView:childView];
        } else {
            [self initializeViewsBeneathView:childView];
        }
    }
}

- (void)initializeView:(UIView*)view {
    if ( [view isKindOfClass:[UITextField class]] && (![(UITextField*)view delegate] || [(UITextField*)view delegate] == self) ) {
        [(UITextField*)view setDelegate:self];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)sender {
    if  (self.view.frame.origin.y < 0) {
        [self setViewMovedUp:NO];
    }
    [sender resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if ([sender isEqual:self.startDDTextField] || [sender isEqual:self.startMMTextField] || [sender isEqual:self.startYYTextField] || [sender isEqual:self.endDDTextField] || [sender isEqual:self.endMMTextField] || [sender isEqual:self.endYYTextField]) {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0) {
            [self setViewMovedUp:YES];
        }
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    if (_editingFrontImage == TRUE) {
        self.frontImage = image;
        [self.frontImageView setImage:image];
    } else if (_editingBackImage == TRUE) {
        self.backImage = image;
        [self.backImageView setImage:image];
    }
    
    _editingFrontImage = _editingBackImage = FALSE;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
