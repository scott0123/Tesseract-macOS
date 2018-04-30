//
//  SLScreenshot.h
//  Screenshot-OCR
//
//  Created by ScottLiu on 4/26/18.
//  Copyright © 2018 Scott Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLScreenshot : NSObject

// easy to use
- (void)TakeScreenshot:(void (^)(NSImage* image))completionBlock;


// more difficult to use
- (void)takeScreenshotFromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr;
- (NSImage *)ScreenshotToNSImageFromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr;
- (NSImage *)ScreenshotTo300dpiNSImageFromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr;
- (NSImage *)ScreenshotTo300dpiNSImageSetBlackTo:(NSColor*)color FromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr;
- (NSImage *)ScreenshotTo300dpiNSImageOnlyKeep:(NSColor*)color FromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr;

@end
