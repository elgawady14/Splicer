//
//  View2.m
//  Splicer
//
//  Created by Ahmad Abdul-Gawad Mahmoud on 4/26/16.
//  Copyright © 2016 Ahmad Abdul-Gawad Mahmoud. All rights reserved.
//

#import "View2.h"
#import <MobileCoreServices/MobileCoreServices.h>


@interface View2 () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong) UIImagePickerController *imagePickerController2;

@end

@implementation View2
@synthesize imagePickerController2;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
//        
//        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//        picker.delegate = self;
//        picker.allowsEditing = NO;
//        picker.sourceType = UIImagePickerControllerCameraDeviceRear;
//        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
//        
//        [self presentViewController:picker animated:YES completion:NULL];
//    } else {
//        
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"I'm afraid there's no camera on this device!" delegate:nil cancelButtonTitle:@"Dang!" otherButtonTitles:nil, nil];
//        [alertView show];
//    }
//
    [self performSelector:@selector(showcamera2) withObject:nil afterDelay:0.6];

}

- (void) showcamera2 {
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {

        imagePickerController2 = [[UIImagePickerController alloc] init];
        imagePickerController2.sourceType = UIImagePickerControllerCameraDeviceRear;
        imagePickerController2.allowsEditing = NO;
        //imagePickerController2.showsCameraControls = YES;
        imagePickerController2.delegate = self;
        imagePickerController2.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, nil];
        
        UIView *controllerView = imagePickerController2.view;
        [controllerView setFrame:CGRectMake(0, self.view.frame.size.height / 2, self.view.frame.size.width, self.view.frame.size.height / 2)];
        
        controllerView.alpha = 0.0;
        //controllerView.transform = CGAffineTransformMakeScale(0.25, 0.25);
        
        [[[[UIApplication sharedApplication] delegate] window] addSubview:controllerView];
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             controllerView.alpha = 1.0;
                         }
                         completion:nil
         ];
    }
    else {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"I'm afraid there's no camera on this device!" delegate:nil cancelButtonTitle:@"Dang!" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}




@end
