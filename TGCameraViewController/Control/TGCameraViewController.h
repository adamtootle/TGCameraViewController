//
//  TGCameraViewController.h
//  TGCameraViewController
//
//  Created by Bruno Tortato Furtado on 13/09/14.
//  Copyright (c) 2014 Tudo Gostoso Internet. All rights reserved.
//

@import UIKit;
#import "TGCamera.h"

@interface TGCameraViewController : UIViewController <UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak) id<TGCameraDelegate> delegate;

@end