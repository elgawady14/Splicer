//
//  HomeView.m
//  Splicer
//
//  Created by Ahmad Abdul-Gawad Mahmoud on 4/25/16.
//  Copyright © 2016 Ahmad Abdul-Gawad Mahmoud. All rights reserved.
//

#import "HomeView.h"
#import "View1.h"
#import "View2.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface HomeView () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{}

@property View1 *view1;
@property View2 *view2;
@property (strong) UIImagePickerController *imagePickerController;

@property (strong) UIImagePickerController *imagePickerController2;

@end

@implementation HomeView
@synthesize imagePickerController, imagePickerController2;
- (void)viewDidLoad {
    [super viewDidLoad];

    
}


- (IBAction)capture:(id)sender {
    
    self.view1 = [self.storyboard instantiateViewControllerWithIdentifier:@"view1"];
    [self addChildViewController:self.view1];
    [self.view1.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.view1.view];
    [self.view1 didMoveToParentViewController:self];
    
    self.view2 = [self.storyboard instantiateViewControllerWithIdentifier:@"view2"];
    [self addChildViewController:self.view2];
    [self.view2.view setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.view2.view];
    [self.view2 didMoveToParentViewController:self];
  
    
    
    ///
    
    
//    [self performSelector:@selector(showcamera) withObject:nil afterDelay:0.3];
//    [self performSelector:@selector(showcamera2) withObject:nil afterDelay:0.6];

//    imagePickerController = [[UIImagePickerController alloc] init];
//    
//    imagePickerController.delegate = self;
//    imagePickerController.allowsEditing = NO;
//    imagePickerController.sourceType = UIImagePickerControllerCameraDeviceFront;
//    imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
//
//    UIView *controllerView = imagePickerController.view;
//    
//    controllerView.alpha = 0.0;
//    
//    
//    controllerView.transform = CGAffineTransformMakeScale(0.5, 0.5);
//
//    
//    [UIView animateWithDuration:0.3
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveLinear
//                     animations:^{
//                         controllerView.alpha = 1.0;
//                     }
//                     completion:nil
//     ];
//    
//    [self.view addSubview:controllerView];

}

- (void) showcamera {
    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerCameraDeviceFront;
    //imagePickerController.showsCameraControls = YES;
    imagePickerController.delegate = self;
    imagePickerController.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, nil];
    
    UIView *controllerView = imagePickerController.view;
    [controllerView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 2)];
    
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

- (void) showcamera2 {
    
    imagePickerController2 = [[UIImagePickerController alloc] init];
    imagePickerController2.sourceType = UIImagePickerControllerCameraDeviceRear;
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




@end
