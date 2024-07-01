// by lujun 16519579@qq,com
Shader "Babu/Terrain/TerrainColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("BaseColor",Color)=(1,1,1,1)

         [HideInInspector]_Mask("Mask", 2D) = "white" {}
         [HideInInspector][Enum(R, 0, G, 1, B, 2, A, 3)] _MaskChannel ("MaskChannel", int) = 0
    }
    SubShader
    {

        Tags { "RenderType"="Opaque"  "Queue"="Transparent" }
        Blend One OneMinusSrcAlpha
 
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #pragma multi_compile_fog

        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor; 
        float4 _MainTex_ST;
        int _MaskChannel;
        CBUFFER_END

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);


        struct VertexInput
        {
            float4 position : POSITION;
            float2 uv : TEXCOORD0;
            float2 uv1 : TEXCOORD1;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
        };

        struct VertexOutput
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
             float fogFactor : TEXCOORD15;
             float2 MaskUV : TEXCOORD12;

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

           VertexOutput vert(VertexInput i)
           {
             VertexOutput o;

             o.pos=TransformObjectToHClip(i.position.xyz);
             o.uv= TRANSFORM_TEX(i.uv, _MainTex);
             o.MaskUV= i.uv;
            o.fogFactor = ComputeFogFactor(o.pos.z);
             return o;
           }

           float4 frag(VertexOutput i) : SV_Target
           {
            float4 baseTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _BaseColor;
           
           float FogZ = i.pos.z * i.pos.w;
           float fogFactor = ComputeFogFactor(FogZ);

            float3 FianlColor2 = MixFog(baseTex.rgb, fogFactor);

            float4 Mask = SAMPLE_TEXTURE2D(_Mask, sampler_Mask,i.MaskUV);

            float newCol;
                switch(_MaskChannel) {
                    case 1:
                        newCol =  Mask.g;
                        break;
                    case 2:
                        newCol = Mask.b;
                        break;
                    case 3:
                        newCol = Mask.a;
                        break;
                    default:
                        newCol =  Mask.r;
                        break;
                }
            FianlColor2 *=newCol;

             return float4(FianlColor2.rgb,newCol);
           }

           ENDHLSL
        }   
        
    }
       Fallback "Hidden/Universal Render Pipeline/FallbackError"
}