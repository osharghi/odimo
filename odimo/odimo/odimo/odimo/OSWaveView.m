//
//  OSWaveView.m
//  odimo
//
//  Created by omid sharghi on 5/10/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import "OSWaveView.h"
#import "UIBezierPath+Smoothing.h"


@interface OSWaveView ()

    @property(nonatomic,strong)AVAsset *audioAsset;
    @property(nonatomic,strong) NSMutableArray *wavePoints;
    @property (nonatomic, strong) NSMutableArray * pointsForInterpolation;



@end


@implementation OSWaveView
{

    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if(self)
    {
  
    }
    return self;
}


- (CAShapeLayer *) createShapeLayer {
    CAShapeLayer* layer = [[CAShapeLayer alloc] init];
    layer.lineWidth = 2;
    layer.fillColor = nil;

    
    
    return layer;
}


- (void)setProgress:(float)progress
{
    [CATransaction setDisableActions:YES];
    _progress = progress;
    [UIView setAnimationsEnabled:NO];
    self.redWave.strokeEnd = _progress;
    [CATransaction setDisableActions:NO];
    [UIView setAnimationsEnabled:YES];

}

- (void)render {

    self.redWave.path = self.path.CGPath;
    self.blueWave.path = self.redWave.path;

}



-(void) layoutSubviews
{
 
//    NSLog(@"From %d:%s", __LINE__, __PRETTY_FUNCTION__);
    [super layoutSubviews];
//    if (!self.blueWave) {
    
        self.blueWave = [self createShapeLayer];
    
    
        self.blueWave.strokeColor = [UIColor colorWithRed:107/255.0f green:212/255.0f blue:231/255.0f alpha:1.0f].CGColor;
    
        self.redWave = [self createShapeLayer];
        self.redWave.strokeColor = [UIColor redColor].CGColor;
        self.redWave.strokeEnd = self.progress;
    
        [self.layer addSublayer:self.blueWave];
        [self.layer insertSublayer:self.redWave above:self.blueWave];
    
        [self render];
    
//    }
    

}



//- (UIBezierPath*) createPath {
//
//    float borderSize = 10;
//
//    
//    CGFloat heightCoef = (self.imageSize.height - borderSize*2)/self.path.bounds.size.height;
//
//    CGFloat widthCoef = self.imageSize.width/self.path.bounds.size.width;
//    
////    // transform scale
//    [self.path applyTransform:CGAffineTransformMakeScale(widthCoef, heightCoef)];
//
//
////    // translation
//    [self.path applyTransform:CGAffineTransformMakeTranslation(0, -(self.minAmpl * heightCoef) + borderSize)];
//    
//    return self.path;
//}



#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]



@end
