//
//  OSAudioTableCell.h
//  odimo
//
//  Created by omid sharghi on 5/3/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSWaveView.h"
#import "OSTablePlayerController.h"



@interface OSAudioTableCell : UITableViewCell <AVAudioPlayerDelegate>
{
    
}

@property (nonatomic, strong) NSURL * testURL;

@property (nonatomic, weak) IBOutlet UILabel * trackLabel;
@property (nonatomic, weak) IBOutlet UIImageView * trackIcon;


@property (nonatomic, weak) IBOutlet OSWaveView * waveView;

@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) NSData * audioData;
@property (nonatomic, strong) AVAsset * audioAsset;
@property (nonatomic, strong) OSTablePlayerController * audioPlayer;
@property (nonatomic) BOOL isDonePlaying;
@property (nonatomic) BOOL isPaused;

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UITextField *textField;



-(void) clearURL;


-(void) restartTimer;


-(void) setImageSize:(CGSize) theSize;
-(void) rowSelected2: (NSURL*) url;
-(void)rowDeselected;
-(void) rowPaused;


-(IBAction) dismissTrackKeypad: (id) sender;
-(void) changeSelectionStyle: (BOOL) selected;


@end
