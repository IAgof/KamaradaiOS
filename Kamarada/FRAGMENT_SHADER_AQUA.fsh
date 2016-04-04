#extension GL_OES_EGL_image_external : require
precision mediump float
varying vec2 vTextureCoord
uniform sampler2D sTexture
void main() {\n +
    vec3 irgb = texture2D(sTexture, vTextureCoord).rgb;
    float gray = dot(irgb, vec3(0.299, 0.587, 0.114))
    gl_FragColor = vec4(gray * vec3(0, 0.749, 1.0), 1.0)
}
