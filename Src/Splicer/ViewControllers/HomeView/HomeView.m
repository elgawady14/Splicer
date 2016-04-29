//
//  HomeView.m
//  Splicer
//
//  Created by Ahmad Abdul-Gawad Mahmoud on 4/25/16.
//  Copyright © 2016 Ahmad Abdul-Gawad Mahmoud. All rights reserved.
//

#import "HomeView.h"


#import <MobileCoreServices/MobileCoreServices.h>

@interface HomeView () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{}


@end

@implementation HomeView

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}


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

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}


@end
