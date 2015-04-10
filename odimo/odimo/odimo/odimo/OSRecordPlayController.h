//
//  OSRecordPlayController.h
//  odimo
//
//  Created by omid sharghi on 4/29/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "OSPrimaryUser.h"
#import "OSManagedDocument.h"
#import "OSAudioTableCell.h"



@interface OSRecordPlayController : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate, AVAudioSessionDelegate>


@property (nonatomic, strong) OSPrimaryUser * primaryUser;
@property (nonatomic, strong) OSManagedDocument * managedDocument;
@property (nonatomic, strong) AVAudioPlayer* player;
@property (nonatomic, strong) AVAudioRecorder * recorder;
@property (nonatomic, strong) AVAsset * songAsset;
@property (nonatomic, strong) NSURL * audioFileURL;


//-(void) setUpNov;

-(void) pickUpAfterTermination:(NSURL*)url;
-(NSMutableArray*) convertVectorToArray;
-(void) convertArrayToVector: (NSMutableArray*)array;
-(void) clearMemoryBuffer;



+(OSRecordPlayController*) getInstance;
-(void)setUpAudioFile;
-(void)recordAudio;

-(void) playAudio;
-(void) stopRecording;
-(void) saveRecording;
-(NSMutableDictionary*) obtainRecordingDictionary;
-(void) interruptionStop;
-(double) songDuration;




//-(NSMutableDictionary*) stopAndSave;
-(BOOL) recordingTime;
-(BOOL) recordingStatus;
-(void) stopPlayer;
-(void) stopAll;
-(void) clearRecorder;
-(void) enableLock;
-(void) activateEmergencyStop;
-(BOOL) isRecorderInitiated;

- (NSTimeInterval)currentTime;
- (NSTimeInterval)duration;

@end
