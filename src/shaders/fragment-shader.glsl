
uniform samplerCube specMap;

varying vec3 vNormal;
varying vec3 vPosition;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

vec3 linearTosRGB(vec3 value) {
  vec3 lt = vec3(lessThanEqual(value.rgb, vec3(0.0031308)));
  
  vec3 v1 = value * 12.92;
  vec3 v2 = pow(value.xyz, vec3(0.41666)) * 1.055 - vec3(0.055);

	return mix(v2, v1, lt);
}

vec3 hemiLighting(vec3 groundColour, vec3 skyColour, vec3 normal) {
  float hemiMix = remap(normal.y, -1.0, 1.0, 0.0, 1.0);
  vec3 hemi = mix(groundColour, skyColour, hemiMix);

  return hemi;
}

vec3 diffuseLighting(vec3 normal, vec3 lightDir, vec3 lightColour, bool isToon, int numToon) {
  float dp = max(0.0, dot(normal, lightDir));

  if (isToon) {
    // Toon effect
    switch(numToon) {
    case (2):
      dp = smoothstep(0.5, 0.505, dp);
      break;
    case (3):
      float fullShadow = smoothstep(0.5, 0.505, dp);
      float partialShadow = smoothstep(0.65, 0.655, dp) * 0.5 + 0.5; 
      // Also possible to use remap on the smoothstep call.

      // Combine values:
      dp = min(fullShadow, partialShadow);
      break;
    default:
      break;
    }
  }

    vec3 diffuse = lightColour * dp;
    return diffuse;
}

vec3 makeSpecular(vec3 normal, vec3 lightDir, vec3 viewDir, float strength, bool isToon){

  vec3 specular = vec3(0.0);

  // Phong Specular
  vec3 r = normalize(reflect(-lightDir, normal));
  float phongValue = max(0.0, dot(viewDir, r));
  phongValue = pow(phongValue, strength);
  
  specular += phongValue;

  if (isToon) {
  specular = smoothstep(0.5, 0.51, specular);
  }

  return specular;
}

vec3 makeSpecularIBL(vec3 normal, vec3 viewDir, vec3 specular) {
  // IBL Specular
  vec3 iblCoord = normalize(reflect(-viewDir, normal));
  vec3 iblSample = textureCubeLodEXT(specMap, iblCoord, 8.0).xyz;

  specular += iblSample * 0.5;
  return specular;
}

float fresnel(vec3 normal, vec3 viewDir, float strength, bool isToon, float toonStep) {
  // Fresnel Effect
  float fresnel = 1.0 - max(0.0, dot(viewDir, normal));
  fresnel = pow(fresnel, strength);

  if (isToon){
  fresnel = step(toonStep, fresnel);
  }

  return fresnel;
}

void main() {
  vec3 baseColour = vec3(0.3);
  vec3 lighting = vec3(0.0);
  
  vec3 normal = normalize(vNormal);
  vec3 viewDir = normalize(cameraPosition - vPosition);

  // Ambient lighting parameters
  vec3 ambient = vec3(1.0);

  // Determine if model will have toon shading effect
  bool isToon = true; // true if toon effect is desired
  int numToon = 3;     // number of colors desired for toon effect.
                       // Code only includes versions for 2 and 3 colors.

  float toonStep = 0.7;// Input for fresnel(); determines how much hemi      
                       // lighting will affect the toon shading.

  // Hemi Light parameters
  vec3 skyColour = vec3(0.0, 0.3, 0.6);
  vec3 groundColour = vec3(0.6, 0.3, 0.1);
  vec3 hemi = hemiLighting(groundColour, skyColour, normal);

  // Diffuse lighting parameters
  vec3 lightDir = normalize(vec3(1.0));
  vec3 lightColour = vec3(0.5);
  vec3 diffuse = diffuseLighting(normal, lightDir, lightColour, isToon, numToon);

  // Phong Specular
  vec3 specular = makeSpecular(normal, lightDir, viewDir, 32.0, isToon);

  // Enable IBL specular; i.e. reflection of surroundings
  // specular = makeSpecularIBL(normal, viewDir, specular);
  
  // Fresnel Effect
  float fresnel = fresnel(normal, viewDir, 2.0, isToon, toonStep);

  // Define amounts for each type of lighting (summing to 1.0)
  float ambientAmount = 0.0;
  float hemiAmount = 0.2;
  float diffuseAmount = 0.8;

  if (!isToon) {
    specular *= fresnel;
    lighting = ambient * ambientAmount + hemi * hemiAmount + diffuse * diffuseAmount;
  }
  else {
    lighting = ambient * ambientAmount + hemi * (hemiAmount + fresnel) + diffuse * diffuseAmount;
  }

  vec3 colour = lighting * baseColour + specular;

  colour = linearTosRGB(colour);
  // colour = pow(colour, vec3(1.0 / 2.2));

  gl_FragColor = vec4(colour, 1.0);
}
