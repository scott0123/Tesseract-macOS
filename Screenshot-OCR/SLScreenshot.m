//
//  SLScreenshot.m
//  Screenshot-OCR
//
//  Created by ScottLiu on 4/26/18.
//  Copyright © 2018 Scott Liu. All rights reserved.
//

#import <AppKit/AppKit.h> // needed for NSBitmapImageRep
#import "SLScreenshot.h"

@implementation SLScreenshot

+ (void)takeScreenshotFromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr {
    // create a CGRect of custom size from bottom-left to top-right
    CGRect imageRect = CGRectMake(ul.x, ul.y, lr.x - ul.x, lr.y - ul.y);
    
    CGImageRef imageRef = CGWindowListCreateImage(imageRect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
    
    CGImageRelease(imageRef);
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    
    NSData *data = [bitmap representationUsingType:NSPNGFileType properties:imageProps];
    
    // method to turn into nsimage
    //NSImage *im = [[NSImage alloc] init];
    //[im addRepresentation:bitmap];
    
    // Method one of getting user desktop path
    NSString *fileName = @"~/Desktop/ss.png";
    NSString *filePath = [[fileName stringByExpandingTildeInPath] stringByStandardizingPath];
    
    /*
     // Method two of getting user desktop path
     NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES );
     NSString* desktopPath = [paths objectAtIndex:0];
     NSString *fileName = @"ss.png";
     NSString *filePath = [NSString stringWithFormat:@"%@/%@", desktopPath, fileName];
     */
    NSLog(@"%@", [NSString stringWithFormat:@"saved to path: %@", filePath]);
    [data writeToFile:filePath atomically: YES];
    
}

+ (NSImage *)ScreenshotToNSImageFromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr {
    // create a CGRect of custom size from bottom-left to top-right
    CGRect imageRect = CGRectMake(ul.x, ul.y, lr.x - ul.x, lr.y - ul.y);
    
    CGImageRef imageRef = CGWindowListCreateImage(imageRect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
    CGImageRelease(imageRef);
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    // method to turn into nsimage
    NSImage *im = [[NSImage alloc] init];
    [im addRepresentation:bitmap];
    return im;
}

+ (NSImage *)ScreenshotTo300dpiNSImageFromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr {
    // create a CGRect of custom size from bottom-left to top-right
    CGRect imageRect = CGRectMake(ul.x, ul.y, lr.x - ul.x, lr.y - ul.y);
    
    CGImageRef imageRef = CGWindowListCreateImage(imageRect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    NSSize pointsSize = bitmap.size;
    NSSize pixelSize = NSMakeSize(bitmap.pixelsWide, bitmap.pixelsHigh);
    
    NSSize updatedPointsSize = pointsSize;
    
    updatedPointsSize.width = roundf((72.0f * pixelSize.width)/300.0);
    updatedPointsSize.height = roundf((72.0f * pixelSize.height)/300.0f);
    
    [bitmap setSize:updatedPointsSize];
    
    // method to turn into nsimage
    NSImage *im = [[NSImage alloc] init];
    [im addRepresentation:bitmap];
    
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    NSData *data = [bitmap representationUsingType:NSPNGFileType properties:imageProps];
    NSString *fileName = @"~/Desktop/300dpi.png";
    NSString *filePath = [[fileName stringByExpandingTildeInPath] stringByStandardizingPath];
    [data writeToFile:filePath atomically: YES];
    return im;
}

+ (NSImage *)ScreenshotTo300dpiNSImageSetBlackTo:(NSColor*)color FromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr {
    // create a CGRect of custom size from bottom-left to top-right
    CGRect imageRect = CGRectMake(ul.x, ul.y, lr.x - ul.x, lr.y - ul.y);
    
    CGImageRef imageRef = CGWindowListCreateImage(imageRect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    
    int a_swap = color.alphaComponent * 255;
    int r_swap = color.redComponent * 255;
    int g_swap = color.greenComponent * 255;
    int b_swap = color.blueComponent * 255;
    
    // loop through all pixels within this bitmap and find matches
    for(int i = 0; i < bitmap.pixelsHigh; i++){
        for(int j = 0; j < bitmap.pixelsWide; j++){
            NSColor *c = [bitmap colorAtX:j y:i];
            float r = c.redComponent;
            float g = c.greenComponent;
            float b = c.blueComponent;
            if(r+g+b < 0.01f){
                // order: alpha, r ,g ,b
                NSUInteger pix[4]; pix[0] = a_swap; pix[1] = r_swap; pix[2] = g_swap; pix[3] = b_swap;
                [bitmap setPixel:pix atX:j y:i];
            }
        }
    }
    CGImageRelease(imageRef);
    
    NSSize pointsSize = bitmap.size;
    NSSize pixelSize = NSMakeSize(bitmap.pixelsWide, bitmap.pixelsHigh);
    
    NSSize updatedPointsSize = pointsSize;
    
    updatedPointsSize.width = roundf((72.0f * pixelSize.width)/300.0);
    updatedPointsSize.height = roundf((72.0f * pixelSize.height)/300.0f);
    
    [bitmap setSize:updatedPointsSize];
    
    // method to turn into nsimage
    NSImage *im = [[NSImage alloc] init];
    [im addRepresentation:bitmap];
    
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    NSData *data = [bitmap representationUsingType:NSPNGFileType properties:imageProps];
    NSString *fileName = @"~/Desktop/300dpi.png";
    NSString *filePath = [[fileName stringByExpandingTildeInPath] stringByStandardizingPath];
    [data writeToFile:filePath atomically: YES];
    return im;
}

+ (NSImage *)ScreenshotTo300dpiNSImageOnlyKeep:(NSColor*)color FromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr {
    
    float threshold = 0.01; // = 2.55
    
    // create a CGRect of custom size from bottom-left to top-right
    CGRect imageRect = CGRectMake(ul.x, ul.y, lr.x - ul.x, lr.y - ul.y);
    
    CGImageRef imageRef = CGWindowListCreateImage(imageRect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    
    // loop through all pixels within this bitmap and find matches
    for(int i = 0; i < bitmap.pixelsHigh; i++){
        for(int j = 0; j < bitmap.pixelsWide; j++){
            NSColor* colorToCompare = [bitmap colorAtX:j y:i];
            bool match = true;
            if(fabs(colorToCompare.redComponent - color.redComponent) > threshold){
                match = false;
            } else if(fabs(colorToCompare.greenComponent - color.greenComponent) > threshold){
                match = false;
            } else if(fabs(colorToCompare.blueComponent - color.blueComponent) > threshold){
                match = false;
            }
            if(match){
                // order: alpha, r ,g ,b
                NSUInteger pix[4]; pix[0] = 255; pix[1] = 0; pix[2] = 0; pix[3] = 0; // black
                [bitmap setPixel:pix atX:j y:i];
            } else {
                // order: alpha, r ,g ,b
                NSUInteger pix[4]; pix[0] = 255; pix[1] = 255; pix[2] = 255; pix[3] = 255; // white
                [bitmap setPixel:pix atX:j y:i];
            }
        }
    }
    CGImageRelease(imageRef);
    
    NSSize pointsSize = bitmap.size;
    NSSize pixelSize = NSMakeSize(bitmap.pixelsWide, bitmap.pixelsHigh);
    
    NSSize updatedPointsSize = pointsSize;
    
    updatedPointsSize.width = roundf((72.0f * pixelSize.width)/300.0);
    updatedPointsSize.height = roundf((72.0f * pixelSize.height)/300.0f);
    
    [bitmap setSize:updatedPointsSize];
    
    // method to turn into nsimage
    NSImage *im = [[NSImage alloc] init];
    [im addRepresentation:bitmap];
    
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    NSData *data = [bitmap representationUsingType:NSPNGFileType properties:imageProps];
    NSString *fileName = @"~/Desktop/300dpi.png";
    NSString *filePath = [[fileName stringByExpandingTildeInPath] stringByStandardizingPath];
    [data writeToFile:filePath atomically: YES];
    return im;
}

@end
