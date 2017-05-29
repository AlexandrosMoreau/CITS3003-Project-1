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
    bool directional;
    float angle;
    vec3 coneDirection;
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
        vec3 lightDir = normalize(Lights[i].position.xyz - pos);  // Direction to the light source
        float lightDist = length(Lights[i].position.xyz - pos);
        float attenuation = 1.0 / (1.0  + Lights[i].attenuation * pow(lightDist, 2.0));
        float brightness = Lights[i].brightness;
        vec3 lightColour = Lights[i].rgb;

        
        //Directional light
        if(Lights[i].directional) {
            //ratio used to replicate sun angle in the sky
            float angleModifier = degrees(Lights[i].angle)/90.0;
            brightness = brightness * angleModifier;
            
            //simulate sunset colours
            lightColour.r = colour.r +(200.0 + 55.0*angleModifier)/255.0;
            lightColour.g = colour.g +(125.0 + 130.0*angleModifier)/255.0;
            lightColour.b = colour.b +(90.0 + 165.0*angleModifier)/255.0;
        }
    
        vec3 halfway = normalize(lightDir + viewDir);  // Halfway vector

        
        // Compute terms in the illumination equation
        vec3 ambient =  AmbientProduct * surfaceColour.rgb * attenuation;
        
        float Kd = max(dot(lightDir, N), 0.0);
        vec3 diffuse = Kd * DiffuseProduct * surfaceColour.rgb;
        
        float Ks = pow(max(dot(N, halfway), 0.0), Shininess);
        vec3 specular = Ks * SpecularProduct * Lights[i].rgb;
        
        // discard the specular highlight if the light's behind the vertex
        if (dot(lightDir, N) < 0.0) {
            specular = vec3(0.0, 0.0, 0.0);
        }
        colour.rgb += attenuation * brightness * lightColour * (ambient + diffuse + specular);
    }
    gl_FragColor = colour;
}
