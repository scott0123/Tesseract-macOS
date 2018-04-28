//
//  ViewController.m
//  Screenshot-OCR
//
//  Created by ScottLiu on 4/26/18.
//  Copyright © 2018 Scott Liu. All rights reserved.
//

#import "SLViewController.h"
#import "SLScreenshot.h"
#import "SLTesseract.h"

@interface SLViewController ()

@property (strong) IBOutlet NSImageView *ssImageView;

@end

@implementation SLViewController

id currentInstance;
int screenHeight;

NSPoint ss_ul; // screenshot upperleft
NSPoint ss_lr; // screenshot lowerright

SLTesseract *ocr;

/*
 *  0: not screenshotting
 *  1: ss phase one, picking the upper left point
 *  2: ss phase two, picking the lower right point
 */
int ss_phase;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentInstance = self;
    screenHeight = [NSScreen mainScreen].frame.size.height;
    ss_ul = NSMakePoint(0, 0);
    ss_lr = NSMakePoint(0, 0);
    ss_phase = 0;
    
    CreateEventTap();
    // Do any additional setup after loading the view.
    
}

- (void)mouseMoved {
    // nothing
}
- (void)mouseDown {

    // switch on ss_phase
    switch (ss_phase) {
        case 1:
            ss_ul = [self getMouseCoordinates];
            ss_phase += 1;
            break;
            
        case 2:
            ss_lr = [self getMouseCoordinates];
            ss_phase = 0;
            //[Screenshotter takeScreenshotFromUpperLeft:ss_ul ToLowerRight:ss_lr];
            
            [self imageToText];
            break;
            
        default:
            break;
    }
}

- (void) imageToText {
    
    //NSColor *yellow = [NSColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:1.0f];
    //NSImage *ss = [SLScreenshot ScreenshotTo300dpiNSImageOnlyKeep:yellow FromUpperLeft:ss_ul ToLowerRight:ss_lr];
    NSImage *ss = [SLScreenshot ScreenshotTo300dpiNSImageFromUpperLeft:ss_ul ToLowerRight:ss_lr];
    [self.ssImageView setImage:ss];
    SLTesseract *ocr = [[SLTesseract alloc] init];
    ocr.language = @"eng";
    //ocr.charWhitelist = @"1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";
    //ocr.charWhitelist = @"1234567890";
    //ocr.charBlacklist = @"1234567890";
    NSString *text = [ocr recognize:ss];
    printf("Text detected: \n%s\n", [text UTF8String]);
    
}


- (IBAction)ButtonPressed:(NSButton *)sender {
    ss_phase = 1;
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
    
    // create the event tap for mouse moves
    CFMachPortRef mouseMovedEventTap = CGEventTapCreate(tap, place, options, eventsOfInterestMouseMoved, mouseMovedCallback, nil);
    // create the event tap for mouse downs
    CFMachPortRef mouseDownEventTap = CGEventTapCreate(tap, place, options, eventsOfInterestMouseDown, mouseDownCallback, nil);
    
    // ---------- YOU WILL HAVE A EXC_BAD_ACCESS FAULT HERE IF APP SANDBOX ISNT OFF ----------
    
    // create a run loop source ref for mouse moves
    CFRunLoopSourceRef mouseMovedRunLoopSourceRef = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, mouseMovedEventTap, 0);
    // create a run loop source ref for mouse downs
    CFRunLoopSourceRef mouseDownRunLoopSourceRef = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, mouseDownEventTap, 0);
    
    // add to the run loops
    CFRunLoopAddSource(CFRunLoopGetCurrent(), mouseMovedRunLoopSourceRef, kCFRunLoopCommonModes);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), mouseDownRunLoopSourceRef, kCFRunLoopCommonModes);
    
    // Enable the event tap
    CGEventTapEnable(mouseMovedEventTap, true);
    CGEventTapEnable(mouseDownEventTap, true);
}

CGEventRef mouseMovedCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon){
    
    [currentInstance mouseMoved];
    return event;
}

CGEventRef mouseDownCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon){
    
    int ss_busy = 0;
    if(ss_phase != 0) ss_busy = 1;
    
    [currentInstance mouseDown];
    
    if(ss_busy == 1) return nil;
    
    return event;
}



/* This function ensures that (0, 0) is the top left of the screen
 */
- (NSPoint)getMouseCoordinates {
    NSPoint mouseCoordInvertedY = [NSEvent mouseLocation];
    return NSMakePoint(mouseCoordInvertedY.x, screenHeight - mouseCoordInvertedY.y);
}




- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}
@end
