//
//  OSManagedDocument.h
//  odimo
//
//  Created by omid sharghi on 7/17/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Recording.h"
#import "OSPrimaryUser.h"
#import "OSAppDelegate.h"

@interface OSManagedDocument : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong)UIManagedDocument * document;
@property (nonatomic, strong) NSURL * url;
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) OSPrimaryUser * primaryUser;
@property (nonatomic, strong) NSFetchedResultsController * frc;
@property (nonatomic, strong) NSString * currentPath;
@property (nonatomic, strong) NSURL * testPath;



+(OSManagedDocument*) getInstance;
-(void) setUpDocument;
-(void) saveRecording:(NSMutableDictionary*) recordPackage inManagedObjectContext:(NSManagedObjectContext*) context;
-(void) updateSaveContext;

-(void) removeFile: (NSURL*) audioURL;
-(NSString*) pathOfLastTrack;
-(NSNumber*) recordingNumberOfLastTrack;
-(NSString*) changeFileName:(NSString*) previousPath withNewComponent:(NSString*)newComponenet error: (NSError**) error;
//-(BOOL) checkIfTrackExists:(NSString*)trackTitle;
//-(BOOL) checkIfTrackExistsAndSaved: (NSString*) trackTitle;
//-(BOOL) checkIfTrackExistsAndSaved: (NSString*) trackTitle trackWaitingForSave:(BOOL) trackWaitingForSave;
-(BOOL) checkForDuplicateRecording: (NSString*) trackTitle;


-(void)deleteWaitingTrack;

-(int) recordingCount;

-(NSUInteger) fileCount;
-(void) newDeleteWaitingTrack;

-(void) deleteAllFromFileManager;

-(void) fetchControllerFiles;

-(void) changeFileNameBeforeSave:(NSString*)oldPath withNewPath:(NSString*)newpath;

-(void) checkFileSizeofURL:(NSURL*)url;

-(NSURL*) attachLastComponent: (NSString*) lastPath;





@end
