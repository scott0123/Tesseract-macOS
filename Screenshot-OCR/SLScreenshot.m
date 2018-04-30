//
//  SLScreenshot.m
//  Screenshot-OCR
//
//  Created by ScottLiu on 4/26/18.
//  Copyright © 2018 Scott Liu. All rights reserved.
//

#import <AppKit/AppKit.h> // needed for NSBitmapImageRep
#import <QuartzCore/QuartzCore.h> // needed for CAShapeLayer
#import "SLScreenshot.h"

@interface SLScreenshot ()

@property (nonatomic, strong) NSWindow *invisibleWindow;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation SLScreenshot

id current_instance;
int screen_height;
int screen_width;
/*
 *  0: not screenshotting
 *  1: ss phase one, picking the upper left point
 *  2: ss phase two, picking the lower right point
 */
int ss_phase;

NSPoint ss_ul; // screenshot upperleft
NSPoint ss_lr; // screenshot lowerright
void (^localCompletionBlock)(NSImage* image);

- (instancetype)init{
    self = [super init];
    
    current_instance = self;
    screen_height = [NSScreen mainScreen].frame.size.height;
    screen_width = [NSScreen mainScreen].frame.size.width;
    ss_phase = 0;
    ss_ul = NSMakePoint(0, 0);
    ss_lr = NSMakePoint(0, 0);
    localCompletionBlock = nil;
    
    CreateEventTap();
    
    return self;
}


- (void)TakeScreenshot:(void (^)(NSImage* image))completionBlock{
    
    ss_phase = 1;
    localCompletionBlock = completionBlock;
}

- (void)saveScreenshotFromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr {
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

- (NSImage *)ScreenshotToNSImageFromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr {
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

- (NSImage *)ScreenshotTo300dpiNSImageFromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr {
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

- (NSImage *)ScreenshotTo300dpiNSImageSetBlackTo:(NSColor*)color FromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr {
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

- (NSImage *)ScreenshotTo300dpiNSImageOnlyKeep:(NSColor*)color FromUpperLeft:(NSPoint)ul ToLowerRight:(NSPoint)lr {
    
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

- (void)mouseDown {
    
    // based on ss_phase
    if (ss_phase == 1) {
        ss_ul = [self getMouseCoordinates];
        ss_lr = [self getMouseCoordinates];
        ss_phase += 1;
        
        bool windowNotNil = true;
        
        // display graphics if main window isnt nil
        if([[NSApplication sharedApplication] windows][0] == nil){
            windowNotNil = false;
        }
        // display the search region in blue
        if(windowNotNil){
            NSRect searchRect = NSMakeRect(ss_ul.x, screen_height - ss_lr.y, ss_lr.x-ss_ul.x, ss_lr.y-ss_ul.y);
            searchRect = NSMakeRect(0, 0, screen_width, screen_height);
            self.invisibleWindow = [[NSWindow alloc]initWithContentRect:searchRect
                                                      styleMask:NSWindowStyleMaskBorderless
                                                        backing:NSBackingStoreBuffered
                                                          defer:NO];
            NSColor* transBlue = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.0];
            self.invisibleWindow.backgroundColor = transBlue;
            [self.invisibleWindow setOpaque:NO];
            [self.invisibleWindow setIgnoresMouseEvents:YES];
            [[[NSApplication sharedApplication] windows][0] addChildWindow:self.invisibleWindow ordered:NSWindowAbove];
            
            // Courtesy of https://stackoverflow.com/a/20359552
            // create and configure shape layer
            self.shapeLayer = [CAShapeLayer layer];
            self.shapeLayer.lineWidth = 1.0;
            self.shapeLayer.strokeColor = [[NSColor blackColor] CGColor];
            self.shapeLayer.fillColor = [[NSColor clearColor] CGColor];
            self.shapeLayer.lineDashPattern = @[@10, @5];
            [self.invisibleWindow.contentView setWantsLayer:YES];
            [self.invisibleWindow.contentView.layer addSublayer:self.shapeLayer];
            
            // create animation for the layer
            CABasicAnimation *dashAnimation;
            dashAnimation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
            [dashAnimation setFromValue:@0.0f];
            [dashAnimation setToValue:@15.0f];
            [dashAnimation setDuration:0.75f];
            [dashAnimation setRepeatCount:HUGE_VALF];
            [self.shapeLayer addAnimation:dashAnimation forKey:@"linePhase"];
        }
    }
}
- (void)mouseMoved {
    // based on ss_phase
    if (ss_phase == 2) {
        ss_lr = [self getMouseCoordinates];
        
        bool windowNotNil = true;
        
        // display graphics if main window isnt nil
        if([[NSApplication sharedApplication] windows][0] == nil){
            windowNotNil = false;
        }
        // display the search region in blue
        if(windowNotNil){
            //NSRect searchRect = NSMakeRect(ss_ul.x, screen_height - ss_lr.y, ss_lr.x-ss_ul.x, ss_lr.y-ss_ul.y);
            //[self.invisibleWindow setFrame:searchRect display:NO];
            //printf("(%f, %f)\n", searchRect.origin.x, searchRect.origin.y + searchRect.size.height);
            //[self.invisibleWindow setContentSize:NSMakeSize(ss_lr.x-ss_ul.x,-ss_lr.y+ss_ul.y)];
            
            // create path for the shape layer
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, ss_ul.x, screen_height - ss_ul.y);
            CGPathAddLineToPoint(path, NULL, ss_ul.x, screen_height - ss_lr.y);
            CGPathAddLineToPoint(path, NULL, ss_lr.x, screen_height - ss_lr.y);
            CGPathAddLineToPoint(path, NULL, ss_lr.x, screen_height - ss_ul.y);
            CGPathCloseSubpath(path);
            
            // set the shape layer's path
            self.shapeLayer.path = path;
            
            CGPathRelease(path);
        }
    }
}
- (void)mouseUp {
    
    // based on ss_phase
    if (ss_phase == 2) {
        ss_lr = [self getMouseCoordinates];
        ss_phase = 0;
        
        bool windowNotNil = true;
        
        // display graphics if main window isnt nil
        if([[NSApplication sharedApplication] windows][0] == nil){
            windowNotNil = false;
        }
         if(windowNotNil){
             [self.shapeLayer removeFromSuperlayer];
             self.shapeLayer = nil;
             [self.invisibleWindow orderOut:self];
         }
        
        if(localCompletionBlock != nil){
            // we have to wait a tiny tiny bit because the shape-layer and window both take some time to exit
            [self performSelector:@selector(completeCompletionBlock) withObject:nil afterDelay:0.01f];
        }
    }
}

- (void)completeCompletionBlock{
    
    //NSColor *yellow = [NSColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:1.0f];
    //NSColor *cyan = [NSColor colorWithRed:0.0f green:1.0f blue:1.0f alpha:1.0f];
    //NSColor *blue = [NSColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f];
    //NSImage *ss = [self ScreenshotTo300dpiNSImageOnlyKeep:yellow FromUpperLeft:ss_ul ToLowerRight:ss_lr];
    localCompletionBlock([self ScreenshotTo300dpiNSImageFromUpperLeft:ss_ul ToLowerRight:ss_lr]);
    localCompletionBlock = nil;
}

// ------------------------------ event taps ------------------------------
void CreateEventTap() {
    
    // kCGHIDEventTap = system-wide tap
    // kCGSessionEventTap = session-wide tap
    // kCGAnnotatedSessionEventTap = application-wide tap
    CGEventTapLocation tap = kCGHIDEventTap;
    // place the tap at the very beginning
    CGEventTapPlacement place = kCGHeadInsertEventTap;
    // this will not be a listen-only tap
    CGEventTapOptions options = kCGEventTapOptionDefault;
    // OR the masks together
    CGEventMask eventsOfInterestMouseMoved = CGEventMaskBit(kCGEventMouseMoved)
    | CGEventMaskBit(kCGEventLeftMouseDragged);
    CGEventMask eventsOfInterestMouseDown = CGEventMaskBit(kCGEventLeftMouseDown);
    CGEventMask eventsOfInterestMouseUp = CGEventMaskBit(kCGEventLeftMouseUp);
    
    // create the event tap for mouse moves
    CFMachPortRef mouseMovedEventTap = CGEventTapCreate(tap, place, options, eventsOfInterestMouseMoved, mouseMovedCallback, nil);
    // create the event tap for mouse downs
    CFMachPortRef mouseDownEventTap = CGEventTapCreate(tap, place, options, eventsOfInterestMouseDown, mouseDownCallback, nil);
    // create the event tap for mouse ups
    CFMachPortRef mouseUpEventTap = CGEventTapCreate(tap, place, options, eventsOfInterestMouseUp, mouseUpCallback, nil);
    
    // ---------- YOU WILL HAVE A EXC_BAD_ACCESS FAULT HERE IF APP SANDBOX ISNT OFF ----------
    
    // create a run loop source ref for mouse moves
    CFRunLoopSourceRef mouseMovedRunLoopSourceRef = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, mouseMovedEventTap, 0);
    // create a run loop source ref for mouse downs
    CFRunLoopSourceRef mouseDownRunLoopSourceRef = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, mouseDownEventTap, 0);
    // create a run loop source ref for mouse downs
    CFRunLoopSourceRef mouseUpRunLoopSourceRef = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, mouseUpEventTap, 0);
    
    // add to the run loops
    CFRunLoopAddSource(CFRunLoopGetCurrent(), mouseMovedRunLoopSourceRef, kCFRunLoopCommonModes);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), mouseDownRunLoopSourceRef, kCFRunLoopCommonModes);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), mouseUpRunLoopSourceRef, kCFRunLoopCommonModes);
    
    // Enable the event tap
    CGEventTapEnable(mouseMovedEventTap, true);
    CGEventTapEnable(mouseDownEventTap, true);
    CGEventTapEnable(mouseUpEventTap, true);
}

CGEventRef mouseMovedCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon){
    
    [current_instance mouseMoved];
    return event;
}

CGEventRef mouseDownCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon){
    
    int ss_busy = 0;
    if(ss_phase != 0) ss_busy = 1;
    
    [current_instance mouseDown];
    
    if(ss_busy == 1) return nil;
    
    return event;
}

CGEventRef mouseUpCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon){
    
    int ss_busy = 0;
    if(ss_phase != 0) ss_busy = 1;
    
    [current_instance mouseUp];
    
    if(ss_busy == 1) return nil;
    
    return event;
}


/* This function ensures that (0, 0) is the top left of the screen
 */
- (NSPoint)getMouseCoordinates {
    NSPoint mouseCoordInvertedY = [NSEvent mouseLocation];
    return NSMakePoint(mouseCoordInvertedY.x, screen_height - mouseCoordInvertedY.y);
}

@end
