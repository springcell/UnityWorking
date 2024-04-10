Shader "Spine/BaBu/2DBrackGround"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_color("Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        LOD 100
        ZWrite Off
        //Stencil
        //{
        //    Ref 0
        //    Comp always
        //    Pass Replace
        //}
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        float4 _MainTex_ST;
        float4 _color;
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
             o.uv=TRANSFORM_TEX(i.uv, _MainTex);
             return o;
           }

           float4 frag(VertexOutput i) : SV_Target
           {
             float4 baseTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
             return baseTex * _color;
           }

           ENDHLSL

        } 
        Pass
        {
            Name "2DLight"
            Tags { "LightMode" = "2dlight" }
            ZWrite Off
            Blend DstColor Zero
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

           VertexOutput vert(VertexInput i)
           {
             VertexOutput o;
             o.pos=TransformObjectToHClip(i.position.xyz);
             o.uv=i.uv.xy;
             return o;
           }

           float4 frag(VertexOutput i) : SV_Target
            {
                return half4(0, 0, 0, 0); 
            }
            ENDHLSL
        }
    }
}