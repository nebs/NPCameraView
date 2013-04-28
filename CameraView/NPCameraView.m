//
//  NPCameraView.m
//  Wireframe
//
//  Created by Nebojsa Petrovic on 4/7/13.
//  Copyright (c) 2013 Nebojsa Petrovic. All rights reserved.
//

#import "NPCameraView.h"
#import <AVFoundation/AVFoundation.h>

@interface NPCameraView ()
@property (nonatomic) AVCaptureDevice *frontCameraCaptureDevice;
@property (nonatomic) AVCaptureDevice *rearCameraCaptureDevice;
@property (nonatomic) AVCaptureDeviceInput *deviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (copy, nonatomic) NPVideoCallbackBlock videoCallbackBlock;

- (void)initialize;
@end

@implementation NPCameraView

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.captureSession = [[AVCaptureSession alloc] init];

    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    }
    
    // Add inputs and outputs.
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device position] == AVCaptureDevicePositionBack) {
                self.rearCameraCaptureDevice = device;
            } else {
                self.frontCameraCaptureDevice = device;
            }
        }
    }
    
    // Setup input
    self.cameraType = NPCameraTypeRear;
    
    // Setup movie output
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSession canAddOutput:self.movieFileOutput]) {
        [self.captureSession addOutput:self.movieFileOutput];
    }

    // Setup image output
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([self.captureSession canAddOutput:self.stillImageOutput]) {
        [self.captureSession addOutput:self.stillImageOutput];
    }
    
    // Add live preview to the view
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.videoPreviewLayer.bounds = self.layer.bounds;
    self.videoPreviewLayer.position = CGPointMake(CGRectGetMidX(self.layer.bounds), CGRectGetMidY(self.layer.bounds));
    [self.layer addSublayer:self.videoPreviewLayer];
    
    // Start the camera
    [self.captureSession startRunning];
}

#pragma mark - Camera Configuration
- (void)setCameraType:(NPCameraType)cameraType {
    _cameraType = cameraType;
    
    if (!self.captureSession ||
        (!self.rearCameraCaptureDevice && self.cameraType == NPCameraTypeRear) ||
        (!self.frontCameraCaptureDevice && self.cameraType == NPCameraTypeFront)) {
        return;
    }
    
    [self.captureSession removeInput:self.deviceInput];
    self.deviceInput = nil;
    NSError *error;
    
    if (self.cameraType == NPCameraTypeRear) {
        self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.rearCameraCaptureDevice error:&error];
    } else {
        self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.frontCameraCaptureDevice error:&error];
    }

    if ([self.captureSession canAddInput:self.deviceInput]) {
        [self.captureSession addInput:self.deviceInput];
    }
}

#pragma mark - AVCaptureFileOutputRecording Delegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error {
    
    BOOL recordedSuccessfully = YES;
    if ([error code] != noErr) {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value) {
            recordedSuccessfully = [value boolValue];
        }
    }

    if (!self.videoCallbackBlock) {
        return;
    }

    if (recordedSuccessfully) {
        self.videoCallbackBlock(outputFileURL);
    } else {
        self.videoCallbackBlock(nil);
    }

    self.videoCallbackBlock = nil;
}

#pragma mark - Camera Controls
- (void)captureImageWithCallback:(void (^)(UIImage *image))callbackBlock {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }

    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         callbackBlock(image);
     }];
}

- (void)recordVideoForDuration:(NSTimeInterval)duration
                     toFileURL:(NSURL *)fileURL
                      callback:(NPVideoCallbackBlock)callbackBlock {
    if (!fileURL) {
        return;
    }

    // If there's already a callback, call it with nil so it knows it failed
    if (self.videoCallbackBlock) {
        self.videoCallbackBlock(nil);
    }

    if ([self.movieFileOutput isRecording]) {
        [self.movieFileOutput stopRecording];
    }

    self.movieFileOutput.maxRecordedDuration = CMTimeMakeWithSeconds(duration, 30.0f);
    self.videoCallbackBlock = callbackBlock;
    [self.movieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
}

- (void)stopRecordingVideo {
    [self.movieFileOutput stopRecording];
    if (self.videoCallbackBlock) {
        self.videoCallbackBlock(nil);
        self.videoCallbackBlock = nil;
    }
}

@end
