//
//  OSWaveView.h
//  odimo
//
//  Created by omid sharghi on 5/10/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
//@import CoreFoundation;
//@import CoreAudio;

#import <CoreFoundation/CoreFoundation.h>
#import <AVFoundation/AVFoundation.h>
#import "OSPrimaryUser.h"
#import "OSCreatePath.h"
#import "OSThemeSettings.h"


@interface OSWaveView : UIView


@property(nonatomic, readwrite, assign) CGSize imageViewSize;
@property (nonatomic) float progress;
@property (nonatomic, strong) OSPrimaryUser *primaryUser;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) UIBezierPath * path;
@property(nonatomic,assign)CGFloat minAmpl;
@property(nonatomic,assign)CGFloat maxAmpl;
@property (nonatomic, strong) CAShapeLayer* blueWave;
@property (nonatomic, strong) CAShapeLayer* redWave;
//@property (nonatomic) BOOL editing;
//@property (nonatomic) BOOL exitingEditing;
//@property (nonatomic) BOOL tableEditing;

@property (nonatomic, strong) OSThemeSettings * themeSettings;






@end
