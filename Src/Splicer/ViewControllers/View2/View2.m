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

@property (strong) UIImagePickerController *imagePickerController;

@end

@implementation View2
@synthesize imagePickerController;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self performSelector:@selector(showcamera2) withObject:nil afterDelay:3.0];

}

- (void) showcamera2 {
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerCameraDeviceFront;
        imagePickerController.allowsEditing = NO;
        //imagePickerController.showsCameraControls = YES;
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, nil];
        
        UIView *controllerView = imagePickerController.view;
        [controllerView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
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
    
}




@end
