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

@end

@implementation View2

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
}



@end
