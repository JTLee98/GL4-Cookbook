#version 430

in vec3 ReflectDir;
in vec3 RefractDir[3];

layout(binding=0) uniform samplerCube CubeMapTex;

struct MaterialInfo {
    float Eta;              // Index of refraction
    bool  ChromaticAbb;     // Chromatic Abberation active
    vec3  ChromaticAbb_RGB; // delta from Eta per RGB
    float ReflectionFactor; // Percentage of reflected light
};
uniform MaterialInfo Material;

layout( location = 0 ) out vec4 FragColor;

void main() {
    // Access the cube map texture
    vec3 reflectColor = texture(CubeMapTex, ReflectDir).rgb;
    vec3 refractColor = vec3(0.0, 0.0, 0.0);
    if (Material.ChromaticAbb)
    {
        refractColor.r = texture(CubeMapTex, RefractDir[0]).r;
        refractColor.g = texture(CubeMapTex, RefractDir[1]).g;
        refractColor.b = texture(CubeMapTex, RefractDir[2]).b;
    }
    else
    {
        refractColor = texture(CubeMapTex, RefractDir[0]).rgb;
    }

    vec3 color = mix(refractColor, reflectColor, Material.ReflectionFactor);
    // Gamma
    color = pow(color, vec3(1.0/2.2));
    
    FragColor = vec4(color , 1);
}
