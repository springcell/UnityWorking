// by lujun 16519579@qq,com

Shader "Babu/ScreenSpace/Decal"
{
    Properties
    {
        [Header(Basic)]
        [MainTexture]_MainTex("Texture", 2D) = "white" {}
        [MainColor][HDR]_Color("_Color (default = 1,1,1,1)", Color) = (1,1,1,1)

        [Header(footprint)]
        _parallax  ("parallax ", 2D) = "white" {}
        _PARALLAX_INTENSITY  ("PARALLAX_INTENSITY ", Range(-1,1)) = 1
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _BaseColor2("_BaseColor2",Color)=(1,1,1,1)
        [Toggle(FOOTPAINT)]_Footprint("_Footprint", float) =0
        [Toggle(SHADOWS)] _SHADOWS("Footprint SHADOWS", Float) = 0.0
        
        [Header(Prevent Side Stretching)]
        [Toggle(_ProjectionAngleDiscardEnable)] _ProjectionAngleDiscardEnable("_ProjectionAngleDiscardEnable", float) = 0   //0 = off
        _ProjectionAngleDiscardThreshold("_ProjectionAngleDiscardThreshold", range(-1,1)) = 0
        
        [Header(Alpha remap(extra alpha control))]
        _AlphaRemap("_AlphaRemap", vector) = (1,0,0,0)
        
        [Header(Mul alpha to rgb)]
        [Toggle]_MulAlphaToRGB("_MulAlphaToRGB (default = off)", Float) = 0

        [Toggle(_UNITYFOGENABLE)]_UnityFogEnable("UnityFogEnable", Float) = 1
        
        [Header(Stencil Masking)]
        _StencilRef("_StencilRef", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("_StencilComp", Float) = 0 //0 = disable

        [Header(Cull)]
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("_Cull", Float) = 1 //1 = Front

        [Header(ZTest)]
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("_ZTest", Float) = 0 //0 = disable

        [Header(Blending)]
        [Enum(UnityEngine.Rendering.BlendMode)]_DecalSrcBlend("_DecalSrcBlend", Int) = 5 // 5 = SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)]_DecalDstBlend("_DecalDstBlend", Int) = 10 // 10 = OneMinusSrcAlpha
    }
    SubShader
    {
        Tags { "RenderType" = "Overlay" "Queue" = "Transparent-499" "DisableBatching" = "True" }

        Pass
        {
            Stencil
            {
                Ref[_StencilRef]
                Comp[_StencilComp]
            }

            Cull[_Cull]
            ZTest[_ZTest]

            ZWrite off
            Blend[_DecalSrcBlend][_DecalDstBlend]
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
    
            #pragma multi_compile_fog
            #pragma shader_feature_local _UNITYFOGENABLE
            #pragma shader_feature_local FOOTPAINT
            #pragma shader_feature_local SHADOWS

            #pragma target 3.0
            #pragma shader_feature_local_fragment _ProjectionAngleDiscardEnable
            
             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

   #if FOOTPAINT         
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
          //  #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
    #endif

            struct Attributes
            {
                float3 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float4 viewRayOS : TEXCOORD1; // xyz: viewRayOS, w: extra copy of positionVS.z 
                float4 cameraPosOS : TEXCOORD2;
                half2 fogFactor : TEXCOORD3;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;

            CBUFFER_START(UnityPerMaterial)               
                float4 _MainTex_ST;
                float _ProjectionAngleDiscardThreshold;
                half4 _Color;
                half2 _AlphaRemap;
                half _MulAlphaToRGB;

                float4 _BaseColor;
                float4 _BaseColor2;
                float4 _parallax_TexelSize;
                
                float _PARALLAX_INTENSITY;
            // float4 _iMouse;
                
            CBUFFER_END

                TEXTURE2D (_parallax);
                SAMPLER(sampler_parallax);


            Varyings vert(Attributes v)
            {
                Varyings o = (Varyings)0;
                
                VertexPositionInputs vertexPositionInput = GetVertexPositionInputs(v.positionOS);
                o.positionCS = vertexPositionInput.positionCS;
                
                o.screenPos = ComputeScreenPos(o.positionCS);
                
                float3 viewRay = vertexPositionInput.positionVS;
                o.viewRayOS.w = viewRay.z;  //垂直方向的距离
                viewRay *= -1;
                float4x4 ViewToObjectMatrix = mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V);
                o.viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, viewRay);
                o.cameraPosOS.xyz = mul(ViewToObjectMatrix, float4(0,0,0,1)).xyz;
        #if _UNITYFOGENABLE
                o.fogFactor = float2(ComputeFogFactor(v.positionOS.z), 1);   
        #else
                o.fogFactor = 0;   
        #endif
                return o;
            }

                float3 reinhard(float3 x)
                {
                    return x / (1.0 + x);
                }

            half4 frag(Varyings i) : SV_Target
            {
                i.viewRayOS.xyz /= i.viewRayOS.w;
                float2 screenSpaceUV = i.screenPos.xy / i.screenPos.w;
                float sceneRawDepth = tex2D(_CameraDepthTexture, screenSpaceUV).r;
                float3 decalSpaceScenePos;
                // perspective camera
                float sceneDepthVS = LinearEyeDepth(sceneRawDepth,_ZBufferParams);
                decalSpaceScenePos = i.cameraPosOS.xyz + i.viewRayOS.xyz * sceneDepthVS;
                // [-0.5,0.5] -> [0,1]
                float2 decalSpaceUV = decalSpaceScenePos.xy + 0.5;
                float shouldClip = 0;
#if _ProjectionAngleDiscardEnable
                float3 decalSpaceHardNormal = normalize(cross(ddx(decalSpaceScenePos), ddy(decalSpaceScenePos)));
                shouldClip = decalSpaceHardNormal.z > _ProjectionAngleDiscardThreshold ? 0 : 1;
#endif
                clip(0.5 - abs(decalSpaceScenePos) - shouldClip);
                // sample the decal texture
                float2 uv = decalSpaceUV.xy * _MainTex_ST.xy + _MainTex_ST.zw;
#if FOOTPAINT // =========脚印
                half3 sceneColor = SampleSceneColor(screenSpaceUV);
                            float2 cam = 0;
                // Heightmap sample
                float heightmap = SAMPLE_TEXTURE2D(_parallax, sampler_parallax, uv + cam).r;
                // Tangent space view direction

                float3 viewDir_ts = normalize(i.viewRayOS.xyz);
                // Parallax
                float2 parallax = viewDir_ts.xz * viewDir_ts.y * (heightmap - 0.5) * _PARALLAX_INTENSITY;
                // New texture with parallax
                float tex = SAMPLE_TEXTURE2D(_parallax, sampler_parallax, uv - parallax + cam).r;
                
                UnityTexture2D Texture_TexelSize = UnityBuildTexture2DStructNoScale(_parallax);
                float2 tex_res = _parallax_TexelSize.zw;
                
                // Lighting
                float tex_x1 = SAMPLE_TEXTURE2D(_parallax, sampler_parallax, uv - parallax + cam + float2(1.0/tex_res.x, 0.0)).r;
                float tex_y1 = SAMPLE_TEXTURE2D(_parallax, sampler_parallax, uv - parallax + cam + float2(0.0, 1.0/tex_res.y)).r;
                
                float tex_ddx = tex - tex_x1;
                float tex_ddy = tex - tex_y1;
                
                float3 normal = normalize(float3(tex_ddx, tex_ddy, 0.004));

                Light mainLight = GetMainLight();
                float3 lightDir =  mainLight.direction;

                float3 light_direct = max(0.0, dot(normal, lightDir)) * _BaseColor.rgb;

                #ifdef SHADOWS
                float tex_shadow = SAMPLE_TEXTURE2D(_parallax, sampler_parallax, uv + cam - parallax + lightDir.xy * lightDir.z * heightmap *  0.5).r;
                float shadow = pow(max(heightmap - tex_shadow, 0.0), 0.25);
                #else
                float shadow = 1.0;
                #endif

                    
                float3 fake_gi = tex * _BaseColor2.rgb * 10;

                half4 col = tex2D(_MainTex, uv);
                
                col.rgb = light_direct * 10.0 * shadow + fake_gi;
                col.rgb = reinhard(col.rgb);

                col.rgb *= pow(abs(sin(uv.x * 3.141592) * sin(uv.y * 3.141592)), 0.1) + _BaseColor2.rgb;
            //  col *= baseTex.a;

                col.rgb *=sceneColor;

#else
                half4 col = tex2D(_MainTex, uv);
#endif
                
                col *= _Color;// tint color
                col.a = saturate(col.a * _AlphaRemap.x + _AlphaRemap.y);// alpha remap MAD
                col.rgb *= lerp(1, col.a, _MulAlphaToRGB);
#if _UNITYFOGENABLE
                col.rgb = MixFog(col.rgb, i.fogFactor.x);
#endif
                return col;
            }
            ENDHLSL
        }
    }
}