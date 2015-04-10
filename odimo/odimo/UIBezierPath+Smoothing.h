//
//  UIBezierPath+Smoothing.h
//  odimo
//
//  Created by omid sharghi on 7/27/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (Smoothing)
+ (UIBezierPath*)smoothedPathWithGranularity:(NSInteger)granularity withPoints:(NSMutableArray*)points;
@end
