//
//  OSRecordPlayController.m
//  odimo
//
//  Created by omid sharghi on 4/29/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import "OSRecordPlayController.h"
#import <vector>
#import "UIBezierPath+Smoothing.h"
#import "Novocaine.h"

@interface OSRecordPlayController()
//@property (nonatomic, strong) AVAudioPlayer* player;
//@property (nonatomic, strong) AVAudioRecorder * recorder;
@property (nonatomic, strong) AVAudioPlayer* defaultPlayer;
@property (nonatomic) BOOL emergencyStopActivated;
@property (nonatomic) BOOL recordingInitiated;
@property(nonatomic, assign) std::vector<double>* memoryBuffer;
@property(nonatomic, assign)SInt16 minAmpl;
@property (nonatomic, strong) NSMutableDictionary * recordingPackage;



@end

@implementation OSRecordPlayController
{
//    NSURL * audioFileURL;
    int i;
    BOOL interruptedDuringRecording;
    BOOL recorderPaused;
    
    //Variable to check if there is already a recording within current allocation (
}

- (NSTimeInterval)duration
{
    return [self.player duration];
}

- (NSTimeInterval)currentTime
{
    return [self.player currentTime];
}

+(OSRecordPlayController*) getInstance
{
    
    static OSRecordPlayController* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[OSRecordPlayController alloc] init];
    });
    return _instance;
    
}

-(void)dealloc{
    [self stopAll];
    delete self.memoryBuffer;
}

-(void)initNovocaine{
//    [[Novocaine audioManager]setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
    [[Novocaine audioManager]setInputBlock:^(float *data, NSInteger numFrames, NSInteger numChannels) {
        double averagePowerForFrame = 0;
        for (int sample=0; sample < numFrames/numChannels; ++sample) {
            averagePowerForFrame += ABS(data[sample*numChannels]);
        }
        // write to memory
        self.memoryBuffer->push_back(averagePowerForFrame);
    }];
}

-(void)initPCMBufer{
    // pcm memory buffer
    self.memoryBuffer = new std::vector<double>;
}

//-(void) setUpNov
//{
//
//    [self initNovocaine];
//
//}

-(void)setUpAudioFile
{
    [self initNovocaine];
    [self initPCMBufer];
    
    self.primaryUser =[OSPrimaryUser getUserInstance];
    self.managedDocument = [OSManagedDocument getInstance];
    //Path is created in "OSRecordViewController" viewDidLoad
    
//    NSString * audioFile = @"Track";

    NSString * audioFile = @"00X00Record00X00Over00X00OTrack00X";
    
    audioFile = [audioFile stringByAppendingString:@".m4a"];
    
    NSString * folderName = @"audioFiles";
    
    NSURL * audioDataFolder = [self.managedDocument.url URLByAppendingPathComponent:folderName];
    self.audioFileURL = [audioDataFolder URLByAppendingPathComponent:audioFile];
    

//Removed CheckTrackExistsMethod

  
    [self.primaryUser storeTrackWaitingURL:self.audioFileURL];
    [self.primaryUser storeTrackWaitingStatus];

    
    
    NSError *error = nil;
    BOOL isDir = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioDataFolder.path isDirectory:&isDir]) {
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:audioDataFolder.path withIntermediateDirectories:NO attributes:nil error:&error];
        if (!success)
        {
            NSLog(@"Failed to create directory with error: %@", error);
        }
    }
    else
    {
        NSAssert(isDir, nil);
    }
    
//    NSDictionary * audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [NSNumber numberWithFloat:44100], AVSampleRateKey,
//                                    [NSNumber numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey,
//                                    [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
//                                    [NSNumber numberWithInt:AVAudioQualityMedium], AVEncoderAudioQualityKey, nil];
    
    
    
    
    NSDictionary * audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithFloat:44100], AVSampleRateKey,
                                    [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                    [NSNumber numberWithInt:AVAudioQualityMedium], AVEncoderAudioQualityKey, nil];
    
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                               error:nil];
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.audioFileURL settings:audioSettings error:nil];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    
    [self.recorder prepareToRecord];
    
}


-(void)recordAudio
{
    if(self.player.playing)
    {
        [_player stop];
    }
    
    if(!self.recorder.recording)
    {
        self.recordingInitiated = YES;
        [self.defaultPlayer play];
        //Recording gets initiated in audioPlayerDidFinishPlaying delegate method below
    }
    
}

-(void) stopRecording
{
    if(self.recorder.recording)
    {

        [self.recorder stop];
        NSLog(@"Audio File URL %@", self.audioFileURL);
        self.songAsset = [AVAsset assetWithURL:self.audioFileURL];
        [[Novocaine audioManager]pause];
    }
        [self enableLock];
}

-(void) interruptionStop
{
    [self.recorder stop];
    self.songAsset = [AVAsset assetWithURL:self.audioFileURL];
    [[Novocaine audioManager]pause];
    [self enableLock];
}


-(void) saveRecording
{
    self.primaryUser = [OSPrimaryUser getUserInstance];
    self.managedDocument = [OSManagedDocument getInstance];
    
    NSString * oldPath = [self.audioFileURL lastPathComponent];
    NSString * recordingNumber = [self.primaryUser.recordingNumber stringValue];
    self.audioFileURL = [self.audioFileURL URLByDeletingLastPathComponent];
    self.audioFileURL = [self.audioFileURL URLByDeletingPathExtension];
    
    NSString * audioFile = @"track";
    audioFile = [audioFile stringByAppendingString:recordingNumber];
    audioFile = [audioFile stringByAppendingString:@".m4a"];
    
    self.audioFileURL = [self.audioFileURL URLByAppendingPathComponent:audioFile];
    
    BOOL doesExist = [self.managedDocument checkForDuplicateRecording:audioFile];

    while(doesExist==YES)
    {
        
        self.audioFileURL = [self.audioFileURL URLByDeletingLastPathComponent];
        [self.primaryUser incrementRecordingNumber];
        NSString * newAudioFile = @"track";
        NSString * recordingNumber = [self.primaryUser.recordingNumber stringValue];
        newAudioFile = [newAudioFile stringByAppendingString:recordingNumber];
        newAudioFile = [newAudioFile stringByAppendingString:@".m4a"];
        self.audioFileURL = [self.audioFileURL URLByAppendingPathComponent:newAudioFile];
        doesExist = [self.managedDocument checkForDuplicateRecording:newAudioFile];
        
    }
    
    NSString * newPath = [self.audioFileURL lastPathComponent];

    [self.managedDocument changeFileNameBeforeSave:oldPath withNewPath:newPath];
    
    self.recordingPackage = [NSMutableDictionary dictionary];
    
    NSArray * cells = [[NSBundle mainBundle] loadNibNamed:@"audioTableCell"
                                                    owner:self
                                                  options:nil];
    
    OSAudioTableCell * myCell = [cells objectAtIndex: 0];
    
    float borderSize = 10;

    
    UIBezierPath * path = [self pathWithSize: myCell.waveView.bounds.size borderSize:borderSize];

    NSData *bezierData = [NSKeyedArchiver archivedDataWithRootObject:path];
    NSNumber * minAmpl = [NSNumber numberWithFloat: self.minAmpl];
    
    
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setActive:NO error:nil];
    
    
    [self.recordingPackage setObject:bezierData forKey:@"waveData"];
    [self.recordingPackage setObject:minAmpl forKey:@"minAmpl"];
    [self.recordingPackage setObject:self.audioFileURL forKey:@"audioURL"];
    [self.recordingPackage setObject:[NSString stringWithFormat:@""] forKey:@"track label"];
    
    //REMOVE THIS
    
//    NSLog(@"Recording Number %@", self.primaryUser.recordingNumber);
    [self.recordingPackage setObject:self.primaryUser.recordingNumber forKey:@"recordingNumber"];
    
    
}

-(NSMutableDictionary*) obtainRecordingDictionary
{
    return self.recordingPackage;
}




-(AVAudioPlayer*)defaultPlayer{
    if (!_defaultPlayer) {
        NSURL *soundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                  pathForResource:@"begin_record"
                                                  ofType:@"mp3"]];
        _defaultPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
        self.defaultPlayer.delegate = self;
    }
    return _defaultPlayer;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if(flag && player == self.defaultPlayer)
    {
        [self setUpAudioFile];
        AVAudioSession * audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:YES error:nil];
        if(self.emergencyStopActivated == NO)
        {

            [self.recorder record];
            [[Novocaine audioManager]play];

            [self disableLock];
        }
        [self resetEmergencyStop];
        self.recordingInitiated = NO;
    }
    else if(flag && player == self.player)
    {
        [self enableLock];
    }
}

-(void) playAudio
{
    if(!self.recorder.recording)
    {
        if(!self.player.playing)
        {
            
            if(self.recorder.url == nil)
            {
            self.player =[[AVAudioPlayer alloc] initWithContentsOfURL:self.audioFileURL error:nil];
            }
            else
            {
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
            }
        

            [self.player setDelegate:self];
            [self.player play];
            [self disableLock];
        }
        else if(self.player.playing)
        {
            [self.player pause];
            [self enableLock];
        }

    }
    
}



-(BOOL) recordingStatus
{
    if(self.recorder.recording)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL) recordingTime
{
    if(self.recorder.currentTime > 0.5)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


-(void) stopPlayer
{
    if(self.player.playing)
    {
        [self.player stop];
        [self enableLock];
    }
}

-(void) stopAll
{
    if(self.recorder.recording)
    {
        [self.recorder stop];
        [[Novocaine audioManager]pause];
    }
    else if(self.player.playing)
    {
        [self.player stop];
        [self enableLock];
    }
}

-(void) clearRecorder
{
    self.recorder = nil;
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

-(void) activateEmergencyStop
{
    self.emergencyStopActivated = YES;
}

-(void) resetEmergencyStop
{
    if(self.emergencyStopActivated == YES)
    {
        self.emergencyStopActivated = NO;
    }
}

-(BOOL) isRecorderInitiated
{
    return self.recordingInitiated;
}

-(UIBezierPath*)pathWithSize:(CGSize)size borderSize:(float)borderSize{
    /*
     * amplitudes for pixels
     */
    float samplesInOnePixels = self.memoryBuffer->size() / size.width * 10;
    double averagePowerForPixel=0;
    int currentPixelNumber = 0;
    self.minAmpl = 0;
    NSMutableArray *pointsForInterpolation = [NSMutableArray array];
    for (int x=0; x<self.memoryBuffer->size(); ++x) {
        averagePowerForPixel -= ABS(self.memoryBuffer->at(x));
        if((x/samplesInOnePixels-1)>currentPixelNumber){
            [pointsForInterpolation addObject:[NSValue valueWithCGPoint:CGPointMake(currentPixelNumber, averagePowerForPixel)]];
            self.minAmpl = MIN(self.minAmpl, averagePowerForPixel);
            averagePowerForPixel = 0;
            ++currentPixelNumber;
        }
    }
    
    NSLog(@"Size Width: %f", size.width);
    NSLog(@"Size height: %f", size.height);
    NSLog(@"minAMpl %hd", self.minAmpl);
    
    
    
    /*
     * Create path
     */
    UIBezierPath *path = [UIBezierPath smoothedPathWithGranularity:10 withPoints:pointsForInterpolation];
    
    // transform
    double heightCoef = (size.height - borderSize*2)/path.bounds.size.height;
    double widthCoef = size.width/path.bounds.size.width;
    // transform scale
    [path applyTransform:CGAffineTransformMakeScale(widthCoef, heightCoef)];
    // translation
    [path applyTransform:CGAffineTransformMakeTranslation(0, -path.bounds.origin.y + borderSize)];

//    [path applyTransform:CGAffineTransformMakeTranslation(0, -(self.minAmpl * heightCoef) + borderSize)];
    
    return path;
}


-(void) audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    
    NSNotificationQueue * queue = [NSNotificationQueue defaultQueue];
    NSNotification * notification = [NSNotification notificationWithName:@"interruption" object:nil userInfo:nil];
    [queue enqueueNotification:notification postingStyle:NSPostNow];
    

//    NSLog(@"Not Recording");

}

-(double) songDuration
{
    
        CMTime time = self.songAsset.duration;
        double durationInSeconds = CMTimeGetSeconds(time);
        NSLog(@"DURATION %f", durationInSeconds);
    
    
    return durationInSeconds;
}

-(void) pickUpAfterTermination:(NSURL*)url
{
    if(url != nil)
    {
        self.songAsset = [AVAsset assetWithURL:url];
        self.audioFileURL = url;
        self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:nil error:nil];
    }
}

-(NSMutableArray*) convertVectorToArray
{
    NSMutableArray *dataArray = [NSMutableArray array];
    
    NSLog(@"VECTOR COUNT %lu", self.memoryBuffer->size());
    
    for (int x=0; x<self.memoryBuffer->size(); ++x)
    {
        dataArray[x]= [NSNumber numberWithDouble:(self.memoryBuffer->at(x))];
    }
    
    NSLog(@"DATA ARRAY COUNT %lu", (unsigned long)dataArray.count);
    
    return dataArray;
}

-(void) convertArrayToVector: (NSMutableArray*)array;
{
//    [self clearMemoryBuffer];

//    self.memoryBuffer = new std::vector<double>(array.count);
    
    [self initPCMBufer];
    
    for (int x=0; x<array.count; ++x)
    {
        self.memoryBuffer->push_back([array[x] doubleValue]);
    }
    
    NSLog(@"VECTOR RETRIEVAL COUNT %lu", self.memoryBuffer->size());
    
    
}

-(void) clearMemoryBuffer
{
//    self.memoryBuffer->clear();
    delete self.memoryBuffer;
    
}


@end
