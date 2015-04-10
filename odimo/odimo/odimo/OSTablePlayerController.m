//
//  OSTablePlayerController.m
//  odimo
//
//  Created by omid sharghi on 5/12/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import "OSTablePlayerController.h"

@interface OSTablePlayerController()


@end

@implementation OSTablePlayerController


+(OSTablePlayerController*) getInstance
{
    
    static OSTablePlayerController* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[OSTablePlayerController alloc] init];
    
    });
    return _instance;
    
}

-(void) playAudio:(NSData*) audioData
{

    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                         error:nil];
    self.player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
    
    [self.player setDelegate:self];
    [self.player play];
    [self disableLock];
    
}

- (NSTimeInterval)duration
{
    return [self.player duration];
}

- (NSTimeInterval)currentTime
{
    return [self.player currentTime];
}

-(void) stopAudio
{
    if(self.player.playing)
    {
        [self.player stop];
        [self enableLock];
    }
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if(flag && player == self.player)
    {
        [self enableLock];
    }
}

-(void) disableLock
{
    if([UIApplication sharedApplication].idleTimerDisabled == NO)
    {
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    }
}

-(void) enableLock
{
    if([UIApplication sharedApplication].idleTimerDisabled == YES)
    {
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    }
}


@end
