# Lighting
Different lighting techniques using three.js and GLSL. The techniques (such as hemi-lighting, diffuse lighting and toon shading) are showcased on a model of "Suzanne" (blender monkey model).

![Display lighting projects](https://i.imgur.com/FI49af5.jpeg)

This project is based on SimonDev's course [GLSL Shaders from Scratch](https://simondev.teachable.com/courses/). The code referenced is located in the `fragment-shader.glsl` file.

This project showcases basic lighting techniques, these being:
- Ambient Lighting;
- Hemi Lighting;
- Diffuse Lighting;
- Specular Highlighting and IBL;
- Fresnel Effect;
- Toon Shading.

## Ambient Lighting
Basic ambient lighting. Ambient light color is determined by `ambient` and the strength is determined by `ambientAmount`.

## Hemi Lighting `hemiLighting()`
Hemi lighting effect, which makes areas that face the ground darker and areas that face up brighter. Darker color is determined by `groundColour`, brighter by `skyColour` and the strenght of this effect by `hemiAmount`.

In case the user opts for toon shading, the `fresnel` parameter contributes to the strength of the hemi light.

## Diffuse Lighting `diffuseLighting()`
Direct light source. The amount of lighting on each part of the mesh is determined by the dot product of the surface normal with the light direction vector (i.e. the more a surface faces away from the light, the darker it is with respect to that light source).

The light direction is determined by `lightDir`, its color is determined by `lightColour`, and the strength in `diffuseAmount`. If toon shading is in effect, the dot product is reduced to only two/three values so that only two/three colors are present.

## Specular Highlights `makeSpecular()` and `makeSpecularIBL()`
There are two techniques for specular highlights present: the [Phong reflection model](https://en.wikipedia.org/wiki/Phong_reflection_model), and IBL (Image Based Lighting) specular.

The former model calculates the dot product between the view direction and the reflection the light ray from hitting the surface. This value (which is less than or equal than 1) is exponentiated as to lessen its effect, and then added to each component of the `lighting` vector. In case of toon shading, it is reduced to two values (reflection or no reflection).

The latter works by sampling the environment and adding it as a reflection, determining the reflection strength in a similar manner as is done in the diffuse light.

## Fresnel Effect `fresnel()`
The [Fresnel Effect](https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/Fresnel-Effect-Node.html#:~:text=Fresnel%20Effect%20is%20the%20effect,normal%20and%20the%20view%20direction.) states that, the closer the viewing angle approaches the grazing angle, more light is reflected. In this shader, this effect is obtained by taking the dot product between the view direction and the surface normal, followed by subracting this value from 1. This value is multiplied into the `specular` vector, providing stonger highlights near the edges.

## Toon Shading
Aims to simulate a more "cartoon-ish" or more flat style of shading, reducing the shading gradient to few colors (2 or 3 in this shader). As previously mentioned, this effect is obtained by reducing the parameters which determine the lighting to the amount of colors desired.

To enable it, set `isToon` to `true`, set `numToon` to the amount of different shades desired (only 2 and 3 are available in this project), and set `toonStep` to how strong (between 0.0 and 1.0) you wish the `fresnel` parameter.
