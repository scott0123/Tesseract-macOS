//
//  SLTesseract.h
//  testOCR
//
//  Created by Scott Liu on 4/27/18.
//  Copyright © 2018 Scott Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLTesseract : NSObject

// language can take values such as "eng", "ita", "eng+ita", or even nil (defaults to eng)
@property (nonatomic, copy) NSString* language;
@property (nonatomic, copy) NSString *charWhitelist;
@property (nonatomic, copy) NSString *charBlacklist;
// @property (nonatomic, assign) NSTimeInterval maximumRecognitionTime; // No longer supporting monitoring

#pragma mark Core Functions
// Core recognition function: returns the closest possible NSString
// match as interpreted by Tesseract for the given NSImage
- (NSString*)recognize:(NSImage*)image;



#pragma mark Optional Functions
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
// [[["A",0.96],["O",0.84],["D",0.72]],
// [["B",0.99],["D",0.87]],
// [["O",0.92], ["C",0.91],["D",0.82],["Q",0.72],["@",0.65]]]
//
// Notice on the third symbol ("C"), Tesseract recognizes it as "O"
// as it has the highest CI but the right answer is "C",
// which has the next highest CI.
- (NSArray*)getClassiferChoicesPerSymbol:(NSImage*)image;

@end
