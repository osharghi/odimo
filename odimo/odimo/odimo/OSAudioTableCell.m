//
//  OSAudioTableCell.m
//  odimo
//
//  Created by omid sharghi on 5/3/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import "OSAudioTableCell.h"

@interface OSAudioTableCell()

//@property (strong,nonatomic) UIBezierPath *maskPath;
//@property (nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation OSAudioTableCell
{
    
    NSDate * pauseStart;
    NSDate * previousFireDate;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        

        
    }
    return self;
}


-(void) rowSelected2: (NSURL*) url
{


    self.audioPlayer = [OSTablePlayerController getInstance];
    NSData *data=[NSData dataWithContentsOfURL:url];
    [self.audioPlayer playAudio:data];
    self.audioPlayer.isPlayerPlaying = YES;
    self.timer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}

-(void) clearURL
{
    self.testURL = nil;
}

-(void) restartTimer
{
    if(self.audioPlayer.player.playing)
    {
        self.timer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    else if(self.isPaused == YES)
    {
        self.waveView.progress = self.audioPlayer.pausedProgressValeue;

    }
    
}


-(void) rowPaused
{
    if(self.audioPlayer.player.playing)
    {
        [self.audioPlayer.player pause];
        self.isPaused=YES;
        //Added to test pause
        [self pauseTimer:self.timer];
        [self.audioPlayer enableLock];
        
    }
    else if( (!self.audioPlayer.player.playing) && (!self.timer.isValid))
    {
        [self.audioPlayer.player play];
        [self.audioPlayer disableLock];
        self.isPaused = NO;
                self.timer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    else if (!self.timer.isValid)
    {
        [self.audioPlayer.player play];
        [self.audioPlayer disableLock];

        self.isPaused = NO;

        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    }
    else
    {
        [self.audioPlayer.player play];
        [self.audioPlayer disableLock];
        self.isPaused = NO;

        
        //Added to test pause
        [self resumeTimer:self.timer];
    }
}

-(void) pauseTimer:(NSTimer *)timer {
    
    pauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
    
    previousFireDate = [timer fireDate];
    
    [timer setFireDate:[NSDate distantFuture]];
}

-(void) resumeTimer:(NSTimer *)timer {
    
    float pauseTime = -1*[pauseStart timeIntervalSinceNow];
    
    [timer setFireDate:[previousFireDate initWithTimeInterval:pauseTime sinceDate:previousFireDate]];
    
}


-(void)rowDeselected
{
    [self.audioPlayer.player stop];
    [self.waveView setProgress:0];
    [self.timer invalidate];
    self.audioPlayer.isPlayerPlaying = NO;
}

- (void)updateProgress:(NSTimer *)timer {
    
    NSTimeInterval playTime = [self.audioPlayer currentTime];
    NSTimeInterval duration = [self.audioPlayer duration];
    
    float progress =  playTime/duration;
    
    self.audioPlayer.pausedProgressValeue = progress;
    [self.waveView setProgress:progress];
    
    if(!(self.audioPlayer.player.playing))
    {
        [self audioPlayerDidFinishPlaying:self.audioPlayer.player successfully:YES];
        
        progress = 0.00;

        self.audioPlayer.pausedProgressValeue = progress;

        [self.waveView setProgress:progress];

    }
}

-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if(flag)
    {
        [self.timer invalidate];
        self.audioPlayer.isPlayerPlaying = NO;
    }
}



-(IBAction) dismissTrackKeypad: (id) sender
{
    [sender resignFirstResponder];
}

-(void) setImageSize:(CGSize) theSize
{
    self.waveView.imageSize = theSize;
}

-(void) prepareForReuse
{

    [super prepareForReuse];
    
    [self.timer invalidate];
    self.waveView.progress= 0;

}

-(void) changeSelectionStyle: (BOOL) selected
{
    if(selected)
    {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else
    {
        //This should be NONE
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
}

//-(void) setExitEditing:(BOOL)exitEditing
//{
//    _exitEditing = exitEditing;
//    self.waveView.tableEditing= exitEditing;
//}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    if(state == UITableViewCellStateDefaultMask)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;

    }
    
}

//- (void)setSpecialEdit:(BOOL)specialEdit {
//    _specialEdit = specialEdit;
//    self.waveView.editing = specialEdit;
//}

//- (void)didTransitionToState:(UITableViewCellStateMask)state
//{
//    [super didTransitionToState:state];
//    
//    
//    if (state == UITableViewCellStateShowingEditControlMask)
//    {
//        
//
//        
//        
//        CGRect newFrame = CGRectMake(self.waveView.frame.origin.x, self.waveView.frame.origin.y, self.waveView.frame.size.width -10, self.waveView.frame.size.height);
//        
//        CGFloat scaleFactor = (self.waveView.frame.size.width-10)/self.waveView.frame.size.width;
//        
//        self.waveView.frame = newFrame;
//
//        CGAffineTransform transform = CGAffineTransformScale(self.waveView.transform,
//                                                             scaleFactor,
//                                                             1);
//        
//        [self.waveView.path applyTransform:transform];
//        
//       
//    }
//    else if (state ==UITableViewCellStateDefaultMask)
//    {
//        
//
//        
//        // normal mode : back to normal
//                CGRect originalFrame = CGRectMake(self.waveView.frame.origin.x, self.waveView.frame.origin.y, self.waveView.frame.size.width +10, self.waveView.frame.size.height);
//        
//        CGFloat scaleFactor = (self.waveView.frame.size.width + 10)/self.waveView.frame.size.width;
//        
//        self.waveView.frame = originalFrame;
//        
//        CGAffineTransform transform = CGAffineTransformScale(self.waveView.transform,
//                                                             scaleFactor,
//                                                             1);
//        
//        [self.waveView.path applyTransform:transform];
//
//
//
//    }
//    
//}


@end
