// by lujun 16519579@qq,com
Shader "Babu/FX/2dLight"
{
    Properties
    {
        _MainTex("BackTex", 2D) = "white" {}
        //_BackTex ("Light", 2D) = "black" {}
       
        [HDR]_color("Color",Color) = (1,1,1,1)
        Brightness("Brightness",Range(0,10)) = 0
        [Toggle(_NOISEANM)] NOISEANM("Noise", Int) = 0
        _NoiseSpeed("NoiseSpeed",float) = 1
       // [HideInInspector][HDR]_color2("Color2",Color) = (0,1,0,0)
    }
    SubShader
    {

        Tags {  "Queue"="Transparent"}  
       // Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
       // ZTest Always
        Blend One One

        LOD 100
        HLSLINCLUDE
        #pragma shader_feature _ _NOISEANM
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
       

        CBUFFER_START(UnityPerMaterial)
        float4 _color;
        //float4 _color2;
        float Brightness;
#if _NOISEANM
        float _NoiseSpeed;
#endif
        CBUFFER_END


        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        //TEXTURE2D(_BackTex);
        //SAMPLER(sampler_BackTex);

        struct VertexInput
        {
            float4 position : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct VertexOutput
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float4 worldPos : TEXCOORD1;
        };

        ENDHLSL
         Pass
        {                    
        //Stencil
        //    {
        //      Ref 0
        //      Comp Equal
        //      Pass incrWrap
        //      Fail keep
        //    }

           HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag


           VertexOutput vert(VertexInput i)
           {
             VertexOutput o;
             o.pos=TransformObjectToHClip(i.position.xyz);
             o.uv=i.uv;
             o.worldPos = mul(unity_ObjectToWorld, i.position.xyzw);
             return o;
           }

#if _NOISEANM
           float hash(float3 p)  
            {
                return frac(sin(dot(p,float3(71.53,13.91,43.63)))*137935.23);
            }
            float noiseUSE (in float2 p , float Scale)
            {
                p *=Scale;
                float2 h = frac(p);
                h = h*h*(3.-2.*h);
                p=floor(p);
                float v1 = hash(float3(p,0.0));
                float v2 = hash(float3(p.x+1.0,p.y,0.0));
                float v3 = hash(float3(p.x,p.y+1.0,0.0));
                float v4 = hash(float3(p+1.0,0.0));
                float k1 = lerp(v1,v2,h.x);
                float k2 = lerp(v3,v4,h.x);
                return lerp(k1,k2,h.y);
            }
#endif
           float4 frag(VertexOutput i) : SV_Target
           {
             float4 Light = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
            // float4 BackTex = SAMPLE_TEXTURE2D(_BackTex, sampler_BackTex, i.uv);
#if _NOISEANM
            Brightness *=max(noiseUSE(i.uv + _Time.y *_NoiseSpeed,0.3),0.4);
#endif
             Light.rgb += 1-Light.a;
             Light *= saturate(Light);
             Light *= _color * Brightness * 10;

           //  BackTex.rgb *= saturate(BackTex.a + Light);

           //  float4 LightColor = Light + _color * BackTex;

             return Light;
             //return BackTex.a;
           }

           ENDHLSL

        } 
        
        
    }
}