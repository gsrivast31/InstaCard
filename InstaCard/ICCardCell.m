//
//  ICCardCell.m
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 16/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "ICCardCell.h"
#import "ICCard.h"
#import "ICUtils.h"

@implementation ICCardCell

-(void) configureCellForCard:(ICCard *)card forIndex:(NSUInteger)index {
    self.backgroundColor = [ICUtils getColor:index];
    [self.name setText:card.cardName];
    [self.image setImage:[UIImage imageNamed:card.iconName]];
}
@end
