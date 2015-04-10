//
//  OSTablePlayerController.h
//  odimo
//
//  Created by omid sharghi on 5/12/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface OSTablePlayerController : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer* player;
@property (atomic, assign) BOOL isPlayerPlaying;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) float pausedProgressValeue;

+(OSTablePlayerController*) getInstance;
-(void) playAudio:(NSData*) audioData;
-(void) stopAudio;
-(void) enableLock;
-(void) disableLock;




- (NSTimeInterval)currentTime;
- (NSTimeInterval)duration;

@end
