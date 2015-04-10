//
//  OSThemeSettings.m
//  odimo
//
//  Created by omid sharghi on 12/13/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import "OSThemeSettings.h"

@implementation OSThemeSettings



+(OSThemeSettings*) getInstance
{
    static OSThemeSettings* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[OSThemeSettings alloc] init];
    });
    return _instance;
}

-(CGFloat) moveViewValue
{
    CGFloat deviceHeight = [self getScreenHeight];
    NSLog(@"Devie Height %f", deviceHeight);
    int moveConstant = (deviceHeight/1.90);
    
    if(deviceHeight==480)
    {
        moveConstant = (deviceHeight/2.55);
    }
    else if(deviceHeight == 568)
    {
        moveConstant = (deviceHeight/2.1);
    }
    else if (deviceHeight == 667)
    {
        moveConstant = (deviceHeight/2.0);
    }
    else if (deviceHeight == 736)
    {
        moveConstant = (deviceHeight/2.0);
    }
    NSLog(@"Devie Height %f", deviceHeight);

    
    return moveConstant;

}

-(CGFloat) moveImageUpValue
{
    
    CGFloat deviceHeight = [self getScreenHeight];
    NSLog(@"Devie Height %f", deviceHeight);
    
    int moveImageUpConstant = 13;
    
    if(deviceHeight==480)
    {
        moveImageUpConstant = 15;
    }
    else if(deviceHeight == 568)
    {
        moveImageUpConstant = 15;
    }
    else if (deviceHeight == 667)
    {
        moveImageUpConstant = 15;
    }
    else if (deviceHeight == 736)
    {
        moveImageUpConstant = 15;
    }
    NSLog(@"Devie Height %f", deviceHeight);
    
    
    return moveImageUpConstant;
    
}

-(CGFloat) moveImageDownValue
{
    CGFloat deviceHeight = [self getScreenHeight];
    NSLog(@"Devie Height %f", deviceHeight);
    int moveImageDownConstant = moveImageDownConstant = (deviceHeight/6.53);
    
    if(deviceHeight==480)
    {
        moveImageDownConstant = 50;
    }
    else if(deviceHeight == 568)
    {
        moveImageDownConstant = 100;
    }
    else if (deviceHeight == 667)
    {
        moveImageDownConstant = 100;
    }
    else if (deviceHeight == 736)
    {
        moveImageDownConstant = 100;
    }
    NSLog(@"Devie Height %f", deviceHeight);
    
    
    return moveImageDownConstant;
}


- (UIFont *)fontWithName:(NSString*)fontName
               smallSize:(NSInteger)s0
             regularSize:(NSInteger)s1
                 bigSize:(NSInteger)s2
                 biggest:(NSInteger)s3 {
    
    
    CGFloat deviceHeight = [self getScreenHeight];
    NSInteger size = s2;
    
    if(deviceHeight == 480)
    {
        size = s0;
    }
    else if(deviceHeight == 568)
    {
        size = s1;
    }
    else if (deviceHeight == 667)
    {
        size = s2;
    }
    else if (deviceHeight == 736)
    {
        size = s3;
    }
    
    return [UIFont fontWithName:fontName size:size];
    
}

- (UIFont *) navAndToolBarFont
{
    CGFloat deviceHeight = [self getScreenHeight];
    NSInteger size = 18;
    
    if(deviceHeight == 480)
    {
        size = 16;
    }
    else if(deviceHeight == 568)
    {
        size = 17;
    }
    else if (deviceHeight == 667)
    {
        size = 18;
    }
    else if (deviceHeight == 736)
    {
        size = 21;
    }
    
    return [UIFont fontWithName:@"Raleway-Bold" size:size];
    
}

-(UIFont*) directionLabelFont
{
    CGFloat deviceHeight = [self getScreenHeight];
    NSInteger size = 21;
    
    if(deviceHeight == 480)
    {
        size = 17;
    }
    else if(deviceHeight == 568)
    {
        size = 20;
    }
    else if (deviceHeight == 667)
    {
        size = 21;
    }
    else if (deviceHeight == 736)
    {
        size = 24;
    }
    
    return [UIFont fontWithName:@"Raleway-SemiBold" size:size];
}

-(UIFont*) directionLabelInitialFont
{
    CGFloat deviceHeight = [self getScreenHeight];
    NSInteger size = 21;
    
    if(deviceHeight ==480)
    {
        size = 17;
    }
    else if(deviceHeight == 568)
    {
        size = 18;
    }
    else if (deviceHeight == 667)
    {
        size = 19;
    }
    else if (deviceHeight == 736)
    {
        size = 22;
    }
    
    return [UIFont fontWithName:@"Raleway-SemiBold" size:size];
}


-(UIFont*) tapToPlayLabelFont
{
    CGFloat deviceHeight = [self getScreenHeight];
    NSInteger size = 15;
    
    if(deviceHeight == 480)
    {
        size = 13;
    }
    else if(deviceHeight == 568)
    {
        size = 14;
    }
    else if (deviceHeight == 667)
    {
        size = 15;
    }
    else if (deviceHeight == 736)
    {
        size = 18;
    }
    
    return [UIFont fontWithName:@"Raleway-SemiBold" size:size];
    
    
}

-(UIFont*) cellLabelFont
{
    CGFloat deviceHeight = [self getScreenHeight];
    NSInteger size = 13;
    
    if(deviceHeight==480)
    {
         size = 12;
    }
    else if(deviceHeight == 568)
    {
        size = 12;
    }
    else if (deviceHeight == 667)
    {
        size = 13;
    }
    else if (deviceHeight == 736)
    {
        size = 16;
    }
    
    return [UIFont fontWithName:@"Raleway-SemiBold" size:size];
    
}




-(CGFloat) getScreenHeight
{
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    return screenHeight;
}



- (UIFont *)headingFont {
    return [self fontWithName:@"Raleway-Regular" smallSize:8 regularSize:10 bigSize:11 biggest:12];
}

- (UIFont *)controlFont {
    return [self fontWithName:@"Arial" smallSize:8 regularSize:10 bigSize:11 biggest:12];
}

-(void) setWaveViewWidth: (CGFloat) width
{
    if(waveViewWidth == 0.0f)
    {
        waveViewWidth = width;
        NSLog(@"waveViewWidth %f and sent width %f", waveViewWidth, width);
    }
}

-(CGFloat) getWaveViewWidth
{
    NSLog(@"Returned waveViewWidth %f", waveViewWidth);

    return waveViewWidth;
}

-(void) setTableViewEditing:(BOOL)tableViewEditing
{
    _tableViewEditing = tableViewEditing;
}

-(BOOL) getTableViewEditing
{
    return self.tableViewEditing;
}

@end
