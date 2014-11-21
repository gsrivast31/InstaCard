//
//  ICNotificationView.m
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 21/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "ICNotificationView.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation ICNotificationView

@synthesize text;

- (CGRect) CGRectMakeFromCenterAndSize:(CGPoint)center withSize:(CGSize)size{
    return CGRectMake(center.x - size.width / 2.0, center.y - size.height / 2.0, size.width, size.height);
}

- (CGPoint) CGRectGetCenter:(CGRect)rect{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

- (CGFloat)findHeightForText:(NSString *)string havingWidth:(CGFloat)widthValue andFont:(UIFont *)font
{
    CGFloat result = font.pointSize+4;
    CGFloat width = widthValue;
    if (string) {
        CGSize textSize = { width, CGFLOAT_MAX };       //Width and height of text area
        CGSize size;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            //iOS 7
            CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:font}
                                              context:nil];
            size = CGSizeMake(frame.size.width, frame.size.height+1);
        }
        else {
            size = [text sizeWithFont:font constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
        }
        result = MAX(size.height, result); //At least one row
    }
    return result;
}

- (id) initWithText: (NSString*)t
{
    UIFont *font = [UIFont fontWithName: @"Helvetica" size: 20];

    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [self findHeightForText:t havingWidth:width andFont:font];
    
    CGFloat y = ([[UIScreen mainScreen] bounds].size.height - height)/2.0;
    if ( (self = [super initWithFrame: CGRectMake(0, y, width, height)]) != nil) {
        self.text = t;
        self.layer.zPosition = 100;
    }
    return self;
}

- (void) show {
    if (!self.superview) return;
    
    UIFont *font = [UIFont fontWithName: @"Helvetica" size: 20];
    
    CGSize size;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        NSMutableParagraphStyle* pStyle1 = [[NSMutableParagraphStyle alloc] init];
        pStyle1.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary* dict1 = [[NSDictionary alloc] initWithObjectsAndKeys:font, NSFontAttributeName, pStyle1, NSParagraphStyleAttributeName, nil];
        size = [self.text boundingRectWithSize:self.frame.size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:dict1 context:nil].size;
    }
    else {
        size = [self.text sizeWithFont:font constrainedToSize:self.frame.size lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    self.frame = [self CGRectMakeFromCenterAndSize:self.center withSize:CGSizeMake(size.width + 20, size.height + 10)];
    
    CGRect rect = self.bounds;
    CGFloat radius = 10.0;
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 255,255,255,1.0);
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius,
                    radius, M_PI / 4, M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius,
                            rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius,
                    rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius,
                    radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius,
                    -M_PI / 2, M_PI, 1);
    
    CGContextFillPath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        NSMutableParagraphStyle* pStyle2 = [[NSMutableParagraphStyle alloc] init];
        pStyle2.lineBreakMode = NSLineBreakByWordWrapping;
        pStyle2.alignment = NSTextAlignmentCenter;
        
        NSDictionary* dict2 = [[NSDictionary alloc] initWithObjectsAndKeys:font, NSFontAttributeName, pStyle2, NSParagraphStyleAttributeName, nil];
        
        [self.text drawInRect:CGRectMake(10, 5, size.width, size.height) withAttributes:dict2];
    } else {
        [self.text drawInRect:CGRectMake(10, 5, size.width, size.height) withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    imageView.frame = [self CGRectMakeFromCenterAndSize:[self CGRectGetCenter:self.bounds] withSize:image.size];
    [self addSubview: imageView];
    
    //[image writeToFile: @"notificationImage.png"];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.2, 0.2, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = 0.3;
    animation.delegate = self;
    
    [self.layer addAnimation:animation forKey:@"popup"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [UIView animateWithDuration: 0.5
                          delay: 0.5
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^(void) {
                         self.alpha = 0.0;
                     } 
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];		
}

@end
