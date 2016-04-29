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
#import <AVFoundation/AVFoundation.h>

@interface HomeView () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

#pragma mark - UI CONTROLS & PROPERITIES

// Recording
@property (nonatomic, strong) CaptureManager *captureManager;
@property (nonatomic, strong) IBOutlet UIView *videoPreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (weak, nonatomic) IBOutlet UIButton *buttonStartStopRecord;



//Exporting progress
@property (nonatomic,strong) UIView *progressView;
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
@property (weak, nonatomic) IBOutlet UIView *viewDotPoint;

@end

@interface HomeView (CaptureManagerDelegate) <CaptureManagerDelegate>

@end


@implementation HomeView

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

}

- (void) setupUI {
    
    if ([self captureManager] == nil) {
        
        CaptureManager *manager = [[CaptureManager alloc] init];
        [self setCaptureManager:manager];
        
        [[self captureManager] setDelegate:self];
        
        if ([[self captureManager] setupSession]) {
            
            // Create video preview layer and add it to the UI
            AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
            
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
        }
    }
    
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

#pragma mark - UI METHODS


- (IBAction)switchCamera:(id)sender {
    
    [self.captureManager switchCamera];
}

- (IBAction)startStopRecording:(UIButton *)sender {
    
    if (![[[self captureManager] recorder] isRecording])
    {
        // update UI start record button.
        
        [self.buttonStartStopRecord setBackgroundImage:[UIImage imageNamed:@"icon-record-stop.png"] forState:UIControlStateNormal];
        
        NSLog(@"START");
        
        [[self captureManager] startRecording];
        
        self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTimerChanged) userInfo:nil repeats:YES];

    }
    else if ([[[self captureManager] recorder] isRecording]) {
        
        // update UI start record button.
        
        [self.buttonStartStopRecord setBackgroundImage:[UIImage imageNamed:@"player_record.png"] forState:UIControlStateNormal];
        
        [self.durationTimer invalidate];
        [[self captureManager] stopRecording];
        self.videoPreviewView.layer.borderColor = [UIColor clearColor].CGColor;
        
        NSLog(@"END number of pieces %lu", (unsigned long)[self.captureManager.assets count]);
        
        [self.timeTimer invalidate];
        self.counter = 0;
    }
}

- (void) timeTimerChanged {
    
    self.counter++;
    
    if (self.counter % 2 == 0) {
        
        self.viewDotPoint.hidden = NO;
        self.videoPreviewView.layer.borderWidth = 2.0;
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
        if (self.duration > self.maxDuration) {
            
            //$$$ passed 2 minutes so what ... ? :):):)
            
            [self.durationTimer invalidate];
            self.durationTimer = nil;
            [[self captureManager] stopRecording];
            
            [self saveVideo];
        }
    }
    else
    {
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }
}

- (void) saveVideo {
    
    [self saveVideoWithCompletionBlock:^(BOOL success) {
        
        if (success)
        {
            NSLog(@"WILL FIND NEW VIDEO IN YOUR CAM ROLL. :) ");
            
        }
    }];
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

@end

#pragma mark - CaptureManagerDelegate

@implementation HomeView (CaptureManagerDelegate)

- (void)captureManagerRecordingBegan:(CaptureManager *)captureManager
{
    self.videoPreviewView.layer.borderColor = [UIColor redColor].CGColor;
    self.videoPreviewView.layer.borderWidth = 2.0;
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateDuration) userInfo:nil repeats:YES];
}

- (void) updateProgress
{
    self.progressView.hidden = NO;
    self.progressBar.hidden = NO;
    self.activityView.hidden = YES;
    self.progressLabel.text = @"Creating the video";
    self.progressBar.progress = self.captureManager.exportSession.progress;
    if (self.duration > self.maxDuration) {
        [self.captureManager.exportProgressBarTimer invalidate];
        self.captureManager.exportProgressBarTimer = nil;
    }
}

- (void) removeProgress
{
    self.progressBar.hidden = YES;
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
























/*- (void) showcamera2 {
 
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
 
        imagePickerController2 = nil;

        imagePickerController2 = [[UIImagePickerController alloc] init];
        imagePickerController2.sourceType = UIImagePickerControllerCameraDeviceFront;
        imagePickerController2.allowsEditing = NO;
        //imagePickerController2.showsCameraControls = YES;
        imagePickerController2.delegate = self;
        imagePickerController2.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, nil];
        
        UIView *controllerView = imagePickerController2.view;
        [controllerView setFrame:CGRectMake(0, self.view.frame.size.height / 2, self.view.frame.size.width, self.view.frame.size.height / 2)];
        
        controllerView.alpha = 0.0;
        //controllerView.transform = CGAffineTransformMakeScale(0.25, 0.25);
        
        [self.view addSubview:controllerView];
        //[[[[UIApplication sharedApplication] delegate] window] addSubview:controllerView];
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             controllerView.alpha = 1.0;
                         }
                         completion:nil
         ];
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"I'm afraid there's no camera on this device!" delegate:nil cancelButtonTitle:@"Dang!" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    [self performSelector:@selector(showcamera) withObject:nil afterDelay:5.0];
    
}*/





