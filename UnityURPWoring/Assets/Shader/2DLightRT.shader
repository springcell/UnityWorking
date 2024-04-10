Shader "Babu/FX/2DLightRT"
{
    Properties
    {
        [MainTexture]_MainTex ("Sprite Texture", 2D) = "white" {}
        [HDR]_color("Color",Color) = (1,1,1,1)
        _HDRBrightness("Brightness",Range(0,10)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Geometry" }
        ZWrite off
        Blend One One
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
        float4 _color;
        float _HDRBrightness;
        CBUFFER_END
       
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);


        struct VertexInput
        {
            float4 position : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct VertexOutput
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        ENDHLSL

        Pass
        { ZWrite off
           HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag

           VertexOutput vert(VertexInput i)
           {
             VertexOutput o;
             o.pos=TransformObjectToHClip(i.position.xyz  + float3(0,0,0.1));
             o.uv=i.uv;
             return o;
           }


           float4 frag(VertexOutput i) : SV_Target
           {
                float4 Light = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _color;
               return Light * _HDRBrightness;
            }

           ENDHLSL

        }         
        
    }
}