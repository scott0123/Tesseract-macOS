//
//  AppDelegate.m
//  Screenshot-OCR
//
//  Created by ScottLiu on 4/26/18.
//  Copyright © 2018 Scott Liu. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // prevent app nap
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(beginActivityWithOptions:reason:)]) {
        self.activity = [[NSProcessInfo processInfo] beginActivityWithOptions:0x00FFFFFF reason:@"screenshot"];
    }
    
    if(![self acquirePrivileges]){
        printf("Privilege not granted.\n");
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


/*
 *  Used to Acquire accessibility privileges because SLScreenshot needs to take mouse control
 */
- (BOOL)acquirePrivileges {
    
    if (&AXIsProcessTrustedWithOptions != NULL) {
        // 10.9 and later
        const void * keys[] = { kAXTrustedCheckOptionPrompt };
        const void * values[] = { kCFBooleanTrue };
        
        CFDictionaryRef options = CFDictionaryCreate(
                                                     kCFAllocatorDefault,
                                                     keys,
                                                     values,
                                                     sizeof(keys) / sizeof(*keys),
                                                     &kCFCopyStringDictionaryKeyCallBacks,
                                                     &kCFTypeDictionaryValueCallBacks);
        
        return AXIsProcessTrustedWithOptions(options);
    }
}

@end
