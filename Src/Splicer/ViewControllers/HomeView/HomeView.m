//
//  HomeView.m
//  Splicer
//
//  Created by Ahmad Abdul-Gawad Mahmoud on 4/25/16.
//  Copyright © 2016 Ahmad Abdul-Gawad Mahmoud. All rights reserved.
//

#import "HomeView.h"
#include "Utils.h"
#import "CaptureManager.h"
#import "AVCamRecorder.h"
#import "PXAlertView.h"
#import "YouTubeUploadVideo.h"
#import <AVFoundation/AVFoundation.h>

@interface HomeView () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, YouTubeUploadVideoDelegate>
{
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer;
}
#pragma mark - UI CONTROLS & PROPERITIES

// Recording
@property (nonatomic, strong) CaptureManager *captureManager;
@property (nonatomic, strong) IBOutlet UIView *videoPreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (weak, nonatomic) IBOutlet UIButton *buttonStartStopRecord;
@property (weak, nonatomic) IBOutlet UIButton *buttonSwitchCam;



//Exporting progress
@property (nonatomic,strong) IBOutlet UIView *progressView;
@property (nonatomic,strong) IBOutlet UIProgressView *progressBar;
@property (nonatomic,strong) IBOutlet UILabel *progressLabel;
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *activityView;

//Recording progress
@property (nonatomic,strong) IBOutlet UIProgressView *durationProgressBar;
@property (nonatomic,assign) float duration;
@property (nonatomic,strong) NSTimer *durationTimer;

// my overall timer.
@property (nonatomic,strong) NSTimer *timeTimer;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property int counter;
@property int savedVideos;
@property (weak, nonatomic) IBOutlet UIView *viewDotPoint;

// YOUTUBE UPLOAD

@property(nonatomic, strong) YouTubeUploadVideo *uploadVideo;


@end

@interface HomeView (CaptureManagerDelegate) <CaptureManagerDelegate>

@end


@implementation HomeView
@synthesize youtubeService;

#pragma mark - VIEW METHODS

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self preSettings];
    
    [self setupUI];
}

- (void) preSettings {
    
    if (IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.maxDuration = 5.0f;
    self.duration = 0.0f;
    self.counter = 0;
    self.savedVideos = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUrlGenerated:) name:@"urlGenerated" object:nil];

}

- (void) setupUI {
    
    if ([self captureManager] == nil) {
        
        CaptureManager *manager = [[CaptureManager alloc] init];
        [self setCaptureManager:manager];
        
        [[self captureManager] setDelegate:self];
        
        if ([[self captureManager] setupSession]) {
            
            // Create video preview layer and add it to the UI
            newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
            
            CALayer *viewLayer = self.videoPreviewView.layer;
            [viewLayer setMasksToBounds:YES];
            
            CGRect bounds = self.videoPreviewView.bounds;
            [newCaptureVideoPreviewLayer setFrame:bounds];
            
            if ([newCaptureVideoPreviewLayer.connection isVideoOrientationSupported]) {
                [newCaptureVideoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                //$$$$ [newCaptureVideoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
                
            }
            
            [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            
            [viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
            
            [self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
            
            // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[[self captureManager] session] startRunning];
            });
            
            self.viewDotPoint.layer.masksToBounds = YES;
            self.viewDotPoint.layer.cornerRadius = 2.5;
            
            self.progressView.layer.masksToBounds = YES;
            self.progressView.layer.cornerRadius = 7;
            
            [[NSNotificationCenter defaultCenter]
             addObserver:self selector:@selector(orientationChanged:)
             name:UIDeviceOrientationDidChangeNotification
             object:[UIDevice currentDevice]];
            
            [[NSNotificationCenter defaultCenter]
             addObserver:self selector:@selector(appWillResignActive:)
             name:UIApplicationWillResignActiveNotification
             object:nil];
            
        }
    }
    
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
                [newCaptureVideoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            [newCaptureVideoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            [newCaptureVideoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
            break;
            
        default:
            break;
    };
}

- (void) appWillResignActive:(NSNotification*)note
{
    // app entered background state.
    
    if ([[[self captureManager] recorder] isRecording]) {
        
        [self.durationTimer invalidate];
        [self.timeTimer invalidate];
        
        [self stopRecordUIChanges];
        
        // set flag value to avoid saving the recorded file before calling [[self captureManager] stopRecording];
        
        Utils *utils = [Utils getInstance];
        utils.buttonStopTapped = true;
        
        [[self captureManager] stopRecording];
        self.counter = 0;
        self.duration = 0.0f;
        
        NSLog(@"END number of pieces %lu", (unsigned long)[self.captureManager.assets count]);
        
    }
    
}

//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    return uiin(toInterfaceOrientation);
//}

#pragma mark - UI METHODS


- (IBAction)switchCamera:(id)sender {
    
    [self.captureManager switchCamera];
}

- (IBAction)startStopRecording:(UIButton *)sender {
    
    if (![[[self captureManager] recorder] isRecording])
    {
        [self beginRecordUIChanges];
        
        self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTimerChanged) userInfo:nil repeats:YES];

        [[self captureManager] startRecording];

    }
    else if ([[[self captureManager] recorder] isRecording]) {

        [self.durationTimer invalidate];
        [self.timeTimer invalidate];
        
        [self stopRecordUIChanges];

        // set flag value to avoid saving the recorded file before calling [[self captureManager] stopRecording];
        
        Utils *utils = [Utils getInstance];
        utils.buttonStopTapped = true;
        
        [[self captureManager] stopRecording];
        self.counter = 0;
        self.duration = 0.0f;

        NSLog(@"END number of pieces %lu", (unsigned long)[self.captureManager.assets count]);

    }
}

- (void) beginRecordUIChanges {
    
    // update UI.
    
    [self.buttonStartStopRecord setBackgroundImage:[UIImage imageNamed:@"icon-record-stop.png"] forState:UIControlStateNormal];
    
    self.buttonSwitchCam.hidden = YES;
}

- (void) stopRecordUIChanges {
    
    // update UI start record button.
    
    [self.buttonStartStopRecord setBackgroundImage:[UIImage imageNamed:@"player_record.png"] forState:UIControlStateNormal];
    
    self.buttonSwitchCam.hidden = NO;
    
    self.videoPreviewView.layer.borderColor = [UIColor clearColor].CGColor;
    
    self.labelTime.text = @"00:00:00";
    
    self.viewDotPoint.hidden = YES;
    
    self.durationProgressBar.progress = 0.0;

}

- (void) timeTimerChanged {
    
    self.counter++;
    
    if (self.counter % 2 == 0) {
        
        self.viewDotPoint.hidden = NO;
        self.videoPreviewView.layer.borderWidth = 5.0;
    } else {
        
        self.viewDotPoint.hidden = YES;
        self.videoPreviewView.layer.borderWidth = 0.0;
    }
    
    int hours = (int)(self.counter / 3600);
    int minutes = (int)(self.counter / 60);
    int seconds = self.counter - ((hours * 3600) + (minutes * 60));
    
    NSMutableString *strGenerated = [NSMutableString new];
    
    if (hours == 0) {
        [strGenerated appendString:@"00 "];
    }
    else if (hours < 10) {
        [strGenerated appendString:[NSString stringWithFormat: @"0%i ", hours]];
    }
    else {
        [strGenerated appendString:[NSString stringWithFormat: @"%i ", hours]];
    }
 
    if (minutes == 0) {
        [strGenerated appendString:@"00 "];
    }
    else if (minutes < 10) {
        [strGenerated appendString:[NSString stringWithFormat: @"0%i ", minutes]];
    }
    else {
        [strGenerated appendString:[NSString stringWithFormat: @"%i ", minutes]];
    }
    if (seconds == 0) {
        [strGenerated appendString:@"00"];
    }
    else if (seconds < 10){
        [strGenerated appendString:[NSString stringWithFormat: @"0%i ", seconds]];
    }
    else {
        [strGenerated appendString:[NSString stringWithFormat: @"%i ", seconds]];
    }
    
    // update UI
    
    self.labelTime.text = strGenerated;
}

#pragma mark - RECORDING METHODS

- (void) updateDuration
{
    if ([[[self captureManager] recorder] isRecording])
    {
        self.duration = self.duration + 1;
        [self.durationProgressBar setProgress:(self.duration/self.maxDuration) animated:YES];
        NSLog(@"self.duration %f, self.progressBar %f", self.duration, self.durationProgressBar.progress);
        
        if (((int)self.duration % (int)self.maxDuration) == 0) {
            
            if (self.savedVideos != 2) {
                
                [self.durationTimer invalidate];
                self.duration = 0.0f;
                [[self captureManager] stopRecording];
                
                // save locally.
                
                [self performSelector:@selector(saveVideo) withObject:nil afterDelay:1.0];
           
            } else {
                
                // save on cloud.
                // TODO
                
                NSLog(@"save it on icloud.");
                
            }
        }
    }
    else
    {
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }
}

- (void) saveVideo {
    
    [self stopRecordUIChanges];
    
    [self saveVideoWithCompletionBlock:^(BOOL success) {
        
        if (success)
        {
            self.savedVideos++;
            
            NSLog(@"WILL FIND NEW VIDEO IN YOUR CAM ROLL. :) ");
            
            [self performSelector:@selector(beginRecordingAgain) withObject:nil afterDelay:1.0];
        }
    }];
}

- (void) beginRecordingAgain {
    
    // start recording the next section.
    
    if (![[[self captureManager] recorder] isRecording])
    {
        [self beginRecordUIChanges];
        
        [[self captureManager] startRecording];
        
    }
}
- (void)saveVideoWithCompletionBlock:(void(^)(BOOL success))completion {
    
    __block id weakSelf = self;
    
    [self.captureManager saveVideoWithCompletionBlock:^(BOOL success) {
        
        if (completion)
        {
            self.progressLabel.text = @"Saved To Photo Album";
            [weakSelf performSelector:@selector(refresh) withObject:nil afterDelay:0.5];
            
        }
        else
        {
            self.progressLabel.text = @"Video Saving Failed";
        }
        
        [self.activityView stopAnimating];
        
        completion (success);
    }];
}

-(void)refresh
{
    self.progressView.hidden = YES;
    self.duration = 0.0;
    self.durationProgressBar.progress = 0.0;
    [self.durationTimer invalidate];
    self.durationTimer = nil;

}

#pragma mark - YOUTUBE API

- (void) notificationUrlGenerated:(NSNotification *) notification {
    
    [PXAlertView showAlertWithTitle: @"Info" message: @"You'll be notified after uploading this section on your youtube channel." cancelTitle:@"OK ☑️" completion: nil];
    
    _uploadVideo = [[YouTubeUploadVideo alloc] init];
    _uploadVideo.delegate = self;
    NSURL *VideoUrl = [notification object];
    
    NSData *fileData = [NSData dataWithContentsOfURL:VideoUrl];
    NSString *title;
    NSString *description;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"'Test Video Uploaded ('EEEE MMMM d, YYYY h:mm a, zzz')"];
    title = [dateFormat stringFromDate:[NSDate date]];
    
    description = @"This is test";
    
    if (self.youtubeService != nil) {
        
        [self.uploadVideo uploadYouTubeVideoWithService:self.youtubeService
                                               fileData:fileData
                                                  title:title
                                            description:description];
    }
}

- (void)uploadYouTubeVideo:(YouTubeUploadVideo *)uploadVideo
      didFinishWithResults:(GTLYouTubeVideo *)video {
    
    [PXAlertView showAlertWithTitle: @"Successfully 😃" message: @"Successfully uploaded the third section on Youtube so check it on your channel. 👍" cancelTitle:@"OK ☑️" completion: nil];
    
}

@end

#pragma mark - CaptureManagerDelegate

@implementation HomeView (CaptureManagerDelegate)

- (void)captureManagerRecordingBegan:(CaptureManager *)captureManager
{
    self.videoPreviewView.layer.borderColor = [UIColor redColor].CGColor;
    self.videoPreviewView.layer.borderWidth = 5.0;
    
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateDuration) userInfo:nil repeats:YES];
    
}

- (void) updateProgress
{
    self.progressView.hidden = NO;
    self.progressBar.hidden = NO;
    self.activityView.hidden = YES;
    self.progressLabel.text = @"Compressing the video";
    self.progressBar.progress = self.captureManager.exportSession.progress;
    if (self.progressBar.progress > .99) {
        [self.captureManager.exportProgressBarTimer invalidate];
        self.captureManager.exportProgressBarTimer = nil;
    }
}

- (void) removeProgress
{
    self.progressBar.hidden = YES;
    self.activityView.hidden = NO;

    [self.activityView startAnimating];
    self.progressLabel.text = @"Saving to Camera Roll";
}

- (void)captureManager:(CaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}


- (void)captureManagerRecordingFinished:(CaptureManager *)captureManager
{
    

}

- (void)captureManagerDeviceConfigurationChanged:(CaptureManager *)captureManager
{
    //Do something
}




@end






