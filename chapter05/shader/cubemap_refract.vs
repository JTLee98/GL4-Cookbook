#version 430

layout (location = 0) in vec3 VertexPosition;
layout (location = 1) in vec3 VertexNormal;
layout (location = 2) in vec2 VertexTexCoord;

out vec3 ReflectDir;
out vec3 RefractDir[3];

struct MaterialInfo {
    float Eta;              // Index of refraction
    bool  ChromaticAbb;     // Chromatic Abberation active
    vec3  ChromaticAbb_RGB; // delta from Eta per RGB
    float ReflectionFactor; // Percentage of reflected light
};
uniform MaterialInfo Material;

uniform vec3 WorldCameraPosition;
uniform mat4 ModelViewMatrix;
uniform mat4 ModelMatrix;
uniform mat3 NormalMatrix;
uniform mat4 ProjectionMatrix;
uniform mat4 MVP;

void main()
{
    vec3 worldPos = vec3( ModelMatrix * vec4(VertexPosition,1.0) );
    vec3 worldNorm = vec3(ModelMatrix * vec4(VertexNormal, 0.0));
    vec3 worldView = normalize( WorldCameraPosition - worldPos );

    ReflectDir = reflect(-worldView, worldNorm );
    if (Material.ChromaticAbb)
    {
        // account for chromatic abberation
        float e = Material.Eta;
        vec3 EtaAbb = vec3(e, e, e) + Material.ChromaticAbb_RGB;
        RefractDir[0] = refract(-worldView, worldNorm, EtaAbb.r ); // Red
        RefractDir[1] = refract(-worldView, worldNorm, EtaAbb.g ); // Green
        RefractDir[2] = refract(-worldView, worldNorm, EtaAbb.b ); // Blue
    }
    else
    {
        // only use element 0 of RefractDir
        RefractDir[0] = refract(-worldView, worldNorm, Material.Eta );
    }
    gl_Position = MVP * vec4(VertexPosition,1.0);
}
