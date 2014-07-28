# Basic ocv_ar example for iOS that uses the native iOS camera API

* shows how to set up ocv_ar for iOS
* shows how to use the native iOS camera API in conjunction with ocv_ar, which is faster than using `CvVideoCamera`
* has a simple GUI to switch between the stages of the marker detection process
* uses OpenGL to display simple colored squares above found markers
* makes use of the `ocv_ar::Track` class for marker tracking and smooth marker motion via pose interpolation
* was tested with an iPad 3 on iOS 7

## Project setup notices

### General
* make sure that *opencv2.framework* from [OpenCV for iOS](http://sourceforge.net/projects/opencvlibrary/files/opencv-ios/2.4.9/opencv2.framework.zip/download) resides at `../../../opencv-ios`
* device orientation is restricted to *landscape right* but you might change it
* iOS 6.0 is set as deployment target
* see the list of linked frameworks and libraries in the project setup

### Build Settings
* *"Compile sources As"* is set to *"Objective-C++"*
* *"Automatic Reference Counting"* is set to *"NO"*

## Configuration options
* check out `RootViewController.h`, it has the following configuration options:
 * `MARKER_REAL_SIZE_M` - set the size of your printed markers in meters
 * `CAM_INTRINSICS_FILE` - select the camera intrinsics file you belonging to your device. you may need to run your own calibration, for example with the tool [cam-intrinsics-db](https://github.com/htw-inka/cam-intrinsics-db)
 * `PROJ_FLIP_MODE` - flip the OpenGL projection (marker display). this might be necessary if you select another default device orientation 

## TODO

* test and adjust for iPad 4
