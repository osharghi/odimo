//
//  OSWaveformView.m
//  odimo
//
//  Created by omid sharghi on 7/19/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import "OSWaveformView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIBezierPath+Smoothing.h"

@interface OSWaveformView()
@property (nonatomic, strong) CAShapeLayer* blueWave;
@property (nonatomic, strong) CAShapeLayer* redWave;
@end

@implementation OSWaveformView


- (void)initialize {
    self.data = @[[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                  [NSValue valueWithCGPoint:CGPointMake(10, 10)],
                  [NSValue valueWithCGPoint:CGPointMake(20, 50)],
                  [NSValue valueWithCGPoint:CGPointMake(30, 20)],
                  [NSValue valueWithCGPoint:CGPointMake(40, 10)],
                  [NSValue valueWithCGPoint:CGPointMake(50, 15)]
                  ];
    self.progress = 0.25;
}

- (void)awakeFromNib {
    [self initialize];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (CAShapeLayer *) createShapeLayer {
    CAShapeLayer* layer = [[CAShapeLayer alloc] init];
    layer.lineWidth = 1;
    layer.fillColor = nil;
    return layer;
}

- (UIBezierPath*) createPath {
    NSMutableArray* data = [self.data mutableCopy];
    return [UIBezierPath smoothedPathWithGranularity:10 withPoints:data];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    self.redWave.strokeEnd = progress;
}

- (void)setData:(NSArray *)data {
    _data = data;
    [self render];
}

- (void)render {
    self.redWave.path = [self createPath].CGPath;
    self.blueWave.path = self.redWave.path;
}


- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    if (!self.blueWave) {
        self.blueWave = [self createShapeLayer];
        self.blueWave.strokeColor = [UIColor blueColor].CGColor;
        
        self.redWave = [self createShapeLayer];
        self.redWave.strokeColor = [UIColor redColor].CGColor;
        self.redWave.strokeEnd = self.progress;
        
        [self.layer addSublayer:self.blueWave];
        [self.layer insertSublayer:self.redWave above:self.blueWave];
        [self render];

    }
}

@end
