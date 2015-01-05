//
//  ICCardViewController.h
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 16/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "REMenu.h"

@class ICCard;

@interface ICCardViewController : UICollectionViewController
{
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    
    BOOL _pinValidated;
    ICCard *_selectedCard;
    NSString *_inputPIN;
}

@property (nonatomic) int16_t viewType;
@property (strong, readonly, nonatomic) REMenu *menu;

- (void)toggleMenu;
- (IBAction)addCard:(id)sender;

@end

