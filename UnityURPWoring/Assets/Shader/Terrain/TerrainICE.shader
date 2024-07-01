// by lujun 16519579@qq,com
Shader "Babu/Terrain/TerrainICE"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("BumpMap", 2D) = "bump" {}
        _BRDF ("BRDF", 2D) = "black" {}
        _Bump1Scale ("BumpScale", float) = 0
        _Roughness("roughness",Range(0,1)) =0.6
        _Metallic("Metallic",Range(0,1)) =0.6
        _ParallaxMap("Parallax map", 2D) = "white" {}
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        //_Iterations("Iterations", Range(1,20)) = 5
        _OffsetScale("Offset scale", float) = 0

         [Toggle(_CRACK)] _Crack("Ice_Crack", Float) = 0

         _IceIn("IceIn",Range(0,1)) =0.3
         //_IceInColor("IceInColor",Color)=(1,1,1,1)
         _IceInTransparent("IceInTransparent",Range(0,1)) =1
         _distanceDepth("distanceDepth",Range(0,10)) =2.25
         _Alpha("Alpha",Range(0,1)) =2.25

         _Mask("Mask", 2D) = "white" {}
         [Enum(R, 0, G, 1, B, 2, A, 3)] _MaskChannel ("MaskChannel", int) = 0
    }
    SubShader
    {

        Tags { "RenderType"="Opaque"  "Queue"="Transparent" }
        Blend One OneMinusSrcAlpha
 
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        #pragma shader_feature _ _CRACK
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile_fog

        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        //float4 _IceInColor;
        float _OffsetScale;
        //float _Iterations;
        float _Bump1Scale;
        float _Roughness;
        float _Metallic;
        float _Alpha;
        float _distanceDepth;
        float _IceIn;
        float _IceInTransparent;
        float4 _MainTex_ST;

        int _MaskChannel;
        CBUFFER_END

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_ParallaxMap);
        SAMPLER(sampler_ParallaxMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_BRDF);
        SAMPLER(sampler_BRDF);
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
            float4 worldPos : TEXCOORD1;
            float3 normal : TEXCOORD2;
            float3 bitangent : TEXCOORD3;
            float3 tangent : TEXCOORD4;
            float3 viewDirTangent : TEXCOORD5;
            float3 viewDir:TEXCOORD6;
            float3x3 tangentMatrix:TEXCOORD7;
            DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 10);
             float4 screenPos : TEXCOORD11;
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
         
           float3 iblSpecular(float3 viewDir,float3 normal)
            {
                float perceptualRoughness =_Roughness*(1.7-0.7*_Roughness);
                float mip_roughness = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness);
                float3 reflectVec = reflect(-viewDir,normal);
                float mip = mip_roughness * UNITY_SPECCUBE_LOD_STEPS;
	            float4 rr = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVec, mip);
                float3 iblSpecular = DecodeHDREnvironment(rr, unity_SpecCube0_HDR);
               // iblSpecular *= s.reflectivity;
	            return iblSpecular;
            }

           //float3 LightDirectSurface(float3 diffuseColor,float3 normal,float3 viewDir,float3 lightDir, float3 lightColor )
           // {
           //     float roughnessfix = max(_roughness, 0.08);
	          //  float roughness = roughnessfix * roughnessfix;

           //     roughness =roughnessfix;

           //     float3 Sufcolor = diffuseColor;
	          //  float3 halfDir = SafeNormalize(lightDir + viewDir);
	          //  float nh = saturate(dot(normal, halfDir));
           //     float lh = saturate(dot(lightDir, halfDir));
	          //  float d = nh * nh * (roughness * roughness - 1.0) + 1.00001;
	          //  float normalizationTerm =roughness * 4.0 + 2.0;
	          //  float specularTerm = roughness * roughness;
	          //  specularTerm /= (d * d) * max(0.1, lh * lh) * normalizationTerm;

           //     float3 colorA =  specularTerm * _specular * Sufcolor; 

           //     return colorA * lightColor;

           // }

           //float G1V ( float dotNV, float k ) {
	          //  return 1.0 / (dotNV*(1.0 - k) + k);
           // }
           //float3 LightDirectSurface(float3 diffuseColor,float3 normal,float3 viewDir,float3 lightDir, float3 lightColor)
           // {
           //     float roughness = max(_roughness,0.04);
           //     float F0 = 0.1;
           //      F0=lerp(F0,diffuseColor,_specular);

           //     float3 N = normal;
           //     float3 H = SafeNormalize(lightDir + viewDir);
           //     float3 V = viewDir;
           //     float3 L = lightDir;
    	      //  float alpha = roughness*roughness;


	          //  float dotNL = clamp (dot (N, L), 0.0, 1.0);
	          //  float dotNV = clamp (dot (N, V), 0.0, 1.0);
	          //  float dotNH = clamp (dot (N, H), 0.0, 1.0);
	          //  float dotLH = clamp (dot (L, H), 0.0, 1.0);

           //     float alphaSqr = alpha*alpha;
	          //  float denom = dotNH * dotNH *(alphaSqr - 1.0) + 1.0;
	          //  float D = alphaSqr / (PI * denom * denom);

           //     float k = alpha / 2.0;
	          //  float vis = G1V (dotNL, k) * G1V (dotNV, k);

           //     float dotLH5 = pow (1.0 - dotLH, 5.0);
	          //  float F = F0 + (1.0 - F0)*(dotLH5);

           //      diffuseColor =  diffuseColor * D * F * vis;
                

           //     return diffuseColor * lightColor;

           // }
                float3 FresnelSchlick(float cosTheta,float3 F0)
            {
                return F0+(1.0-F0)*pow(1.0-cosTheta,5.0);
            }
             float DistributionGGX(float3 N,float3 H,float roughness)
            {
                float a2=roughness*roughness;
                a2=a2*a2;
                float NdotH=saturate(dot(N,H));
                float NdotH2=NdotH*NdotH;

                float denom=(NdotH2*(a2-1.0)+1.0);
                denom=PI*denom*denom;
                return a2/denom;
            }

            float GeometrySchlickGGX(float NdotV,float roughness)
            {

                float r=roughness+1.0;
                float k=r*r/8.0;

                float denom=NdotV*(1.0-k)+k;
                return NdotV/denom;
            }

            float GeometrySmith(float3 N,float3 V,float3 L,float roughness)
            {
                float NdotV=saturate(dot(N,V));
                float NdotL=saturate(dot(N,L));
                float ggx1=GeometrySchlickGGX(NdotV,roughness);
                float ggx2=GeometrySchlickGGX(NdotL,roughness);

                return ggx1*ggx2;
            }


           VertexOutput vert(VertexInput i)
           {
             VertexOutput o;

             o.pos=TransformObjectToHClip(i.position.xyz);
             o.uv= TRANSFORM_TEX(i.uv, _MainTex);
             o.MaskUV= i.uv;
             o.worldPos = mul(unity_ObjectToWorld, i.position.xyzw);
             o.normal = TransformObjectToWorldNormal(i.normal.xyz);
             o.tangent = normalize(mul(unity_ObjectToWorld, float4(i.tangent.xyz, 0.0)).xyz);
             o.bitangent = normalize(cross(o.normal, o.tangent) * i.tangent.w);
             o.tangentMatrix = float3x3(o.tangent,o.bitangent,o.normal);

             o.viewDir =normalize(_WorldSpaceCameraPos.xyz -  o.worldPos.xyz);
             o.viewDirTangent = mul(o.tangentMatrix, o.viewDir);

            o.screenPos = ComputeScreenPos(o.pos);

            OUTPUT_LIGHTMAP_UV(i.uv1, unity_LightmapST, o.lightmapUV);
            OUTPUT_SH(i.normal.xyz, o.vertexSH);

             //#if defined(_FOG_FRAGMENT)
             //        half fogFactor = 0;
             //#else
             //        half fogFactor = ComputeFogFactor(o.pos.z);
             //#endif
            o.fogFactor = ComputeFogFactor(o.pos.z);
             return o;
           }

           float4 frag(VertexOutput i) : SV_Target
           {
            float4 baseTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
            float4 BumpMap = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, i.uv);

             float4 shadowCoord = TransformWorldToShadowCoord(i.worldPos.xyz );
              Light mainLight = GetMainLight(shadowCoord);
             float3 lightDir = mainLight.direction;
             float3 lightColor = mainLight.color;
             float Shadow = mainLight.shadowAttenuation;
             float3 viewDir = i.viewDir;
             baseTex.rgb *= _BaseColor.rgb * Shadow;
             float4 parallax =  SAMPLE_TEXTURE2D(_ParallaxMap, sampler_ParallaxMap,i.uv);

#if _CRACK
            //float4 parallax = 0;
            //_OffsetScale *=0.01;
            //for (int j = 0; j < _Iterations; j ++) {
            //    float ratio = (float) j / _Iterations;
            //    parallax +=  SAMPLE_TEXTURE2D(_ParallaxMap, sampler_ParallaxMap,i.uv + lerp(0, _OffsetScale, ratio) * normalize(i.viewDirTangent.xy)) * lerp(1, 0, ratio);
            //}
            //parallax /= _Iterations;
            //baseTex += parallax * 2;
           
            _OffsetScale *=0.01;
            int Iterations = 6;
            //01
            int j = 1;
            float ratio = (float) j / Iterations;
            parallax +=  SAMPLE_TEXTURE2D(_ParallaxMap, sampler_ParallaxMap,i.uv + lerp(0, _OffsetScale, ratio) * normalize(i.viewDirTangent.xy)) * lerp(1, 0, ratio);
            //02
             j = 2;
            ratio = (float) j / Iterations;
            parallax +=  SAMPLE_TEXTURE2D(_ParallaxMap, sampler_ParallaxMap,i.uv + lerp(0, _OffsetScale, ratio) * normalize(i.viewDirTangent.xy)) * lerp(1, 0, ratio);
            //03
             j = 3;
            ratio = (float) j / Iterations;
            parallax +=  SAMPLE_TEXTURE2D(_ParallaxMap, sampler_ParallaxMap,i.uv + lerp(0, _OffsetScale, ratio) * normalize(i.viewDirTangent.xy)) * lerp(1, 0, ratio);
            //04
             j = 4;
            ratio = (float) j / Iterations;
            parallax +=  SAMPLE_TEXTURE2D(_ParallaxMap, sampler_ParallaxMap,i.uv + lerp(0, _OffsetScale, ratio) * normalize(i.viewDirTangent.xy)) * lerp(1, 0, ratio);
            //05
             j = 5;
            ratio = (float) j / Iterations;
            parallax +=  SAMPLE_TEXTURE2D(_ParallaxMap, sampler_ParallaxMap,i.uv + lerp(0, _OffsetScale, ratio) * normalize(i.viewDirTangent.xy)) * lerp(1, 0, ratio);
            //06
             j = 6;
            ratio = (float) j / Iterations;
            parallax +=  SAMPLE_TEXTURE2D(_ParallaxMap, sampler_ParallaxMap,i.uv + lerp(0, _OffsetScale, ratio) * normalize(i.viewDirTangent.xy)) * lerp(1, 0, ratio);
            
            parallax /= Iterations;
            

#endif
              baseTex += parallax ;
              half3 normalmap= UnpackNormalScale(BumpMap, _Bump1Scale);
              float3 NormalFix = normalize(mul(normalmap, i.tangentMatrix));

              float3 iblDiffuse = SAMPLE_GI(i.lightmapUV, i.vertexSH, NormalFix);

            //  baseTex.rgb *= iblDiffuse.rgb;
              float4 screenPosNorm = i.screenPos.xyzw / i.screenPos.w;
              float screenDepth = LinearEyeDepth(SampleSceneDepth(screenPosNorm.xy + NormalFix.xz  * _IceIn),_ZBufferParams);
              float DepthMask = abs( ( screenDepth - LinearEyeDepth( screenPosNorm.z,_ZBufferParams ) ) /(_distanceDepth *_WorldSpaceCameraPos.z *0.1));

              DepthMask = saturate(DepthMask);

              half3 ScenesColor = SampleSceneColor(screenPosNorm.xy + NormalFix.xz  * _IceIn) ; 

              // IBL
              float3 lightColorIBLcolor = lerp(_GlossyEnvironmentColor.r, lightColor,0.5);

               // reflection 
              float3 refl = iblSpecular(viewDir,NormalFix);
            // PBR ============================================================
             float3 halfDir=normalize(lightDir+viewDir);
             half3 albedo=lightColor*baseTex.rgb * _BaseColor.rgb;
             float3 F0=float3(0.01,0.01,0.01);

             float3 metallic=(float3)_Metallic;
             F0=lerp(F0,albedo,metallic);

             float3 Lo=float3(0,0,0);

             float roughness=1- _Roughness;

            float NDF=DistributionGGX(NormalFix,halfDir,roughness);
            float G=GeometrySmith(NormalFix,viewDir,lightDir,roughness);
            float3 F=FresnelSchlick(clamp(dot(halfDir,viewDir),0,1),F0);
                           
            float3 nom=NDF*G*F;
            float3 denom=4*max(dot(NormalFix,viewDir),0)*saturate(dot(NormalFix,lightDir));
            float3 specular=nom/max(denom,0.001);//max±ÜÃâdenomÎªÁã
                            float3 Ks=F;
            float3 Kd=1-Ks;
            Kd*=1.0-metallic;
            float NdotL=max(dot(NormalFix,lightDir),0.0);
            Lo=(Kd*albedo+specular)*NdotL;//

            half3 irradiance=iblDiffuse;

            half3 ambient=_GlossyEnvironmentColor.rgb;
            half3 diffuse=max(half3(0,0,0),ambient+irradiance)*albedo;

            half3 preColor=refl;

            half NdotV=saturate(dot(NormalFix,viewDir));
            half2 brdf=SAMPLE_TEXTURE2D(_BRDF,sampler_BRDF,half2(lerp(0, 0.99,NdotV),lerp(0, 0.99,_Roughness))).rg +0.2;

            specular=preColor *(F*brdf.x+brdf.y);

            Lo+=Kd*diffuse+specular;

            //===============================================================
           // float3 SurfaceLightColor = LightDirectSurface(diffuseColor.rgb,NormalFix,viewDir,lightDir,lightColorIBLcolor);

            float4 FianlColor =0;
            FianlColor += float4(lerp(ScenesColor.rgb,Lo.rgb,DepthMask * _IceInTransparent),1) ;
             
          // FianlColor.rgb = 0;
           float Alpha =saturate(DepthMask + _Alpha);

           float FogZ = i.pos.z * i.pos.w;
           float fogFactor = ComputeFogFactor(FogZ);

            float3 FianlColor2 = MixFog(FianlColor.rgb, fogFactor);

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