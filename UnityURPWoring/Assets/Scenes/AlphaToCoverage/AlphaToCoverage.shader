Shader "URP/UPRSample"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _Cutoff("Cutoff",float)=0.5
        _MipScale("MipScale",float)=0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
        AlphaToMask On
        LOD 100
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        float _Cutoff;
        float _MipScale;
        float4 _MainTex_TexelSize;
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
        {
           HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag

           VertexOutput vert(VertexInput i)
           {
             VertexOutput o;
             o.pos=TransformObjectToHClip(i.position.xyz);
             o.uv=i.uv;
             return o;
           }


             float CalcMipLevel(float2 texture_coord)
            {
                float2 dx = ddx(texture_coord);
                float2 dy = ddy(texture_coord);
                float delta_max_sqr = max(dot(dx, dx), dot(dy, dy));

                return max(0.0, 0.5 * log2(delta_max_sqr));
            }


           float4 frag(VertexOutput i) : SV_Target
           {
             float4 baseTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
             baseTex.a *= 1 + max(0, CalcMipLevel(i.uv * _MainTex_TexelSize.zw)) * _MipScale;
             baseTex.a = (baseTex.a - _Cutoff) / max(fwidth(baseTex.a), 0.0001) + 0.5;
             return baseTex;
           }

           ENDHLSL

        }         
        
    }
}