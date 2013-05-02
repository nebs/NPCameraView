NPCameraView
============

NPCameraView is a UIView subclass that acts like a camera.

![Alt text](/Screenshots/screenshot.png "Screenshot")

The included sample project demonstrates all the basic features.


Features
--------
- Live camera preview directly in a UIView.
- Easy switch between front and rear cameras.
- Easily capture still images into a UIImage.
- Record videos with specified duration directly onto disk.


Installation
------------

- Add NPCameraView.h and NPCameraView.m to your project.
- Import NPCameraView.h
- Add AVFoundation and CoreMedia frameworks to your project.


Initialization
--------------

You initialize an NPCameraView just like any other UIView.  
The simplest way is to drag a UIView in IB and change its class to NPCameraView.
As soon as an NPCameraView is created you will be able to see a live preview from the camera.


Switch front & rear cameras
---------------------------

```objc
// self.cameraView is an instance of NPCameraView

// Switch to the rear camera
self.cameraView.cameraType = NPCameraTypeRear;

// Switch to the front camera
self.cameraView.cameraType = NPCameraTypeFront;
```


Capture still image
-------------------

```objc
[self.cameraView captureImageWithCallback:^(UIImage *image) {
	// Do something with this new image
    self.myImageView.image = image;
}];
```


Record video
------------

```objc
// Record a 5 second video and save it to a file
NSURL *myVideoFilePathURL = ... // create a full path to a video file (*.mov)
[self.cameraView recordVideoForDuration:5.0f
                              toFileURL:myVideoFilePathURL
                               callback:^(NSURL *videoFileURL) {
                                   if (videoFileURL) {
                                       // Do something with this video
                                   }
                               }];
```
