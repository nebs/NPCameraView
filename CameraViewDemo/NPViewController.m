//
//  NPViewController.m
//  CameraViewDemo
//
//  Created by Nebojsa Petrovic on 4/27/13.
//  Copyright (c) 2013 Nebojsa Petrovic. All rights reserved.
//

#import "NPViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation NPViewController

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

// Returns a random new file URL for a movie file in the Documents directory
- (NSURL *)uniqueVideoPathURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSDate *now = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"movie_%f.mov", now.timeIntervalSince1970];
    NSString *path = [basePath stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    return fileURL;
}

#pragma mark - Actions
- (IBAction)captureImageButtonPressed:(id)sender {
    [self.cameraView captureImageWithCallback:^(UIImage *image) {
        self.stillImageView.image = image;
    }];
}

- (IBAction)flipButtonPressed:(id)sender {
    if (self.cameraView.cameraType == NPCameraTypeFront) {
        self.cameraView.cameraType = NPCameraTypeRear;
    } else {
        self.cameraView.cameraType = NPCameraTypeFront;
    }
}

- (IBAction)recordVideoButtonPressed:(id)sender {
    self.statusLabel.text = @"Recording 5 secs...";
    [self.cameraView recordVideoForDuration:5.0f
                                  toFileURL:[self uniqueVideoPathURL]
                                   callback:^(NSURL *videoFileURL) {
                                       self.statusLabel.text = @"Idle...";

                                       if (!videoFileURL) {
                                           return;
                                       }

                                       MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoFileURL];
                                       [self presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
                                   }];
}

@end
