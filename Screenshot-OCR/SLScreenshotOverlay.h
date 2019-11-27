//
//  SLScreenshotOverlay.h
//  OSToggle
//
//  Created by ScottLiu on 11/26/19.
//  Copyright © 2019 Scott Liu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLScreenshotOverlay : NSWindow

- (void)GetPoints:(void (^)(NSDictionary* points))completionBlock;

@end

NS_ASSUME_NONNULL_END
