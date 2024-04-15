Shader "URP/ICE"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("BumpMap", 2D) = "bump" {}
        _Bump1Scale ("BumpScale", float) = 0
        _roughness("roughness",Range(0,1)) =0.6
        _specular("specular",Range(0,1)) =0.6
        _ParallaxMap("Parallax map", 2D) = "white" {}
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _Iterations("Iterations", Range(1,20)) = 5
        _OffsetScale("Offset scale", float) = 0

         [Toggle(_CRACK)] _Crack("Ice_Crack", Float) = 0

         _IceIn("IceIn",Range(0,1)) =0.3
         _IceInColor("IceInColor",Color)=(1,1,1,1)
         _distanceDepth("distanceDepth",Range(0,10)) =2.25
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"  "Queue"="Transparent" }
        LOD 100
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        #pragma shader_feature _ _CRACK

        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        float4 _MainTex_ST;
        float4 _IceInColor;
        float _OffsetScale;
        float _Iterations;
        float _Bump1Scale;
        float _roughness;
        float _specular;
        float _distanceDepth;
        float _IceIn;
        CBUFFER_END

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_ParallaxMap);
        SAMPLER(sampler_ParallaxMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);

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
            float4 worldPos : TEXCOORD1;
            float3 normal : TEXCOORD2;
            float3 bitangent : TEXCOORD3;
            float3 tangent : TEXCOORD4;
            float3 viewDirTangent : TEXCOORD5;
            float3 viewDir:TEXCOORD6;
            float3x3 tangentMatrix:TEXCOORD7;
            DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 10);
             float4 screenPos : TEXCOORD11;

        };

        ENDHLSL

        Pass
        {

           HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag

           float3 iblSpecular(float3 viewDir,float3 normal)
            {
                float perceptualRoughness = max(_specular, 0.08);
                float mip_roughness = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness);
                float3 reflectVec = reflect(-viewDir,normal);
                float mip = mip_roughness * UNITY_SPECCUBE_LOD_STEPS;
	            float4 rr = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVec, mip);
                float3 iblSpecular = DecodeHDREnvironment(rr, unity_SpecCube0_HDR);
               // iblSpecular *= s.reflectivity;
	            return iblSpecular;
            }

           float3 LightDirectSurface(float3 diffuseColor,float3 normal,float3 viewDir,float3 lightDir, float3 lightColor )
            {
                float roughnessfix = max(_roughness, 0.08);
	            float roughness = roughnessfix * roughnessfix;

                float3 Sufcolor = diffuseColor;
	            float3 halfDir = SafeNormalize(lightDir + viewDir);
	            float nh = saturate(dot(normal, halfDir));
                float lh = saturate(dot(lightDir, halfDir));
	            float d = nh * nh * (roughness * roughness - 1.0) + 1.00001;
	            float normalizationTerm =roughness * 4.0 + 2.0;
	            float specularTerm = roughness * roughness;
	            specularTerm /= (d * d) * max(0.1, lh * lh) * normalizationTerm;
               // float3 colorA = pow(nh , exp2(_specular *10));  
                float3 colorA =  specularTerm * _specular * Sufcolor; 

                return colorA * lightColor;

            }

           VertexOutput vert(VertexInput i)
           {
             VertexOutput o;

             o.pos=TransformObjectToHClip(i.position.xyz);
             o.uv= TRANSFORM_TEX(i.uv, _MainTex);
             o.worldPos = mul(unity_ObjectToWorld, i.position.xyzw);
             o.normal = TransformObjectToWorldNormal(i.normal.xyz);
             o.tangent = normalize(mul(unity_ObjectToWorld, float4(i.tangent.xyz, 0.0)).xyz);
             o.bitangent = normalize(cross(o.normal, o.tangent) * i.tangent.w);
             o.tangentMatrix = float3x3(o.tangent,o.bitangent,o.normal);

             o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldPos.xyz);
             o.viewDirTangent = mul(o.tangentMatrix, o.viewDir);

            o.screenPos = ComputeScreenPos(o.pos);

            OUTPUT_LIGHTMAP_UV(i.uv1, unity_LightmapST, o.lightmapUV);
            OUTPUT_SH(i.normal.xyz, o.vertexSH);
             return o;
           }

           float4 frag(VertexOutput i) : SV_Target
           {
            float4 baseTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
            float4 BumpMap = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, i.uv);
#if _CRACK
            float4 parallax = 0;
            _OffsetScale *=0.01;
            for (int j = 0; j < _Iterations; j ++) {
                float ratio = (float) j / _Iterations;
                parallax +=  SAMPLE_TEXTURE2D(_ParallaxMap, sampler_ParallaxMap,i.uv + lerp(0, _OffsetScale, ratio) * normalize(i.viewDirTangent.xy)) * lerp(1, 0, ratio);
            }
            parallax /= _Iterations;
            baseTex += parallax;
#endif

              Light mainLight = GetMainLight();
             float3 lightDir = mainLight.direction;
             float3 lightColor = mainLight.color;
             float3 viewDir = i.viewDir;
           

              half3 normalmap= UnpackNormalScale(BumpMap, _Bump1Scale);
              float3 NormalFix = normalize(mul(normalmap, i.tangentMatrix));

              float3 iblDiffuse = SAMPLE_GI(i.lightmapUV, i.vertexSH, NormalFix);

              baseTex.rgb *= iblDiffuse.rgb;

               float4 screenPosNorm = i.screenPos.xyzw / i.screenPos.w;
              float screenDepth = LinearEyeDepth(SampleSceneDepth(screenPosNorm.xy),_ZBufferParams);
              float DepthMask = abs( ( screenDepth - LinearEyeDepth( screenPosNorm.z,_ZBufferParams ) ) /_distanceDepth *0.01);

              DepthMask = saturate(DepthMask);

              half3 ScenesColor = SampleSceneColor(screenPosNorm.xy) * _IceInColor.rgb; 

              float3 IblColor = iblSpecular(viewDir,NormalFix);


              lightColor += _GlossyEnvironmentColor.rgb;

              float3 SurfaceLightColor = LightDirectSurface(baseTex.rgb,NormalFix,viewDir,lightDir,lightColor);

              float4 FianlColor = float4(lerp(ScenesColor.rgb,SurfaceLightColor.rgb,DepthMask),1);
             
            //  FianlColor.rgb = lightColor;
              FianlColor.rgb +=IblColor;
               FianlColor.rgb *= min(DepthMask +_IceIn,1) ;
           // return float4(FianlColor,1);
             return FianlColor;
           }



           ENDHLSL


        }   
        
    }
}