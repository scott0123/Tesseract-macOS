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

// returns a 3D NSArray of all possible choices as interpreted by
// Tesseract per symbol with corresponding confidence intervals (0-1)
//
// Example:
// Assume an image that contains the symbols/characters "A B C"
// Tesseract would recognize 3 symbols in this image and the following
// function will return an array that has the all classifier choices
// per symbol with corresponding confidence intervals
//
// Example return value:
// [[["A",.96],["O",.84],["D",.72]],
// [["B",.99],["D",.87]],
// [["O",.92], ["C",.91],["D",.82],["Q",.72],["@",.65]]]
//
// Notice on the third symbol ("C"), Tesseract recognizes it as "O"
// as it has the highest CI but the right answer is "C",
// which has the next highest CI.
- (NSArray*)getClassiferChoicesPerSymbol:(NSImage*)image;

@end
