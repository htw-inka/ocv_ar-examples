/**
 * simple opengl shader helper class - implementation file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, June 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * BSD licensed (see LICENSE file).
 */

#include "shader.h"

#include <iostream>

Shader::Shader() {
	programId = -1;
}

Shader::~Shader() {
	if (programId > 0) {
		glDeleteProgram(programId);
	}
}

bool Shader::buildFromSrc(const char *vshSrc, const char *fshSrc) {
	programId = create(vshSrc, fshSrc, &vshId, &fshId);

	return (programId > 0);
}

void Shader::use() {
	glUseProgram(programId);
}

GLint Shader::getParam(ShaderParamType type, const char *name) {
	GLint id = (type == ATTR) ?
			glGetAttribLocation(programId, name) :
			glGetUniformLocation(programId, name);

	if (id < 0) {
        std::cerr << "Shader: Could not get parameter id for param "  << name << std::endl;
	}

	return id;
}

GLuint Shader::create(const char *vshSrc, const char *fshSrc, GLuint *vshId, GLuint *fshId) {
	*vshId = compile(GL_VERTEX_SHADER, vshSrc);
	*fshId = compile(GL_FRAGMENT_SHADER, fshSrc);

	GLuint programId = glCreateProgram();

	if (programId == 0) {
        std::cerr << "Shader: Could not create shader program." << std::endl;
		return -1;
	}

	glAttachShader(programId, *vshId);   // add the vertex shader to program
	glAttachShader(programId, *fshId);   // add the fragment shader to program
	glLinkProgram(programId);

	// check link status
	GLint linkStatus;
	glGetProgramiv(programId, GL_LINK_STATUS, &linkStatus);
	if (linkStatus != GL_TRUE) {
        std::cerr << "Shader: Could not link shader program:" << std::endl;
		GLchar infoLogBuf[1024];
		GLsizei infoLogLen;
		glGetProgramInfoLog(programId, 1024, &infoLogLen, infoLogBuf);
        std::cerr << infoLogBuf << std::endl;

		glDeleteProgram(programId);

		return -1;
	}

	return programId;
}

GLuint Shader::compile(GLenum type, const char *src) {
	GLuint shId = glCreateShader(type);

	if (shId == 0) {
        std::cerr << "Shader: Could not create shader." << std::endl;
		return -1;
	}

    glShaderSource(shId, 1, (const GLchar**)&src, NULL);
    glCompileShader(shId);

    // check compile status
    GLint compileStatus;
    glGetShaderiv(shId, GL_COMPILE_STATUS, &compileStatus);

	if (compileStatus != GL_TRUE) {
        std::cerr << "Shader: Could not compile shader:" << std::endl;
		GLchar infoLogBuf[1024];
		GLsizei infoLogLen;
		glGetShaderInfoLog(shId, 1024, &infoLogLen, infoLogBuf);
        std::cerr << infoLogBuf << std::endl;

		glDeleteShader(shId);

		return -1;
	}

	return shId;
}
