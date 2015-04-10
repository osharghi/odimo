//
//  OSManagedDocument.m
//  odimo
//
//  Created by omid sharghi on 7/17/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import "OSManagedDocument.h"

@implementation OSManagedDocument


+(OSManagedDocument*) getInstance
{
    static OSManagedDocument* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[OSManagedDocument alloc] init];
    });
    return _instance;
}

-(void) setUpDocument
{
 
    if(self.document == nil)
    {

        
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSURL * documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSString * documentName = @"MyRecordings";
        self.url = [documentsDirectory URLByAppendingPathComponent:documentName];
        self.document = [[UIManagedDocument alloc] initWithFileURL:self.url];
        
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self.url path]];
        
        if(fileExists)
        {
            [self.document openWithCompletionHandler:^(BOOL success) {
                if(success)
                {
                    [self documentIsReady];
                    
                }
                
            }];
        }
        else
        {
            [self.document saveToURL:self.url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
                if(success)
                {
                    [self documentIsReady];
                    
                }
                else
                {
                    NSLog(@"Fail");
                }
                
            }];
            
        }
    }
}

-(void) documentIsReady
{

    if(self.document.documentState ==UIDocumentStateNormal)
    {
        self.managedObjectContext = self.document.managedObjectContext;
        NSLog(@"context is ready");
        [self fetchControllerFiles];
        [self recordingCount];
    }
}


-(void) saveRecording:(NSMutableDictionary*) recordPackage inManagedObjectContext:(NSManagedObjectContext*) context
{
    
    Recording * recording = [NSEntityDescription insertNewObjectForEntityForName:@"Recording" inManagedObjectContext:context];

    recording.trackTitle = [recordPackage objectForKey:@"track label"];
    recording.audioURL = [[recordPackage objectForKey:@"audioURL"] absoluteString];
    recording.timeAdded = [NSDate date];
    recording.waveData = [recordPackage objectForKey:@"waveData"];
    recording.minAmpl = [recordPackage objectForKey:@"minAmpl"];
    recording.recordingNumber = [recordPackage objectForKey:@"recordingNumber"];
    
    [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        if(success)
        {
            NSLog(@" NEW FILE SAVED");
        }
        else
        {
            NSLog(@"FAIL TO SAVE");
        }
        
    }];
    
//    NSLog(@"Path of just saved recording %@", recording.audioURL);
    
    //Show files
    NSURL * newURL = [self.url URLByAppendingPathComponent:@"audioFiles"];
    NSError * error;
    NSArray * directoryContents =  [[NSFileManager defaultManager]
                                    contentsOfDirectoryAtPath:[newURL path] error:&error];
    
    NSLog(@"directoryContents ====== %@",directoryContents);
    
}

-(void) updateSaveContext
{
    [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        if(success)
        {
            NSLog(@" NEW FILE SAVED");
        }
        else
        {
            NSLog(@"FAIL TO SAVE");
        }
        
    }];

}

-(int) recordingCount
{
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Recording"];
    NSError *error;
    request.predicate = nil;
    request.sortDescriptors =nil;
    NSArray * recordings = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if(recordings == nil)
    {
        NSLog(@"NILLLLLL");
    }
    
    NSLog(@"recordings count %lu", (unsigned long)recordings.count);
    return (int)[recordings count];
}

-(void) removeFile: (NSURL*) audioURL
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:audioURL error:NULL];
//    BOOL testDelete = [fileManager removeItemAtURL:audioURL error:NULL];
//    
//    NSAssert(testDelete, nil);
    
    //Show files
    NSURL * newURL = [self.url URLByAppendingPathComponent:@"audioFiles"];
    NSError * error;
    NSArray * directoryContents =  [[NSFileManager defaultManager]
                                    contentsOfDirectoryAtPath:[newURL path] error:&error];
    
    NSLog(@"directoryContents ====== %@",directoryContents);
    
}

-(void) changeFileNameBeforeSave:(NSString*)oldPath withNewPath:(NSString*)newpath
{
    NSURL * oldURL = [self.url URLByAppendingPathComponent:@"audioFiles"];
    oldURL = [oldURL URLByAppendingPathComponent:oldPath];
    
    NSURL * newURL = [self.url URLByAppendingPathComponent:@"audioFiles"];
    newURL = [newURL URLByAppendingPathComponent:newpath];
    
    NSError * error;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager moveItemAtURL:oldURL toURL:newURL error:&error];
    if(result)
    {
        NSLog(@"Success");
    }
    else
    {
        NSLog(@"FAIL");
    }

    
}

-(NSString*) changeFileName:(NSString*) previousPath withNewComponent:(NSString*)newComponenet error: (NSError**) error
{
    

    
    NSURL * oldURL = [self.url URLByAppendingPathComponent:@"audioFiles"];
    oldURL = [oldURL URLByAppendingPathComponent:[previousPath lastPathComponent]];
    
    NSString * trimmedString = [newComponenet stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSURL * newURL = [self.url URLByAppendingPathComponent:@"audioFiles"];
    newURL = [newURL URLByAppendingPathComponent:[trimmedString lowercaseString]];
    newURL = [newURL URLByAppendingPathExtension:@"m4a"];
    

    

    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager moveItemAtURL:oldURL toURL:newURL error:error];
    if(!result)
    {
        return nil;
    }
    
    return newURL.absoluteString;
  
}



-(BOOL) checkForDuplicateRecording: (NSString*) trackTitle
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSURL * path = [self.url URLByAppendingPathComponent:@"audioFiles"];
    path = [path URLByAppendingPathComponent:trackTitle];
    BOOL doesTrackExist = [fileManager fileExistsAtPath:path.path];
    BOOL trackExistsAndSaved = NO;
    
    if(doesTrackExist)
    {
        trackExistsAndSaved = YES;
    }
    else
    {
        trackExistsAndSaved = NO;
    }
    
    return trackExistsAndSaved;
}




-(NSString*) pathOfLastTrack
{
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Recording"];
    NSError *error;
    request.predicate = nil;
    request.sortDescriptors =@[[NSSortDescriptor sortDescriptorWithKey:@"timeAdded" ascending:NO]];
    [request setFetchLimit:1];
    NSArray * result = [self.managedObjectContext executeFetchRequest:request error:&error];
//    NSLog(@"Throw back error %@", error.localizedDescription);
    if(result.count != 0)
    {
        Recording * recording = [result objectAtIndex:0];
//        NSLog(@"result count %lu", (unsigned long)result.count);
//        NSLog(@"Last track %@", recording.audioURL);
        return recording.audioURL;
    }
    else
    {
        return nil;
    }
        
}

-(NSNumber*) recordingNumberOfLastTrack
{
    
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Recording"];
    NSError *error;
    request.predicate = nil;
    request.sortDescriptors =@[[NSSortDescriptor sortDescriptorWithKey:@"timeAdded" ascending:NO]];
    [request setFetchLimit:1];
    NSArray * result = [self.managedObjectContext executeFetchRequest:request error:&error];
    Recording * recording = [result objectAtIndex:0];
//    NSLog(@"result count %lu", (unsigned long)result.count);
//    NSLog(@"Last track %@", recording.audioURL);
    return recording.recordingNumber;
}

-(void)deleteWaitingTrack;
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSLog(@"Current Path to delete %@", self.currentPath);
    [fileManager removeItemAtPath:self.currentPath error:NULL];
    
    //Show files
    NSURL * newURL = [self.url URLByAppendingPathComponent:@"audioFiles"];
    NSError * error;
    NSArray * directoryContents =  [[NSFileManager defaultManager]
                                    contentsOfDirectoryAtPath:[newURL path] error:&error];
    
    NSLog(@"directoryContents ====== %@",directoryContents);
    
    [self.primaryUser decrementRecordingNumber];
    
}


-(void) newDeleteWaitingTrack
{
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSLog(@"Delete test path %@", self.testPath.path);
        [fileManager removeItemAtURL:self.testPath error:NULL];
        
        //Show files
        NSURL * newURL = [self.url URLByAppendingPathComponent:@"audioFiles"];
        NSError * error;
        NSArray * directoryContents =  [[NSFileManager defaultManager]
                                        contentsOfDirectoryAtPath:[newURL path] error:&error];
        
        NSLog(@"directoryContents ====== %@",directoryContents);
        
    
}

-(NSUInteger) fileCount
{
    //This does not reflect what is saved
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSURL * path = [self.url URLByAppendingPathComponent:@"audioFiles"];
    NSArray * numberOfFiles = [fileManager contentsOfDirectoryAtPath:path.path error:nil];
    NSUInteger filesCount = [numberOfFiles count];
    return filesCount;
}

-(void) deleteAllFromFileManager
{
    
    
    
    NSURL * newURL = [self.url URLByAppendingPathComponent:@"audioFiles"];
    NSError * error2;
    NSArray * directoryContents =  [[NSFileManager defaultManager]
                                    contentsOfDirectoryAtPath:[newURL path] error:&error2];
    
    NSLog(@"directoryContents ====== %@",directoryContents);

    if(directoryContents.count > 0)
    {
    
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSURL * path = [self.url URLByAppendingPathComponent:@"audioFiles"];
        
        NSError * error = nil;
        for (NSString * file in [fileManager contentsOfDirectoryAtPath:path.path error:&error])
        {
            NSString * totalPath = [path.path stringByAppendingPathComponent:file];

            BOOL success = [fileManager removeItemAtPath:totalPath error:&error];
            if(!success || error)
            {
                NSLog(@"FAIL");
            }
            
        }
        


    }
    
    NSArray * directoryContents2 =  [[NSFileManager defaultManager]
                                     contentsOfDirectoryAtPath:[newURL path] error:&error2];
    
    NSLog(@"directoryContents2 ====== %@",directoryContents2);
    
}

-(void) listFiles
{
    NSURL * newURL = [self.url URLByAppendingPathComponent:@"audioFiles"];
    NSError * error2;
    NSArray * directoryContents =  [[NSFileManager defaultManager]
                                    contentsOfDirectoryAtPath:[newURL path] error:&error2];
    
    NSLog(@"directoryContents ====== %@",directoryContents);
}

-(void) fetchControllerFiles
{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Recording"];
    NSError *error;
    request.predicate = nil;
    request.sortDescriptors =nil;
    NSArray * recordings = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    int x = (int) recordings.count;
    if(recordings.count >0)
    {
        for( int y = 0; y == x; y++)
        {
            Recording * recording = [recordings objectAtIndex:y];

            NSLog(@"FRC FILES :%@", recording.audioURL);
        }
    }
    
    
}

-(void) checkFileSizeofURL:(NSURL*)url
{
  
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:url.path error:nil];
    
    NSString *string = [NSByteCountFormatter stringFromByteCount:[fileAttributes fileSize] countStyle:NSByteCountFormatterCountStyleFile];

    NSLog(@"FILE SIZE %@", string);

//    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
//    long long fileSize = [fileSizeNumber longLongValue];
//    NSLog(@"file size is %lli", fileSize);

}

-(NSURL*) attachLastComponent: (NSString*) lastPath
{
    NSLog(@"Last Path %@", lastPath);
    NSURL * newURL = [self.url URLByAppendingPathComponent:@"audioFiles"];
    newURL = [newURL URLByAppendingPathComponent:lastPath];
    NSLog(@"new URL 1 %@", newURL.path);
    return newURL;
}




@end
