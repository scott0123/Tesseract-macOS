//
//  SLScreenshot.m
//  OSToggle
//
//  Created by ScottLiu on 11/26/19.
//  Copyright © 2019 Scott Liu. All rights reserved.
//

#import "SLScreenshot.h"
#import "SLScreenshotOverlay.h"
#import <AppKit/AppKit.h> // needed for NSBitmapImageRep

@implementation SLScreenshot

+ (void)TakeScreenshot:(void (^)(NSImage* image))completionBlock{
    bool mainWindowNotNil = true;
    
    // set cursor to crosshair
    [[NSCursor crosshairCursor] push];
    
    // display graphics if main window isnt nil
    if([[NSApplication sharedApplication] windows][0] == nil){
        mainWindowNotNil = false;
    }
    // put the overlay on the main window
    if(mainWindowNotNil){
        SLScreenshotOverlay* overlay = [[SLScreenshotOverlay alloc] init];
        [overlay GetPoints:^(NSDictionary * _Nonnull points) {
            NSPoint upper_left = [points[@"upper_left"] pointValue];
            NSPoint lower_right = [points[@"lower_right"] pointValue];
            completionBlock([self ScreenshotTo300dpiNSImageFromUpperLeft:upper_left ToLowerRight:lower_right]);
        }];
    }
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
    
    updatedPointsSize.width = roundf((72.0f * pixelSize.width)/300.0f);
    updatedPointsSize.height = roundf((72.0f * pixelSize.height)/300.0f);
    
    [bitmap setSize:updatedPointsSize];
    
    // method to convert into NSImage
    NSImage *im = [[NSImage alloc] init];
    [im addRepresentation:bitmap];
    
    return im;
}

@end
