	// Rest of shader follows - do not touch !
	#include "UnityCG.cginc"
	#include "VolumetricFogOptions.cginc"

	// Core uniforms!
	sampler2D  _MainTex;
	float4     _MainTex_TexelSize;
	float4     _MainTex_ST;
	sampler2D  _NoiseTex;
	sampler2D_float _CameraDepthTexture;
	float4 _CameraDepthTexture_TexelSize;
	#if FOG_COMPUTE_DEPTH
	sampler2D_float _VolumetricFogDepthTexture;
	#endif
	sampler2D _FogDownsampled;
	sampler2D _DownsampledDepth;
	float4 _DownsampledDepth_TexelSize;
    float4x4 _ClipToWorld;
    float3     _ClipDir;

	sampler2D _OriginalTex;

	half   _FogAlpha;
	half3  _Color;
	float4 _FogDistance;	
	float4 _FogData; // x = _FogBaseHeight, y = _FogHeight, z = density, w = scale;
	float3 _FogWindDir;
	float4 _FogStepping; // x = stepping, y = stepping near, z = edge improvement threshold, w = dithering on (>0 = dithering intensity)
	float4 _FogSkyData; // x = haze, y = noise, z = speed, w = depth (note, need to be available for all shader variants)

	// Optional uniforms according to enabled features!
    #if FOG_BLUR_ON
    sampler2D _BlurTex;
    #endif
	
	#if FOG_VOID_SPHERE	|| FOG_VOID_BOX
	float3 _FogVoidPosition;	// xyz
	float4 _FogVoidData;
	#endif

	#if FOG_AREA_SPHERE || FOG_AREA_BOX
	float3 _FogAreaPosition;	// xyz
	float4 _FogAreaData;
	#endif

	#if FOG_HAZE_ON
	half4  _FogSkyColor;
	#endif
	
    #if FOG_OF_WAR_ON 
    sampler2D _FogOfWar;
    float3 _FogOfWarCenter;
    float3 _FogOfWarSize;
    float3 _FogOfWarCenterAdjusted;
    #endif
    
    #if FOG_POINT_LIGHT0 || FOG_POINT_LIGHT1 || FOG_POINT_LIGHT2 || FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5
    float3 _FogPointLightPosition0;
    half3 _FogPointLightColor0;
    #endif

    #if FOG_POINT_LIGHT1 || FOG_POINT_LIGHT2 || FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5
    float3 _FogPointLightPosition1;
    half3 _FogPointLightColor1;
    #endif

    #if FOG_POINT_LIGHT2 || FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5
    float3 _FogPointLightPosition2;
    half3 _FogPointLightColor2;
    #endif

    #if FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5
    float3 _FogPointLightPosition3;
    half3 _FogPointLightColor3;
    #endif

    #if FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5
    float3 _FogPointLightPosition4;
    half3 _FogPointLightColor4;
    #endif
    
    #if FOG_POINT_LIGHT5
    float3 _FogPointLightPosition5;
    half3 _FogPointLightColor5;
    #endif
    
    #if FOG_SCATTERING_ON || FOG_DIFFUSION
	float3 _SunPosition;
	float3 _SunDir;
	half3  _SunColor;
    half4 _FogScatteringData;	// x = 1 / samples * spread, y = samples, z = exposure, w = weight
    half4 _FogScatteringData2;  // x = illumination, y = decay, z = jitter, w = diffusion
    #endif

	#if FOG_SUN_SHADOWS_ON
	sampler2D_float _VolumetricFogSunDepthTexture;
	float4 _VolumetricFogSunDepthTexture_TexelSize;
	float4x4 _VolumetricFogSunProj;
	float4 _VolumetricFogSunWorldPos;
	half4 _VolumetricFogSunShadowsData;
	#endif

	#if FOG_TRANSPARENCY_BLEND_PASS
	half _BlendPower;
	#endif

	// Computed internally
	float3 wsCameraPos;
	float dither;
	float4 adir;

	// Structures!
    struct appdata {
    	float4 vertex : POSITION;
		half2 texcoord : TEXCOORD0;
    };
    
	struct v2f {
	    float4 pos : SV_POSITION;
	    float2 uv: TEXCOORD0;
    	float2 depthUV : TEXCOORD1;
    	float3 cameraToFarPlane : TEXCOORD2;
		float2 depthUVNonStereo : TEXCOORD3;
	};
	
	// the Vertex shader

	v2f vert(appdata v) {
    	v2f o;
    	o.pos = UnityObjectToClipPos(v.vertex);
    	o.uv = UnityStereoScreenSpaceUVAdjust(v.texcoord, _MainTex_ST);
   		o.depthUV = o.uv;
		o.depthUVNonStereo = v.texcoord;

    	#if UNITY_UV_STARTS_AT_TOP
    	if (_MainTex_TexelSize.y < 0) {
	        // Depth texture is inverted WRT the main texture
    	    o.depthUV.y = 1.0 - o.depthUV.y;
			o.depthUVNonStereo.y = 1.0 - o.depthUVNonStereo.y;
    	}
    	#endif
               
    	// Clip space X and Y coords
    	float2 clipXY = o.pos.xy / o.pos.w;
               
    	// Position of the far plane in clip space
    	float4 farPlaneClip = float4(clipXY, 1.0, 1.0);
               
    	// Homogeneous world position on the far plane
    	farPlaneClip.y *= _ProjectionParams.x;	

    	#if UNITY_SINGLE_PASS_STEREO
    	_ClipToWorld = mul(_ClipToWorld, unity_CameraInvProjection);
    	#endif
    	float4 farPlaneWorld4 = mul(_ClipToWorld, farPlaneClip);
               
    	// World position on the far plane
    	float3 farPlaneWorld = farPlaneWorld4.xyz / farPlaneWorld4.w;
               
    	// Vector from the camera to the far plane
    	o.cameraToFarPlane = farPlaneWorld - _WorldSpaceCameraPos;
    	
    	return o;
	}


	// Misc functions
	
	float3 getWorldPos(v2f i, float depth01) {
    	// Reconstruct the world position of the pixel
 		#if FOG_USE_XY_PLANE
    		wsCameraPos = float3(_WorldSpaceCameraPos.x, _WorldSpaceCameraPos.y, _WorldSpaceCameraPos.z - _FogData.x);
    		#if FOG_ORTHO
    		float3 worldPos = i.cameraToFarPlane - _ClipDir * _ProjectionParams.z * (1.0 - depth01) + wsCameraPos;
    		#else
    		float3 worldPos = (i.cameraToFarPlane * depth01) + wsCameraPos;
    		#endif
    		worldPos.z += 0.00001; // fixes artifacts when worldPos.y = _WorldSpaceCameraPos.y which is really rare but occurs at y = 0
 		#else
	    	wsCameraPos = float3(_WorldSpaceCameraPos.x, _WorldSpaceCameraPos.y - _FogData.x, _WorldSpaceCameraPos.z);
    		#if FOG_ORTHO
    		float3 worldPos = i.cameraToFarPlane - _ClipDir * _ProjectionParams.z * (1.0 - depth01) + wsCameraPos;
    		#else
    		float3 worldPos = (i.cameraToFarPlane * depth01) + wsCameraPos;
    		#endif
    		worldPos.y += 0.00001; // fixes artifacts when worldPos.y = _WorldSpaceCameraPos.y which is really rare but occurs at y = 0
 		#endif
    	return worldPos;
    }
    
	#if FOG_HAZE_ON
	half4 getSkyColor(half4 color, float3 worldPos, float2 uv) {
		// Compute sky color
		float y = 1.0f / max(worldPos.y + _FogData.x, 1.0);
		float2 np = worldPos.xz * y * _FogData.w + _FogSkyData.z;
		float skyNoise = tex2D(_NoiseTex, np).a;
		skyNoise += dither * 3.0 * _FogStepping.w;
		half t = _FogSkyColor.a * saturate( _FogSkyData.x * y * (1.0 - skyNoise*_FogSkyData.y) );
		color.rgb = lerp(color.rgb, _FogSkyColor.rgb, t);
		return color;
	}
	#endif
	
	#if FOG_SUN_SHADOWS_ON
	float3 getShadowCoords(float3 worldPos) {
		float4 shadowClipPos = mul(_VolumetricFogSunProj, float4(worldPos, 1.0));
		// transform from clip to texture space
		shadowClipPos.xy /= shadowClipPos.w;
		shadowClipPos.xy *= 0.5;
		shadowClipPos.xy += 0.5;
		shadowClipPos.z = 0;
		return shadowClipPos.xyz;
	}
	#endif

	#if FOG_SCATTERING_ON || FOG_DIFFUSION
	half4 getShaft(float2 uv) {

		#if UNITY_SINGLE_PASS_STEREO
			_SunPosition.xy = UnityStereoScreenSpaceUVAdjust(_SunPosition.xy, _MainTex_ST);
		#endif
	    #if UNITY_UV_STARTS_AT_TOP
    	if (_MainTex_TexelSize.y < 0) {
		    _SunPosition.y = 1.0 - _SunPosition.y;
		}
	    #endif
	    float2 duv = _SunPosition.xy - uv;
  		duv *= _FogScatteringData.x * (1.0 + dither * _FogScatteringData2.z);  
  		half illumination = _FogScatteringData2.x;
  		half4 acum = half4(0,0,0,0);
   		for (float i = _FogScatteringData.y; i > 0; i--) {
    		uv += duv;  
   			half4 rgba = tex2Dlod(_MainTex, float4(uv.xy,0,0));  
    		acum += rgba * illumination * _FogScatteringData.w;
    		illumination *= _FogScatteringData2.y;
  		}  
   		return acum * _FogScatteringData.z;
	}

	void applyDiffusion(inout half4 sum) {
		float sunAmount = max( (dot( adir.xyz/adir.w, _SunDir)) * _FogScatteringData2.w, 0.0 );
		sum.rgb = lerp(sum.rgb, _SunColor, pow(sunAmount, 8.0) * sum.a );
	}
	#endif


	half4 getFogColor(float3 worldPos, float depth01) {

	    const half4 zeros = half4(0.0,0.0,0.0,0.0);

		// early exit if fog is not crossed
#if FOG_USE_XY_PLANE
		if ( (wsCameraPos.z>_FogData.y && worldPos.z>_FogData.y) ||
		     (wsCameraPos.z<-_FogData.y && worldPos.z<-_FogData.y) ) {
			return zeros;		
		}
#else
		if ( (wsCameraPos.y>_FogData.y && worldPos.y>_FogData.y) ||
		     (wsCameraPos.y<-_FogData.y && worldPos.y<-_FogData.y) ) {
			return zeros;		
		}
#endif
 		
 		#if FOG_VOID_SPHERE	|| FOG_VOID_BOX || FOG_OF_WAR_ON
 		half voidAlpha = 1.0;
 		#endif
 				
		#if FOG_OF_WAR_ON
		if (depth01<_FogSkyData.w) {
#if FOG_USE_XY_PLANE
			float2 fogTexCoord = worldPos.xy / _FogOfWarSize.xy - _FogOfWarCenterAdjusted.xy;
#else
			float2 fogTexCoord = worldPos.xz / _FogOfWarSize.xz - _FogOfWarCenterAdjusted.xz;
#endif
			voidAlpha = tex2D(_FogOfWar, fogTexCoord).a;
			if (voidAlpha <=0) return zeros;
		}
		#endif

		// Determine "fog length" and initial ray position between object and camera, cutting by fog distance params
		adir = float4(worldPos - wsCameraPos, 0);
		adir.w = length(adir.xyz);
		#if FOG_AREA_SPHERE
			// compute sphere intersection or early exit if ray does not sphere
    		float3  oc = wsCameraPos - _FogAreaPosition;
    		float3 nadir = adir.xyz / adir.w;
		    float   b = dot(nadir, oc);
    		float   c = dot(oc,oc) - _FogAreaData.y;
    		float   t = b*b - c;
    		if (t>=0) t = sqrt(t);
	        float distanceToFog = max(-b-t, 0);
	        float dist  = min(adir.w, _FogDistance.z);
			float t1 = min(-b+t, dist);
    		float fogLength = t1 - distanceToFog;
			if (fogLength<0) return zeros;
    		float3 fogCeilingCut = wsCameraPos + nadir * distanceToFog;
    	#elif FOG_AREA_BOX
			// compute box intersectionor early exit if ray does not cross box
			float3 ro = wsCameraPos - _FogAreaPosition;
		    float3 invR   = adir.w / adir.xyz;
		    float3 boxmax = 1.0 / _FogAreaData.xyz;
    		float3 tbot   = invR * (-boxmax - ro);
    		float3 ttop   = invR * (boxmax - ro);
			float3 tmin   = min (ttop, tbot);
			float2 tt0    = max (tmin.xx, tmin.yz);
			float distanceToFog  = max(tt0.x, tt0.y);
			distanceToFog = max(distanceToFog, 0);
			float3 tmax   = max (ttop, tbot);
			tt0 = min (tmax.xx, tmax.yz);
			float t1  = min(tt0.x, tt0.y);	
			float dist  = min(adir.w, _FogDistance.z);
			t1 = min(t1, dist);
			float fogLength = t1 - distanceToFog;
			if (fogLength<=0) return zeros;
			float3 fogCeilingCut = wsCameraPos + distanceToFog / invR;
			#if FOG_USE_XY_PLANE
				_FogAreaData.xy /= _FogData.w;
			#else
				_FogAreaData.xz /= _FogData.w;
			#endif
		#else 
		
			// ceiling cut

#if FOG_USE_XY_PLANE
			float delta = length(adir.xy);
			float2 ndirxy = adir.xy / delta;
			delta /= adir.z;
		
			float h = clamp(wsCameraPos.z, -_FogData.y, _FogData.y);
			float xh = delta * (wsCameraPos.z - h);
			float2 xy = wsCameraPos.xy - ndirxy * xh;
			float3 fogCeilingCut = float3(xy.x, xy.y, h);
#else
			float delta = length(adir.xz);
			float2 ndirxz = adir.xz / delta;
			delta /= adir.y;
		
			float h = clamp(wsCameraPos.y, -_FogData.y, _FogData.y);
			float xh = delta * (wsCameraPos.y - h);
			float2 xz = wsCameraPos.xz - ndirxz * xh;
			float3 fogCeilingCut = float3(xz.x, h, xz.y);
#endif
			// does fog starts after pixel? If it does, exit now
			float dist  = min(adir.w, _FogDistance.z);
			float distanceToFog = distance(fogCeilingCut, wsCameraPos);
			if (distanceToFog>=dist) return zeros;

			// floor cut
#if FOG_USE_XY_PLANE	
			float hf = 0;
			// edge cases
			if (delta>0 && worldPos.z > -0.5) {
				hf = _FogData.y;
			} else if (delta<0 && worldPos.z < 0.5) {
				hf = - _FogData.y;
			}
			float xf = delta * ( hf - wsCameraPos.z ); 
		
			float2 xzb = wsCameraPos.xy - ndirxy * xf;
			float3 fogFloorCut = float3(xzb.x, xzb.y, hf);
#else
			float hf = 0;
			// edge cases
			if (delta>0 && worldPos.y > -0.5) {
				hf = _FogData.y;
			} else if (delta<0 && worldPos.y < 0.5) {
				hf = - _FogData.y;
			}
			float xf = delta * ( hf - wsCameraPos.y ); 
 		
			float2 xzb = wsCameraPos.xz - ndirxz * xf;
			float3 fogFloorCut = float3(xzb.x, hf, xzb.y);
#endif

			// fog length is...
			float fogLength = distance(fogCeilingCut, fogFloorCut);
			fogLength = min(fogLength, dist - distanceToFog);
			if (fogLength<=0) return zeros;
		#endif
		
 		#if FOG_VOID_SPHERE
		float3 wpos = fogCeilingCut + fogLength * adir.xyz/adir.w;
		float voidDistance = distance(_FogVoidPosition, wpos) * _FogVoidData.x;
		voidAlpha *= saturate(lerp(1.0, voidDistance, _FogVoidData.w));
		if (voidAlpha <= 0) return zeros;
		#elif FOG_VOID_BOX
		float3 wpos = fogCeilingCut + fogLength * adir.xyz/adir.w;
		float3 absPos = abs(_FogVoidPosition - wpos) * _FogVoidData.xyz;
		float voidDistance = max(max(absPos.x, absPos.y), absPos.z);
		voidAlpha *= saturate(lerp(1.0, voidDistance, _FogVoidData.w));
		if (voidAlpha <= 0) return zeros;
		#endif		

		// Calc Ray-march params
		float rs = 0.1 + max( log(fogLength), 0 ) * _FogStepping.x;		// stepping ratio with atten detail with distance
		rs *= _FogData.z;	// prevents lag when density is too low
		rs *= saturate (dist * _FogStepping.y);
		dist -= distanceToFog;
		rs = max(rs, 0.01);
		float4 dir = float4( adir.xyz * rs / adir.w, fogLength / rs);       // ray direction & length
//		dir.w = min(dir.w, 200);	// maximum iterations could be clamped to improve performance under some point of view, most of time got unnoticieable

		// Point light preparation
		#if FOG_POINT_LIGHT0 || FOG_POINT_LIGHT1 || FOG_POINT_LIGHT2 || FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5 
		float3 pldir = dir.xyz;
		_FogPointLightPosition0 = fogCeilingCut - _FogPointLightPosition0;
		#endif
		
		#if FOG_POINT_LIGHT1 || FOG_POINT_LIGHT2 || FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5
		_FogPointLightPosition1 = fogCeilingCut - _FogPointLightPosition1;
		#endif

		#if FOG_POINT_LIGHT2 || FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5
		_FogPointLightPosition2 = fogCeilingCut - _FogPointLightPosition2;
		#endif

		#if FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5
		_FogPointLightPosition3 = fogCeilingCut - _FogPointLightPosition3;
		#endif

		#if FOG_POINT_LIGHT4 | FOG_POINT_LIGHT5
		_FogPointLightPosition4 = fogCeilingCut - _FogPointLightPosition4;
		#endif

		#if FOG_POINT_LIGHT5
		_FogPointLightPosition5 = fogCeilingCut - _FogPointLightPosition5;
		#endif

		// Extracted operations from ray-march loop for additional optimizations
#if FOG_USE_XY_PLANE
		dir.xy  *= _FogData.w;
		_FogData.y *= _FogData.z;	// extracted from loop, dragged here.
		dir.z   /= _FogData.y;
		float4 ft4 = float4(fogCeilingCut.xyz, 0); 
		ft4.xy  += _FogWindDir.xz;  // apply wind speed and direction; already defined above if the condition is true
		ft4.xy  *= _FogData.w;
		ft4.z   /= _FogData.y;	
#else
		dir.xz  *= _FogData.w;
		_FogData.y *= _FogData.z;	// extracted from loop, dragged here.
		dir.y   /= _FogData.y;
		float4 ft4 = float4(fogCeilingCut.xyz, 0); 
		ft4.xz  += _FogWindDir.xz;  // apply wind speed and direction; already defined above if the condition is true
		ft4.xz  *= _FogData.w;
		ft4.y   /= _FogData.y;	
#endif

#if FOG_USE_XY_PLANE
		#if FOG_AREA_SPHERE || FOG_AREA_BOX
			float2 areaCenter = _FogAreaPosition.xy + _FogWindDir.xy;
			areaCenter  *= _FogData.w;
		#endif
		
		#if FOG_DISTANCE_ON
			float2 camCenter = wsCameraPos.xy + _FogWindDir.xy;
			camCenter *= _FogData.w;
		#endif
#else
		#if FOG_AREA_SPHERE || FOG_AREA_BOX
			float2 areaCenter = _FogAreaPosition.xz + _FogWindDir.xz;
			areaCenter  *= _FogData.w;
		#endif
		
		#if FOG_DISTANCE_ON
			float2 camCenter = wsCameraPos.xz + _FogWindDir.xz;
			camCenter *= _FogData.w;
		#endif
#endif

		// Shadow preparation
		#if FOG_SUN_SHADOWS_ON
			#if FOG_USE_XY_PLANE
				fogCeilingCut.z += _FogData.x;
			#else
				fogCeilingCut.y += _FogData.x;
			#endif
			// reduce banding
			dir.w += frac(dither);

			float3 shadowCoords0 = getShadowCoords(fogCeilingCut);
			float3 fogEndPos = fogCeilingCut.xyz + fogLength * (1.0 + dither * _VolumetricFogSunShadowsData.y) * adir.xyz / adir.w;
			float3 shadowCoords1 = getShadowCoords(fogEndPos);
			// shadow out of range, exclude with a subtle falloff
			_VolumetricFogSunShadowsData.x *= saturate( (_VolumetricFogSunWorldPos.w - distanceToFog) / 35.0 );
			_VolumetricFogSunShadowsData.w = 1.0 / dir.w;
		#endif

		fogLength = (fogLength >= dist); // from this point, fogLenth == 1 if fog hits geometry

		// Ray-march
		half4 sum   = zeros;
		half4 fgCol = zeros;

		for (;dir.w>1;dir.w--, ft4.xyz+=dir.xyz) {
			#if FOG_AREA_SPHERE
				#if FOG_USE_XY_PLANE
					float2 vd = (areaCenter - ft4.xy) * _FogAreaData.x;
				#else
					float2 vd = (areaCenter - ft4.xz) * _FogAreaData.x;
				#endif
				float voidDistance = dot(vd, vd);
//				if (voidDistance>1) continue; // already cropped outside
				#if FOG_USE_XY_PLANE
					half4 ng = tex2Dlod(_NoiseTex, ft4.xyww);
					ng.a -= abs(ft4.z) + voidDistance * _FogAreaData.w; // - 0.3;
				#else
					half4 ng = tex2Dlod(_NoiseTex, ft4.xzww);
					ng.a -= abs(ft4.y) + voidDistance * _FogAreaData.w; // - 0.3;
				#endif
			#elif FOG_AREA_BOX
				#if FOG_USE_XY_PLANE
					float2 vd = abs(areaCenter - ft4.xy) * _FogAreaData.xy;
				#else
					float2 vd = abs(areaCenter - ft4.xz) * _FogAreaData.xz;
				#endif
				float voidDistance = max(vd.x, vd.y);
//				if (voidDistance>1.1) continue; // already cropped outside
				#if FOG_USE_XY_PLANE
					half4 ng = tex2Dlod(_NoiseTex, ft4.xyww);
					ng.a -= abs(ft4.z) + voidDistance * _FogAreaData.w;
				#else
					half4 ng = tex2Dlod(_NoiseTex, ft4.xzww);
					ng.a -= abs(ft4.y) + voidDistance * _FogAreaData.w;
				#endif
			#else
				#if FOG_USE_XY_PLANE
					half4 ng = tex2Dlod(_NoiseTex, ft4.xyww);
					ng.a -= abs(ft4.z);
				#else
					half4 ng = tex2Dlod(_NoiseTex, ft4.xzww);
					ng.a -= abs(ft4.y);
				#endif
			#endif

			#if FOG_DISTANCE_ON
				#if FOG_USE_XY_PLANE
					float2 fd = camCenter - ft4.xy;
				#else
					float2 fd = camCenter - ft4.xz;
				#endif
				float fdm = max(_FogDistance.x - dot(fd, fd), 0) * _FogDistance.y;
				ng.a -= fdm;
			#endif
				
			if (ng.a > 0) {
				fgCol   = half4(_Color * (1.0-ng.a), ng.a * 0.4);

				#if FOG_SUN_SHADOWS_ON
					float t = dir.w * _VolumetricFogSunShadowsData.w;
					float3 shadowCoords = lerp(shadowCoords1, shadowCoords0, t);
					float4 sunDepthWorldPos = tex2Dlod(_VolumetricFogSunDepthTexture, shadowCoords.xyzz);
					float sunDepth = 1.0 / DecodeFloatRGBA(sunDepthWorldPos);
					float3 curPos = lerp(fogEndPos, fogCeilingCut, t);
					float sunDist = distance(curPos, _VolumetricFogSunWorldPos.xyz);
					float shadowAtten = saturate(sunDepth - sunDist);
					ng.rgb *= lerp(1.0, shadowAtten, _VolumetricFogSunShadowsData.x * sum.a);
					fgCol *= lerp(1, shadowAtten, _VolumetricFogSunShadowsData.z );
				#endif

				#if FOG_POINT_LIGHT0 || FOG_POINT_LIGHT1 || FOG_POINT_LIGHT2 || FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5
				half pd0 = 1.0 / dot(_FogPointLightPosition0, _FogPointLightPosition0);
				#endif
				
				#if FOG_POINT_LIGHT1 || FOG_POINT_LIGHT2 || FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5
				half pd1 = 1.0 / dot(_FogPointLightPosition1, _FogPointLightPosition1);
				#endif
				
				#if FOG_POINT_LIGHT2 || FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5
				half pd2 = 1.0 / dot(_FogPointLightPosition2, _FogPointLightPosition2);
				#endif
				
				#if FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5
				half pd3 = 1.0 / dot(_FogPointLightPosition3, _FogPointLightPosition3);
				#endif
				
				#if FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5
				half pd4 = 1.0 / dot(_FogPointLightPosition4, _FogPointLightPosition4);
				#endif
				
				#if FOG_POINT_LIGHT5
				half pd5 = 1.0 / dot(_FogPointLightPosition5, _FogPointLightPosition5);
				ng.rgb += (_FogPointLightColor5 * pd5 + _FogPointLightColor4 * pd4 + _FogPointLightColor3 * pd3 + _FogPointLightColor2 * pd2 + _FogPointLightColor1 * pd1 + _FogPointLightColor0 * pd0) * fgCol.a;
				#elif FOG_POINT_LIGHT4
				ng.rgb += (_FogPointLightColor4 * pd4 + _FogPointLightColor3 * pd3 + _FogPointLightColor2 * pd2 + _FogPointLightColor1 * pd1 + _FogPointLightColor0 * pd0) * fgCol.a;
				#elif FOG_POINT_LIGHT3
				ng.rgb += (_FogPointLightColor3 * pd3 + _FogPointLightColor2 * pd2 + _FogPointLightColor1 * pd1 + _FogPointLightColor0 * pd0) * fgCol.a;
				#elif FOG_POINT_LIGHT2
				ng.rgb += (_FogPointLightColor2 * pd2 + _FogPointLightColor1 * pd1 + _FogPointLightColor0 * pd0) * fgCol.a;
				#elif FOG_POINT_LIGHT1
				ng.rgb += (_FogPointLightColor1 * pd1 + _FogPointLightColor0 * pd0) * fgCol.a;
				#elif FOG_POINT_LIGHT0
				ng.rgb += _FogPointLightColor0 * pd0 * fgCol.a;
				#endif

				fgCol.rgb *= ng.rgb * fgCol.aaa;
				sum += fgCol * (1.0-sum.a);
				if (sum.a>0.99) break;
			}
			
			#if FOG_POINT_LIGHT0 || FOG_POINT_LIGHT1 || FOG_POINT_LIGHT2 || FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5 
			_FogPointLightPosition0 += pldir;
			#endif
			#if FOG_POINT_LIGHT1 || FOG_POINT_LIGHT2 || FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5 
			_FogPointLightPosition1 += pldir;
			#endif
			#if FOG_POINT_LIGHT2 || FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5 
			_FogPointLightPosition2 += pldir;
			#endif
			#if FOG_POINT_LIGHT3 || FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5 
			_FogPointLightPosition3 += pldir;
			#endif
			#if FOG_POINT_LIGHT4 || FOG_POINT_LIGHT5 
			_FogPointLightPosition4 += pldir;
			#endif
			#if FOG_POINT_LIGHT5
			_FogPointLightPosition5 += pldir;
			#endif
		}
			
		// adds fog fraction to prevent banding due stepping on low densities
//		sum += (fogLength >= dist) * (sum.a<0.99) * fgCol * (1.0-sum.a) * dir.w; // if fog hits geometry and accumulation is less than 0.99 add remaining fraction to reduce banding
		half f1 = (sum.a<0.99);
		half f2 = (1.0-sum.a);
		half f3 = (half)(fogLength * dir.w);
		sum += fgCol * (f1 * f2 * f3);

		#if FOG_SCATTERING_ON || FOG_DIFFUSION
			applyDiffusion(sum);
		#endif

		sum *= _FogAlpha;
		
		// max distance falloff
		#if !FOG_AREA_SPHERE && !FOG_AREA_BOX
		float farBlend = saturate( (_FogDistance.z - distanceToFog)  / _FogDistance.w); 
		sum *= farBlend * farBlend;
		#endif

		#if FOG_VOID_SPHERE	|| FOG_VOID_BOX || FOG_OF_WAR_ON
		sum *= voidAlpha;
		#endif
		
		return sum;
	}
	


	inline void SetDither(float2 uv) {
		dither = frac(dot(float2(2.4084507, 3.2535211), uv * _ScreenParams.xy)) - 0.5;
	}

	inline float getDepth(v2f i) {
		#if FOG_ORTHO
			float depth01 = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.depthUV));
			#if UNITY_REVERSED_Z
				depth01 = 1.0 - depth01;
			#endif
		#else
			float depth01 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.depthUV)));
		#endif
		return depth01;
	}


	// Fragment Shaders
	half4 fragBackFog(v2f i) : SV_Target{

		float depthOpaque = getDepth(i);
		#if FOG_COMPUTE_DEPTH
			float depthTex = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_VolumetricFogDepthTexture, i.depthUVNonStereo)));
			float depth01 = min(depthOpaque, depthTex);
		#else
			float depth01 = depthOpaque;
		#endif

		float3 worldPos = getWorldPos(i, depth01);

		SetDither(i.uv);

		half4 sum = getFogColor(worldPos, depth01);
		sum *= 1.0 + dither * _FogStepping.w;
		#if FOG_DEBUG
		return sum;
		#endif

		half4 color = tex2D(_MainTex, i.uv);

		#if FOG_BLUR_ON
		half4 blurColor = tex2D(_BlurTex, i.depthUV);
		#endif

		#if FOG_TRANSPARENCY_BLEND_PASS
			#if FOG_COMPUTE_DEPTH
				half4 colorOpaque;
				if (depthTex < depthOpaque) {
					colorOpaque = color;
				} else {
					colorOpaque = tex2Dlod(_OriginalTex, float4(i.uv, 0, 0));
				}
			#else
				half4 colorOpaque = tex2D(_OriginalTex, i.uv);
			#endif
			half4 colorTrans = color - colorOpaque;
			#if FOG_BLUR_ON
				colorOpaque = lerp(colorOpaque, blurColor, sum.a);
			#endif
		#elif FOG_BLUR_ON
			color = lerp(color, blurColor, sum.a);
		#endif

		#if FOG_HAZE_ON
		if (depth01 >= _FogSkyData.w) {
			#if FOG_TRANSPARENCY_BLEND_PASS
				colorOpaque = getSkyColor(colorOpaque, worldPos, i.uv);
			#else
				color = getSkyColor(color, worldPos, i.uv);
			#endif
		}
		#endif

		#if FOG_TRANSPARENCY_BLEND_PASS
			color = colorOpaque * saturate(1.0 - sum.a) + sum;
			color = 1.0 - (1 - color) * (1 - colorTrans * _BlendPower);
		#else 
			color = color * saturate(1.0 - sum.a) + sum;
		#endif

		#if FOG_SCATTERING_ON
			color += getShaft(i.uv);
		#endif

		return color;
	}

	struct FragmentOutput
    {
        half4 dest0 : SV_Target0;
        float4 dest1 : SV_Target1;
    };
		
	FragmentOutput fragGetFog (v2f i) {

		float depthFull = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.depthUV + float2(0,-0.75) * _CameraDepthTexture_TexelSize.xy));
		float depthFull2 = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.depthUV + float2(0,0.75) * _CameraDepthTexture_TexelSize.xy)); // prevents artifacts on terrain under some perspective and high downsampling factor
		#if UNITY_REVERSED_Z
		depthFull = max(depthFull, depthFull2);
		#else
		depthFull = min(depthFull, depthFull2);
		#endif
		#if FOG_ORTHO
			float depth01  = depthFull;
		#else
	    	float depth01  = Linear01Depth(depthFull);
	    #endif
		#if FOG_COMPUTE_DEPTH
			float depthTex = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_VolumetricFogDepthTexture, i.depthUVNonStereo)));
			depth01 = min(depth01, depthTex);
		#endif
		float3 worldPos = getWorldPos(i, depth01);
		
		#if FOG_SUN_SHADOWS_ON
		SetDither(i.uv);
		#endif
		
		half4 fogColor = getFogColor(worldPos, depth01);
		FragmentOutput o;
		o.dest0 = fogColor;
		o.dest1 = depthFull.xxxx;
		return o;
	}

	half4 fragGetJustFog(v2f i) : SV_Target {

		float depthFull = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.depthUV + float2(0, -0.75) * _CameraDepthTexture_TexelSize.xy));
		float depthFull2 = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.depthUV + float2(0, 0.75) * _CameraDepthTexture_TexelSize.xy)); // prevents artifacts on terrain under some perspective and high downsampling factor
		#if UNITY_REVERSED_Z
		depthFull = max(depthFull, depthFull2);
		#else
		depthFull = min(depthFull, depthFull2);
		#endif
		#if FOG_ORTHO
			float depth01  = depthFull;
		#else
	    	float depth01  = Linear01Depth(depthFull);
	    #endif

		#if FOG_COMPUTE_DEPTH
			float depthTex = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_VolumetricFogDepthTexture, i.depthUVNonStereo)));
			depth01 = min(depth01, depthTex);
		#endif

		float3 worldPos = getWorldPos(i, depth01);
		
		#if FOG_SUN_SHADOWS_ON
		SetDither(i.uv);
		#endif
		return getFogColor(worldPos, depth01);
	}

	float4 fragGetJustDepth(v2f i) : SV_Target {

		float depthFull = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.depthUV + float2(0, -0.75) * _CameraDepthTexture_TexelSize.xy));
		float depthFull2 = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.depthUV + float2(0, 0.75) * _CameraDepthTexture_TexelSize.xy)); // prevents artifacts on terrain under some perspective and high downsampling factor
		#if UNITY_REVERSED_Z
			depthFull = max(depthFull, depthFull2);
		#else
			depthFull = min(depthFull, depthFull2);
		#endif

		#if FOG_COMPUTE_DEPTH
			float depthTex = UNITY_SAMPLE_DEPTH(tex2D(_VolumetricFogDepthTexture, i.depthUVNonStereo));
			#if UNITY_REVERSED_Z
				depthFull = max(depthTex, depthFull);
			#else
				depthFull = min(depthTex, depthFull);
			#endif
		#endif

		return depthFull.xxxx;
	}


	half4 fragApplyFog (v2f i) : SV_Target {
		
    	float depthFull = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.depthUV));
		float2 minUV = i.depthUV;
  		if (_FogStepping.z > 0) {
			float2 uv00 = i.depthUV - 0.5 * _DownsampledDepth_TexelSize.xy;
			float2 uv10 = uv00 + float2(_DownsampledDepth_TexelSize.x, 0);
			float2 uv01 = uv00 + float2(0, _DownsampledDepth_TexelSize.y);
			float2 uv11 = uv00 + _DownsampledDepth_TexelSize.xy;
    		float4 depths;
    		depths.x = tex2Dlod(_DownsampledDepth, float4(uv00, 0, 0)).r;
    		depths.y = tex2Dlod(_DownsampledDepth, float4(uv10, 0, 0)).r;
    		depths.z = tex2Dlod(_DownsampledDepth, float4(uv01, 0, 0)).r;
    		depths.w = tex2Dlod(_DownsampledDepth, float4(uv11, 0, 0)).r;
	  		float4 diffs = abs(depthFull.xxxx - depths);
			if (any(diffs > _FogStepping.zzzz)) {
	  			// Check 10 vs 00
	  			float minDiff  = lerp(diffs.x, diffs.y, diffs.y < diffs.x);
	  			minUV    = lerp(uv00, uv10, diffs.y < diffs.x);
	  			// Check against 01
	  			minUV    = lerp(minUV, uv01, diffs.z < minDiff);
	  			minDiff  = lerp(minDiff, diffs.z, diffs.z < minDiff);
	  			// Check against 11
	  			minUV    = lerp(minUV, uv11, diffs.w < minDiff);
			}
		}
		half4 sum = tex2Dlod(_FogDownsampled, float4(minUV, 0, 0));
		SetDither(i.uv);
		sum *= 1.0 + dither * _FogStepping.w;

		#if FOG_DEBUG
			return sum;
		#endif

		half4 color = tex2D(_MainTex, i.uv);

#if FOG_BLUR_ON
		half4 blurColor = tex2D(_BlurTex, i.depthUV);
#endif

	#if FOG_TRANSPARENCY_BLEND_PASS
		half4 colorOpaque = tex2D(_OriginalTex, i.uv);
		half4 colorTrans = color - colorOpaque;
		#if FOG_BLUR_ON
			colorOpaque = lerp(colorOpaque, blurColor, sum.a);
		#endif
	#elif FOG_BLUR_ON
		color = lerp(color, blurColor, sum.a);
	#endif

		#if FOG_HAZE_ON
			#if FOG_ORTHO
				float depthLinear01 = depthFull;
			#else
				float depthLinear01 = Linear01Depth(depthFull);
			#endif

			#if FOG_COMPUTE_DEPTH
				float depthTex = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_VolumetricFogDepthTexture, i.depthUVNonStereo)));
				depthLinear01 = min(depthTex, depthLinear01);
			#endif

  			if (depthLinear01>=_FogSkyData.w) {		
				float3 worldPos = getWorldPos(i, depthLinear01);
				color = getSkyColor(color, worldPos, i.uv);
			}
		#endif

		#if FOG_TRANSPARENCY_BLEND_PASS
			color = colorOpaque * saturate(1.0 - sum.a) + sum;
			color = 1.0 - (1 - color) * (1 - colorTrans * _BlendPower);
		#else 
			color = color * saturate(1.0 - sum.a) + sum;
		#endif

		#if FOG_SCATTERING_ON
			color += getShaft(i.uv);
		#endif

		return color;
	}

	//half4 fragDebugDepthPass (v2f i) : SV_Target {
	//    //float depthTex = DecodeFloatRGBA (tex2D(_VolumetricFogDepthTexture, i.depthUVNonStereo));
	//	float depthTex = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_DepthCamera, i.depthUVNonStereo)));
	//    return half4(depthTex.xxx,  1.0);
	//}
