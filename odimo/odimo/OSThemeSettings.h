//
//  OSThemeSettings.h
//  odimo
//
//  Created by omid sharghi on 12/13/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSThemeSettings : NSObject
{
    CGFloat waveViewWidth;
}

@property (nonatomic) BOOL tableViewEditing;
-(BOOL) getTableViewEditing;



+(OSThemeSettings*) getInstance;
- (UIFont *)fontWithName:(NSString*)fontName
               smallSize:(NSInteger)s0
             regularSize:(NSInteger)s1
                 bigSize:(NSInteger)s2
                 biggest:(NSInteger)s3;

- (UIFont *) navAndToolBarFont;
-(UIFont*) directionLabelFont;
-(UIFont*) tapToPlayLabelFont;
-(UIFont*) directionLabelInitialFont;
-(UIFont*) cellLabelFont;
- (UIFont*) headingFont;

-(void) setWaveViewWidth: (CGFloat) width;
-(CGFloat) getWaveViewWidth;
-(CGFloat) moveViewValue;
-(CGFloat) moveImageUpValue;
-(CGFloat) moveImageDownValue;
-(CGFloat) getScreenHeight;





@end
