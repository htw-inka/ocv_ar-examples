# Basic ocv_ar example for Linux and Mac OSX

* shows how to set up ocv_ar to compile for Linux Mac OSX
* shows the frame output of the individual steps of the marker detection
* uses `CvVideoCamera` to grab the camera's frames
* no marker pose estimation in 3D is provided (see OpenGL based examples for this)

## Usage

* use keys 1 to 6 to switch between the display of the individual processing steps (note that for key *1* only the source camera frame is shown)
* use the ESC key to close the program

## Compile

This project comes with a *Makefile*. Have a look in this file and make sure that `HEADER_SEARCH_PATH` and `LIB_SEARCH_PATH` point to the correct paths of your OpenCV installation. The Makefile also references the *ocv_ar* sources contained as submodule in this git repository.

When all paths are set correctly, you can compile the program via `make`.