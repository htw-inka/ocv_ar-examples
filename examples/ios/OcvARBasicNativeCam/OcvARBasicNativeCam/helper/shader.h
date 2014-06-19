/**
 * simple opengl shader helper class - header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, June 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * BSD licensed (see LICENSE file).
 */


#ifndef SHADER_H
#define SHADER_H

#include <OpenGLES/ES2/gl.h>

typedef enum {
	ATTR,
	UNIF
} ShaderParamType;

class Shader {
public:
	Shader();
	~Shader();

	bool buildFromSrc(const char *vshSrc, const char *fshSrc);
	void use();

	GLint getParam(ShaderParamType type, const char *name);

private:
	static GLuint create(const char *vshSrc, const char *fshSrc, GLuint *vshId, GLuint *fshId);
	static GLuint compile(GLenum type, const char *src);

	GLuint programId;
	GLuint vshId;
	GLuint fshId;
};

#endif
