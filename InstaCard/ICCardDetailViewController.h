//
//  ICCardDetailViewController.h
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 16/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICUtils.h"

@class ICCard;

@interface ICCardDetailViewController : UIViewController

@property (nonatomic, strong) ICCard *card;
@property (weak, nonatomic) IBOutlet UITextField *cardTextField;
@property (weak, nonatomic) IBOutlet UITextField *personTextField;
@property (weak, nonatomic) IBOutlet UITextField *cardNumbeTextField;

@property (weak, nonatomic) IBOutlet UITextField *startDDTextField;
@property (weak, nonatomic) IBOutlet UITextField *startMMTextField;
@property (weak, nonatomic) IBOutlet UITextField *startYYTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDDTextField;
@property (weak, nonatomic) IBOutlet UITextField *endMMTextField;
@property (weak, nonatomic) IBOutlet UITextField *endYYTextField;

@property (weak, nonatomic) IBOutlet UIImageView *frontImageView;
@property (weak, nonatomic) IBOutlet UIImageView *endImageView;

- (IBAction)saveCard:(id)sender;
- (IBAction)editBackImage:(id)sender;
- (IBAction)editFrontImage:(id)sender;

- (void)setCardType:(ICCardType)type;

@end
