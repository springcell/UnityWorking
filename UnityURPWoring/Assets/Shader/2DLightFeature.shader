Shader "Babu/FX/2DLightFeature"
{
    Properties
    {
        _AMBIENTColor("_AMBIENTColor",color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        Blend DstColor Zero
        LOD 100
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        //#include "./ScenesFxCode.hlsl"

        CBUFFER_START(UnityPerMaterial)
        float4 _AMBIENTColor;
        
        CBUFFER_END


        struct VertexInput
        {
            float4 position : POSITION;
        };

        struct VertexOutput
        {
            float4 pos : SV_POSITION;
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
             return o;
           }


           float4 frag(VertexOutput i) : SV_Target
           {
               
               return _AMBIENTColor;
            }

           ENDHLSL

        }         
        
    }
}