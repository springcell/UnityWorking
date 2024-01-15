Shader "Babu/FX/Water"
{
    Properties
    {
        [ToggleOff] _SceneDepth ("SceneDepth on/off", Float ) = 0  
        _MainTex ("Texture", 2D) = "bump" {}
       // _BaseColor("BaseColor",Color)=(1,1,1,1)
        _RampColor("Ramp",Color)=(1,1,1,1)
        _distanceDepth("distanceDepth",Range(1,20)) =2.25
        //_distanceColor("distanceColor",Range(0.001,0.005)) =0
        _Normal("Normal",Range(0,1)) =0.03
        _light_Normal("light_Normal",Range(0,1)) =0.03
        _EdgeNormal("EdgeNorma",Range(0,1)) =0.15
        _EdgeSize_X("EdgeSizeX",Range(0,1)) =0.4
        _EdgeSize_Y("EdgeSizeY",Range(0,1)) =0.3
        _EdgeTransparent("EdgeTransparent",Range(0,1)) =0.3
        _Speed("Speed",Range(0,1)) =0.4
        _iblSpecular("reflexBlur",Range(0,5)) =0.2
        //_reflexintensity("reflex_intensity",Range(0,1)) =0.4
        _Gloss_var("Gloss",Range(0,1)) =0.6
        [HDR]_GlossColor("GlossColor",Color) =(0,0,0,0)
        _EnvironmentColor("EnvironmentColor",Range(0,1)) = 1
        _Transparent("Transparent",Range(0,1)) =00.4
        _lightDir("lightDir",Vector) =(1,1,1,1)
    [Toggle(_RIPPER)] _ripper("ripper", Float) = 1.0
        _RipperNormal("RipperNormal",float) = 1
        _WaterRT ("Texture", 2D) = "white" {}

        //_Caustics("Caustics",float) = 1

       // _temp("temp",Range(0,1)) =0

    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #pragma shader_feature _SCENEDEPTH_OFF
        #pragma shader_feature _RIPPER
        #pragma multi_compile_fog

        CBUFFER_START(UnityPerMaterial)
        float4 _RampColor;
       // float4 _BaseColor;
        float4 _MainTex_ST;
        half4 _GlossColor;
        float _distanceDepth;
        float _Normal;
        float _light_Normal;
        float _EdgeNormal;
        float _Speed;
        float _EdgeTransparent;
       // float _temp;
        float _EdgeSize_X;
        float _EdgeSize_Y;
        float _iblSpecular;
        float _Gloss_var;
        float _EnvironmentColor;
       // float _Caustics;
        float4 _lightDir;
        //float _reflexintensity;
        float _Transparent;
        float _RipperNormal;
        CBUFFER_END

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_WaterRT);
        SAMPLER(sampler_WaterRT);

        struct VertexInput
        {
            float4 position : POSITION;
            float2 uv : TEXCOORD0;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
        };

        struct VertexOutput
        {
            float4 pos : SV_POSITION;
            float4 screenPos : TEXCOORD0;
            float2 uv : TEXCOORD1;
            float3 normal : TEXCOORD2;
            float3 tangent : TEXCOORD4;
            float3 bitangent : TEXCOORD5;
            float4 worldPos : TEXCOORD3;
             half2 fogFactor : TEXCOORD6;
        };

        ENDHLSL

        Pass
        {
           Name "Pass"
            Tags
            {
            "LightMode" = "UniversalForward"
            }
           HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag
//------------------------------------
            half3 NormalMaps (half3 Color, float Str  )
            {
                float lum = dot(Color,half3(0.333,0.333,0.333));
                float f =1-fwidth( lum );
                half3 nor = normalize(half3( ddx(lum), max(0.05,1-Str), ddy(lum) )).xzy + 0.5;
                return nor;
            }
//-------------------------------------
           VertexOutput vert(VertexInput i)
           {
             VertexOutput o;
             o.pos=TransformObjectToHClip(i.position.xyz);
             o.screenPos = ComputeScreenPos(o.pos);

             o.normal = TransformObjectToWorldNormal(i.normal.xyz);
             o.worldPos = mul(unity_ObjectToWorld, i.position.xyzw);
             o.tangent = normalize(mul(unity_ObjectToWorld, float4(i.tangent.xyz, 0.0)).xyz);
             o.bitangent = normalize(cross(o.normal, o.tangent) * i.tangent.w);
             o.uv = TRANSFORM_TEX(i.uv, _MainTex);
             o.fogFactor = float2(ComputeFogFactor(o.pos.z), 1);
             return o;
           }

           float4 frag(VertexOutput i) : SV_Target
           {
             half2 screenUV = (i.pos.xy / _ScreenParams.xy);
            float2 EdgeSize = float2(_EdgeSize_X,_EdgeSize_Y) * 0.5;


             float4 screenPosNorm = i.screenPos.xyzw / i.screenPos.w;

             
    #if _RIPPER
            float4 ripples = SAMPLE_TEXTURE2D(_WaterRT, sampler_WaterRT, screenUV) * _RipperNormal *100;
            _Normal += ripples.r;
     #endif
             float2 uv1=i.uv+_Time.xy*0.5 *_Speed;
             float2 uv2=i.uv+_Time.xy*0.2 *_Speed;



            float3 Normal = normalize(i.normal);
            float3x3 tangentTransform = float3x3(i.tangent, i.bitangent, i.normal);
            float3 NormalTexA = UnpackNormalScale(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv1),_Normal);
            float3 NormalTexB = UnpackNormalScale(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv2),_Normal);

            float3 WaterNormalTexA = UnpackNormalScale(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv1),_light_Normal*2);
            float3 WaterNormalTexB = UnpackNormalScale(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv2),_light_Normal*2);
            float3 WaterNormalTex=WaterNormalTexA+WaterNormalTexB;
            float3 WaterNormalFix = normalize(mul(WaterNormalTex, tangentTransform));

            float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

            float3 NormalTex=NormalTexA+NormalTexB;
            float3 NormalFix = normalize(mul(NormalTex, tangentTransform));


             Light mainLight = GetMainLight();
             float3 lightDir = mainLight.direction;
              lightDir += _lightDir.xyz;
             float3 lightColor = mainLight.color;

             float3 halfDir = SafeNormalize(lightDir + viewDir);
             float nh =pow(max(0,dot(WaterNormalFix,halfDir)),exp2(lerp(1,11,_Gloss_var *2)));
             _GlossColor.rgb  *= nh;

 
            //  float3 reflectVec = reflect(-viewDir,NormalFix);
            //  float mip =_iblSpecular ;
            //  float4 rr = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVec, mip);
            //  float iblSpecular = DecodeHDREnvironment(rr, unity_SpecCube0_HDR);
              float3 iblSpecular = max(lightColor.rgb,0.1) * _EnvironmentColor *20 + _GlossyEnvironmentColor.rgb;
             //_GlossColor.rgb  *= iblSpecular;


         #if defined(_SCENEDEPTH_OFF)
              float screenDepth = 1;
              float DepthMask =1;
              float DepthMaskColor = 1;
              float EdgeNormaAnm = 1;
         #else

            float3 EdgegeTexA = UnpackNormalScale(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv1 * EdgeSize *10),_EdgeNormal);
            float3 EdgegeTexB =UnpackNormalScale(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv2 * EdgeSize *10),_EdgeNormal);

            EdgegeTexA += EdgegeTexB;

             float EdgeNormaAnm = EdgegeTexA.r * max(_EdgeNormal *10,0.001);
            // float EdgeNormaAnm = EdgegeTexA.r * max(_EdgeNormal *100,0.001);

             float screenDepth = LinearEyeDepth(SampleSceneDepth(screenPosNorm.xy),_ZBufferParams);
             float DepthMask = abs( ( screenDepth - LinearEyeDepth( screenPosNorm.z,_ZBufferParams ) ) /_distanceDepth * 2);
             float DepthMaskColor = abs( ( screenDepth - LinearEyeDepth( screenPosNorm.z,_ZBufferParams ) ) /EdgeNormaAnm);
         #endif

             DepthMaskColor = clamp(DepthMaskColor,0,1);
             DepthMask = saturate(DepthMask);
            // float3 screenDepthColor = _BaseColor * screenDepth;
             

             //float4 baseTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, screenUV);
             half3 col2 = SampleSceneColor(screenPosNorm.xy + NormalTex.xy * DepthMaskColor )*iblSpecular+_GlossColor.rgb; 
            // half3 col2 = SampleSceneColor(screenPosNorm.xy); 
             col2 = lerp(_RampColor.xyz * DepthMask ,col2,_Transparent);
             col2 += saturate((1-DepthMaskColor)*_EdgeTransparent);
             float3 fianlColor = col2 ;
             //float alpha = DepthMask;
            // return  float4 (col2 + (1-DepthMaskColor),1);

           // fianlColor = ripplesNormal.rgb;

            fianlColor.rgb = MixFog(fianlColor.rgb, i.fogFactor.x);
             return  float4 (fianlColor.rgb,1);
            // return  1;

            }
           ENDHLSL

        }         
        
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}