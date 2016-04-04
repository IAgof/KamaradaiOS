varying highp vec2 vTextureCoord;
uniform sampler2D sTexture;
void main() {
    lowp vec3 texel = texture2D(sTexture, vTextureCoord.xy).rgb;
    gl_FragColor = vec4(texel.x,texel.y,texel.z, 1.0);
    gl_FragColor.r = dot(texel, vec3(.393, .769, .189));
    gl_FragColor.g = dot(texel, vec3(.349, .686, .168));
    gl_FragColor.b = dot(texel, vec3(.272, .534, .131));
}
