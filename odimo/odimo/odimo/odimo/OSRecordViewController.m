//
//  OSRecordViewController.m
//  odimo
//
//  Created by omid sharghi on 4/28/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import "OSRecordViewController.h"


@interface OSRecordViewController ()
{
    NSData * waveFormImageData;
    NSMutableDictionary * recordingPackage;
    NSTimer * timer;
    AVURLAsset * songAsset;
    BOOL stopBlinking;
    BOOL viewIsUp;
    BOOL waitingTrackToSave;
    BOOL recordCalled;
    BOOL resignCalled;
    NSTimer * saveTimer;

}

@end

@implementation OSRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

-(void) viewDidDisappear:(BOOL)animated
{
    
//    [[OSRecordPlayController getInstance] enableLock];
    [self.recorder enableLock];
    
}

//- (void)traceNotifications:(NSNotification *)notification
//{
//    NSLog(@"received notification %@", [notification name]);
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
 
//    self.recorder = [[OSRecordPlayController alloc] init];
//    [self.recorder setUpNov];
    
    waitingTrackToSave = NO;
    viewIsUp = NO;
    
    [self setUpSine];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterResign:) name:UIApplicationWillResignActiveNotification object:nil];
    
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLaunch:) name:UIApplicationDidBecomeActiveNotification object:nil];
    

    stopBlinking = YES;
    
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:107/255.0f green:212/255.0f blue:231/255.0f alpha:1.0f];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.toolbar setTranslucent:NO];

    self.navigationController.toolbar.backgroundColor = [UIColor colorWithRed:107/255.0f green:212/255.0f blue:231/255.0f alpha:1.0f];
    
    self.navigationController.toolbar.barTintColor = [UIColor colorWithRed:107/255.0f green:212/255.0f blue:231/255.0f alpha:1.0f];
    
 

    
    
    //Set Nav Controller save Button
    [self.saveButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Raleway-Bold" size:17.0], NSFontAttributeName,
      [UIColor whiteColor], NSForegroundColorAttributeName,nil]
                          forState:UIControlStateNormal];
        self.saveButton.title = @"SAVE";

    
    //Set Nav Controller Library Button
    [self.libraryButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Raleway-Bold" size:17.0], NSFontAttributeName,
      [UIColor whiteColor], NSForegroundColorAttributeName,nil]
                                   forState:UIControlStateNormal];
        self.libraryButton.title = @"LIBRARY";
    
    //Set label fonts and visibility
    [self.recordLabel setFont:[UIFont fontWithName:@"Raleway-SemiBold" size:18]];
    [self.stopLabel setFont:[UIFont fontWithName:@"Raleway-SemiBold" size:18]];
    [self.recordingLabel setFont:[UIFont fontWithName:@"Raleway-Bold" size:18]];
    [self.stopLabel setHidden:YES];


    
    
    //Play Swipe down indicatior
    [self.playLabel setFont:[UIFont fontWithName:@"Raleway-SemiBold" size:14]];
    NSString * playDownArrowImagePath = [[NSBundle mainBundle] pathForResource:@"DownArrow" ofType:@"png"];
    self.playSwipeImageView.image = [UIImage imageWithContentsOfFile:playDownArrowImagePath];
    [self.playLabel setHidden:YES];
    [self.playSwipeImageView setHidden:YES];

    
    //Set Image paths and add to image views
    NSString * upArrowImagePath = [[NSBundle mainBundle] pathForResource:@"UpArrow" ofType:@"png"];
    self.upArrow.image = [UIImage imageWithContentsOfFile:upArrowImagePath];
    NSString * downArrowImagePath = [[NSBundle mainBundle] pathForResource:@"DownArrow" ofType:@"png"];
    self.downArrow.image = [UIImage imageWithContentsOfFile:downArrowImagePath];
    [self.downArrow setHidden:YES];
    NSString * micImagePath = [[NSBundle mainBundle] pathForResource:@"mic" ofType:@"png"];
    self.micImageView.image = [UIImage imageWithContentsOfFile:micImagePath];
    NSString * recordCicleImagePath = [[NSBundle mainBundle] pathForResource:@"RecordingLabelCircle" ofType:@"png"];
    self.recordingLabelCircle.image = [UIImage imageWithContentsOfFile:recordCicleImagePath];
    
    [self.recordingIndicatorView setHidden:YES];

    [self.view insertSubview:self.micImageView aboveSubview:self.panedView];
    
    

    //Initialize storage document
    self.managedDocument = [OSManagedDocument getInstance];
    [self.managedDocument setUpDocument];
    
    //Initialize user singleton
    self.primaryUser = [OSPrimaryUser getUserInstance];
    
    self.primaryUser.recordingNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"recordingNumber"];
    if(self.primaryUser.recordingNumber == nil)
    {
        self.primaryUser.recordingNumber = [NSNumber numberWithInt:1];
    }
    
    
    
    self.primaryUser.firstTimeAppOpened = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstTimeAppOpened"];


    UISwipeGestureRecognizer * swipeUpRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpSwipe:)];
    [self.panedView addGestureRecognizer:swipeUpRec];
    
    UISwipeGestureRecognizer * swipeDownRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDownSwipe:)];
    [self.panedView addGestureRecognizer:swipeDownRec];
    [self.view addGestureRecognizer:swipeDownRec];

    swipeUpRec.direction = UISwipeGestureRecognizerDirectionUp;
    swipeDownRec.direction = UISwipeGestureRecognizerDirectionDown;
    
    swipeDownRec.delaysTouchesBegan = NO;
    swipeUpRec.delaysTouchesBegan = NO;
    
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlay)];
    [self.panedView addGestureRecognizer:tapRec];

    self.waveView = [[OSWaveView alloc] init];

    if(!waitingTrackToSave)
    {
        [self disableSaveButton];
    }
    
    
    
}

-(void) viewWillAppear:(BOOL)animated
{

    
//    if(self.primaryUser.waitingTrackToSave == [NSNumber numberWithInt:1])
//    {
//        waitingTrackToSave = YES;
//        [self enableSaveButton];
//        [self hidePlayLabel];
//        [self.primaryUser resetTrackWaitingStatus];
//    }
    
    
    [self labelInstructions];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)handleUpSwipe:(UISwipeGestureRecognizer *)recognizer
{
    
    NSLog(@"Begin");

    if(!resignCalled)
    {
    recordCalled = YES;
        if(!resignCalled)
        {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAssert([NSThread isMainThread], nil);
            if(!resignCalled)
            {
                if (granted) {
                    // Microphone enabled code
                    [self beginRecord];
                }
                else {
                    // Microphone disabled code
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Odimo needs permission to use your microphone.  To grant permission go to Settings->Privacy->Microphone and enable Odimo." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                }
            }
        });
    }];
        }
    }

    if(self.saveButton.enabled)
    {
        [self disableSaveButton];
    }

}


-(void) beginRecord
{

    if(!resignCalled)
    {

    if(viewIsUp == NO)
    {
        
//        if(waitingTrackToSave)
//        {
//            [self.managedDocument newDeleteWaitingTrack];
//            waitingTrackToSave = NO;
//        }
        
        waitingTrackToSave = YES;
        [self.primaryUser storeTrackWaitingStatus];
        
        self.recorder = [[OSRecordPlayController alloc] init];
        
        [self.recorder stopPlayer];
        
        [self.sineWave animateWave];

        [self showSine];
        
//        [self.playLabel setHidden:YES];
        [self.recordLabel setHidden:YES];
        [self.upArrow setHidden:YES];
        [self.recordingIndicatorView setHidden:NO];
        [self flashOn:self.recordingIndicatorView];
    
        [UIView animateWithDuration:.20 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{

            [self moveViewsUp];
            [self.downArrow setHidden:NO];
            [self.stopLabel setHidden:NO];
            

        } completion:^(BOOL finished){
            
        stopBlinking = NO;

            
            
        }];
    
        
        
        [self.recorder recordAudio];
        waitingTrackToSave = YES;
        
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        
        [mainQueue addOperationWithBlock:^{
            
           saveTimer = [NSTimer scheduledTimerWithTimeInterval: 1.5 target: self selector:@selector(enableSaveButton)
                                           userInfo: nil repeats:NO];
            
        }];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruptionDetected) name:@"interruption" object:nil];
    }
    }
}

-(void) moveViewsUp
{
    if(!viewIsUp)
    {
    self.panedView.frame = CGRectOffset(self.panedView.frame, 0, -274);

   
        if(self.panedView.frame.origin.y < 0)
        {

            
            self.sineWave.frame = CGRectOffset(self.sineWave.frame, 0, -246);
            self.micImageView.frame = CGRectOffset(self.micImageView.frame, 0, -85.5);
            viewIsUp = YES;
            [self hidePlayLabel];
        }
    
    }
}

- (IBAction)handleDownSwipe:(UISwipeGestureRecognizer *)recognizer
{

    
    if(viewIsUp == YES && [self.recorder recordingStatus] && [self.recorder recordingTime])
    {
        if([self.recorder recordingTime])
        {
            waitingTrackToSave = YES;
            
        }
        
        
        if(self.panedView.frame.origin.y <0)
        {
            
            [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{

            [self moveViewsDown];
            [self adjustLabelsDoneRecording];



        } completion:^(BOOL finished){
            
            if(viewIsUp == NO)
            {
                [self onlyStopRecorder];
//                [self.sineWave.layer removeAllAnimations];
                [self.recordingIndicatorView.layer removeAllAnimations];
                [self hidePlayLabel];
                [self animatePlayLabel];
            }
            

            
        }];
            
        }
    }
}

-(void) moveViewsDown
{
    if(viewIsUp)
    {
    self.panedView.frame = CGRectOffset( self.panedView.frame, 0, 274);

        
        if(self.panedView.frame.origin.y == 0)
        {
            self.sineWave.frame = CGRectOffset(self.sineWave.frame, 0, 246);
            self.micImageView.frame = CGRectOffset(self.micImageView.frame, 0, 85.5);
            viewIsUp = NO;
            [self hidePlayLabel];
            [self removeLabelInstructions];
            [self.sineWave.layer removeAllAnimations];

        }
    }
}

-(IBAction) tapPlay
{
    if(waitingTrackToSave && self.playLabel.hidden == NO)
    {
        [self.recorder playAudio];
    }
}

- (void)updateProgress:(NSTimer *)timer {
    NSTimeInterval playTime = [self.recorder currentTime];
    NSTimeInterval duration = [self.recorder duration];

    float progress = playTime/duration;
    [self.waveView setProgress:progress];
    
}

-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if(flag)
    {
        [timer invalidate];
    }
}

-(IBAction)tapSave:(id)sender
{
    
    if([self.recorder recordingStatus] && [self.recorder recordingTime])
    {
//        [self stopRecording];
//        [self.recorder stopRecording];
        [self onlyStopRecorder];
        [self adjustLabelsDoneRecording];
        [self saveRecording];
        [self moveViewsDown];
        [self performSegueWithIdentifier:@"goToLibrary" sender:self];
    }

    else if([self.recorder isRecorderInitiated] && ![self.recorder recordingTime])
    {
        UIAlertView * saveAlert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Too fast! You've barely recorded anything!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [saveAlert show];
    }
    else if(!waitingTrackToSave && ![self.recorder recordingStatus])
    {
        
        UIAlertView * saveAlert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You haven't recorded anything!  Swipe up anywhere to make a recording." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [saveAlert show];
    }
    else if(waitingTrackToSave)
    {
        double songDuration = [self.recorder songDuration];
        
        if(songDuration>0.5)
        {
            [self.recorder stopPlayer];
            [self saveRecording];
            [self hidePlayLabel];
            [self performSegueWithIdentifier:@"goToLibrary" sender:self];
        }
        else
        {
            UIAlertView * saveAlert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You haven't recorded anything!  Swipe up anywhere to make a recording." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [saveAlert show];
        }
    }
    
}


-(void) setUpSine
{
    
        self.sineWave = [[OSDrawWave alloc] initWithFrame:CGRectMake(-1*self.view.bounds.size.width, self.view.bounds.size.height, 2*self.view.bounds.size.width, .3125*(2*self.view.bounds.size.width))];
    
        [self.sineWave setBackgroundColor:[UIColor clearColor]];
    
        [self.view insertSubview:self.sineWave belowSubview:self.panedView];
    
}

-(void) showSine
{

    [self.sineWave fadeInAnimation];

}

-(void) hideSine
{

    [self.sineWave fadeOutAnimation];
}

-(IBAction) tapLibrary
{
    
    
    if([self.recorder recordingStatus] && [self.recorder recordingTime])
    {
        [self onlyStopRecorder];
        UIAlertView * recordingAlert = [[UIAlertView alloc] initWithTitle:@"Save?" message:@"Would you like to save your current recording?" delegate:self cancelButtonTitle:@"Don't Save" otherButtonTitles: @"Save", nil];
        recordingAlert.tag = 1;
        [recordingAlert show];
        
    }
    else if([self.recorder recordingStatus] && ![self.recorder recordingTime])
    {
        UIAlertView * noRecordingAlert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Too fast!  You haven't recorded anything yet." delegate:self cancelButtonTitle:@"Stop" otherButtonTitles: @"Record", nil];
        noRecordingAlert.tag = 2;
        [noRecordingAlert show];
    }
    else
    {
        if(viewIsUp)
        {
            if([self.recorder isRecorderInitiated])
            {
                [self onlyStopRecorder];
                [self.recorder activateEmergencyStop];
                [self adjustLabelsDoneRecording];
                waitingTrackToSave = YES;
                [self emergencyDisableSaveButton];
                [self emergencyMoveViewsDown];

            }
        }
        
        [self.recorder stopPlayer];
        
        [self.sineWave.layer removeAllAnimations];
        [self.recordingIndicatorView.layer removeAllAnimations];

        [self performSegueWithIdentifier:@"goToLibrary" sender:self];
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1)
    {
        if (buttonIndex == 0)
        {
//            recordingPackage = [self.recorder stopAndSave];
//            [self stopRecording];
            waitingTrackToSave = YES;
            [self adjustLabelsDoneRecording];
            [self moveViewsDown];
//            [self onlyHideRecordView];
            [self performSegueWithIdentifier:@"goToLibrary" sender:self];

        }
        else
        {
            //Stop Recording
//            recordingPackage = [self.recorder stopAndSave];
//            [self stopRecording];
//            [self onlyHideRecordView];
            [self adjustLabelsDoneRecording];
            [self saveRecording];
            [self moveViewsDown];
            [self performSegueWithIdentifier:@"goToLibrary" sender:self];
        }
    }
    else if(alertView.tag == 2)
    {
        if (buttonIndex == 0)
        {
//            [self stopRecording];
            [self onlyStopRecorder];
            [self enableSaveButton];
            [self adjustLabelsDoneRecording];
            waitingTrackToSave = YES;
            [self moveViewsDown];
            [self performSegueWithIdentifier:@"goToLibrary" sender:self];
            
        }
    }
}


- (void)flashOff:(UIView *)v
{
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        self.recordingIndicatorView.alpha = 0.01;  //don't animate alpha to 0, otherwise you won't be able to interact with it
    } completion:^(BOOL finished) {
        
        if(stopBlinking == NO && viewIsUp)
        {
            [self flashOn:self.recordingIndicatorView];
        }
        
    }];
}

- (void)flashOn:(UIView *)v
{
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        self.recordingIndicatorView.alpha = 1;
    } completion:^(BOOL finished) {
        [self flashOff:self.recordingIndicatorView];
    }];
}

-(void) testAnimation: (UIView*)v
{
    while( stopBlinking == NO)
    {
        
    [UIView animateKeyframesWithDuration:.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAutoreverse animations:^{
        self.recordingIndicatorView.alpha = 0.01;

    } completion:^(BOOL finished) {
        self.recordingIndicatorView.alpha = 1.0;
    }];
    }

}



-(void)adjustLabelsDoneRecording
{
 
    stopBlinking = YES;

    
    [self hideSine];
    [self.recordLabel setHidden:NO];
    [self.upArrow setHidden:NO];
    [self.downArrow setHidden:YES];
    [self.stopLabel setHidden:YES];
    [self.recordingIndicatorView setHidden:YES];

}


-(void) onlyStopRecorder
{
    [self.recorder stopRecording];
    recordCalled = NO;
}


-(void) interruptionAnimation
{
    
    stopBlinking = YES;
    
    [self.recordLabel setHidden:NO];
    [self.upArrow setHidden:NO];
    [self.downArrow setHidden:YES];
    [self.stopLabel setHidden:YES];
    [self.recordingIndicatorView setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"interruption" object:nil];

}

-(void) saveRecording
{

        [self.recorder saveRecording];
        recordingPackage = [self.recorder obtainRecordingDictionary];
    
        [self addToDataArray:recordingPackage];
        [self.primaryUser incrementRecordingNumber];
        waitingTrackToSave = NO;
        [self.primaryUser resetTrackWaitingStatus];
        [self.primaryUser resetArray];
        [self disableSaveButton];
    
}


-(void) addToDataArray: (NSMutableDictionary*) package
{
    
    [self.managedDocument saveRecording:package inManagedObjectContext:self.managedDocument.managedObjectContext];
    
}


-(void) appDidEnterForeground:(NSNotification *)notification
{

    
    if( viewIsUp == NO)
    {
        [self.sineWave.layer removeAllAnimations];
    }
    else
    {
    [self.sineWave animateWave];
    }
    

    
}


-(void) appDidEnterResign:(NSNotification *)notification
{
    
    resignCalled = YES;

//    if(recordCalled)
//    {
//        [self.panedView.layer removeAllAnimations];
//        viewIsUp = NO;
//        waitingTrackToSave = NO;
//        [self moveViewsDown];
//        [self adjustLabelsDoneRecording];
//        [self onlyStopRecorder];
//        [self.sineWave.layer removeAllAnimations];
//    }
    
    if(self.recorder.player.playing)
    {
        [self.recorder stopPlayer];
    }
    
    if(viewIsUp == YES)
    {
        [self onlyStopRecorder];
        [self adjustLabelsDoneRecording];
        [self moveViewsDown];
        [self.sineWave.layer removeAllAnimations];
    }
    
    if(waitingTrackToSave)
    {
        [self.primaryUser storeTrackWaitingStatus];
        
        if(self.recorder.recorder.url != nil)
        {
            [self.primaryUser storeTrackWaitingURL:self.recorder.recorder.url];
        }
        else
        {
            [self.primaryUser storeTrackWaitingURL:self.storageURL];
        }
        
        NSMutableArray * dataArray = [self.recorder convertVectorToArray];
        
        [self.primaryUser storeAudioSamplesArray:dataArray];
        
    }


}

-(void) appDidEnterBackground:(NSNotification *)notification
{
    
//        if(viewIsUp == YES)
//        {
//            [self onlyStopRecorder];
//            [self adjustLabelsDoneRecording];
//            [self moveViewsDown];
//            [self.sineWave.layer removeAllAnimations];
//        }
//    
//    if(waitingTrackToSave)
//    {
//        [self.primaryUser storeTrackWaitingStatus];
//        
//        if(self.recorder.recorder.url != nil)
//        {
//            [self.primaryUser storeTrackWaitingURL:self.recorder.recorder.url];
//        }
//        else
//        {
//            [self.primaryUser storeTrackWaitingURL:self.storageURL];
//        }
//        
//        NSMutableArray * dataArray = [self.recorder convertVectorToArray];
//        
//        [self.primaryUser storeAudioSamplesArray:dataArray];
//
//    }

}

-(void) appDidTerminate:(NSNotification *)notification
{
    
    if(viewIsUp == YES && [self.recorder recordingStatus])
    {
        [self onlyStopRecorder];
        [self adjustLabelsDoneRecording];
        waitingTrackToSave = YES;
        [self moveViewsDown];
        [self.sineWave.layer removeAllAnimations];
        [self.recordingIndicatorView.layer removeAllAnimations];
    }

//    if(waitingTrackToSave)
//    {
//        
//        [self.recorder clearMemoryBuffer];
//    }

}

-(void) didLaunch:(NSNotification *)notification
{

    
    resignCalled = NO;
    
    self.primaryUser = [OSPrimaryUser getUserInstance];
    [self.primaryUser retrieveTrackWaitingStatus];
    self.managedDocument = [OSManagedDocument getInstance];
    
    if([self.primaryUser.waitingTrackToSave isEqualToString:@"YES"])
        {
            waitingTrackToSave = YES;
            
            self.storageURL = [self.primaryUser retrieveTrackWaitingURL];

            if(self.storageURL !=nil )
            {

                self.recorder = [[OSRecordPlayController alloc] init];
                [self.recorder pickUpAfterTermination:self.storageURL];
                self.managedDocument.testPath = self.storageURL;

                
                double songDuration = [self.recorder songDuration];
                
                if(songDuration > 0.5)
                {
                
                    NSMutableArray * array = [self.primaryUser retrieveAudioSamples];
                    if(array.count >0)
                    {
                        [self.recorder convertArrayToVector:array];
                        waitingTrackToSave = YES;
                        [self enableSaveButton];
                        [self hidePlayLabel];
                    }
                    else
                    {
                        
                        [self.managedDocument newDeleteWaitingTrack];
                        waitingTrackToSave = NO;
                        [self disableSaveButton];
                        [self hidePlayLabel];
                        [self.primaryUser resetTrackWaitingStatus];
                        [self.managedDocument fetchControllerFiles];
                    }
                }
                else
                {
                    
                    self.managedDocument.testPath = self.storageURL;
                    [self.managedDocument newDeleteWaitingTrack];
                    waitingTrackToSave = NO;
                    [self disableSaveButton];
                    [self hidePlayLabel];
                    [self.primaryUser resetTrackWaitingStatus];
                }
            }
            
        }
}




-(void) interruptionDetected
{
    [self.recorder interruptionStop];
    [self interruptionAnimation];
    waitingTrackToSave = YES;
    
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        
        [self moveViewsDown];
        [self adjustLabelsDoneRecording];

        
    } completion:^(BOOL finished){
        
        
        [self.sineWave.layer removeAllAnimations];
        [self.recordingIndicatorView.layer removeAllAnimations];

        
    }];
}

-(void) hidePlayLabel
{
    
//    if(waitingTrackToSave && !viewIsUp && self.saveButton.enabled)

    if(waitingTrackToSave && !viewIsUp)
    {
        [self.playLabel setHidden: NO];
    }
    else
    {
        [self.playLabel setHidden: YES];
    }
}

-(void) disableSaveButton
{
    if(self.saveButton.enabled)
    {
        self.saveButton.enabled = NO;
        
        [self.saveButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIFont fontWithName:@"Raleway-Bold" size:17.0], NSFontAttributeName,
          [UIColor colorWithRed:236.0f/255.0f
                          green:242.0f/255.0f
                           blue:243.0f/255.0f
                          alpha:0.5f], NSForegroundColorAttributeName,nil]
                                       forState:UIControlStateDisabled];
        

    }
}

-(void) emergencyDisableSaveButton
{
    [saveTimer invalidate];
    saveTimer = nil;
    
    self.saveButton.enabled = NO;
    
    [self.saveButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Raleway-Bold" size:17.0], NSFontAttributeName,
      [UIColor colorWithRed:236.0f/255.0f
                      green:242.0f/255.0f
                       blue:243.0f/255.0f
                      alpha:0.5f], NSForegroundColorAttributeName,nil]
                                   forState:UIControlStateDisabled];
}

-(void) emergencyMoveViewsDown
{
    
    if(viewIsUp)
    {
        self.panedView.frame = CGRectOffset( self.panedView.frame, 0, 274);
        
        
        if(self.panedView.frame.origin.y == 0)
        {
            self.sineWave.frame = CGRectOffset(self.sineWave.frame, 0, 246);
            self.micImageView.frame = CGRectOffset(self.micImageView.frame, 0, 85.5);
            viewIsUp = NO;
            [self removeLabelInstructions];
            [self.sineWave.layer removeAllAnimations];
            
        }
    }
    
}

-(void) enableSaveButton
{

        if(!self.saveButton.enabled  && (waitingTrackToSave || self.recorder.isRecorderInitiated))
        {
            self.saveButton.enabled = YES;
            
            [self.saveButton setTitleTextAttributes:
             [NSDictionary dictionaryWithObjectsAndKeys:
              [UIFont fontWithName:@"Raleway-Bold" size:17.0], NSFontAttributeName,
              [UIColor whiteColor], NSForegroundColorAttributeName,nil]
                                           forState:UIControlStateNormal];
            
        
        }

}

-(void) enableSaveButtonTimer:(NSTimer *)timer
{
    
    if(!self.saveButton.enabled  && (waitingTrackToSave || self.recorder.isRecorderInitiated))
    {
        self.saveButton.enabled = YES;
        
        [self.saveButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIFont fontWithName:@"Raleway-Bold" size:17.0], NSFontAttributeName,
          [UIColor whiteColor], NSForegroundColorAttributeName,nil]
                                       forState:UIControlStateNormal];
        
    }
    
}


-(void) animatePlayLabel
{
    

    CGAffineTransform moveLeft = CGAffineTransformTranslate(self.playLabel.transform, -10, 0);

    self.playLabel.transform = moveLeft;

    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.1 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{

        
        self.playLabel.transform = CGAffineTransformIdentity;
       
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void) labelInstructions
{
    
    if([self.managedDocument fileCount] == 0)
    {
//        waitingTrackToSave = NO;
//        [self hidePlayLabel];
//        [self disableSaveButton];
//        [self.primaryUser resetTrackWaitingStatus];
        
        [self.recordLabel setFont:[UIFont fontWithName:@"Raleway-SemiBold" size:18]];
        self.recordLabel.text = @"DRAG UP TO RECORD";

        [self.stopLabel setFont:[UIFont fontWithName:@"Raleway-SemiBold" size:18]];

        self.stopLabel.text = @"DRAG DOWN TO STOP";

    }
    else
    {

        [self.recordLabel setFont:[UIFont fontWithName:@"Raleway-Bold" size:20]];
        self.recordLabel.text = @"RECORD";
        
        [self.stopLabel setFont:[UIFont fontWithName:@"Raleway-Bold" size:20]];
        self.stopLabel.text = @"STOP";

    }
    
}

-(void) removeLabelInstructions
{
    if([self.managedDocument fileCount] > 0)
    {
        [self.recordLabel setFont:[UIFont fontWithName:@"Raleway-Bold" size:20]];
        self.recordLabel.text = @"RECORD";
        
        [self.stopLabel setFont:[UIFont fontWithName:@"Raleway-Bold" size:20]];
        self.stopLabel.text = @"STOP";
    }
}




@end
