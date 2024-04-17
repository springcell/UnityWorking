// by lujun 16519579@qq,com

Shader "Spine/BaBu/2DSpriteShadow"
{
    Properties
    {
		 [MainTexture]_MainTex ("Sprite Texture", 2D) = "white" {}
		 _LightTex ("LightTex", 2D) = "white" {}
		 _Color ("Tint", Color) = (1,1,1,1)
		// [HDR]_LightColor ("LightColor", Color) = (1,1,1,1.1)
         _HDRBrightness("Brightness",Range(0,10)) = 1


     //[Toggle(_SHADOWMODE)]_ShadowMode("ShadowMode", Int) = 0
     //_ShadowAlpha("ShadowAlpha",Range(0,1)) = 1

     //_ShadowColor("ShadowColor",Color) = (0,0,0,0)
     //_ShadowOffset("ShadowOffset",vector) = (0,0,0,0)
      [Toggle(_STRAIGHT_ALPHA_INPUT)] _StraightAlphaInput("Straight Alpha Texture", Int) = 0
      [Toggle(_RTIMG)] RtImg("RtImg", Int) = 0
     [HideInInspector]_StencilRef("Stencil Reference", Float) = 1.0
      //_StencilRef("Stencil Reference", Float) = 1.0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comparison", Float) = 8 // Set to Always as default
		//[Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comparison", Float) = 8 // Set to Always as default
    // [HideInInspector][Enum(UnityEngine.Rendering.ColorWriteMask)]_ColorMask ("ColorMask", Float) = 15

    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
        LOD 100
    
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
        half4 _Color;
      //  half4 _LightColor;
       // half _ShadowAlpha;
      //  half _ShadowMode;
        half _HDRBrightness;
        CBUFFER_END
        
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_LightTex);
        SAMPLER(sampler_LightTex);

        half _Alpha;
     
        float4 _ShadowOffset;
        half4 _ShadowColor;

        struct VertexInput
        {
            float4 position : POSITION;
            float2 uv : TEXCOORD0;
            float4 vertexColor : COLOR;
        };

        struct VertexOutput
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float4 vertexColor : COLOR;
            float4 scrPos : TEXCOORD1;
        };

        ENDHLSL

        Pass
        {
            Name "Normal"
            Tags { "LightMode" = "UniversalForward" }

		Fog { Mode Off }
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		Lighting Off

		Stencil {
			Ref[_StencilRef]
			Comp[_StencilComp]
			Pass Keep
		}

          
           HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           #pragma shader_feature _ _STRAIGHT_ALPHA_INPUT
           #pragma shader_feature _ _RTIMG

           VertexOutput vert(VertexInput i)
           {
             VertexOutput o;
             o.pos=TransformObjectToHClip(i.position.xyz);
             o.uv=i.uv.xy;
             o.vertexColor = i.vertexColor;
             o.scrPos = ComputeScreenPos(o.pos);
             return o;
           }

           float4 frag(VertexOutput i) : SV_Target
           {
             float2 screenPos = i.scrPos.xy / i.scrPos.w;
             float4 baseTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
             float4 LightTex = SAMPLE_TEXTURE2D(_LightTex, sampler_LightTex, screenPos);     

          // #if defined(_STRAIGHT_ALPHA_INPUT)
				      baseTex.rgb *= baseTex.a;
		 //  #endif
         
            float Alpha =baseTex.a * i.vertexColor.a;
#if _RTIMG

            LightTex.rgb = min(max(pow(LightTex.rgb + 0.2,4),0.3),1.2);

            float3 finalColor =  baseTex.rgb * i.vertexColor.rgb * _Color.rgb + LightTex.rgb * baseTex.rgb * _HDRBrightness *0.5;
#else  
            float3 finalColor =  baseTex.rgb * i.vertexColor.rgb * _Color.rgb ;
#endif  
            half4 finalOut= half4 (finalColor.rgb,Alpha);

             return finalOut;
           }

           ENDHLSL

        }  
      //  Pass
      //  { 
      //  Name "Shadow"
      //    Tags { "LightMode" = "SRPDefaultUnlit" }  
      //      Blend SrcAlpha OneMinusSrcAlpha

      //      ZWrite Off
      //      Cull Off
      //      ColorMask [_ColorMask]
      //      Stencil
      //      {
      //        Ref 0
      //        Comp Equal
      //        Pass incrWrap
      //        Fail keep
      //      }
      //     HLSLPROGRAM
      //     #pragma vertex vert
      //     #pragma fragment frag
      //     #pragma shader_feature _ _SHADOWMODE

      //     VertexOutput vert(VertexInput i)
      //     {
      //       VertexOutput o;
      //  #ifdef _SHADOWMODE
      //      i.position.xy *=abs(_ShadowOffset.z);

      //       //o.pos=TransformObjectToHClip(i.position.xyz  + _ShadowOffset.xyz * float3(1,1,0));

      //      half3 lightDir = half3(0.5, 0.5, 0.5);
      //      lightDir.xyz = float3(_ShadowOffset.xy, 0);
      //      i.position.xy += lightDir.xy;
             
      //      float3 worldPos = TransformObjectToWorld(i.position.xyz);	
      //        o.pos = TransformWorldToHClip(worldPos);
      //  #else

      //      half3 lightDir = half3(0.5, 0.5, 0.5);

      //     // float3 worldPos = TransformObjectToWorld(i.position.xyz);	
      //      float3 worldPos = TransformObjectToWorld(i.position.xyz);	
				  // // float3 center = float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w);
				  //  float3 center = float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w);

      //        lightDir = normalize( _ShadowOffset.xyz);
      //        _ShadowOffset.w =1;
              
      //        float2 shadowPos = worldPos.xz - (worldPos.y - center.y) * lightDir.xz / lightDir.y; 
      //        worldPos.x = shadowPos.x;
      //        worldPos.y = (shadowPos.y - center.z) * cos(_ShadowOffset.w) * sin(_ShadowOffset.w) + center.y;
      //        worldPos.z = center.z;//(shadowPos.z - center.z) * cos(_Angle) * cos(_Angle) + center.z;
      //        o.pos = TransformWorldToHClip(worldPos);
      //#endif

      //       o.uv=i.uv;
      //       o.vertexColor = i.vertexColor;
      //       o.scrPos = ComputeScreenPos(o.pos);
      //       return o;
      //     }

      //     float4 frag(VertexOutput i) : SV_Target
      //     {
      //       float4 baseTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
      //       _ShadowAlpha =1;
      //       _ShadowAlpha *= _Alpha;
      //       #ifdef _SHADOWMODE
      //       clip(baseTex.a - 0.9);
      //       return half4(_ShadowColor.rgb,_ShadowAlpha)* i.vertexColor ;
      //       #else
      //       clip(baseTex.a - 0.8);
      //       return half4(_ShadowColor.rgb,_ShadowAlpha);
      //       #endif
      //     }

      //     ENDHLSL
      //  }  
          Pass
        {
            Name "2DLight"
            Tags { "LightMode" = "2dlight" }
            Blend DstColor Zero
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            struct lightOutput
            {
                float4 pos : SV_POSITION;
            };
            lightOutput vert(VertexInput i)
           {
             lightOutput o;
             o.pos=TransformObjectToHClip(i.position.xyz);
             return o;
           }

           float4 frag(lightOutput i) : SV_Target
            {
                return half4(0, 0, 0, 0); 
            }
            ENDHLSL
        }
   
    }
    
}