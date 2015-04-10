//
//  OSCreatePath.h
//  odimo
//
//  Created by omid sharghi on 7/27/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface OSCreatePath : NSObject

@property(nonatomic, strong) AVAsset * audioAsset;
@property (nonatomic, assign) CGSize imageSize;
@property(nonatomic, assign)CGFloat minAmpl;
@property(nonatomic,assign)CGFloat maxAmpl;



+(OSCreatePath*) getInstance;
-(UIBezierPath*) createPathWithAsset:(AVAsset*)theAsset andSize:(CGSize)viewSize;



@end
