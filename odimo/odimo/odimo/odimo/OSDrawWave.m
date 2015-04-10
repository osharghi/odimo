//
//  OSDrawWave.m
//  testWave
//
//  Created by omid sharghi on 6/1/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import "OSDrawWave.h"

@implementation OSDrawWave
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


-(void) prepWave
{
    [self setNeedsDisplay];

}

- (void)animateWave {
    
    [self.layer removeAllAnimations];
    
    self.transform=CGAffineTransformIdentity;

    [UIView animateWithDuration:3 delay:0.0 options: UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction  animations:^{
        
        self.transform = CGAffineTransformMakeTranslation(self.frame.size.width/2,0);
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformMakeTranslation(-self.frame.size.width/2, 0);
    }];
    
    
}

-(void) fadeInAnimation
{
    
    [UIView animateWithDuration:0 animations:^{
        self.alpha = 1.0;}];
}

-(void) fadeOutAnimation
{
    [UIView animateWithDuration:3 animations:^{
        self.alpha = 0.0;}];
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{    
    self.yc = 30;//The height of a crest.
    float w = 0;//starting x value.
    float y = rect.size.height;
    float width = rect.size.width;
    int cycles = 6;//number of waves
    self.x = width/cycles;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGContextSetLineWidth(context, 2);
    while (w <= width) {
        CGPathMoveToPoint(path, NULL, w,y/2);
        CGPathAddQuadCurveToPoint(path, NULL, w+self.x/4, y/2 - self.yc, w+self.x/2, y/2);
        CGPathAddQuadCurveToPoint(path, NULL, w+3*self.x/4, y/2 + self.yc, w+self.x, y/2);
        w+=self.x;
    }
    CGContextAddPath(context, path);
    [[UIColor colorWithRed:107/255.0f green:212/255.0f blue:231/255.0f alpha:1.0f]setStroke];
    CGContextDrawPath(context, kCGPathStroke);
    self.alpha= 0.0;
}


@end
