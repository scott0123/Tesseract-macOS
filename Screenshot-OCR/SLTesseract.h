//
//  SLTesseract.h
//  testOCR
//
//  Created by ScottLiu on 4/27/18.
//  Copyright © 2018 Scott Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLTesseract : NSObject

// language can take values such as "eng", "ita", "eng+ita", or even nil (defaults to eng)
@property (nonatomic, copy) NSString* language;
@property (nonatomic, copy) NSString *charWhitelist;
@property (nonatomic, copy) NSString *charBlacklist;
// @property (nonatomic, assign) NSTimeInterval maximumRecognitionTime; // No longer supporting monitoring


- (NSString*)recognize:(NSImage*)image;
- (NSMutableArray*)getIterator:(NSImage*)image;

@end
