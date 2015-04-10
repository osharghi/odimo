//
//  OSWaveformView.h
//  odimo
//
//  Created by omid sharghi on 7/19/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSWaveformView : UIView

/***
 * An array of CGPoints 
 */
@property (nonatomic, strong) NSArray* data;
@property (nonatomic) CGFloat progress;

@end
