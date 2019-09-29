//
//  SLTesseract.mm
//  testOCR
//
//  Created by Scott Liu on 4/27/18.
//  Copyright © 2018 Scott Liu. All rights reserved.
//  Inspired by Loïs Di Qual (24/09/12)

#import <AppKit/AppKit.h>
#import "SLTesseract.h"
#include "include/tesseract/baseapi.h" // contains the base API
#include "include/tesseract/ocrclass.h" // defines the ETEXT_DESC class

#import "include/leptonica/environ.h" // defines the l_int types that pix needs
#import "include/leptonica/pix.h" // required for the pix class
#include "include/tesseract/publictypes.h" // required for engine mode enums
#import "include/leptonica/allheaders.h" // required for pix related functions


@interface SLTesseract ()

// representation of the base API
@property (nonatomic, assign, readonly) tesseract::TessBaseAPI *tesseract;
// @property (nonatomic, assign, readonly) ETEXT_DESC *monitor; // No longer supporting monitoring

// data path to the tessdata folder
@property (nonatomic, readonly, copy) NSString *absoluteDataPath;

@end

@implementation SLTesseract

- (instancetype)init {
    self = [super init];
    _tesseract = new tesseract::TessBaseAPI();
    // _monitor = new ETEXT_DESC(); // No longer supporting monitoring
    _absoluteDataPath = [[NSBundle mainBundle].bundlePath stringByAppendingString:@"/Contents/Resources/tessdata"];
    
    setenv("TESSDATA_PREFIX", _absoluteDataPath.fileSystemRepresentation, 1);
    
    return self;
}


- (NSString*)recognize:(NSImage*)image {
    
    // initiallize the tesseract
    _tesseract->Init(_absoluteDataPath.fileSystemRepresentation, self.language.UTF8String);
    
    /* No longer supporting monitoring
    // set the maximum recognition time
    if (self.maximumRecognitionTime > FLT_EPSILON) {
        _monitor->set_deadline_msecs((inT32)(self.maximumRecognitionTime * 1000));
    }
    */
    
    if(self.charWhitelist != nil){
        _tesseract->SetVariable("tessedit_char_whitelist", self.charWhitelist.UTF8String);
    }
    if(self.charBlacklist != nil){
        _tesseract->SetVariable("tessedit_char_blacklist", self.charBlacklist.UTF8String);
    }
    
    // set the image
    [self setEngineImage:image];
    
    // uncomment the following line to save image to desktop (mostly for debugging purposes)
    //[self saveThresholdedImage];
    
    int returnCode = 0;
    // call the recognize function
    // returnCode = _tesseract->Recognize(_monitor); // No longer supporting monitoring
    returnCode = _tesseract->Recognize(nullptr);
    
    if(returnCode != 0) printf("recognition function failed\n");
    
    // retrieve the recognized text
    char *utf8Text = _tesseract->GetUTF8Text();
    NSString *text;
    if(utf8Text != NULL){
        // convert the utf8 text to NSString, and then
        // trim off the newlines at the beginning and end
        text = [[NSString stringWithUTF8String:utf8Text]
                stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    } else {
        text = @"";
    }
    delete[] utf8Text;
    return text;
}

- (NSArray*)getClassiferChoicesPerSymbol:(NSImage*)image {
    // returns a 3D array of all possible choices as interpreted by
    // Tesseract per symbol/character with corresponding confidence
    // intervals (0-1)
    
    // initialize the tesseract
    _tesseract->Init(_absoluteDataPath.fileSystemRepresentation, self.language.UTF8String);
    
    if(self.charWhitelist != nil){
        _tesseract->SetVariable("tessedit_char_whitelist", self.charWhitelist.UTF8String);
    }
    if(self.charBlacklist != nil){
        _tesseract->SetVariable("tessedit_char_blacklist", self.charBlacklist.UTF8String);
    }
    
    // set the image
    [self setEngineImage:image];
    
    int returnCode = 0;
    // call the recognize function
    // returnCode = _tesseract->Recognize(_monitor); // No longer supporting monitoring
    returnCode = _tesseract->Recognize(nullptr);
    
    if(returnCode != 0) printf("recognition function failed\n");
    
    // Result iterator object to be iterated through
    tesseract::ResultIterator* ri = _tesseract->GetIterator();
    
    // Iterator `level`, will go through each recognized symbol
    tesseract::PageIteratorLevel level = tesseract::RIL_SYMBOL;
    
    // Holds array of array of symbols where each symbol has all
    // possible classifier choices with corresponding CI
    NSMutableArray *result = [NSMutableArray array];
    if(ri != 0) {
        do {
            // Holds current array for current symbol and its classifier choices
            NSMutableArray *symbol_result = [NSMutableArray array];
            const char* symbol = ri->GetUTF8Text(level);
            if(symbol != 0) {
                // Iterate through all classifer choices for symbol
                tesseract::ChoiceIterator ci(*ri);
                do {
                    // Array to hold current symbol + CI in iterator
                    NSMutableArray *character = [NSMutableArray array];
                    const char* choice = ci.GetUTF8Text();
                    [character addObject:@(choice)];
                    [character addObject:@(ci.Confidence()/100)];
                    [symbol_result addObject:character];
                } while(ci.Next());
            }
            [result addObject:symbol_result];
            delete[] symbol;
        } while((ri->Next(level)));
    }
    delete ri;
    NSArray *resultFinal = [result copy];
    return resultFinal;
}



- (void)setEngineImage:(NSImage *)image {
    
    if (image.size.width <= 0 || image.size.height <= 0) {
        NSLog(@"ERROR: Image has invalid size!");
        return;
    }
    
    Pix *pix = nullptr;
    
    pix = [self pixForImage:image];
    
    @try {
        _tesseract->SetImage(pix);
    }
    //LCOV_EXCL_START
    @catch (NSException *exception) {
        NSLog(@"ERROR: Can't set image: %@", exception);
    }
    //LCOV_EXCL_STOP
    pixDestroy(&pix);
    
}

/*
 * Debug feature: save the thresholded image to desktop
 */
- (void)saveThresholdedImage {
    Pix* thresh = _tesseract->GetThresholdedImage();
    NSString *fileName = @"~/Desktop/thresh.png";
    NSString *filePath = [[fileName stringByExpandingTildeInPath] stringByStandardizingPath];
    pixWrite(filePath.UTF8String, thresh, IFF_DEFAULT);
    pixDestroy(&thresh);
}

- (void)setLanguage:(NSString *)language {
    if ([language isEqualToString:_language] == NO || (!language && _language) ) {
        
        _language = language.copy;
    }
}

- (void)setCharWhitelist:(NSString *)charWhitelist {
    if ([_charWhitelist isEqualToString:charWhitelist] == NO) {
        _charWhitelist = charWhitelist.copy;
        
        _tesseract->SetVariable("tessedit_char_whitelist", charWhitelist.UTF8String);
    }
}

- (void)setCharBlacklist:(NSString *)charBlacklist {
    if ([_charBlacklist isEqualToString:charBlacklist] == NO) {
        _charBlacklist = charBlacklist.copy;
        
        _tesseract->SetVariable("tessedit_char_blacklist", charBlacklist.UTF8String);
    }
}



- (Pix *)pixForImage:(NSImage *)image
{
    CGImageRef cg  = [image CGImageForProposedRect:NULL context:NULL hints:NULL];
    unsigned long width  = CGImageGetWidth (cg),
    height = CGImageGetHeight (cg);
    
    l_uint32* pixels;
    pixels = (l_uint32 *) malloc(width * height * sizeof(l_uint32));
    memset(pixels, 0, width * height * sizeof(l_uint32));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context =
    CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                          kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cg);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    Pix* pix = pixCreate((l_uint32)width, (l_uint32)height, (l_uint32)CGImageGetBitsPerPixel(cg));
    pixFreeData(pix);
    pixSetData(pix, pixels);
    pixSetYRes(pix, (l_int32)300);
    
    return pix;
}

- (void)dealloc {
    /* No longer supporting monitoring
    if (_monitor != nullptr) {
        delete _monitor;
        _monitor = nullptr;
    }
    */
    [self freeTesseract];
}

- (void)freeTesseract {
    if (_tesseract != nullptr) {
        // There is no needs to call Clear() and End() explicitly.
        // End() is sufficient to free up all memory of TessBaseAPI.
        // End() is called in destructor of TessBaseAPI.
        delete _tesseract;
        _tesseract = nullptr;
    }
}

@end
