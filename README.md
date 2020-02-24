# Tesseract macOS
[![Build Status](https://travis-ci.org/scott0123/Tesseract-macOS.svg?branch=master)](https://travis-ci.org/scott0123/Tesseract-macOS)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/scott0123/Tesseract-macOS/blob/master/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/scott0123/Tesseract-macOS.svg?style=social&label=Stars)](https://github.com/scott0123/Tesseract-macOS)


This is an open-source macOS-based Objective-C wrapper for the OCR library *Tesseract*.

You can also use this in Swift, instructions below.

Fork this repo if you want to experiment with it.

## Overview

The wrapper consists of just the following files

* `SLTesseract.h` (Header file)
* `SLTesseract.mm` (Implementation file)
* `tessdata/` (Language files for Tesseract)
* `lib/` (Compiled dependencies)
* `include/` (Headers for the dependencies)

## Demo Application

For those of you who wish to first test out the OCR capabilities, the included `Screenshot-OCR` is a demo application to showcase this.

First build the Xcode project included in this repository. This will generate an application through wish you can take a screenshot, as shown in the following gif.

![Screenshot example](./demo_images/demo.gif)

In the Xcode log you will find the corresponding text Tesseract detected for this screenshot.

![Output text](./demo_images/output_text.png)

## Getting Started

### Getting this to work in your own project

1. Clone this project
2. Copy over the `include`, `lib`, and `tessdata` folders to your project.
3. Add these folders to your project in Xcode. Make sure `include` and `lib` are added as *groups* and `tessdata` is added as a *folder reference*. 

	The location of this setting is shown in the following image:

	![add settings](./demo_images/add_settings.png)

4. Copy over the files `SLTesseract.mm` and `SLTesseract.h` to your code directory.
5. Verify that the file `SLTesseract.mm` is added to `Targets > Build Phases > Compile Sources`. Additionally, verify that all the static libraries are also added to `Targets > Build Phases > Link Binary With Libraries`. (This process should be done automatically)
6. You are now ready to use Tesseract in your macOS project. (See Example Usage for code syntax)


## Example Usage

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

#### Usage in Swift

This library can be easily imported in a Swift project.

Just replicate all the steps above. 

When adding .h and .mm files you will be prompted by Xcode to add a *Bridging Header* (if don't have one already).

Xcode will generate a file named `yourProject-Bridging-Header.h`

Add this line to the *Bridging Header*:

``` 
#import "SLTesseract.h" 
```

Initialize like this:

```
let ocr = SLTesseract()
```
(optional) `ocr.language = "eng"`

(optional) `ocr.charWhitelist = "abcdefghijklmnopqrstuvwxyz"`

(optional) `ocr.charBlacklist = "1234567890"`

Finally perform OCR by doing this:

```
let text = ocr.recognize(image)
```

## Dependencies

The libraries below are all included in the `lib/` directory.

* [Tesseract](https://github.com/tesseract-ocr/tesseract) (v4.1.0)
* [Leptonica](http://leptonica.org/) (v1.75.3)
	* LibPNG (v1.6.34)
	* LibTIFF (v4.0.9)
	* LibJPEG (v9c)
	* LibZ (v1.2.11)

## License

My project *Tesseract macOS* itself is distributed under the MIT license (see LICENSE);

Keep in mind that the main dependency *Tesseract* is distributed under the Apache 2.0 license.

## Contact

Open an issue if you want something fixed.

You may reach me at `Tesseract-macOS@scott-liu.com` to inquire about this project.

## Used by

* [Handwriting-Input-Recognition](https://github.com/chargeflux/Handwriting-Input-Recognition) by [chargeflux](https://github.com/chargeflux)

