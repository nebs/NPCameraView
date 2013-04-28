//
//  NPCameraView.h
//  Wireframe
//
//  Created by Nebojsa Petrovic on 4/7/13.
//  Copyright (c) 2013 Nebojsa Petrovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureOutput.h>

typedef enum {
    NPCameraTypeFront = 0,
    NPCameraTypeRear
} NPCameraType;

typedef void (^NPImageCallbackBlock)(UIImage *image);
typedef void (^NPVideoCallbackBlock)(NSURL *videoFileURL);

@class NPCameraView;

@interface NPCameraView : UIView <AVCaptureFileOutputRecordingDelegate>

@property (assign, nonatomic) NPCameraType cameraType;

// Camera controls
- (void)captureImageWithCallback:(NPImageCallbackBlock)callbackBlock;
- (void)recordVideoForDuration:(NSTimeInterval)duration
                     toFileURL:(NSURL *)fileURL
                      callback:(NPVideoCallbackBlock)callbackBlock;
- (void)stopRecordingVideo;

@end
