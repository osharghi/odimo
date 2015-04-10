//
//  OSDrawWave.h
//  testWave
//
//  Created by omid sharghi on 6/1/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSDrawWave : UIView

@property (nonatomic) CGFloat yc;
@property (nonatomic) CGFloat x;
-(void) animateWave;
-(void) prepWave;
-(void) fadeInAnimation;
-(void) fadeOutAnimation;
@end
