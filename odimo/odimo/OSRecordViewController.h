//
//  OSRecordViewController.h
//  odimo
//
//  Created by omid sharghi on 4/28/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "OSRecordPlayController.h"
#import "OSAudioTableCell.h"
#import "OSPrimaryUser.h"
#import "OSWaveView.h"
#import "OSDrawWave.h"
#import "OSAudioTableCell.h"
#import "OSManagedDocument.h"
#import "Recording.h"
#import "OSCreatePath.h"
#import "Novocaine.h"
#import "OSAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "OSThemeSettings.h"



@interface OSRecordViewController : UIViewController <UIGestureRecognizerDelegate, UIAlertViewDelegate, AVAudioRecorderDelegate>

@property (nonatomic, strong) OSThemeSettings * themeSettings;


@property (nonatomic, strong) OSAudioTableCell * tableCell;
@property (nonatomic, weak) IBOutlet UIImageView * speakerImageView;
@property (nonatomic, strong) NSString * speakerPlayImagePath;
@property (nonatomic, strong) NSString * speakerPauseImagePath;

@property (nonatomic, weak) IBOutlet UILabel * recordLabel;
@property (nonatomic, weak) IBOutlet UIImageView * upArrow;

@property (nonatomic, weak) IBOutlet UILabel * playLabel;
@property (nonatomic, weak) IBOutlet UIImageView * playSwipeImageView;


@property (nonatomic, weak) IBOutlet UIView * recordingIndicatorView;
@property (nonatomic, weak) IBOutlet UILabel * recordingLabel;
@property (nonatomic, weak) IBOutlet UIImageView * recordingLabelCircle;

@property (nonatomic, weak) IBOutlet UILabel * stopLabel;
@property (nonatomic, weak) IBOutlet UIImageView * downArrow;

@property (nonatomic, strong)IBOutlet UIBarButtonItem * saveButton;
@property (nonatomic, strong)IBOutlet UIBarButtonItem * libraryButton;

@property (nonatomic, weak)IBOutlet UIView * displayWaveView;
@property (nonatomic, weak)IBOutlet UIView * panedView;
@property (nonatomic, weak) IBOutlet UIImageView * micImageView;

@property (nonatomic, weak) IBOutlet UIView * demoView;
@property (nonatomic, weak) IBOutlet UIImageView * demoUpArrow;
@property (nonatomic, weak) IBOutlet UIImageView * demoHandGesture;
@property (nonatomic, weak) IBOutlet UILabel * demoUpLabelText;
@property (nonatomic, weak) IBOutlet UILabel * demoDownLabelText;
@property (nonatomic, weak) IBOutlet UIButton * demoNextButton;

@property (nonatomic, strong) NSURL * storageURL;

@property (nonatomic, strong) IBOutlet OSDrawWave * sineWave;


@property (nonatomic, strong) OSPrimaryUser * primaryUser;
@property (nonatomic, strong) OSWaveView * waveView;

@property (nonatomic, strong) OSManagedDocument * managedDocument;

@property (nonatomic, strong) OSRecordPlayController * recorder;



-(IBAction)tapPlay;
-(IBAction)tapSave:(id)sender;
-(IBAction) tapLibrary;


@end
