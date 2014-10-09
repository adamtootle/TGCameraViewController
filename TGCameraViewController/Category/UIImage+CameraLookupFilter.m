//
//  UIImage+CameraLookupFilter.m
//  Spire
//
//  Created by Adam Tootle on 10/9/14.
//  Copyright (c) 2014 LifeKraze. All rights reserved.
//

#import "UIImage+CameraLookupFilter.h"

@implementation UIImage (CameraLookupFilter)

- (CIFilter *)filterWithLookupImage:(UIImage *)lookupImage
{
    // The first task of this filter is to convert the lookup image
    // into a usable set of pixel data. We do this by building a CGContext
    // that is stored in a char array that we'll draw the image into.
    CGImageRef imageRef = [lookupImage CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    if(width < 512 || height < 512) {
        return nil;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef rawContext = CGBitmapContextCreate(rawData, width, height,
                                                    
                                                    bitsPerComponent, bytesPerRow, colorSpace,
                                                    
                                                    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(rawContext, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(rawContext);
    
    // Next, We're using a CIColorCube that expects a particular format of 3D array.
    // For iOS, it can only be 64^3, sp forst. let setup some raw containers to
    // hold this old C array
    const unsigned int size = 64;
    size_t cubeDataSize = size * size * size * sizeof ( float ) * 4;
    float *cubeData = (float *) malloc ( cubeDataSize ); // This is the flat data structure that we have to put our array in.
    
    // Iterate through all RGB values from 0-63,
    // figure out what the RGB value is at that position,
    // and set it into our 3D array.
    size_t offset = 0;
    for (int z = 0; z < size; z++)
    {
        for (int y = 0; y < size; y++)
        {
            for (int x = 0; x < size; x++)
            {
                // So now we have x,y,z representing RGB 0-63
                // In our lookup images, we have 64 blocks of RG, which ends up making a B grid.
                // Thus, we need to which quadrand we are in for Blue (the z math part)
                // and turn that into an acutal XY coordinate we can use in our
                // lookup table.
                int realX = (z % 8) * size + x;
                int realY = (z / 8) * size + y;
                
                // CoreGraphics dropped our lookup table into a 1D array, so we'll use
                // this to get the byte index from our 2D coordinates, and then set the data.
                unsigned long byteIndex = (bytesPerRow * realY) + (realX * bytesPerPixel);
                // The raw data is a byte, so we convert it to float (1.0) and then divide by 255 to get the format it wants.
                cubeData[offset]   = (rawData[byteIndex] * 1.0) / 255.0f;
                cubeData[offset+1] = (rawData[byteIndex+1] * 1.0) / 255.0f;
                cubeData[offset+2] = (rawData[byteIndex+2] * 1.0) / 255.0f;
                cubeData[offset+3] = 1.0; // We don't touch alpha right now. I only did this because GPUImage did it too.
                // Techncially, we could read alpha data too from the lookup and use it here.
                
                offset += 4;
            }
        }
    }
    
    // Turn our array into an NSData that CIFilter likes
    NSData *data = [NSData dataWithBytesNoCopy:cubeData length:cubeDataSize freeWhenDone:YES];
    
    // And then build the filter and return it.
    CIFilter *filter = [CIFilter filterWithName:@"CIColorCube"];
    [filter setValue:[NSNumber numberWithInt:size] forKey:@"inputCubeDimension"];
    [filter setValue:data forKey:@"inputCubeData"];
    return filter;
}

- (CIFilter *)filterWithLookupImageNamed:(NSString *)lookupImageName
{
    if(lookupImageName == nil) {
        return nil;
    }
    UIImage *gradientImage = [UIImage imageNamed:lookupImageName];
    if(gradientImage == nil) {
        return nil;
    }
    return [self filterWithLookupImage:gradientImage];
}

- (UIImage *)filteredWithLookupImage:(UIImage *)lookupImage
{
    // Get a reference to the image we're working with.
    CIImage *inputImage = [[CIImage alloc] initWithImage:self];
    
    CIFilter *filter = [self filterWithLookupImage:lookupImage];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIImage *outputImage = [filter outputImage];
    CGRect extent = [filter.outputImage extent];
    
    CGImageRef imageRef = [context createCGImage:outputImage fromRect:extent];
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return image;
}

- (UIImage *)filteredWithLookupImageNamed:(NSString *)lookupImageName
{
    if(lookupImageName == nil) {
        return nil;
    }
    UIImage *gradientImage = [UIImage imageNamed:lookupImageName];
    if(gradientImage == nil) {
        return nil;
    }
    return [self filteredWithLookupImage:gradientImage];
}

@end
