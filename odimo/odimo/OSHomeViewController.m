//
//  OSHomeViewController.m
//  odimo
//
//  Created by omid sharghi on 4/28/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import "OSHomeViewController.h"

@interface OSHomeViewController ()
{

    NSData * audioData;
    CGFloat recordViewOrigin;
    CGFloat recordViewHeight;
    AVURLAsset * songAsset;
    NSMutableDictionary * recordingPackage;
    BOOL recordActivated;
    CGFloat swipeUpDelta;
    CGFloat swipeDownDelta;
    NSString * currentURL;
    NSString * previousURL;
    NSData * currentData;
    NSData * oldData;
    BOOL titleChanged;
    BOOL resigned;
    
}

@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) NSFetchedResultsController * fetchController;
@property (nonatomic, strong) NSIndexPath * selectedIndexPath;
@property (nonatomic, strong) NSIndexPath * shiftCellIndexPath;
@property (nonatomic, strong) NSString * defaultTitle;
@property (nonatomic)BOOL isViewIsLoadedForTheFirstTime;





@end

@implementation OSHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidDisappear:(BOOL)animated
{
    self.audioPlayer = [OSTablePlayerController getInstance];
    [self.audioPlayer enableLock];
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.audioTable.allowsMultipleSelectionDuringEditing = YES;
    self.isViewIsLoadedForTheFirstTime = YES;


    
    self.themeSettings = [OSThemeSettings getInstance];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterResign:) name:UIApplicationWillResignActiveNotification object:nil];
    
    self.managedDocument = [OSManagedDocument getInstance];
    [self fetchWithContext:self.managedDocument.managedObjectContext];


 //Comment this out if using FRC
    self.primaryUser = [OSPrimaryUser getUserInstance];
    
    [self.audioTable registerNib:[UINib nibWithNibName:@"audioTableCell" bundle:nil] forCellReuseIdentifier:@"audioTableCell"];
    
    //Set empty array background texture and image and label
    NSString * emptyArrayBackgroundImagePath = [[NSBundle mainBundle] pathForResource:@"emptyArrayBackground" ofType:@"png"];
    self.emptyArrayBackground.image = [UIImage imageWithContentsOfFile:emptyArrayBackgroundImagePath];
    NSString * reelLightImagePath = [[NSBundle mainBundle] pathForResource:@"reelLight" ofType:@"png"];
    self.reelImageView.image = [UIImage imageWithContentsOfFile:reelLightImagePath];
    
    //Set Bar Button font and color
    
    UIFont * labelFonts = [self.themeSettings navAndToolBarFont];
    [self.recordButton setTitleTextAttributes:
    [NSDictionary dictionaryWithObjectsAndKeys:
      labelFonts, NSFontAttributeName,
      [UIColor whiteColor], NSForegroundColorAttributeName,nil]
                                      forState:UIControlStateNormal];
    
    self.optionsButton = [[UIBarButtonItem alloc] initWithTitle:@"OPTIONS" style:UIBarButtonItemStylePlain target:self action:@selector(editTableView)];
    
    [self.optionsButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      labelFonts, NSFontAttributeName,
      [UIColor whiteColor], NSForegroundColorAttributeName,nil]
                                      forState:UIControlStateNormal];
    
    self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"HIDE" style:UIBarButtonItemStylePlain target:self action:@selector(editTableView)];
    
    [self.cancelButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      labelFonts, NSFontAttributeName,
      [UIColor whiteColor], NSForegroundColorAttributeName,nil]
                                     forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = self.optionsButton;
    
    self.deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"DELETE" style:UIBarButtonItemStylePlain target:self action:@selector(newMultiDelete)];
    
    [self.deleteButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      labelFonts, NSFontAttributeName,
      [UIColor whiteColor], NSForegroundColorAttributeName,nil]
                                     forState:UIControlStateNormal];
    
    
    self.exportButton = [[UIBarButtonItem alloc] initWithTitle:@"SHARE" style:UIBarButtonItemStylePlain target:self action:@selector(newExport)];
    
    [self.exportButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      labelFonts, NSFontAttributeName,
      [UIColor whiteColor], NSForegroundColorAttributeName,nil]
                                     forState:UIControlStateNormal];
    
    
    
    UIBarButtonItem *flexibleSpaceBarButton = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                               target:nil
                                               action:nil];
    
    
    NSMutableArray *toolBarButtonsArray = [[NSMutableArray alloc] init];
    [toolBarButtonsArray addObject:self.deleteButton];
    [toolBarButtonsArray addObject:flexibleSpaceBarButton];
    [toolBarButtonsArray addObject:self.exportButton];
    [self setToolbarItems:toolBarButtonsArray];
    self.navigationController.toolbar.clipsToBounds = YES;

    self.arrayStatusLabel.font = [self.themeSettings fontWithName:@"Raleway-Regular" smallSize:21 regularSize:21 bigSize:23 biggest:25];
    
    [self checkRecordingCount];
    
    self.audioPlayer = [OSTablePlayerController getInstance];
    self.audioPlayer.isPlayerPlaying = NO;
    
    recordActivated = NO;
    
    [self.navigationItem setHidesBackButton:YES];

    [self.audioTable setSeparatorInset:UIEdgeInsetsZero];
    
    self.audioTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self.audioTable reloadData];
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.audioTable reloadData];
    
    [self checkRecordingCount];
    

}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.audioTable reloadData];
    



}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if([self.fetchCon.fetchedObjects count]>0)
    {
        [self enableOptions];
    }
    else
    {
        [self disableOptions];
    }
    
    
    return [self.fetchCon.fetchedObjects count];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"audioTableCell";
    
    OSAudioTableCell *cell = [self.audioTable dequeueReusableCellWithIdentifier:identifier];
    
    if(cell == nil)
    {
        cell = [[OSAudioTableCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: identifier];
    }
    else
    {
//        NSLog(@"From %s: scrubbing reused cell at %d", __PRETTY_FUNCTION__, indexPath.row);

        
        [cell.waveView.blueWave removeFromSuperlayer];
        [cell.waveView.redWave removeFromSuperlayer];
        cell.waveView.blueWave = nil;
        cell.waveView.redWave = nil;
        cell.waveView.path = nil;
        cell.trackLabel.text = nil;
    }

            Recording * recording = [self.fetchCon objectAtIndexPath:indexPath];
    
            cell.waveView.minAmpl = [recording.minAmpl floatValue];
            NSData * pathData = recording.waveData;
    
            cell.waveView.path = [NSKeyedUnarchiver unarchiveObjectWithData:pathData];
    
    
            [cell setImageSize:cell.waveView.bounds.size];
    
            if([self.selectedIndexPath isEqual:indexPath])
            {
                //allocate progressbar and start timer

                    [cell restartTimer];
                
                
            }
    
            cell.tag = indexPath.row;
    
            UIFont * cellLabel = [self.themeSettings cellLabelFont];
    
//            [cell.textField setFont:[UIFont fontWithName:@"Raleway-SemiBold" size:12]];
            [cell.textField setFont:cellLabel];
            cell.textField.delegate = self;

    
            if([recording.trackTitle isEqualToString:@""])
            {
                NSString * track = @"Track";
                NSNumber * recordingNumber  = recording.recordingNumber;
                track = [track stringByAppendingFormat:@" %@",recordingNumber];
                cell.textField.text = track;
            }
            else
            {
                cell.textField.text = recording.trackTitle;

            }
  
            UIColor * circleColor = [UIColor colorWithRed:107/255.0f green:212/255.0f blue:231/255.0f alpha:1.0f];
            cell.trackIcon.backgroundColor = circleColor;
            [cell.trackIcon.layer setCornerRadius:cell.trackIcon.bounds.size.width/2];
            cell.trackIcon.layer.masksToBounds = YES;
    
    
            if(self.audioTable.editing)
            {
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;

            }
            else
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

            }
    
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.audioTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    
//    NSArray *selectedRows = [self.audioTable indexPathsForSelectedRows];
//    for (NSIndexPath *selectionIndex in selectedRows)
//    {
//        if(selectionIndex.row == indexPath.row)
//        {
//            cell.selected = YES;
//            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//
//
//            
//        }
//        else
//        {
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//        }
//        
//    }
    

            UIView * cellBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cellBackgroundView.backgroundColor = [UIColor clearColor];
            cell.multipleSelectionBackgroundView = cellBackgroundView;
            cell.selectedBackgroundView = cellBackgroundView;
    

    
    
//    NSArray *selectedRows = [self.audioTable indexPathsForSelectedRows];
//    if ([selectedRows containsObject:[NSNumber numberWithLong:indexPath.row]])
//    {
//    
//        
//        cell.selected = YES;
//        
//        
//    }
//    else
//    {
//        cell.selected = NO;
//        
//    }

    
//    NSNumber *rowNsNum = [NSNumber numberWithUnsignedInt:indexPath.row];
//    if ( [selectedCells containsObject:rowNsNum]  )
//    {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
//    else
//    {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    
    

    return cell;
}

- (BOOL)isInputValid:(NSString*)text
{
    return [text length] != 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.defaultTitle = textField.text;

    
    NSArray* cells = [self.audioTable visibleCells];
    for (OSAudioTableCell* cell in cells)
    {
        if (textField == cell.textField)
        {
            NSInteger index = cell.tag;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            self.shiftCellIndexPath = indexPath;
        }
    }
}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    return YES;
//}


-(void) textFieldDidEndEditing:(UITextField *)textField
{
    NSAssert(textField != nil, @"Should never be nil");
    textField.delegate = self;

    
    NSArray* cells = [self.audioTable visibleCells];
    for (OSAudioTableCell* cell in cells)
    {
        if (textField == cell.textField)
        {
            NSInteger index = cell.tag;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            Recording * recording = [self.fetchCon objectAtIndexPath:indexPath];

            
            if (![self isInputValid:textField.text])
            {
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"You forgot to enter a title!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
                if([recording.trackTitle isEqualToString:@""])
                {
                    
                    NSString *trackTitle = @"Track";
                    trackTitle = [trackTitle stringByAppendingFormat:@" %@", recording.recordingNumber];
                    textField.text = trackTitle;
                }
                else
                {
                    textField.text = recording.trackTitle;
                }
                
            }
            else if(![self.defaultTitle isEqualToString:textField.text])
            {
                
                
                NSString * previousPath = recording.audioURL;
//                NSLog(@"previous path check %@", previousPath);
//                NSLog(@"New Path componenet %@", textField.text);
                NSError * aError;
                
                NSString * returnedURL = [self.managedDocument changeFileName:previousPath withNewComponent:textField.text error:&aError];
                if(returnedURL != nil)
                {
                    recording.audioURL = returnedURL;
//                    NSLog(@"NEW recording.audioURL %@", recording.audioURL);
                    recording.trackTitle = textField.text;
//                    previousURL = nil;
                    titleChanged = YES;
                    [self.managedDocument updateSaveContext];
                    
                }
                else
                {
                    if(aError.code == 516)
                    {
                        NSString *errorMessage = @"Track title already exists.";
                        
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        
                        [alert show];
                        
                        if([recording.trackTitle isEqualToString:@""])
                        {

                            NSString *trackTitle = @"Track";
                            trackTitle = [trackTitle stringByAppendingFormat:@" %@", recording.recordingNumber];
                            textField.text = trackTitle;
                        }
                        else
                        {

                            textField.text = recording.trackTitle;
                        }
                        
                    }
                    else
                    {
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:aError.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        
                        [alert show];
                        
                        NSString *trackTitle = @"Track";
                        
                        trackTitle = [trackTitle stringByAppendingFormat:@" %@", recording.recordingNumber];
                        
                        textField.text = trackTitle;
                    }
                }
            }

        }
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateToolBarButtonState];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if(!self.audioTable.editing)
    {
        
        Recording * recording = [self.fetchCon objectAtIndexPath:indexPath];
        
        NSString * lastPathComp = [recording.audioURL lastPathComponent];
        
        NSURL * audioURL = [self.managedDocument attachLastComponent:lastPathComp];
        NSLog(@"new audio url %@", audioURL.path);
        
        [self.managedDocument checkFileSizeofURL:audioURL];

//        NSURL * audioURL =[[NSURL alloc] initWithString:recording.audioURL];
        

        currentURL = recording.audioURL;
        
        if((previousURL != nil && ![previousURL isEqualToString:currentURL]) || titleChanged)
        {
            
            titleChanged = NO;

            previousURL = currentURL;

            [((OSAudioTableCell*)[self.audioTable cellForRowAtIndexPath:previousCellIndexPath]) rowDeselected];
            [((OSAudioTableCell*)[self.audioTable cellForRowAtIndexPath:indexPath]) rowSelected2:audioURL];
            self.selectedIndexPath = indexPath;
        }
        else if([previousURL isEqualToString:currentURL])
        {
            previousURL = currentURL;
            [((OSAudioTableCell*)[self.audioTable cellForRowAtIndexPath:indexPath]) rowPaused];
            self.selectedIndexPath = indexPath;

        }
        else
        {
            previousURL = currentURL;
            [((OSAudioTableCell*)[self.audioTable cellForRowAtIndexPath:indexPath]) rowSelected2:audioURL];
            self.selectedIndexPath = indexPath;

        }
            previousCellIndexPath = indexPath;
            oldData = recording.waveData;
    
    }
    else
    {
        
        [self updateToolBarButtonState];
        
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove the deleted object from your data source.
        //If your data source is an NSMutableArray, do this
        [((OSAudioTableCell*)[self.audioTable cellForRowAtIndexPath:previousCellIndexPath]) rowDeselected];
        
        self.primaryUser = [OSPrimaryUser getUserInstance];
        
        if(self.audioPlayer.player.playing)
        {
            [self.audioPlayer stopAudio];
        }

        
        
//Complex
        
        Recording * recording = [self.fetchCon objectAtIndexPath:indexPath];
        NSString * pathOfLastTrack = [self.managedDocument pathOfLastTrack];
        
//        if([recording.audioURL isEqualToString:pathOfLastTrack])
        if([[recording.audioURL lastPathComponent] isEqualToString:[pathOfLastTrack lastPathComponent]])
        {
            [self.managedDocument.managedObjectContext deleteObject:recording];
            
            
            //Directory issue fix
            NSString * lastPathComp = [recording.audioURL lastPathComponent];
            NSURL * audioURL = [self.managedDocument attachLastComponent:lastPathComp];
            NSLog(@"new audio url %@", audioURL.path);
            
//            NSURL * audioURL = [[NSURL alloc] initWithString:recording.audioURL];
            [self.managedDocument removeFile:audioURL];
            [self.managedDocument.managedObjectContext save:nil];
            [self.managedDocument updateSaveContext];
            if([self.managedDocument recordingCount] !=0)
            {
                NSNumber * lastTrackNumber = [self.managedDocument recordingNumberOfLastTrack];
//                NSLog(@"Recording Number of last track %@",lastTrackNumber);
                self.primaryUser.recordingNumber = lastTrackNumber;
                [self.primaryUser incrementRecordingNumber];
            }
            else
            {
                [self disableOptions];
                [self.primaryUser restartRecordingNumber];
                
                [UIView transitionWithView:self.audioTable
                                  duration:0.4
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:NULL
                                completion:NULL];
                
                [self.audioTable setHidden:YES];
                
                [self.arrayStatusLabel setHidden:NO];
            }
        }
        else
        {
            [self.managedDocument.managedObjectContext deleteObject:recording];
            
            
            //Directory issue fix
            NSString * lastPathComp = [recording.audioURL lastPathComponent];
            NSURL * audioURL = [self.managedDocument attachLastComponent:lastPathComp];
            NSLog(@"new audio url %@", audioURL.path);
            
            
//            NSURL * audioURL = [[NSURL alloc] initWithString:recording.audioURL];
            [self.managedDocument removeFile:audioURL];
            [self.managedDocument.managedObjectContext save:nil];
            [self.managedDocument updateSaveContext];

        }
        
        [tableView reloadData]; // tell table to refresh now
        
    }
}

-(IBAction) tapRecord:(id)sender
{

    if(self.audioTable.editing)
    {
        [self editTableView];
        self.audioTable.editing = NO;
    }
    
    
    

    [self.audioPlayer stopAudio];
    [self.view endEditing:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction) tapHelp: (id) sender
{
    [self.view endEditing:YES];
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Help!"];
    [controller setMessageBody:@"" isHTML:NO];
    [controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@"hello@odimoapp.com"]; // (NSString *) [feed valueForKey:@"email"]];
    [controller setToRecipients:toRecipients];
    [self presentViewController:controller animated:YES completion:nil];
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (error) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"error" message:[NSString stringWithFormat:@"error %@",[error description]] delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
        [alert show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
//    switch(type) {
//        case NSFetchedResultsChangeDelete:
//            [self.audioTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
    
    [self.managedDocument.managedObjectContext save:nil];
    [self.managedDocument updateSaveContext];
    
    if(type == NSFetchedResultsChangeDelete)
    {
        [self.audioTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if(type == NSFetchedResultsChangeInsert)
    {
        [self.audioTable insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    }
    else if(type == NSFetchedResultsChangeUpdate)
    {
        [self.audioTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    }
    else if(type == NSFetchedResultsChangeMove)
    {
        [self.audioTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.audioTable insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self checkRecordingCount];
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    [self.audioTable endUpdates];
    [self. audioTable reloadData];
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    [self.audioTable beginUpdates];
}

-(void) checkRecordingCount
{
    
    if([self.fetchCon.fetchedObjects count] == 0)
        
    {
        [self.audioTable setHidden:YES];
        [self.emptyBackgroundView setHidden:NO];
    }
    else
    {
        [self.audioTable setHidden:NO];
        [self.emptyBackgroundView setHidden:YES];
    }
    
}


-(void) fetchWithContext: (NSManagedObjectContext*) context
{
    
    NSFetchRequest * request;
    
    
    if(request == nil)
    {
        request = [NSFetchRequest fetchRequestWithEntityName:@"Recording"];
        request.predicate = nil;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeAdded" ascending:NO]];
    }
    
    
    
    if(self.fetchCon == nil)
    {
        self.fetchCon = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        self.fetchCon.delegate = self;
    }
    
    NSError * error;
    
    [self.fetchCon performFetch:&error];
    
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    } else {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
    }
    
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
    self.audioTable.contentInset = contentInsets;
    self.audioTable.scrollIndicatorInsets = contentInsets;
    [self.audioTable scrollToRowAtIndexPath:self.shiftCellIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{

    self.audioTable.contentInset = UIEdgeInsetsZero;
    self.audioTable.scrollIndicatorInsets = UIEdgeInsetsZero;
        }];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews
{
    if ([self.audioTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.audioTable setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.audioTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.audioTable setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void) appDidEnterResign:(NSNotification *)notification
{
    
    if(self.audioPlayer.player.playing)
    {
        [((OSAudioTableCell*)[self.audioTable cellForRowAtIndexPath:self.selectedIndexPath]) rowDeselected];
        previousURL = nil;
    }
    

    
}

-(void) editTableView
{
    
    if(!self.audioTable.editing)
    {
        
        [self.audioTable setEditing:YES animated:YES];
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        [self updateToolBarButtonState];
        
        //used for waveView class to keep consistent path width
        self.themeSettings.tableViewEditing = YES;
//        for (OSAudioTableCell *cell in [self.audioTable visibleCells]) {
//            cell.exitEditing = self.audioTable.editing;
//        }
        //
        
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
    else
    {
        
        [self.audioTable setEditing:NO animated:YES];
        
        //used for waveView class to keep consistent path width
//        for (OSAudioTableCell *cell in [self.audioTable visibleCells]) {
//            cell.exitEditing = self.audioTable.editing;
//        }
        self.themeSettings.tableViewEditing = NO;
        //

        self.navigationItem.rightBarButtonItem = self.optionsButton;
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
    

    
    
//    for (OSAudioTableCell *cell in [self.audioTable visibleCells]) {
//        cell.specialEdit = self.audioTable.editing;
//    }
    
//    [self.audioTable reloadData];
}



- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {

    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled) {
        
        NSLog(@"Message cancelled");
        
    } else if (result == MessageComposeResultSent) {
        
        NSLog(@"Message sent");
    }
    
}


-(void) newExport
{
    UIAlertController * exportAlert = [[UIAlertController alloc] init];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
            [exportAlert dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    UIAlertAction * textAction = [UIAlertAction actionWithTitle:@"Text" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [exportAlert dismissViewControllerAnimated:YES completion:nil];
        
        if ([MFMessageComposeViewController canSendText])
        {
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            controller.messageComposeDelegate = self;
            [controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            
            NSArray *selectedRows = [self.audioTable indexPathsForSelectedRows];
            BOOL sendSpecificRows = selectedRows.count > 0;
            if ([MFMessageComposeViewController canSendAttachments])
            {
                if (sendSpecificRows)
                {
                    for (NSIndexPath *selectionIndex in selectedRows)
                    {
                        Recording * recording = [self.fetchCon objectAtIndexPath:selectionIndex];
                        
                        NSString * lastPathComp = [recording.audioURL lastPathComponent];
                        NSURL * audioURL = [self.managedDocument attachLastComponent:lastPathComp];
//                        NSLog(@"new audio url %@", audioURL.path);
//                        [self.managedDocument checkFileSizeofURL:audioURL];

            
//                        NSURL * audioURL = [NSURL URLWithString:[recording.audioURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        
                        
                        NSData * audioDataEmail = [NSData dataWithContentsOfURL:audioURL];
                        NSString * title = [recording.audioURL lastPathComponent];
                        BOOL didAttachAudio = [controller addAttachmentData:audioDataEmail typeIdentifier:@"audio/m4a" filename:title];
                        
                        if (didAttachAudio)
                        {
                            NSLog(@"Audio Attached.");
                            [self presentViewController:controller animated:YES completion:nil];
                            
                        }
                        else
                        {
                            
                            NSLog(@"Audio Could Not Be Attached.");
                            
                            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Can't attach files.  Try removing a file or two." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] ;
                            [alert show];
                            
                        }
                    }
                }
                
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Can't send files.  Try removing a file or two." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] ;
                [alert show];
            }
            
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Can't send!  Try removing a file or two." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] ;
            [alert show];
        }


        
    }];
    
    UIAlertAction * emailAction = [UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [exportAlert dismissViewControllerAnimated:YES completion:nil];
        
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setSubject:@"Audio Recordings!"];
            [controller setMessageBody:@"" isHTML:NO];
            [controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            
            NSArray *selectedRows = [self.audioTable indexPathsForSelectedRows];
            BOOL sendSpecificRows = selectedRows.count > 0;
            if (sendSpecificRows)
            {
                for (NSIndexPath *selectionIndex in selectedRows)
                {
                    Recording * recording = [self.fetchCon objectAtIndexPath:selectionIndex];
                    NSString * lastPathComp = [recording.audioURL lastPathComponent];
                    NSURL * audioURL = [self.managedDocument attachLastComponent:lastPathComp];
                    NSLog(@"new audio url %@", audioURL.path);
                    [self.managedDocument checkFileSizeofURL:audioURL];
                    
//                    NSString * lastPathComp = [recording.audioURL lastPathComponent];
//                    NSURL * audioURL = [self.managedDocument attachLastComponent:lastPathComp];

                    NSData * audioDataText = [NSData dataWithContentsOfURL:audioURL];
                    NSString * title = [recording.audioURL lastPathComponent];
                    [controller addAttachmentData:audioDataText mimeType:@"audio/m4a" fileName:title];
                }
                
                [self presentViewController:controller animated:YES completion:NULL];
            }
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Can't send message.  Try removing a file or two." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] ;
            [alert show];
        }

        

    }];
    
    [exportAlert addAction:cancelAction];
    [exportAlert addAction:textAction];
    [exportAlert addAction:emailAction];
    
    [self presentViewController:exportAlert animated:YES completion:nil];
    
}

- (void)sendMailPicker:(MFMailComposeViewController*)picker attachmentURL:(NSURL*)url andTitle:(NSString*)title {
    

//    NSError * error;
//    [self.managedDocument checkFileSizeofURL:url];
//    NSData * attachmentData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
//    NSString * audioTitle = title;
//    [picker addAttachmentData:attachmentData mimeType:@"audio/m4a" fileName:audioTitle];


    NSData * audioDataText = [NSData dataWithContentsOfURL:url];
    NSString * audioTitle = title;
    [picker addAttachmentData:audioDataText mimeType:@"audio/m4a" fileName:audioTitle];

}

-(void) newMultiDelete
{
//    UIAlertController * deleteAlert = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure you want to remove these items?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertController * deleteAlert = [[UIAlertController alloc] init];
    
    UIAlertAction * deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [deleteAlert dismissViewControllerAnimated:YES completion:nil];

        NSArray *selectedRows = [self.audioTable indexPathsForSelectedRows];

        
        BOOL deleteSpecificRows = selectedRows.count > 0;
        if (deleteSpecificRows)
        {
            // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
//            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            NSMutableArray *objectsToDelete = [NSMutableArray array];

            for (NSIndexPath *selectionIndex in selectedRows)
            {
                 Recording * recording = [self.fetchCon objectAtIndexPath:selectionIndex];
                [objectsToDelete addObject:recording];
            }
                for (Recording *recording in [objectsToDelete reverseObjectEnumerator])
                {

                
                    NSString * pathOfLastTrack = [self.managedDocument pathOfLastTrack];
//                    if([recording.audioURL isEqualToString:pathOfLastTrack])
                    if([[recording.audioURL lastPathComponent] isEqualToString:[pathOfLastTrack lastPathComponent]])
                    {
                        [self.managedDocument.managedObjectContext deleteObject:recording];
                        
                        
                        NSString * lastPathComp = [recording.audioURL lastPathComponent];
                        NSURL * audioURL = [self.managedDocument attachLastComponent:lastPathComp];
                        NSLog(@"new audio url %@", audioURL.path);
                        
//                        NSURL * audioURL = [[NSURL alloc] initWithString:recording.audioURL];
                        
                        [self.managedDocument removeFile:audioURL];

                        
                        if([self.managedDocument recordingCount] !=0)
                        {
                            NSNumber * lastTrackNumber = [self.managedDocument recordingNumberOfLastTrack];
                            //                NSLog(@"Recording Number of last track %@",lastTrackNumber);
                            self.primaryUser.recordingNumber = lastTrackNumber;
                            [self.primaryUser incrementRecordingNumber];
                        }
                        else
                        {
                            [self disableOptions];
                            [self.primaryUser restartRecordingNumber];
                            
                            [UIView transitionWithView:self.audioTable
                                              duration:0.4
                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                            animations:NULL
                                            completion:NULL];
                            
                            [self.audioTable setHidden:YES];
                            
                            [self.arrayStatusLabel setHidden:NO];
                        }
                        
                        
                    }
                    else
                    {
                        //Simple
                        [self.managedDocument.managedObjectContext deleteObject:recording];
                        
                        
                        //Directory issue fix
                        NSString * lastPathComp = [recording.audioURL lastPathComponent];
                        NSURL * audioURL = [self.managedDocument attachLastComponent:lastPathComp];
                        NSLog(@"new audio url %@", audioURL.path);
                        
//                        NSURL * audioURL = [[NSURL alloc] initWithString:recording.audioURL];
                        
                        [self.managedDocument removeFile:audioURL];
                        

                        
                        
                    }
                }

        }
        
//        [self.managedDocument.managedObjectContext save:nil];
//        [self.managedDocument updateSaveContext];
        
        
//        [self.audioTable reloadData];
        
        [self editTableView];
        
    }];
    
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        [deleteAlert dismissViewControllerAnimated:YES completion:nil];

    }];
    
    [deleteAlert addAction:deleteAction];
    [deleteAlert addAction:cancelAction];
    
    [self presentViewController:deleteAlert animated:YES completion:nil];

    
}
                                    
- (void)updateToolBarButtonState
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.audioTable indexPathsForSelectedRows];
    
    UIFont * labelFonts = [self.themeSettings navAndToolBarFont];

    
    if([selectedRows count] == 0)
    {
        self.deleteButton.enabled = NO;
        [self.deleteButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          labelFonts, NSFontAttributeName,
          [UIColor colorWithRed:236.0f/255.0f
                          green:242.0f/255.0f
                           blue:243.0f/255.0f
                          alpha:0.5f], NSForegroundColorAttributeName,nil]
                                       forState:UIControlStateNormal];
        
        self.exportButton.enabled = NO;
        [self.exportButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          labelFonts, NSFontAttributeName,
          [UIColor colorWithRed:236.0f/255.0f
                          green:242.0f/255.0f
                           blue:243.0f/255.0f
                          alpha:0.5f], NSForegroundColorAttributeName,nil]
                                         forState:UIControlStateNormal];
        
        
    }
    else if ([selectedRows count] > 0)
    {
        self.deleteButton.enabled = YES;
        [self.deleteButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          labelFonts, NSFontAttributeName,
          [UIColor colorWithRed:236.0f/255.0f
                          green:242.0f/255.0f
                           blue:243.0f/255.0f
                          alpha:1.0f], NSForegroundColorAttributeName,nil]
                                         forState:UIControlStateNormal];
        
        self.exportButton.enabled = YES;
        [self.exportButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          labelFonts, NSFontAttributeName,
          [UIColor colorWithRed:236.0f/255.0f
                          green:242.0f/255.0f
                           blue:243.0f/255.0f
                          alpha:1.0f], NSForegroundColorAttributeName,nil]
                                         forState:UIControlStateNormal];

    }

}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    
    if(tableView.editing)
    {
                [((OSAudioTableCell*)[self.audioTable cellForRowAtIndexPath:indexPath]) changeSelectionStyle:YES];
    }
    else
    {
                [((OSAudioTableCell*)[self.audioTable cellForRowAtIndexPath:indexPath]) changeSelectionStyle:NO];
    }
    
    // By default, allow row to be selected
    return indexPath;
}

-(void) disableOptions
{

    
    self.optionsButton.enabled = NO;
    
    UIFont * navBarFont = [self.themeSettings navAndToolBarFont];
    
    
    [self.optionsButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      navBarFont, NSFontAttributeName,
      [UIColor colorWithRed:236.0f/255.0f
                      green:242.0f/255.0f
                       blue:243.0f/255.0f
                      alpha:0.5f], NSForegroundColorAttributeName,nil]
                                   forState:UIControlStateDisabled];
}

-(void) enableOptions
{
    
    
    self.optionsButton.enabled = YES;
    
    UIFont * navBarFont = [self.themeSettings navAndToolBarFont];
    
    [self.optionsButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      navBarFont, NSFontAttributeName,
      [UIColor colorWithRed:236.0f/255.0f
                      green:242.0f/255.0f
                       blue:243.0f/255.0f
                      alpha:1.0f], NSForegroundColorAttributeName,nil]
                                      forState:UIControlStateDisabled];
}


@end
