//
//  ICCardCell.h
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 16/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ICCard;

@interface ICCardCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *image;

- (void)configureCellForCard:(ICCard*)card forIndex:(NSUInteger)index;

@end
