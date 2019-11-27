//
//  SLScreenshot.h
//  OSToggle
//
//  Created by ScottLiu on 11/26/19.
//  Copyright © 2019 Scott Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLScreenshot : NSObject

+ (void)TakeScreenshot:(void (^)(NSImage* image))completionBlock; // returns the screenshot in the completion block

@end

NS_ASSUME_NONNULL_END
