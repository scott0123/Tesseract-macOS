//
//  SLScreenshotOverlay.m
//  OSToggle
//
//  Created by ScottLiu on 11/26/19.
//  Copyright © 2019 Scott Liu. All rights reserved.
//

#import "SLScreenshotOverlay.h"
#import <QuartzCore/QuartzCore.h> // needed for CAShapeLayer

@interface SLScreenshotOverlay ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation SLScreenshotOverlay

int screen_height;
int screen_width;
NSPoint upper_left; // screenshot upper left
NSPoint lower_right; // screenshot lower right
void (^localCompletionBlock)(NSDictionary* points);

- (instancetype)init
{
    upper_left = NSMakePoint(0, 0);
    lower_right = NSMakePoint(0, 0);
    screen_height = [NSScreen mainScreen].frame.size.height;
    screen_width = [NSScreen mainScreen].frame.size.width;
    NSRect full_screen = NSMakeRect(0, 0, screen_width, screen_height);
    self = [self initWithContentRect:full_screen
                           styleMask:NSWindowStyleMaskBorderless
                             backing:NSBackingStoreBuffered
                               defer:NO];
    [self setBackgroundColor:[NSColor clearColor]];
    [self setIgnoresMouseEvents:NO];
    [[[NSApplication sharedApplication] windows][0] addChildWindow:self ordered:NSWindowAbove];
    return self;
}

- (void)GetPoints:(void (^)(NSDictionary* points))completionBlock{
    localCompletionBlock = completionBlock;
}

- (void)mouseDown:(NSEvent *)event {
    [self disableCursorRects];
    upper_left = [self getMouseCoordinates];
    lower_right = [self getMouseCoordinates];
    
    // Courtesy of https://stackoverflow.com/a/20359552
    // create and configure shape layer
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.lineWidth = 1.0;
    self.shapeLayer.strokeColor = [[NSColor blackColor] CGColor];
    self.shapeLayer.fillColor = [[NSColor clearColor] CGColor];
    self.shapeLayer.lineDashPattern = @[@10, @5];
    [self.contentView setWantsLayer:YES];
    [self.contentView.layer addSublayer:self.shapeLayer];
    
    // create animation for the layer
    CABasicAnimation *dashAnimation;
    dashAnimation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
    [dashAnimation setFromValue:@0.0f];
    [dashAnimation setToValue:@15.0f];
    [dashAnimation setDuration:0.75f];
    [dashAnimation setRepeatCount:HUGE_VALF];
    [self.shapeLayer addAnimation:dashAnimation forKey:@"linePhase"];
}

- (void)mouseDragged:(NSEvent *)event {
    lower_right = [self getMouseCoordinates];
    
    // create path for the shape layer
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, upper_left.x, screen_height - upper_left.y);
    CGPathAddLineToPoint(path, NULL, upper_left.x, screen_height - lower_right.y);
    CGPathAddLineToPoint(path, NULL, lower_right.x, screen_height - lower_right.y);
    CGPathAddLineToPoint(path, NULL, lower_right.x, screen_height - upper_left.y);
    CGPathCloseSubpath(path);
    
    // set the shape layer's path
    self.shapeLayer.path = path;
    
    CGPathRelease(path);
}

- (void)mouseUp:(NSEvent *)event {
    [self enableCursorRects];
    [self resetCursorRects];
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer = nil;
    [self orderOut:self];
    if(localCompletionBlock != nil){
        // we have to wait a tiny tiny bit because the shape-layer and window both take some time to exit
        [self performSelector:@selector(completeCompletionBlock) withObject:nil afterDelay:0.01f];
    }
}

- (void)completeCompletionBlock{
    NSMutableDictionary *points = [[NSMutableDictionary alloc] init];
    points[@"upper_left"] = [NSValue valueWithPoint:upper_left];
    points[@"lower_right"] = [NSValue valueWithPoint:lower_right];
    localCompletionBlock([NSDictionary dictionaryWithDictionary:points]);
    localCompletionBlock = nil;
}

- (NSPoint)getMouseCoordinates {
    NSPoint mouseCoordInvertedY = [NSEvent mouseLocation];
    return NSMakePoint(mouseCoordInvertedY.x, screen_height - mouseCoordInvertedY.y);
}

@end
