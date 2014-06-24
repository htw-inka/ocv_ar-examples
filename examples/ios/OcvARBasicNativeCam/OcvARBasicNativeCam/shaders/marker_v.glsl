precision mediump float;

uniform mat4 uProjMat;
uniform mat4 uModelViewMat;
uniform mat4 uTransformMat; // for scaling

attribute vec4 aPos;

void main() {
    gl_Position = uProjMat * uModelViewMat * uTransformMat * aPos;
}