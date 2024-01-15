#ifndef UNIVERSAL_SIMPLE_LIT_PASS_LJ_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_PASS_LJ_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "./LjHlsl.hlsl"

struct Attributes
{
    float4 positionOS    : POSITION;
    float3 normalOS      : NORMAL;
    float4 tangentOS     : TANGENT;
    float2 texcoord      : TEXCOORD0;
    float2 staticLightmapUV    : TEXCOORD1;
    float2 dynamicLightmapUV    : TEXCOORD2;
    float4 vertexColor : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;
    float2 uv1                      : TEXCOORD9;
    float2 uv2                      : TEXCOORD10;
    float2 uv3                      : TEXCOORD11;
    float2 SplatmapUV               : TEXCOORD12;
#if NOISEBUG  //Noise BUG
    float3 POSoff               : TEXCOORD20; // bug noise
#endif
    float3 positionWS                  : TEXCOORD1;    // xyz: posWS

    #ifdef _NORMALMAP
        half4 normalWS                 : TEXCOORD2;    // xyz: normal, w: viewDir.x
        half4 tangentWS                : TEXCOORD3;    // xyz: tangent, w: viewDir.y
        half4 bitangentWS              : TEXCOORD4;    // xyz: bitangent, w: viewDir.z
    #else
        half3  normalWS                : TEXCOORD2;
    #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half4 fogFactorAndVertexLight  : TEXCOORD5; // x: fogFactor, yzw: vertex light
    #else
        half  fogFactor                 : TEXCOORD5;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        float4 shadowCoord             : TEXCOORD6;
    #endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);

#ifdef DYNAMICLIGHTMAP_ON
    float2  dynamicLightmapUV : TEXCOORD8; // Dynamic lightmap UVs
#endif

    float4 positionCS                  : SV_POSITION;
    float4 vertexColor                  : TEXCOORD13;
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;

    inputData.positionWS = input.positionWS;

    #ifdef _NORMALMAP
        half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
        inputData.tangentToWorld = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
        inputData.normalWS = TransformTangentToWorld(normalTS, inputData.tangentToWorld);
    #else
        half3 viewDirWS = GetWorldSpaceNormalizeViewDir(inputData.positionWS);
        inputData.normalWS = input.normalWS;
    #endif

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    viewDirWS = SafeNormalize(viewDirWS);

    inputData.viewDirectionWS = viewDirWS;

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        inputData.shadowCoord = input.shadowCoord;
    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
    #else
        inputData.shadowCoord = float4(0, 0, 0, 0);
    #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactorAndVertexLight.x);
        inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
    #else
        inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactor);
        inputData.vertexLighting = half3(0, 0, 0);
    #endif

#if defined(DYNAMICLIGHTMAP_ON)
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV, input.vertexSH, inputData.normalWS);
#else
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
#endif

    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

    #if defined(DEBUG_DISPLAY)
    #if defined(DYNAMICLIGHTMAP_ON)
    inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
    #endif
    #if defined(LIGHTMAP_ON)
    inputData.staticLightmapUV = input.staticLightmapUV;
    #else
    inputData.vertexSH = input.vertexSH;
    #endif
    #endif
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

//// Used in Standard (Simple Lighting) shader
// Varyings LitPassVertexSimple(Attributes input)
// {
//     Varyings output = (Varyings)0;

//     UNITY_SETUP_INSTANCE_ID(input);
//     UNITY_TRANSFER_INSTANCE_ID(input, output);
//     UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

//     VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
//     VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

// #if defined(_FOG_FRAGMENT)
//         half fogFactor = 0;
// #else
//         half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
// #endif

//     output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
//     output.positionWS.xyz = vertexInput.positionWS;
//     output.positionCS = vertexInput.positionCS;

// #ifdef _NORMALMAP
//     half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
//     output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
//     output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
//     output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);
// #else
//     output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
// #endif

//     OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
// #ifdef DYNAMICLIGHTMAP_ON
//     output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
// #endif
//     OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

//     #ifdef _ADDITIONAL_LIGHTS_VERTEX
//         half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
//         output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
//     #else
//         output.fogFactor = fogFactor;
//     #endif

//     #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
//         output.shadowCoord = GetShadowCoord(vertexInput);
//     #endif

//     return output;
// }

// // Used for StandardSimpleLighting shader
// half4 LitPassFragmentSimple(Varyings input) : SV_Target
// {
//     UNITY_SETUP_INSTANCE_ID(input);
//     UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

//     SurfaceData surfaceData;
//     InitializeSimpleLitSurfaceData(input.uv, surfaceData);

//     InputData inputData;
//     InitializeInputData(input, surfaceData.normalTS, inputData);
//     SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

// #ifdef _DBUFFER
//     ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
// #endif

//     half4 color = UniversalFragmentBlinnPhong(inputData, surfaceData);
//     color.rgb = MixFog(color.rgb, inputData.fogCoord);
//     color.a = OutputAlpha(color.a, _Surface);

//     return color;
// }

Varyings LitPassVertexSimple(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);


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
#if NOISEBUG
    output.POSoff= Wind;//bug noise
#endif

    VertexPositionInputs vertexInput = GetVertexPositionInputs(POSoff);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half4 VColor = input.vertexColor;
    output.vertexColor = VColor;
#if defined(_FOG_FRAGMENT)
        half fogFactor = 0;
#else
        half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
#endif

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
#ifdef _SPLATMAPON
    output.uv1= TRANSFORM_TEX(input.texcoord, _BaseMap1);
    output.uv2= TRANSFORM_TEX(input.texcoord, _BaseMap2);
    output.uv3= TRANSFORM_TEX(input.texcoord, _BaseMap3);
    output.SplatmapUV = input.texcoord;
 #endif
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;

#ifdef _NORMALMAP
    half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
    output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
    output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
    output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);
#else
    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
#endif

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
#ifdef DYNAMICLIGHTMAP_ON
    output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
        output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
    #else
        output.fogFactor = fogFactor;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        output.shadowCoord = GetShadowCoord(vertexInput);
    #endif

    return output;
}
// Used for StandardSimpleLighting shader
half4 LitPassFragmentSimple(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    SurfaceData surfaceData;
#ifdef _SPLATMAPON
    InitializeSimpleLitSurfaceData(input.uv,input.uv1,input.uv2,input.uv3, input.SplatmapUV, surfaceData);
#else
    InitializeSimpleLitSurfaceData(input.uv, surfaceData);
#endif
    InputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

// #if _RAINON //==雨
//     half Rain = RainRipple(input.uv,_RainRippleS,_RainRippleNum);
// #else
//     half Rain = 0;
// #endif

#ifdef _SPLATMAPON //地形材质
    half4 Tex01 = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
    half4 Tex02 = SAMPLE_TEXTURE2D(_BaseMap1, sampler_BaseMap1,input.uv1);
    half4 Tex03 = SAMPLE_TEXTURE2D(_BaseMap2, sampler_BaseMap2, input.uv2);
    half4 Tex04 = SAMPLE_TEXTURE2D(_BaseMap3, sampler_BaseMap3, input.uv3);

    half4 Splatmap = SAMPLE_TEXTURE2D(_Splatmap, sampler_Splatmap, input.SplatmapUV);
    half4 texColor1 = lerp(Tex04,Tex01,Splatmap.r);
    half4 texColor2 = lerp(texColor1,Tex02,Splatmap.g);
    half4 texColor3 = lerp(texColor2,Tex03,Splatmap.b);
    half4 texColor4 = lerp(texColor3,Tex04,Splatmap.a);

    surfaceData.albedo = texColor4.rgb;
#endif

#ifdef _VMC //上下颜色混合
    float4 vertexColor = input.vertexColor;
    
    float4 BaseColorBlend = SoftLight_float4(half4(surfaceData.albedo,1),_TopTint,vertexColor.r*_TopTintAmount);
    BaseColorBlend = SoftLight_float4(BaseColorBlend,_BottomTint,(1-vertexColor.r)*_BottomTintAmount);

    surfaceData.albedo = saturate(BaseColorBlend.rgb);
#endif

#ifdef _DBUFFER
    ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
#endif

    half4 color = UniversalFragmentBlinnPhong(inputData, surfaceData);

#if _RANDOMCOLOR //隨機色
    half4 ColorRandom = ColorVariation(_RandomColorTint);
    color.rgb = SoftLight_float4(color,ColorRandom,_RandomColorAmount).rgb;
#endif

    color.rgb = MixFog(color.rgb, inputData.fogCoord);
    color.a = OutputAlpha(color.a, _Surface);
#if NOISEBUG  //Noise BUG
    color.rgb = saturate(input.POSoff);
#endif

    return color;
   // return _UIPoslerp;
}

#endif
