// by lujun 16519579@qq,com
Shader "Babu/Skybox/URP 6 Sided"
{
    Properties
    {
        _Tint ("Tint Color", Color) = (.5, .5, .5, .5)
        [Gamma] _Exposure ("Exposure", Range(0, 8)) = 1.0
        _Rotation ("Rotation", Range(0, 360)) = 0
        [NoScaleOffset] _FrontTex ("Front [+Z]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _BackTex ("Back [-Z]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _LeftTex ("Left [+X]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _RightTex ("Right [-X]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _UpTex ("Up [+Y]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _DownTex ("Down [-Y]   (HDR)", 2D) = "grey" {}
    }
    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        Cull Off ZWrite Off
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
        half4 _Tint;
        half _Exposure;
        float _Rotation;

        half4 _FrontTex_HDR;
        half4 _BackTex_HDR;
        half4 _LeftTex_HDR;
        half4 _RightTex_HDR;
        half4 _UpTex_HDR;
        half4 _DownTex_HDR;
        CBUFFER_END

        TEXTURE2D(_FrontTex);
        SAMPLER(sampler_FrontTex);
        TEXTURE2D(_BackTex);
        SAMPLER(sampler_BackTex);
        TEXTURE2D(_LeftTex);
        SAMPLER(sampler_LeftTex);
        TEXTURE2D(_RightTex);
        SAMPLER(sampler_RightTex);
        TEXTURE2D(_UpTex);
        SAMPLER(sampler_UpTex);
        TEXTURE2D(_DownTex);
        SAMPLER(sampler_DownTex);


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
        
        #define unity_ColorSpaceDouble half4(4.59479380, 4.59479380, 4.59479380, 2.0)

            float3 RotateAroundYInDegrees (float3 vertex, float degrees)
        {
            float alpha = degrees * PI / 180.0;
            float sina, cosa;
            sincos(alpha, sina, cosa);
            float2x2 m = float2x2(cosa, -sina, sina, cosa);
            return float3(mul(m, vertex.xz), vertex.y).xzy;
        }
        inline half3 DecodeHDR (half4 data, half4 decodeInstructions)
        {
            // Take into account texture alpha if decodeInstructions.w is true(the alpha value affects the RGB channels)
            half alpha = decodeInstructions.w * (data.a - 1.0) + 1.0;

            // If Linear mode is not supported we can skip exponent part
            #if defined(UNITY_COLORSPACE_GAMMA)
                return (decodeInstructions.x * alpha) * data.rgb;
            #else
            #   if defined(UNITY_USE_NATIVE_HDR)
                    return decodeInstructions.x * data.rgb; // Multiplier for future HDRI relative to absolute conversion.
            #   else
                    return (decodeInstructions.x * pow(abs(alpha), decodeInstructions.y)) * data.rgb;
            #   endif
            #endif
        }


            half4 skybox_frag (VertexOutput i,TEXTURE2D_PARAM(smp, samplersmp), half4 smpDecode)
        {
            half4 tex = SAMPLE_TEXTURE2D (smp,samplersmp,i.uv);
            half3 c = DecodeHDR (tex, smpDecode);
            c = c * _Tint.rgb * unity_ColorSpaceDouble.rgb;
            c *= _Exposure;
            return half4(c, 1);
        }

            VertexOutput vert(VertexInput i)
           {
             VertexOutput o;
              float3 rotated = RotateAroundYInDegrees(i.position.xyz, _Rotation);
             o.pos=TransformObjectToHClip(rotated);
             o.uv=i.uv;
             return o;
           }


        ENDHLSL

        Pass
        {
           HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           float4 frag(VertexOutput i) : SV_Target
           {
             return  skybox_frag(i,_FrontTex, sampler_FrontTex, _FrontTex_HDR);
           }
           ENDHLSL
        } 

          Pass
        {
           HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           float4 frag(VertexOutput i) : SV_Target
           {
             return  skybox_frag(i,_BackTex, sampler_BackTex,_BackTex_HDR);
           }
           ENDHLSL
        }          
        
        Pass
        {
           HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           float4 frag(VertexOutput i) : SV_Target
           {
             return  skybox_frag(i,_LeftTex, sampler_LeftTex,_LeftTex_HDR);
           }
           ENDHLSL
        }        
        Pass
        {
           HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           float4 frag(VertexOutput i) : SV_Target
           {
             return  skybox_frag(i,_RightTex, sampler_RightTex,_RightTex_HDR);
           }
           ENDHLSL
        } 
          Pass
        {
           HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           float4 frag(VertexOutput i) : SV_Target
           {
             return  skybox_frag(i,_UpTex, sampler_UpTex,_UpTex_HDR);
           }
           ENDHLSL
        } 
          Pass
        {
           HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           float4 frag(VertexOutput i) : SV_Target
           {
             return  skybox_frag(i,_DownTex, sampler_DownTex,_DownTex_HDR);
           }
           ENDHLSL
        } 
        
    }
}
