//------------------------------------------------------------------------------------------------------------------
// Volumetric Fog & Mist Scriptable Object
// Created by Ramiro Oliva (Kronnect)
//------------------------------------------------------------------------------------------------------------------
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif
using System;
using System.Collections;
using System.Collections.Generic;


namespace VolumetricFogAndMist {

				[CreateAssetMenu(fileName = "VolumetricFogProfile", menuName = "Volumetric Fog Profile", order = 100) ]
				public class VolumetricFogProfile: ScriptableObject {

								public LIGHTING_MODEL lightingModel = LIGHTING_MODEL.Classic;

								public bool sunCopyColor = true;

								[Range(0, 1.25f)]
								public float density = 1.0f;

								[Range(0, 1f)]
								public float noiseStrength = 0.8f;

								[Range(0, 500)]
								public float height = 4f;

								public float baselineHeight = 0f;

								[Range(0, 1000)]
								public float distance = 0f;

								[Range(0, 5f)]
								public float distanceFallOff = 0f;

								[Range(0, 2000)]
								public float maxFogLength = 1000f;

								[Range(0, 1f)]
								public float maxFogLengthFallOff = 0f;

								public bool baselineRelativeToCamera = false;

								[Range(0, 1f)]
								public float baselineRelativeToCameraDelay = 0;

								[Range(0.2f, 10f)]
								public float noiseScale = 1f;

								[Range(-0.3f, 1f)]
								public float	noiseSparse = 0f;

								[Range(0, 1.05f)]
								public float alpha = 1f;

								public Color color = new Color (0.89f, 0.89f, 0.89f, 1);

								public Color specularColor = new Color (1, 1, 0.8f, 1);

								[Range(0, 1f)]
								public float specularThreshold = 0.6f;

								[Range(0, 1f)]
								public float specularIntensity = 0.2f;

								public Vector3 lightDirection  = new Vector3 (1, 0, -1);

								[Range(-1f, 3f)]
								public float lightIntensity = 0.2f;

								public Color lightColor = Color.white;

								[Range(0, 1f)]
								public float speed = 0.01f;

								public Vector3 windDirection = new Vector3 (-1, 0, 0);

								[Range(0, 10f)]
								public float turbulenceStrength = 0f;

								public bool useXYPlane = false;

								public Color skyColor = new Color (0.89f, 0.89f, 0.89f, 1);

								[Range(0f, 1000f)]
								public float skyHaze = 50f;

								[Range(0, 1f)]
								public float skySpeed = 0.3f;

								[Range(0, 1f)]
								public float skyNoiseStrength = 0.1f;

								[Range(0, 1f)]
								public float skyAlpha = 1f;

								public float stepping = 12f;

								public float steppingNear = 1f;

								public bool dithering = false;

								public float ditherStrength = 0.75f;


								/// <summary>
								/// Applies profile settings
								/// </summary>
								/// <param name="fog">Fog.</param>
								public void Load(VolumetricFog fog) {
												// Fog Geo
												fog.density = density;
												fog.noiseStrength = noiseStrength;
												fog.height = height;
												fog.baselineHeight = baselineHeight;
												fog.distance = distance;
												fog.distanceFallOff = distanceFallOff;
												fog.maxFogLength = maxFogLength;
												fog.maxFogLengthFallOff = maxFogLengthFallOff;
												fog.baselineRelativeToCamera = baselineRelativeToCamera;
												fog.baselineRelativeToCameraDelay = baselineRelativeToCameraDelay;
												fog.noiseScale = noiseScale;
												fog.noiseSparse = noiseSparse;
												fog.useXYPlane = useXYPlane;

												// Fog Colors
												fog.sunCopyColor = sunCopyColor;
												fog.alpha = alpha;
												fog.color = color;
												fog.specularColor = specularColor;
												fog.specularThreshold = specularThreshold;
												fog.specularIntensity = specularIntensity;
												fog.lightDirection = lightDirection;
												fog.lightIntensity = lightIntensity;
												fog.lightColor = lightColor;

												// Fog animation
												fog.speed = speed;
												fog.windDirection = windDirection;
												fog.turbulenceStrength = turbulenceStrength;

												// Fog sky
												fog.skyColor = skyColor;
												fog.skyHaze = skyHaze;
												fog.skySpeed = skySpeed;
												fog.skyNoiseStrength = skyNoiseStrength;
												fog.skyAlpha = skyAlpha;

												// Optimization
												fog.stepping = stepping;
												fog.steppingNear = steppingNear;
												fog.dithering = dithering;
												fog.ditherStrength = ditherStrength;
								}


								/// <summary>
								/// Replaces profile settings with current fog configuration
								/// </summary>
								public void Save(VolumetricFog fog) {
												// Fog Geo
												density = fog.density;
												noiseStrength = fog.noiseStrength;
												height = fog.height;
												baselineHeight = fog.baselineHeight;
												distance = fog.distance;
												distanceFallOff = fog.distanceFallOff;
												maxFogLength = fog.maxFogLength;
												maxFogLengthFallOff = fog.maxFogLengthFallOff;
												baselineRelativeToCamera = fog.baselineRelativeToCamera;
												baselineRelativeToCameraDelay = fog.baselineRelativeToCameraDelay;
												noiseScale = fog.noiseScale;
												noiseSparse = fog.noiseSparse;
												useXYPlane = fog.useXYPlane;

												// Fog Colors
												sunCopyColor = fog.sunCopyColor;
												alpha = fog.alpha;
												color = fog.color;
												specularColor = fog.specularColor;
												specularThreshold = fog.specularThreshold;
												specularIntensity = fog.specularIntensity;
												lightDirection = fog.lightDirection;
												lightIntensity = fog.lightIntensity;
												lightColor = fog.lightColor;

												// Fog animation
												speed = fog.speed;
												windDirection = fog.windDirection;
												turbulenceStrength = fog.turbulenceStrength;

												// Fog sky
												skyColor = fog.skyColor;
												skyHaze = fog.skyHaze;
												skySpeed = fog.skySpeed;
												skyNoiseStrength = fog.skyNoiseStrength;
												skyAlpha = fog.skyAlpha;

												// Optimization
												stepping = fog.stepping;
												steppingNear = fog.steppingNear;
												dithering = fog.dithering;
												ditherStrength = fog.ditherStrength;
								}

								/// <summary>
								/// Lerps between profile1 and profile2 using t as the transition amount (0..1) and assign the values to given fog
								/// </summary>
								public static void Lerp(VolumetricFogProfile profile1, VolumetricFogProfile profile2, float t, VolumetricFog fog) {
												if (t<0) t = 0; else if (t>1f) t = 1f;
												// Fog Geo
												fog.density = profile1.density * (1f-t) + profile2.density * t;
												fog.noiseStrength = profile1.noiseStrength * (1f-t) + profile2.noiseStrength * t;;
												fog.height = profile1.height * (1f-t) + profile2.height * t;;
												fog.baselineHeight = profile1.baselineHeight * (1f-t) + profile2.baselineHeight * t;
												fog.distance = profile1.baselineHeight * (1f-t) + profile2.distance * t;;
												fog.distanceFallOff = profile1.distanceFallOff * (1f-t) + profile2.distanceFallOff * t;
												fog.maxFogLength = profile1.maxFogLength * (1f-t) + profile2.maxFogLength * t;
												fog.maxFogLengthFallOff = profile1.maxFogLengthFallOff * (1f-t) + profile2.maxFogLengthFallOff * t;
												fog.baselineRelativeToCamera = t<0.5f ? profile1.baselineRelativeToCamera : profile2.baselineRelativeToCamera;
												fog.baselineRelativeToCameraDelay = profile1.baselineRelativeToCameraDelay * (1f-t) + profile2.baselineRelativeToCameraDelay * t;
												fog.noiseScale = profile1.noiseScale * (1f-t) + profile2.noiseScale * t;
												fog.noiseSparse = profile1.noiseSparse * (1f-t) + profile2.noiseSparse * t;
//												fog.useXYPlane = t<0.5f ? profile1.useXYPlane : profile2.useXYPlane;

												// Fog Colors
												fog.sunCopyColor = t<0.5f ? profile1.sunCopyColor : profile2.sunCopyColor;
												fog.alpha = profile1.alpha * (1f-t) + profile2.alpha * t;
												fog.color = profile1.color * (1f-t) + profile2.color * t;
												fog.specularColor = profile1.specularColor * (1f-t) + profile2.color * t;
												fog.specularThreshold = profile1.specularThreshold * (1f-t) + profile2.specularThreshold * t;
												fog.specularIntensity = profile1.specularIntensity * (1f-t) + profile2.specularIntensity * t;
												fog.lightDirection = profile1.lightDirection * (1f-t) + profile2.lightDirection * t;
												fog.lightIntensity = profile1.lightIntensity * (1f-t) + profile2.lightIntensity * t;
												fog.lightColor = profile1.lightColor * (1f-t) + profile2.lightColor * t;

												// Fog animation
												fog.speed = profile1.speed * (1f-t) + profile2.speed * t;
												fog.windDirection = profile1.windDirection * (1f-t) + profile2.windDirection * t;
												fog.turbulenceStrength = profile1.turbulenceStrength * (1f-t) + profile2.turbulenceStrength * t;

												// Fog sky
												fog.skyColor = profile1.skyColor * (1f-t) + profile2.skyColor * t;
												fog.skyHaze = profile1.skyHaze * (1f-t) + profile2.skyHaze * t;
												fog.skySpeed = profile1.skySpeed * (1f-t) + profile2.skySpeed * t;
												fog.skyNoiseStrength = profile1.skyNoiseStrength * (1f-t) + profile2.skyNoiseStrength * t;
												fog.skyAlpha = profile1.skyAlpha * (1f-t) + profile2.skyAlpha * t;

												// Optimization
												fog.stepping = profile1.stepping * (1f-t) + profile2.stepping * t;
												fog.steppingNear = profile1.steppingNear * (1f-t) + profile2.steppingNear * t;
												fog.dithering = t<0.5f ? profile1.dithering: profile2.dithering;
												fog.ditherStrength = profile1.ditherStrength * (1f-t) + profile2.ditherStrength * t;
								}


				}

}