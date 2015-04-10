//
//  OSAppDelegate.h
//  odimo
//
//  Created by omid sharghi on 4/24/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSPrimaryUser.h"


@interface OSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) OSPrimaryUser * primaryUser;
//@property (nonatomic, strong) NSString * returnFromBackground;


@end
