varying vec3 pos;
varying vec3 normal;
varying vec2 texCoord;  // The third coordinate is always 0.0 and is discarded

uniform vec3 AmbientProduct, DiffuseProduct, SpecularProduct;
uniform float Shininess;
uniform sampler2D texture;
uniform float texScale;
uniform mat4 ModelView;

#define MAX_LIGHTS 10
uniform int numLights;
uniform struct Light {
    vec4 position;
    vec3 rgb;
    float brightness;
    float attenuation;
    //float coneAngle;
    vec3 coneDirection;
    bool directional;
} Lights[MAX_LIGHTS];

void main()
{
    vec4 surfaceColour = texture2D(texture, texCoord * texScale);
    
    vec3 viewDir = normalize(-pos);  // Direction to the eye/camera
    vec3 N = normalize((ModelView * vec4(normal, 0.0)).xyz);  // Normal vector
    
    // globalAmbient is independent of distance from the light source
    vec3 globalAmbient = vec3(0.1, 0.1, 0.1);
    vec4 colour = vec4(globalAmbient, 1.0) * surfaceColour;
    
    for(int i =0; i < numLights; i++)
    {
        // Unit direction vectors for Blinn-Phong shading calculation
        vec3 lightDir;
        lightDir = normalize(Lights[i].position.xyz - pos);  // Direction to the light source
        float lightDist = length(Lights[i].position.xyz - pos);
        float attenuation = 1.0 / (1.0  + Lights[i].attenuation * pow(lightDist, 2.0));
        
        if(Lights[i].position.w == 0.0)
        {
            lightDir = normalize(Lights[i].position.xyz);
        }
        
        //Directional light
        /*if(Lights[i].directional) {
            float coneAngle = 5.0;
            float lightToSurfaceAngle = degrees(acos(dot(-normalize(Lights[i].position.xyz), normalize(Lights[i].coneDirection))));
            if(lightToSurfaceAngle > coneAngle){
                attenuation = 0.0;
            }
        }*/
        
        vec3 halfway = normalize(lightDir + viewDir);  // Halfway vector

        
        // Compute terms in the illumination equation
        vec3 ambient =  AmbientProduct * surfaceColour.rgb * attenuation * Lights[i].rgb;
        
        float Kd = max(dot(lightDir, N), 0.0);
        vec3 diffuse = Kd * DiffuseProduct * surfaceColour.rgb * Lights[i].rgb;
        
        float Ks = pow(max(dot(N, halfway), 0.0), Shininess);
        vec3 specular = Ks * SpecularProduct * Lights[i].rgb;
        
        // discard the specular highlight if the light's behind the vertex
        if (dot(lightDir, N) < 0.0) {
            specular = vec3(0.0, 0.0, 0.0);
        }
        colour.rgb += attenuation * Lights[i].brightness * (ambient + diffuse + specular);
    }
    gl_FragColor = colour;
}
