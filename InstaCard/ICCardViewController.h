//
//  ICCardViewController.h
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 16/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

@interface ICCardViewController : UICollectionViewController
{
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    NSMutableArray *_colorsArray;
    
    int16_t _viewType;
}

- (void)setViewType:(int16_t)type;
- (IBAction)addCard:(id)sender;

@end

