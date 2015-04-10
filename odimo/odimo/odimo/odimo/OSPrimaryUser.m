 //
//  OSPrimaryUser.m
//  odimo
//
//  Created by omid sharghi on 4/24/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import "OSPrimaryUser.h"

@implementation OSPrimaryUser

+(OSPrimaryUser*) getUserInstance
{
    static OSPrimaryUser* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[OSPrimaryUser alloc] init];
    });
    return _instance;
}

-(void) incrementRecordingNumber
{
    self.recordingNumber = [NSNumber numberWithInt:[self.recordingNumber intValue] + 1];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.recordingNumber forKey:@"recordingNumber"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    NSLog(@"Incremeted recording Number %@", self.recordingNumber);

}

-(void) decrementRecordingNumber
{
    self.recordingNumber = [NSNumber numberWithInteger:[self.recordingNumber intValue] - 1];
//    NSLog(@"decremeted recording Number  %@", self.recordingNumber);
    
}

-(void) restartRecordingNumber
{
    self.recordingNumber = [NSNumber numberWithInteger:1];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.recordingNumber forKey:@"recordingNumber"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    NSLog(@"Incremeted recording Number %@", self.recordingNumber);
}

-(void) hideFirstTimePopUp
{
    self.firstTimeAppOpened = [NSNumber numberWithInteger:1];
    [[NSUserDefaults standardUserDefaults] setObject:self.firstTimeAppOpened forKey:@"firstTimeAppOpened"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
}

-(void) storeTrackWaitingStatus
{
//    self.waitingTrackToSave = [NSNumber numberWithInt:1];
    self.waitingTrackToSave = @"YES";
    [[NSUserDefaults standardUserDefaults] setObject:self.waitingTrackToSave forKey:@"waitingTrackToSave"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void) storeTrackWaitingURL:(NSURL*)url
{
    
    self.waitingURL = url;
//    [[NSUserDefaults standardUserDefaults] setObject:self.waitingURL forKey:@"waitingTrackURL"];
    
    [[NSUserDefaults standardUserDefaults] setURL:self.waitingURL forKey:@"waitingTrackURL"];

    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) storeAudioSamplesArray:(NSMutableArray*) array
{
    NSLog(@"ARRAY COUNT %lu", (unsigned long)array.count);
    
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"waitingTrackSamples"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

-(NSMutableArray*) retrieveAudioSamples
{
    NSMutableArray * dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"waitingTrackSamples"];
    
    NSLog(@"DATA ARRAY COUNT RETRIVEAL %lu", (unsigned long)dataArray.count);
    
    return dataArray;
}

-(NSURL*) retrieveTrackWaitingURL
{
    self.waitingURL = [[NSUserDefaults standardUserDefaults] URLForKey:@"waitingTrackURL"];
    return  self.waitingURL;
}

-(void) retrieveTrackWaitingStatus
{
    
    self.waitingTrackToSave = [[NSUserDefaults standardUserDefaults] stringForKey:@"waitingTrackToSave"];
}


-(void) resetTrackWaitingStatus
{
    self.waitingTrackToSave = @"NO";
    [[NSUserDefaults standardUserDefaults] setObject:self.waitingTrackToSave forKey:@"waitingTrackToSave"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void) resetArray
{
    NSMutableArray * array = [NSMutableArray array];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"waitingTrackSamples"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
