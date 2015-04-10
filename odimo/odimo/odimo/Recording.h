//
//  Recording.h
//  odimo
//
//  Created by omid sharghi on 8/12/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Recording : NSManagedObject

@property (nonatomic, retain) NSString * audioURL;
@property (nonatomic, retain) NSNumber * minAmpl;
@property (nonatomic, retain) NSDate * timeAdded;
@property (nonatomic, retain) NSString * trackTitle;
@property (nonatomic, retain) NSData * waveData;
@property (nonatomic, retain) NSNumber * recordingNumber;

@end
