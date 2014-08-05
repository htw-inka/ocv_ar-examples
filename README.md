# Example projects for ocv_ar - OpenCV based Augmented Reality library

*Markus Konrad <konrad@htw-berlin.de>, June 2014*

*INKA Research Group / Project MINERVA, HTW Berlin - http://inka.htw-berlin.de/inka/projekte/minerva/*

This repository contains some examples on how to use the OpenCV based Augmented Reality library *[ocv_ar](https://github.com/htw-inka/ocv_ar)*. For now, only iOS based exampels exist, but different platforms will be available in the future.

Please note, that this is still a work in progress.

## How to clone this repository

Please note that *ocv_ar* is included as a submodule in this repository. Therefore, the following command needs to be used to clone the repo:

```
git clone --recursive git@github.com:htw-inka/ocv_ar-examples.git
```

## Available projects in folder *examples/*

All projects come with a separate README file for instructions on how to compile and configure the project.

* *ios/OcvARBasic* - basic iOS based ocv_ar showcase that uses OpenGL for display and *CvVideoCamera* for grabbing the video frames from the camera
* *ios/OcvARBasicNativeCam* - iOS based ocv_ar showcase that uses OpenGL for display and native iOS camera APIs for grabbing the video frames. It makes use of the `ocv_ar::Track` class for marker tracking and smooth marker motion. **This is the most full-featured version and shows the current state best.**
* *ios/OcvARBCocos2D* - iOS based ocv_ar showcase that uses [Cocos2D](http://www.cocos2d-swift.org/) for display and native iOS camera APIs for grabbing the video frames. It makes use of the `ocv_ar::Track` class for marker tracking and smooth marker motion. The integration into Cocos2D makes it possible to easily display sprites and effects
* *linux-osx/basic* - basic ocv_ar example that compiles under Linux and Mac OSX
