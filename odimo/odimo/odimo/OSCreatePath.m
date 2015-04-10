//
//  OSCreatePath.m
//  odimo
//
//  Created by omid sharghi on 7/27/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import "OSCreatePath.h"
#import "UIBezierPath+Smoothing.h"

@interface OSCreatePath ()



@end

@implementation OSCreatePath
{
    
}


+(OSCreatePath*) getInstance
{
    
    static OSCreatePath* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[OSCreatePath alloc] init];
    });
    return _instance;
    
    
}


-(UIBezierPath*) createPathWithAsset:(AVAsset*)theAsset andSize:(CGSize)viewSize
{
    self.audioAsset = theAsset;
    self.imageSize = viewSize;
    
    if (self.audioAsset == nil) {
        //        return nil;
//        NSLog(@"Asset is nil!");
    }
    
    NSError *error = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:self.audioAsset error:&error];
    
    NSArray *audioTrackArray = [self.audioAsset tracksWithMediaType:AVMediaTypeAudio];
    
    if (audioTrackArray.count == 0) {
        //        return nil;
//        NSLog(@"COUNT is nill!");
    }
    
    AVAssetTrack *songTrack = [audioTrackArray objectAtIndex:0];
    
    NSDictionary *outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                        [NSNumber numberWithInt:32], AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:YES], AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                        nil];
    AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    [reader addOutput:output];
    
    // THIS IS NOT FOR PRODUCTION!!!
//    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(backgroundQueue, ^{
//        for (NSUInteger i = 0; i < 10000; i++) {
//            NSLog(@"Hello (background) world!!! (for the %lu time)", i);
//        }
//        
//        // Call UI thread-queue here AT THE END OF BACKGROUND BLOCK!!!
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // Execute animation code here
//        });
//    });
    
    // /THIS IS NOT FOR PRODUCTION!!!
    
    
    UInt32 channelCount = 0;
    NSArray *formatDesc = songTrack.formatDescriptions;
    for (unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription(item);
        
        if (fmtDesc == nil) {
            //            return nil;
        }
        
        channelCount = fmtDesc->mChannelsPerFrame;
    }
    
    UInt32 bytesPerInputSample = 4 * channelCount;
    [reader startReading];
    
    NSMutableData * data = [NSMutableData dataWithLength:32768];
    
    
    NSMutableArray *allSamples = [NSMutableArray array];
    
    
    while (reader.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef sampleBufferRef = [output copyNextSampleBuffer];
        
        if (sampleBufferRef) {
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            size_t bufferLength = CMBlockBufferGetDataLength(blockBufferRef);
            
            if (data.length < bufferLength) {
                [data setLength:bufferLength];
            }
            
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, bufferLength, data.mutableBytes);
            
            Float32 *samples = (Float32 *)data.mutableBytes;
            int sampleCount = (int)(bufferLength / bytesPerInputSample);
            for (int i = 0; i < sampleCount; i++) {
                [allSamples addObject:@(samples[i*channelCount])];
            }
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
        }
    }
    
    /*
     * Points for interpolation
     */
    float samplesInOnePixels = allSamples.count / self.imageSize.width * 10;
    
    
    double averagePowerForPixel=0;
    int currentPixelNumber = 0;
    self.minAmpl = 0;
    self.maxAmpl = 0;
    
    
    
    NSMutableArray * pointsForInterpolation = [NSMutableArray array];
    
    
    for (int i=0; i<allSamples.count; ++i) {
        averagePowerForPixel -= ABS([allSamples[i] floatValue]);
        if((i/samplesInOnePixels-1)>currentPixelNumber){
            self.minAmpl = MIN(self.minAmpl, averagePowerForPixel);
            self.maxAmpl = MAX(self.maxAmpl, averagePowerForPixel);
            
            [pointsForInterpolation addObject:[NSValue valueWithCGPoint:CGPointMake(currentPixelNumber, averagePowerForPixel)]];
            averagePowerForPixel = 0;
            ++currentPixelNumber;
        }
    }
    
    
    return [UIBezierPath smoothedPathWithGranularity:10 withPoints:pointsForInterpolation];
    
    
    
}

@end
