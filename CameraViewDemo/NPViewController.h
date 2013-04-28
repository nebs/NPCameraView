//
//  NPViewController.h
//  CameraViewDemo
//
//  Created by Nebojsa Petrovic on 4/27/13.
//  Copyright (c) 2013 Nebojsa Petrovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NPCameraView.h"

@interface NPViewController : UIViewController

@property (weak, nonatomic) IBOutlet NPCameraView *cameraView;
@property (weak, nonatomic) IBOutlet UIImageView *stillImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)captureImageButtonPressed:(id)sender;
- (IBAction)flipButtonPressed:(id)sender;
- (IBAction)recordVideoButtonPressed:(id)sender;

@end
