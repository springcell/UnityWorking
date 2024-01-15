#ifndef UNIVERSAL_SIMPLE_LIT_INPUTTREE_LJ_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_INPUTTREE_LJ_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "./SurfaceInputLJ.hlsl"
#include "./LjHlsl.hlsl"

CBUFFER_START(UnityPerMaterial)
    half4 _BaseMap_ST;
    
    half4 _BaseMap1_ST;
    half4 _BaseMap2_ST;
    half4 _BaseMap3_ST;

    half4 _RandomColorTint;
    half _RandomColorAmount;

    half4 _Splatmap_ST;
    half4 _TopTint;
    half4 _BottomTint;

    half _Bump1Scale;
    half _Bump2Scale;
    half _Bump3Scale;
    half _Bump4Scale;

    half4 _BaseColor;
    half4 _SpecColor;
    half4 _EmissionColor;
    half4 _NoiseMap_ST;
    half _Cutoff;
    half _Surface;


    half _WindSpeed;
    half _WindLeavesScale;
    half _TreeSwaySpeed;
    half _WindSwayScale;
    half _WindStrength;
    half _WindLeavesStrength;
    half _TopTintAmount;
    half _BottomTintAmount;

    float _UIPoslerp;
    float _UIPoslerpTime;
    half _RainRippleS;
    half _RainRippleNum;

 
    //half4 _temp;
// ==Terrain====
    // half _CutoffA;
    // half _CutoffAsmooth;
    // half _CutoffB;
    // half _CutoffBsmooth;
    // half _CutoffC;
    // half _CutoffCsmooth;
    // half _CutoffD;
    // half _CutoffDsmooth;
    //Terrain

    // half _Speed;
    // half4 _WindDirection;
    // half  _WindPower;

CBUFFER_END
#ifdef _UIPOSAITION
   float4 _UIPosition;
#endif

#ifdef UNITY_DOTS_INSTANCING_ENABLED
    UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
        UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
        UNITY_DOTS_INSTANCED_PROP(float4, _SpecColor)
        UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
        UNITY_DOTS_INSTANCED_PROP(float , _Cutoff)
        UNITY_DOTS_INSTANCED_PROP(float , _Surface)
    UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

    #define _BaseColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata_BaseColor)
    #define _SpecColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata_SpecColor)
    #define _EmissionColor      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata_EmissionColor)
    #define _Cutoff             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata_Cutoff)
    #define _Surface            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata_Surface)
#endif

TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);


half4 SampleSpecularSmoothness(float2 uv, half alpha, half4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap))
{
     half4 specularSmoothness = half4(0, 0, 0, 1) ;
#ifdef _SPECGLOSSMAP
    specularSmoothness = SAMPLE_TEXTURE2D(specMap, sampler_specMap, uv) * specColor;
#elif defined(_SPECULAR_COLOR)
    specularSmoothness = specColor;
#endif

#ifdef _GLOSSINESS_FROM_BASE_ALPHA
    specularSmoothness.a = alpha;
#endif
    return specularSmoothness;
}

#ifdef _SPLATMAPON
inline void InitializeSimpleLitSurfaceData(float2 uv,float2 uv1,float2 uv2,float2 uv3, float2 SplatmapUV,out SurfaceData outSurfaceData)
{
    outSurfaceData = (SurfaceData)0;

    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    outSurfaceData.alpha = albedoAlpha.a * _BaseColor.a;
    AlphaDiscard(outSurfaceData.alpha, _Cutoff);

    outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
#ifdef _ALPHAPREMULTIPLY_ON
    outSurfaceData.albedo *= outSurfaceData.alpha;
#endif

    half4 specularSmoothness = SampleSpecularSmoothness(uv, outSurfaceData.alpha, _SpecColor , TEXTURE2D_ARGS(_SpecGlossMap, sampler_SpecGlossMap));
    outSurfaceData.metallic = 0.0; // unused
    outSurfaceData.specular = specularSmoothness.rgb;
    outSurfaceData.smoothness = specularSmoothness.a ;

#if _RAINON //==雨
    half Rain = RainRipple(uv,_RainRippleS,_RainRippleNum);
#else
    half Rain = 0;
#endif

#ifdef _SPLATMAPON
    half4 Splatmap = SAMPLE_TEXTURE2D(_Splatmap, sampler_Splatmap, SplatmapUV);
    half3 normal1= SampleNormal(uv + Rain,  TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap) ,_Bump1Scale *10);
    half3 normal2= SampleNormal(uv1+ Rain, TEXTURE2D_ARGS(_BumpMap1, sampler_BumpMap1),_Bump2Scale *10);
    half3 normal3= SampleNormal(uv2+ Rain, TEXTURE2D_ARGS(_BumpMap2, sampler_BumpMap2),_Bump3Scale *10);
    half3 normal4= SampleNormal(uv3+ Rain, TEXTURE2D_ARGS(_BumpMap3, sampler_BumpMap3),_Bump4Scale *10);

    half3 texBump1 = lerp(normal4,normal1,Splatmap.r);
    half3 texBump2 = lerp(texBump1,normal2,Splatmap.g);
    half3 texBump3 = lerp(texBump2,normal3,Splatmap.b);
    half3 texBump4 = lerp(texBump3,normal4,Splatmap.a);

    outSurfaceData.normalTS = texBump4;
#else
    outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap),_Bump1Scale *10);
#endif


    //outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
   // outSurfaceData.normalTS = texBump4;
    outSurfaceData.occlusion = 1.0;
    outSurfaceData.emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
}

#else

inline void InitializeSimpleLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{

    outSurfaceData = (SurfaceData)0;

    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    outSurfaceData.alpha = albedoAlpha.a * _BaseColor.a;
    AlphaDiscard(outSurfaceData.alpha, _Cutoff);

    outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
#ifdef _ALPHAPREMULTIPLY_ON
    outSurfaceData.albedo *= outSurfaceData.alpha;
#endif

    half4 specularSmoothness = SampleSpecularSmoothness(uv, outSurfaceData.alpha, _SpecColor, TEXTURE2D_ARGS(_SpecGlossMap, sampler_SpecGlossMap));
    outSurfaceData.metallic = 0; // unused
    outSurfaceData.specular = specularSmoothness.rgb;
    outSurfaceData.smoothness = specularSmoothness.a;
    outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap),_Bump1Scale *10);
    outSurfaceData.occlusion = 1.0;
    outSurfaceData.emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
}
#endif
#endif
