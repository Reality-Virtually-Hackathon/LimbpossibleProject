//------------------------------------------------------------------------------------------------------------------
// Volumetric Fog & Mist
// Created by Ramiro Oliva (Kronnect)
//------------------------------------------------------------------------------------------------------------------
using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;


namespace VolumetricFogAndMist
{

    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera), typeof(VolumetricFog))]
    public class VolumetricFogPreT : MonoBehaviour, IVolumetricFogRenderComponent
    {

        public VolumetricFog fog { get; set; }
        RenderTexture opaqueFrame;

        [ImageEffectOpaque]
        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            if (fog == null || !fog.enabled)
            {
                Graphics.Blit(source, destination);
                return;
            }

            if (fog.renderBeforeTransparent)
            {
                fog.DoOnRenderImage(source, destination);
            }
            else
            {
                // Save frame buffer
                RenderTextureDescriptor desc = source.descriptor;
                opaqueFrame = RenderTexture.GetTemporary(desc);
                Graphics.Blit(source, opaqueFrame);
                fog.fogMat.SetTexture("_OriginalTex", opaqueFrame);
                Graphics.Blit(source, destination);
            }

        }

        void OnPostRender()
        {
            if (opaqueFrame != null)
            {
                RenderTexture.ReleaseTemporary(opaqueFrame);
                opaqueFrame = null;
            }
        }

								public void DestroySelf() {
												DestroyImmediate(this);
								}


    }

}