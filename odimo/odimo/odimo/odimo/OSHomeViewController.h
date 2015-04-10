//
//  OSHomeViewController.h
//  odimo
//
//  Created by omid sharghi on 4/28/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSPrimaryUser.h"
#import "OSAudioTableCell.h"
#import <AVFoundation/AVFoundation.h>
#import "OSWaveView.h"
#import "OSTablePlayerController.h"
#import <QuartzCore/QuartzCore.h>
#import "OSRecordPlayController.h"
#import "OSManagedDocument.h"
#import "Recording.h"
#import <MessageUI/MessageUI.h>



@interface OSHomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>
{
    NSIndexPath * previousCellIndexPath;
    NSIndexPath * currentCellIndexPath;

}

@property (nonatomic, strong) OSManagedDocument * managedDocument;
@property (nonatomic, strong) NSFetchedResultsController * fetchCon;


@property (nonatomic, weak) IBOutlet UIView * emptyBackgroundView;
@property (nonatomic, weak) IBOutlet UIImageView * emptyArrayBackground;
@property (nonatomic, weak) IBOutlet UIImageView * reelImageView;;
@property (nonatomic, strong)IBOutlet UIBarButtonItem * recordButton;
@property (nonatomic, strong) UIBarButtonItem * optionsButton;
@property (nonatomic, strong) UIBarButtonItem * cancelButton;

@property (nonatomic, strong)  UIBarButtonItem * deleteButton;
@property (nonatomic, strong)  UIBarButtonItem * exportButton;



@property (nonatomic, weak) IBOutlet UILabel * arrayStatusLabel;
@property (nonatomic, strong) OSPrimaryUser * primaryUser;
@property (nonatomic, weak) IBOutlet UITableView * audioTable;
@property (nonatomic, strong) OSWaveView * waveView;
@property (nonatomic, strong) OSTablePlayerController* audioPlayer;
@property (nonatomic, strong) UINib *myNib;
@property (nonatomic, strong) NSMutableArray * audioTableArray;
@property (nonatomic, strong) NSMutableDictionary* playerDictionary;

-(IBAction) tapRecord: (id) sender;
-(void) editTableView;


@end
