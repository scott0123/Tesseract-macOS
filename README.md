# Tesseract macOS
[![Build Status](https://travis-ci.org/scott0123/Tesseract-macOS.svg?branch=master)](https://travis-ci.org/scott0123/Tesseract-macOS)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/scott0123/Tesseract-macOS/blob/master/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/scott0123/Tesseract-macOS.svg?style=social&label=Stars)](https://github.com/scott0123/GravSim)


I have searched long and hard on the internet for a macOS based Objective-C wrapper for Tesseract to no avail.

Thus I have decided to create my own!

## Getting started

### Prerequisites
// TODO

## Example usage

At the top of the file include the header file

```
#import "SLTesseract.h"
```

And then

```
SLTesseract *ocr = [[SLTesseract alloc] init];
```

will initiallize the class SLTesseract. 

(optional) `ocr.language = @"eng";`

(optional) `ocr.charWhitelist = @"abcdefghijklmnopqrstuvwxyz"`

(optional) `ocr.charBlacklist = @"1234567890"`

Finally, assuming you already have the image that you wish to perform OCR on in NSImage form, you can call

```
NSString *text = [ocr recognize:image];
```

to recognize the image in question and get the corresponding text.

## Application

I have included a sample application if one wishes to test out the OCR capabilities.

First build the Xcode project included in this repository. This will generate an application through wish you can take a screenshot, as shown in the following gif.

![Screenshot example](./demo_images/demo.gif)

In the Xcode log you will find the corresponding text Tesseract detected for this screenshot.

![Output text](./demo_images/output_text.png)

## Libraries used

* [Tesseract](https://github.com/tesseract-ocr/tesseract) (v3.05.01)
* [Leptonica](http://leptonica.org/) (v1.75.3)
	* LibPNG (v1.6.34)
	* LibTIFF (v4.0.9)
	* LibJPEG (v9c)
	* LibZ (v1.2.11)

## License

My project *Tesseract macOS* itself is distributed under the MIT license (see LICENSE);

Keep in mind that the main dependency *Tesseract* is distributed under the Apache 2.0 license.

## Contact

You may reach me at `Tesseract-macOS@scott-liu.com` to inquire about this project.