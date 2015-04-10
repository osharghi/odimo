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

    CGFloat viewWidth;
    
    
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
    self.themeSettings = [OSThemeSettings getInstance];
    if (!self.blueWave)
    {
    
//        if(!self.tableEditing && viewWidth == 0.0f)
        if(!self.themeSettings.tableViewEditing && viewWidth == 0.0f)
        {
            [self.themeSettings setWaveViewWidth:self.bounds.size.width];
 
            viewWidth = [self.themeSettings getWaveViewWidth];

        }
        
        self.blueWave = [self createShapeLayer];
    
    
        self.blueWave.strokeColor = [UIColor colorWithRed:107/255.0f green:212/255.0f blue:231/255.0f alpha:1.0f].CGColor;
    
        self.redWave = [self createShapeLayer];
        self.redWave.strokeColor = [UIColor redColor].CGColor;
        self.redWave.strokeEnd = self.progress;
    
        [self.layer addSublayer:self.blueWave];
        [self.layer insertSublayer:self.redWave above:self.blueWave];
    
        
        CGRect pathBounds = self.path.bounds;
        CGFloat sizeAdjust;

//        if(self.tableEditing)
        if(self.themeSettings.tableViewEditing == YES)
        {
            viewWidth = [self.themeSettings getWaveViewWidth];
            sizeAdjust = viewWidth/ pathBounds.size.width;
        }
        else
        {
            sizeAdjust = self.bounds.size.width / pathBounds.size.width;

        }

//        CGFloat sizeAdjust = self.bounds.size.width / pathBounds.size.width;
    
        self.blueWave.transform = CATransform3DMakeScale(sizeAdjust, 1, 1);
        self.redWave.transform = CATransform3DMakeScale(sizeAdjust, 1, 1);
    
    
        [self render];
    
    }


    
//    NSLog(@"Exiting editing %i", self.exitingEditing);
    
//     if(self.exitingEditing == YES && self.bounds.size.width>self.path.bounds.size.width)
//     {
//         
//         self.blueWave = [self createShapeLayer];
//         
//         
//         self.blueWave.strokeColor = [UIColor colorWithRed:107/255.0f green:212/255.0f blue:231/255.0f alpha:1.0f].CGColor;
//         
//         self.redWave = [self createShapeLayer];
//         self.redWave.strokeColor = [UIColor redColor].CGColor;
//         self.redWave.strokeEnd = self.progress;
//         
//         [self.layer addSublayer:self.blueWave];
//         [self.layer insertSublayer:self.redWave above:self.blueWave];
//         
//         
//         
//         CGRect pathBounds = self.path.bounds;
//         CGFloat sizeAdjust = self.bounds.size.width / pathBounds.size.width;
//         
//         self.blueWave.transform = CATransform3DMakeScale(sizeAdjust, 1, 1);
//         self.redWave.transform = CATransform3DMakeScale(sizeAdjust, 1, 1);
//         
//         [self render];
//         
//     }
    
    
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

- (void)setPath:(UIBezierPath *)path {
    _path = path;
}

#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]



@end
