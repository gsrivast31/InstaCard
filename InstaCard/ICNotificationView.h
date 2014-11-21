//
//  ICNotificationView.h
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 21/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

@interface ICNotificationView : UIView {
    NSString *text;
}

@property (nonatomic, retain) NSString *text;

- (id)initWithText:(NSString*)text;
- (void)show;

@end
