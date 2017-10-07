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
    public class VolumetricFogPosT : MonoBehaviour, IVolumetricFogRenderComponent
    {

        public VolumetricFog fog { get; set; }

        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            if (fog == null || !fog.enabled)
            {
                Graphics.Blit(source, destination);
                return;
            }

            fog.DoOnRenderImage(source, destination);
        }

        public void DestroySelf()
        {
            DestroyImmediate(this);
        }

    }

}