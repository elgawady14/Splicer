//
//  HomeView.h
//  Splicer
//
//  Created by Ahmad Abdul-Gawad Mahmoud on 4/25/16.
//  Copyright © 2016 Ahmad Abdul-Gawad Mahmoud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import "GTLYouTube.h"
#import "UploadController.h"
#import "YouTubeGetUploads.h"
#import "YouTubeUploadVideo.h"

@class CaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;

@interface HomeView : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) float maxDuration;
@property (nonatomic,assign) BOOL showCameraSwitch;
@property (nonatomic, strong) GTLServiceYouTube *youtubeService;

- (void)saveVideoWithCompletionBlock:(void(^)(BOOL success))completion;
- (void) notificationUrlGenerated:(NSNotification *) notification;

@end
