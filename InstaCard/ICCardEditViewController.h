//
//  ICCardEditViewController.h
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 16/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "ICUtils.h"

@class ICCard;

@interface ICCardEditViewController : UIViewController

@property (nonatomic, strong) ICCard *card;
@property (nonatomic) ICCardType cardType;

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
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@property (nonatomic, strong) UIImage *frontImage;
@property (nonatomic, strong) UIImage *backImage;

- (IBAction)saveCard:(id)sender;

- (void)setCardType:(ICCardType)type;

@end
