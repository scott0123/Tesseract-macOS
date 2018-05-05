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

SLTesseract *ocr;
SLScreenshot *shooter;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    shooter = [[SLScreenshot alloc] init];
    ocr = [[SLTesseract alloc] init];
    // Do any additional setup after loading the view.
    
}


- (IBAction)ButtonPressed:(NSButton *)sender {
    
    [shooter TakeScreenshot:^(NSImage* ss){
        [self.ssImageView setImage:ss];
        [self imageToText];
    }];
}


- (void) imageToText {
    
    ocr.language = @"eng";
    ocr.language = @"osrs";
    //ocr.charWhitelist = @"1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";
    //ocr.charWhitelist = @"1234567890";
    //ocr.charBlacklist = @"1234567890";
    NSString *text = [ocr recognize:self.ssImageView.image];
    printf("Text detected: \n%s\n", [text UTF8String]);
    
}





- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}
@end
