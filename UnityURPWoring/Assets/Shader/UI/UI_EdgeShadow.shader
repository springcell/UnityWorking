
Shader "Babu/UI/UI_EdgeShadow"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

[Toggle(_EDGEON)] _EdgeOn("Edge On", Float) = 1.0
        _OutlineSize("OutlineSize",Range(0,20) )=0.01
        _OutlineColor("OutlineColor",Color)=(0,0,0,0)

[Toggle(_SHADOWON)] _shadow("shadow ON", Float) = 1.0
        _tex_offset("shaodw_offset",Range(0,1) )=0.01
        _tex_offsetX("tex_offsetX",float)=0
        _tex_offsetY("tex_offsetY",float)=0
        _ShadowColor("shadow_color",Color)=(0,0,0,1)
        _UIScale("UIScale",Vector)= (1,1,1,1)

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend One OneMinusSrcAlpha
        ColorMask [_ColorMask]
HLSLINCLUDE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    CBUFFER_START(UnityPerMaterial)      
            float4 _Color;
            float4 _MainTex_ST;
			float2 _MainTex_TexelSize;
			float _OutlineSize;
			float4 _OutlineColor;
            float _tex_offset;
            float _tex_offsetX;
            float _tex_offsetY;
            float4 _UIScale;
            float4 _ShadowColor;
    CBUFFER_END

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float4 _TextureSampleAdd;
        float4 _ClipRect;
        float _UIMaskSoftnessX;
        float _UIMaskSoftnessY; 
        
    ENDHLSL

        Pass
        {
        Name "Default"
        Tags{ "LightMode"="UniversalForward" }
        
        HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP
            #pragma multi_compile_local _ _EDGEON

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                float4  mask : TEXCOORD2;
            };


            

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                float4 vPosition = TransformObjectToHClip(v.vertex.xyz);
                OUT.worldPosition = v.vertex;
                OUT.vertex = vPosition;

                float2 pixelSize = vPosition.w;
                pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

                float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
                float2 maskUV = (v.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                OUT.mask = float4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));

                OUT.color = v.color * _Color;
                return OUT;
            }


            float sobel(float2 uv,TEXTURE2D_PARAM(tex, samplertex)) {
				float2 delta = _MainTex_TexelSize * _OutlineSize;
				float hr = 0;
				float4 vt = float4(0, 0, 0, 0);
				hr += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(-1.0, -1.0) * delta)).a *  1.0;
				hr += SAMPLE_TEXTURE2D(tex,samplertex, (uv + float2(0.0, -1.0) * delta)).a*  0.0;
				hr += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(1.0, -1.0) * delta)).a * -1.0;
				hr += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(-1.0, 0.0) * delta)).a *  2.0;
				hr += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(0.0, 0.0) * delta)).a *  0.0;
				hr += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(1.0, 0.0) * delta)).a * -2.0;
				hr += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(-1.0, 1.0) * delta)).a *  1.0;
				hr += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(0.0, 1.0) * delta)).a *  0.0;
				hr += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(1.0, 1.0) * delta)).a * -1.0;
				vt += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(-1.0, -1.0) * delta)).a *  1.0;
				vt += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(0.0, -1.0) * delta)).a *  2.0;
				vt += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(1.0, -1.0) * delta)).a *  1.0;
				vt += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(-1.0, 0.0) * delta)).a *  0.0;
				vt += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(0.0, 0.0) * delta)).a *  0.0;
				vt += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(1.0, 0.0) * delta)).a *  0.0;
				vt += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(-1.0, 1.0) * delta)).a * -1.0;
				vt += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(0.0, 1.0) * delta)).a * -2.0;
				vt += SAMPLE_TEXTURE2D(tex, samplertex, (uv + float2(1.0, 1.0) * delta)).a * -1.0;
				return sqrt(hr * hr + vt * vt).x;
			}

            float4 frag(v2f IN) : SV_Target
            {
                half4 color =  SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,IN.texcoord);
                
            #if _EDGEON
				float outline  = saturate((sobel(IN.texcoord,_MainTex, sampler_MainTex) + color.a) * 2);
                float4 OutlineColor = _OutlineColor * outline;

                color.rgb = lerp(OutlineColor.rgb, color.rgb * 1, color.a);
                color = saturate(color);
                color.a += OutlineColor.a;
                color.a = saturate(color.a);
            
            #endif
                            
                color += _TextureSampleAdd;
                color *= IN.color;

                #ifdef UNITY_UI_CLIP_RECT
                half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
                color.a *= m.x * m.y;
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif
                color.rgb *= color.a;
                
                return color;
            }
        ENDHLSL
        }

    Pass
        {
            Name "Shadow"
            //Tags{ "LightMode"="SRPDefaultUnlit" }
             Tags{ "LightMode"="SRPDefaultUnlit" }
             
             
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma shader_feature_local _SHADOWON

             
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color    : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color    : COLOR;
            };


            v2f vert (appdata v)
            {
                v2f o;

                // float4 screenPos1 = abs(UNITY_MATRIX_MV[0].xyzw);
                // float4 screenPos2 = v.vertex;
                // float Distance =distance(screenPos1.xy / screenPos1.w, screenPos2.xy / screenPos2.w);

                // float estimatedScale =Distance/ length(screenPos1 - screenPos2);

             #if _SHADOWON 
                v.vertex.xy += float2(_tex_offsetX,_tex_offsetY) * _UIScale.xy;
            #endif
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                o.color = v.color * _Color;

                // float2 pixelSize = v.vertex.w;
                // pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));
                // float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
                // o.mask = float4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));
                return o;
            }

      #if _SHADOWON      
            float Blur(TEXTURE2D_PARAM(_MainTex, sampler_MainTex), float2 uv,float texoffset)
            {
            float2 tex_offset = _MainTex_TexelSize * texoffset * 10;
            half color =
                    SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,uv).a
                    +SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + tex_offset *  float2(-1 ,  0)).a
                    +SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,uv + tex_offset *  float2( 1,  0)).a
                    +SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,uv + tex_offset *  float2( 0, -1)).a
                    +SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,uv + tex_offset *  float2( 0,  1)).a
                    +SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,uv + tex_offset *  float2(-1, -1)).a
                    +SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,uv + tex_offset *  float2(-1,  1)).a
                    +SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,uv + tex_offset *  float2( 1, -1)).a
                    +SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,uv + tex_offset *  float2( 1,  1)).a;

            color /= 9;

            return color.x;
            }
    #endif
            float4 frag (v2f i) : SV_Target
            {



                
#if _SHADOWON
                half Shadow = Blur(_MainTex, sampler_MainTex,i.uv,_tex_offset);
                half4 ShadowColor= _ShadowColor *Shadow * i.color;
                half4 FianlColor =  ShadowColor;
#else
                half4 FianlColor = 0;
#endif

                // #ifdef UNITY_UI_CLIP_RECT
              
                // half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(i.mask.xy)) * i.mask.zw);
                // FianlColor.a *= i.mask.;
                // #endif

                // #ifdef UNITY_UI_ALPHACLIP
                // clip (FianlColor.a - 0.001);
                // #endif
      
              return FianlColor;
            }

            ENDHLSL
        }
    }
}
