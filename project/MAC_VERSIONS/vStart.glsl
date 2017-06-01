attribute vec3 vPosition;
attribute vec3 vNormal;
attribute vec2 vTexCoord;
attribute vec4 boneIDs;
attribute vec4 boneWeights;

varying vec3 pos;
varying vec4 normal;
varying vec2 texCoord;

uniform mat4 boneTransforms[64];
uniform mat4 ModelView;
uniform mat4 Projection;

void main()
{
    
    mat4 boneTransform = boneWeights[0] * boneTransforms[int(boneIDs[0])] +
                         boneWeights[1] * boneTransforms[int(boneIDs[1])] +
                         boneWeights[2] * boneTransforms[int(boneIDs[2])] +
                         boneWeights[3] * boneTransforms[int(boneIDs[3])];
    
    vec4 vpos = boneTransform * vec4(vPosition, 1.0);

    // Transform vertex position into eye coordinates
    pos = (ModelView * vpos).xyz;
    // Transform vertex normal into eye coordinates (assumes scaling is uniform across dimensions)
    
    normal = boneTransform * vec4(vNormal, 1.0);
    

    
    gl_Position = Projection * ModelView * vpos;
    texCoord = vTexCoord;
}
