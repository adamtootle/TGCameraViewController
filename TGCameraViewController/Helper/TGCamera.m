//
//  TGCamera.m
//  TGCameraViewController
//
//  Created by Bruno Tortato Furtado on 14/09/14.
//  Copyright (c) 2014 Tudo Gostoso Internet. All rights reserved.
//

#import "TGCamera.h"
#import "TGCameraGrid.h"
#import "TGCameraGridView.h"
#import "TGCameraFlash.h"
#import "TGCameraFocus.h"
#import "TGCameraShot.h"
#import "TGCameraToggle.h"



@interface TGCamera ()

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) TGCameraGridView *gridView;

+ (instancetype)newCamera;

- (void)setupWithFlashButton:(UIButton *)flashButton;

@end



@implementation TGCamera

+ (instancetype)cameraWithFlashButton:(UIButton *)flashButton
{
    TGCamera *camera = [TGCamera newCamera];
    [camera setupWithFlashButton:flashButton];
    
    return camera;
}

+ (BOOL)deviceSupportsCamera
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

#pragma mark -
#pragma mark - Public methods

- (void)startRunning
{
    [_session startRunning];
}

- (void)stopRunning
{
    [_session stopRunning];
}

- (void)insertSublayerWithCaptureView:(UIView *)captureView atRootView:(UIView *)rootView
{
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    CALayer *rootLayer = [rootView layer];
    rootLayer.masksToBounds = YES;
    
    CGRect frame = captureView.frame;
    _previewLayer.frame = frame;
    
    [rootLayer insertSublayer:_previewLayer atIndex:0];
    
    NSInteger index = [captureView.subviews count]-1;
    [captureView insertSubview:self.gridView atIndex:index];
}

- (void)disPlayGridView
{
    [TGCameraGrid disPlayGridView:self.gridView];
}

- (void)changeFlashModeWithButton:(UIButton *)button
{
    [TGCameraFlash changeModeWithCaptureSession:_session andButton:button];
}

- (void)focusView:(UIView *)focusView inTouchPoint:(CGPoint)touchPoint
{
    [TGCameraFocus focusWithCaptureSession:_session touchPoint:touchPoint inFocusView:focusView];
}

- (void)takePhotoWithCaptureView:(UIView *)captureView effectiveScale:(NSInteger)effectiveScale videoOrientation:(AVCaptureVideoOrientation)videoOrientation completion:(void (^)(UIImage *))completion
{
    [TGCameraShot takePhotoCaptureView:captureView stillImageOutput:_stillImageOutput effectiveScale:effectiveScale videoOrientation:videoOrientation
    completion:^(UIImage *photo) {
        completion(photo);
    }];
}

- (void)toogleWithFlashButton:(UIButton *)flashButton
{
    [TGCameraToggle toogleWithCaptureSession:_session];
    [TGCameraFlash flashModeWithCaptureSession:_session andButton:flashButton];
}

#pragma mark -
#pragma mark - Private methods

+ (instancetype)newCamera
{
    return [super new];
}

- (TGCameraGridView *)gridView
{
    if (_gridView == nil) {
        CGRect frame = _previewLayer.frame;
        frame.origin.x = frame.origin.y = 0;
        
        _gridView = [[TGCameraGridView alloc] initWithFrame:frame];
        _gridView.numberOfColumns = 2;
        _gridView.numberOfRows = 2;
        _gridView.alpha = 0;
    }
    
    return _gridView;
}

- (void)setupWithFlashButton:(UIButton *)flashButton
{
    //
    // create session
    //
    
    _session = [AVCaptureSession new];
    _session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    //
    // setup device
    //
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device lockForConfiguration:nil]) {
        if (device.autoFocusRangeRestrictionSupported) {
            device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
        }
        
        if (device.smoothAutoFocusSupported) {
            device.smoothAutoFocusEnabled = YES;
        }
        
        device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        
        [device unlockForConfiguration];
    }

    //
    // add device input to session
    //
    
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [_session addInput:deviceInput];
    
    //
    // add output to session
    //
    
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    
    _stillImageOutput = [AVCaptureStillImageOutput new];
    _stillImageOutput.outputSettings = outputSettings;
    
    [_session addOutput:_stillImageOutput];
    
    //
    // setup flash button
    //
    
    [TGCameraFlash flashModeWithCaptureSession:_session andButton:flashButton];
}

@end