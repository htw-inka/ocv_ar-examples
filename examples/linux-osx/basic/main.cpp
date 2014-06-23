/**
 * ocv_ar_basic - Basic ocv_ar example for Linux / Mac OSX
 *
 * Main program file.
 *
 * This program shows the basic usage of ocv_ar and how frames are
 * processed during marker detection. Use keys 1 to 6 to switch between
 * the display of the individual processing steps. Note that for key "1"
 * only the source camera frame is shown. This basic program does not make
 * use of the marker pose estimation and display (see OpenGL based examples
 * for this). Also note that the camera input frame will get downscaled to
 * half of its size and width.
 *
 * Use the ESC key to close the program.
 *
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, June 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * BSD licensed (see LICENSE file).
 */


#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <iostream>

// include ocv_ar library
#include "../../../ocv_ar/ocv_ar.h"

using namespace std;

#define WIN_NAME "ocv_ar basic example for linux and mac osx"

// set up the detector for 7x7 aruco style markers
ocv_ar::Detect detector(ocv_ar::IDENT_TYPE_CODE_7X7);

cv::VideoCapture cam;
cv::Mat camFrame;   // will contain the input frame
cv::Mat *outFrame;  // will point to an output frame

void switchProcOutput(int mode) {
    cout << "switching to processing frame output mode " << mode << endl;
    
    detector.setFrameOutputLevel((ocv_ar::FrameProcLevel)mode);
}

void shutdown() {
    outFrame = NULL;
    cam.release();
}

int main(int argc, char *argv[]) {
    // we do not estimate the correct marker position in 3D space
    // in this basic example. therefore we do not specify correct
    // camera intrinsics
    cv::Mat camMat = cv::Mat::eye(3, 3, CV_64F);
    cv::Mat camDist;
    detector.setCamIntrinsics(camMat, camDist);
    
    // try to open the camera
    if (!cam.open(0) || !cam.isOpened()) {
        cerr << "could not open camera device" << endl;
        
        shutdown();
        
        return 1;
    }
    
    // open a window
    cv::namedWindow(WIN_NAME, CV_WINDOW_AUTOSIZE);
    bool firstFrame = true;
    
    // loop until stopped
    while (true) {
        // read a frame from the camera
        if (!cam.read(camFrame)) {
            cerr << "could not read camera frame" << endl;
            
            break;
        }
        
        // for the first frame, prepare the ocv_ar detector
        if (firstFrame) {
            detector.prepare(camFrame.cols, camFrame.rows, camFrame.channels());
            detector.setFrameOutputLevel(ocv_ar::PROC_LEVEL_DETECTED_MARKERS);
            firstFrame = false;
        }
        
        // set the input frame, process the frame and get an output frame
        detector.setInputFrame(&camFrame);
        detector.processFrame();
        outFrame = detector.getOutputFrame();
        
        // the output frame can be empty when no output frame should be generated
        // in the detector. then use the input frame
        if (!outFrame) {
            outFrame = &camFrame;
        }
        
        // show the frame
        cv::imshow(WIN_NAME, *outFrame);
        
        // handle key input
        int key = cv::waitKey(1);
        if (key >= '1' && key <= '6') {
            switchProcOutput(key - 50);
        } else if (key == 27) {
            cout << "aborting..." << endl;
            
            break;
        }
    }
    
    shutdown();
    
    return 0;
}
