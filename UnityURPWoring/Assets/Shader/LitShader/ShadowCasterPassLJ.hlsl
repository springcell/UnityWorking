#ifndef UNIVERSAL_SHADOW_CASTER_PASSLJ_INCLUDED
#define UNIVERSAL_SHADOW_CASTER_PASSLJ_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "./LjHlsl.hlsl"

// Shadow Casting Light geometric parameters. These variables are used when applying the shadow Normal Bias and are set by UnityEngine.Rendering.Universal.ShadowUtils.SetupShadowCasterConstantBuffer in com.unity.render-pipelines.universal/Runtime/ShadowUtils.cs
// For Directional lights, _LightDirection is used when applying shadow Normal Bias.
// For Spot lights and Point lights, _LightPosition is used to compute the actual light direction because it is different at each shadow caster geometry vertex.
float3 _LightDirection;
float3 _LightPosition;
float3 POSoff;

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float2 texcoord     : TEXCOORD0;
    float4 vertexColor : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float4 positionCS   : SV_POSITION;
};

float4 GetShadowPositionHClip(Attributes input)
{

#ifdef _UIPOSAITION //飞UI
    float3 UIpos = WorldToLocal(_UIPosition.xyz,input.positionOS);
    float3 UIOff = lerp(input.positionOS.xyz,UIpos.xyz,min((_UIPoslerp * _UIPoslerpTime),1));
   // float3 UIOff = lerp(input.positionOS.xyz,UIpos.xyz,saturate(_UIPoslerpTime));
#else
    float3 UIOff = input.positionOS.xyz;
#endif

#ifdef _WINDON //==风
        float3 WinfPos = GetAbsolutePositionWS(TransformObjectToWorld(UIOff));
        float Wind = LeavesWind(WinfPos.xy,_WindSpeed,_WindLeavesScale,_WindLeavesStrength,_TreeSwaySpeed,_WindSwayScale,_WindStrength,input.vertexColor);
        float3 POSoff  = TransformWorldToObject(float3(Wind,0,Wind) + WinfPos);
#else
    // #if _GRASSMODE
    //     float3 worldPos= mul(unity_ObjectToWorld, input.positionOS).xyz;
    //     float3 POSoff = GrassAnmTexture(input.vertexColor, _NoiseMap, sampler_NoiseMap, worldPos, _Speed, _WindDirection, _WindPower) + input.positionOS.xyz;
    // #else
         float3 POSoff  = UIOff;
   // #endif
#endif


    float3 positionWS = TransformObjectToWorld(POSoff);

    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

#if _CASTING_PUNCTUAL_LIGHT_SHADOW
    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
#else
    float3 lightDirectionWS = _LightDirection;
#endif

    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

#if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#else
    positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#endif

    return positionCS;
}

Varyings ShadowPassVertex(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.positionCS = GetShadowPositionHClip(input);
    return output;
}

half4 ShadowPassFragment(Varyings input) : SV_TARGET
{
    Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
    return 0;
}

#endif
