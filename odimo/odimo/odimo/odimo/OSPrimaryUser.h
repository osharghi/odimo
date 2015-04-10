//
//  OSPrimaryUser.h
//  odimo
//
//  Created by omid sharghi on 4/24/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSPrimaryUser : NSObject



@property (nonatomic, strong) NSData * imageData;
@property (nonatomic, copy) NSString * objectID;

@property (nonatomic, strong) NSMutableArray *userAudioArray;
@property (nonatomic, strong) NSMutableArray *audioDataArray;


@property (nonatomic, strong) NSData * profileImageData;

@property (nonatomic, strong) NSNumber * recordingNumber;
@property (nonatomic, strong) NSNumber * firstTimeAppOpened;

@property (nonatomic, strong) NSString * waitingTrackToSave;

@property (nonatomic, strong) NSURL* waitingURL;


+(OSPrimaryUser*) getUserInstance;
-(void) decrementRecordingNumber;
-(void) incrementRecordingNumber;
-(void) restartRecordingNumber;
-(void) hideFirstTimePopUp;
-(void) storeTrackWaitingStatus;
-(void) storeTrackWaitingURL:(NSURL*)url;
-(void) storeAudioSamplesArray:(NSMutableArray*) array;

-(void) resetTrackWaitingStatus;
-(void) retrieveTrackWaitingStatus;
-(NSURL*) retrieveTrackWaitingURL;
-(NSMutableArray*) retrieveAudioSamples;
-(void) resetArray;






@end
