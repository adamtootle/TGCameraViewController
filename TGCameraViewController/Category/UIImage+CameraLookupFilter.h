//
//  UIImage+CameraLookupFilter.h
//  Spire
//
//  Created by Adam Tootle on 10/9/14.
//  Copyright (c) 2014 LifeKraze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CameraLookupFilter)

- (CIFilter *)filterWithLookupImage:(UIImage *)lookupImage;
- (CIFilter *)filterWithLookupImageNamed:(NSString *)lookupImageName;
- (UIImage *)filteredWithLookupImage:(UIImage *)lookupImage;
- (UIImage *)filteredWithLookupImageNamed:(NSString *)lookupImageName;

@end
