varying vec3 pos;
varying vec3 normal;
varying vec2 texCoord;  // The third coordinate is always 0.0 and is discarded

uniform vec3 LightColor;
uniform vec3 AmbientProduct, DiffuseProduct, SpecularProduct;
uniform float Shininess;
uniform sampler2D texture;
uniform float texScale;
uniform vec4 LightPosition;
uniform mat4 ModelView;

void main()
{
    // Unit direction vectors for Blinn-Phong shading calculation
    vec3 lightDir = normalize(LightPosition.xyz - pos);  // Direction to the light source
    float lightDist = length(LightPosition.xyz - pos);
    float lightAttenuation = 5.0;
    float attenuation = 1.0 / (1.0  + lightAttenuation * pow(lightDist, 2.0));
    float brightness = 30.0;
    
    vec3 viewDir = normalize(-pos);  // Direction to the eye/camera
    vec3 H = normalize(lightDir + viewDir);  // Halfway vector
    vec3 N = normalize((ModelView * vec4(normal, 0.0)).xyz);  // Normal vector
    
    // Compute terms in the illumination equation
    vec3 ambient =  AmbientProduct * attenuation * brightness;
    
    float Kd = max(dot(lightDir, N), 0.0);
    vec3 diffuse = Kd * DiffuseProduct * attenuation * brightness;
    
    float Ks = pow(max(dot(N, H), 0.0), Shininess);
    vec3 specular = Ks * SpecularProduct * attenuation * brightness;
    
    // discard the specular highlight if the light's behind the vertex
    if (dot(lightDir, N) < 0.0) {
        specular = vec3(0.0, 0.0, 0.0);
    }
    
    // globalAmbient is independent of distance from the light source
    vec3 globalAmbient = vec3(0.1, 0.1, 0.1);
    
    // Reduce point light with distance

    vec4 color = vec4(globalAmbient + ambient + diffuse, 1.0);
    gl_FragColor = vec4(specular, 1.0) + color * texture2D(texture, texCoord * texScale);
}
