// by lujun 16519579@qq,com
Shader "Babu/BabuSimpleLit"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        [Toggle(_SPLATMAPON)] _SplatmapOn("Splatmap", Float) = 0.0
        [Toggle(_WINDON)] _WindOn("Wind", Float) = 0.0
        [NoScaleOffset]_Splatmap("Splatmap", 2D) = "white" {}
        [MainTexture] _BaseMap("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" {}
        [NoScaleOffset] _BumpMap("Normal Map", 2D) = "bump" {}
        _BaseMap1("Texture1", 2D) = "white" {}
        [NoScaleOffset]_BumpMap1("Normal Map1", 2D) = "bump" {}
        _BaseMap2("Texture2", 2D) = "white" {}
        [NoScaleOffset]_BumpMap2("Normal Map2", 2D) = "bump" {}
        _BaseMap3("Texture3", 2D) = "white" {} 
        [NoScaleOffset]_BumpMap3("Normal Map3", 2D) = "bump" {}
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)

        [HideInInspector]_Bump1Scale("Bump1Scale",Range(0,1)) = 1
        [HideInInspector]_Bump2Scale("Bump2Scale",Range(0,1)) = 1
        [HideInInspector]_Bump3Scale("Bump3Scale",Range(0,1)) = 1
        [HideInInspector]_Bump4Scale("Bump4Scale",Range(0,1)) = 1

        _Cutoff("Alpha Clipping", Range(0.0, 1.0)) = 0.5

        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _SpecGlossMap("Specular Map", 2D) = "white" {}
        _SmoothnessSource("Smoothness Source", Float) = 0.0
        _SpecularHighlights("Specular Highlights", Float) = 1.0

        [HideInInspector] _BumpScale("Scale", Float) = 1.0


        [HDR] _EmissionColor("Emission Color", Color) = (0,0,0)
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "white" {}

        // Blending state
        _Surface("__surface", Float) = 0.0
        _Blend("__blend", Float) = 0.0
        //_Cull("__cull", Float) = 2.0
        [HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_Cull ("剔除模式(CullMode)", Int) = 2
        [HideInInspector] [Toggle(_ALPHATEST_ON)] _AlphaClip("__clip", Float) = 0.0
         _SrcBlend("__src", Float) = 1.0
         _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0

        [Toggle(_RECEIVE_SHADOWS_OFF)] _ReceiveShadows("Receive Shadows", Float) = 1.0
        [Toggle(_SURFACE_TYPE_TRANSPARENT)] _Surfacetype("_Surfacetype", Float) = 1.0
        //[MaterialToggle]_Inhole ("In Hole", Float) = 0
        // Editmode props
        _QueueOffset("Queue offset", Float) = 0.0

        // ObsoleteProperties
        _MainTex("BaseMap", 2D) = "white" {}
        _Color("Base Color", Color) = (1, 1, 1, 1)
        //==================隨機色
         [Toggle(_RANDOMCOLOR)] _RandomColor("RandomColor", Float) = 0
        _RandomColorTint("Random Color", Color) = (1, 1, 1, 1)
        _RandomColorAmount("RandomColorAmount", float) = 1
        //======================
        _Shininess("Smoothness", Float) = 0.0
        _GlossinessSource("GlossinessSource", Float) = 0.0
        _SpecSource("SpecularHighlights", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

        _WindSpeed("WindSpeed",Range(0,2)) =0.2
        _WindLeavesScale("WindLeavesScale",Range(0,4)) =2
        _TreeSwaySpeed("TreeSwaySpeed",Range(0,8)) =2.4
        _WindSwayScale("WindSwayScale",Range(0,0.1)) =0.02
        _WindStrength("WindStrength",Range(0,5)) =0.2
        _WindLeavesStrength("WindLeavesStrength",Range(0,1)) =0

        //[HideInInspector]_temp("temp",Vector) = (0,0,0,0)
        [HideInInspector] [Toggle(_UIPOSAITION)] _UIPosAnm("_UIPosition", Float) = 0
        [HideInInspector]_UIPoslerp("_UIPoslerp",Range(0,1)) = 1
        [HideInInspector]_UIPoslerpTime("_UIPoslerpTime",Range(0,1)) = 0
        //[HideInInspector]_UIPosition("_UIPosition",Range(0,1)) = 1
//  ========顶点色maskColor====================================================
        [HideInInspector]_TopTint("TopTint",Color)=(1, 0.9183047, 0.5896226, 0)
        [HideInInspector]_TopTintAmount("TopTintAmount",Range(0,5)) = 3.28
        [HideInInspector] _BottomTint("BottomTint",Color)=(0.1226255, 0.5377358, 0.08877712, 0)
        [HideInInspector]_BottomTintAmount("BottomTintAmount",Range(0,5))=0
        [HideInInspector][Toggle(_VMC)] _vertexColorMaskColor("vertexColorMaskColor", Float) = 0
//  ========顶点色maskColor====================================================

//==================雨水n===============================================================
    //    [HideInInspector][Toggle(_RAINON)] _RainOn("RainOn", Float) = 0
    //    [HideInInspector]_RainRippleS("RainRipple",float) = 10
    //    [HideInInspector]_RainRippleNum("RainRippleNum",float) = 10
       // _NoiseMap("NoiseMap", 2D) = "black" {}
//====================================================================================
        [HideInInspector] [Toggle(NOISEBUG)] NOISEBUG("NOISEBUG", Float) = 0
//=================================================================
    //  [Toggle(_GRASSMODE)] _GrassMode("GrassMode", Float) = 0
    //  _NoiseMap("NoiseMap", 2D) = "black" {}
    //  _Speed("WindSpeed", Range( 0 , 1)) = 0.1
    //  _WindDirection("WindDirection", Vector) = (1,1,0,0)
    //  _WindPower("WindPower", Range( 0 , 0.1)) = 0.003

//=================================================================

        
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel"="3.0"}
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            // Use same blending / depth states as Standard shader
            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM
            //#pragma exclude_renderers gles gles3 glcore
            #pragma target 3.0

            // -------------------------------------
            // Material Keywords
            
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _ _SPECGLOSSMAP _SPECULAR_COLOR
            #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA
            #pragma shader_feature_local _SPLATMAPON
            #pragma shader_feature_local _WINDON
            #pragma shader_feature_local _UIPOSAITION
            #pragma shader_feature_local _VMC  //上下颜色混合
          //  #pragma shader_feature_local _GRASSMODE //草飯店的動態
            #pragma shader_feature_local _RANDOMCOLOR 

           // #pragma shader_feature_local _RAINON
            #pragma shader_feature_local NOISEBUG //bug noise

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
           // #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            //#pragma multi_compile _ SHADOWS_SHADOWMASK
           //#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
           // #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
           // #pragma multi_compile _ _CLUSTERED_RENDERING
            
            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple
            #define BUMP_SCALE_NOT_SUPPORTED 0
            //--------------WQLJ---------------------

            #include "./SimpleLitInputLJ.hlsl"
            #include "./SimpleLitForwardPassLJ.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            //#pragma exclude_renderers gles gles3 glcore
            #pragma target 3.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA
            #pragma shader_feature_local _WINDON
            #pragma shader_feature_local _UIPOSAITION
            #pragma shader_feature_local _GRASSMODE //草飯店的動態


            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // -------------------------------------
            // Universal Pipeline keywords

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "./SimpleLitInputLJ.hlsl"
            #include "./ShadowCasterPassLJ.hlsl"
            ENDHLSL
        }
        // Pass
        // {
        //     Name "RainObject"
        //     Tags { "LightMode" = "RainObject" }

        //     HLSLPROGRAM
        //     #pragma vertex vert
        //     #pragma fragment frag

        //     struct NullStruct{};

        //     NullStruct vert()
        //     {
        //         NullStruct o;
        //         return o;
        //     }

        //     float4 frag() : SV_Target
        //         {
        //             return 0; 
        //         }
        //         ENDHLSL
        // }

        // Pass
        // {
        //     Name "GBuffer"
        //     Tags{"LightMode" = "UniversalGBuffer"}

        //     ZWrite[_ZWrite]
        //     ZTest LEqual
        //     Cull[_Cull]

        //     HLSLPROGRAM
        //     #pragma exclude_renderers gles gles3 glcore
        //     #pragma target 4.5

        //     // -------------------------------------
        //     // Material Keywords
        //     #pragma shader_feature_local_fragment _ALPHATEST_ON
        //     //#pragma shader_feature _ALPHAPREMULTIPLY_ON
        //     #pragma shader_feature_local_fragment _ _SPECGLOSSMAP _SPECULAR_COLOR
        //     #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA
        //     #pragma shader_feature_local _NORMALMAP
        //     #pragma shader_feature_local_fragment _EMISSION
        //     #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
        //     //#pragma shader_feature_local _SPLATMAPON

        //     // -------------------------------------
        //     // Universal Pipeline keywords
        //     #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        //     //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        //     //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        //     #pragma multi_compile_fragment _ _SHADOWS_SOFT
        //     #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        //     #pragma multi_compile_fragment _ _LIGHT_LAYERS

        //     // -------------------------------------
        //     // Unity defined keywords
        //     #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        //     #pragma multi_compile _ LIGHTMAP_ON
        //     #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        //     #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        //     #pragma multi_compile _ SHADOWS_SHADOWMASK
        //     #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        //     #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

        //     //--------------------------------------
        //     // GPU Instancing
        //     #pragma multi_compile_instancing
        //     #pragma instancing_options renderinglayer
        //     #pragma multi_compile _ DOTS_INSTANCING_ON

        //     #pragma vertex LitPassVertexSimple
        //     #pragma fragment LitPassFragmentSimple
        //     #define BUMP_SCALE_NOT_SUPPORTED 1

        //     #include "./SimpleLitInputLJ.hlsl"
        //     #include "./SimpleLitGBufferPassLJ.hlsl"
        //     ENDHLSL
        // }

        // Pass
        // {
        //     Name "DepthOnly"
        //     Tags{"LightMode" = "DepthOnly"}

        //     ZWrite On
        //     ColorMask 0
        //     Cull[_Cull]

        //     HLSLPROGRAM
        //     #pragma exclude_renderers gles gles3 glcore
        //     #pragma target 4.5

        //     #pragma vertex DepthOnlyVertex
        //     #pragma fragment DepthOnlyFragment

        //     // -------------------------------------
        //     // Material Keywords
        //     #pragma shader_feature_local_fragment _ALPHATEST_ON
        //     #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

        //     //--------------------------------------
        //     // GPU Instancing
        //     #pragma multi_compile_instancing
        //     #pragma multi_compile _ DOTS_INSTANCING_ON

        //     #include "./SimpleLitInputLJ.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
        //     ENDHLSL
        // }

        // This pass is used when drawing to a _CameraNormalsTexture texture
        // Pass
        // {
        //     Name "DepthNormals"
        //     Tags{"LightMode" = "DepthNormals"}

        //     ZWrite On
        //     Cull[_Cull]

        //     HLSLPROGRAM
        //     #pragma exclude_renderers gles gles3 glcore
        //     #pragma target 4.5

        //     #pragma vertex DepthNormalsVertex
        //     #pragma fragment DepthNormalsFragment

        //     // -------------------------------------
        //     // Material Keywords
        //     #pragma shader_feature_local _NORMALMAP
        //     #pragma shader_feature_local_fragment _ALPHATEST_ON
        //     #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

        //     //--------------------------------------
        //     // GPU Instancing
        //     #pragma multi_compile_instancing
        //     #pragma multi_compile _ DOTS_INSTANCING_ON

        //     #include "./SimpleLitInputLJ.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitDepthNormalsPass.hlsl"
        //     ENDHLSL
        // }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags{ "LightMode" = "Meta" }

            Cull Off

            HLSLPROGRAM
            //#pragma exclude_renderers gles gles3 glcore
            #pragma target 3.0

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaSimple
            #pragma shader_feature EDITOR_VISUALIZATION

            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _SPECGLOSSMAP

            #include "./SimpleLitInputLJ.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitMetaPass.hlsl"

            ENDHLSL
        }

        // Pass
        // {
        //     Name "Universal2D"
        //     Tags{ "LightMode" = "Universal2D" }
        //     Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }

        //     HLSLPROGRAM
        //     #pragma exclude_renderers gles gles3 glcore
        //     #pragma target 4.5

        //     #pragma vertex vert
        //     #pragma fragment frag
        //     #pragma shader_feature_local_fragment _ALPHATEST_ON
        //     #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON

        //     #include "./SimpleLitInputLJ.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
        //     ENDHLSL
        // }
    }

    // SubShader
    // {
    //     Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel"="2.0"}
    //     LOD 300

    //     Pass
    //     {
    //         Name "ForwardLit"
    //         Tags { "LightMode" = "UniversalForward" }

    //         // Use same blending / depth states as Standard shader
    //         Blend[_SrcBlend][_DstBlend]
    //         ZWrite[_ZWrite]
    //         Cull[_Cull]

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         // -------------------------------------
    //         // Material Keywords
    //         #pragma shader_feature_local _NORMALMAP
    //         #pragma shader_feature_local_fragment _EMISSION
    //         #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
    //         #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
    //         #pragma shader_feature_local_fragment _ALPHATEST_ON
    //         #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
    //         #pragma shader_feature_local_fragment _ _SPECGLOSSMAP _SPECULAR_COLOR
    //         #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

    //         // -------------------------------------
    //         // Universal Pipeline keywords
    //         #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
    //         #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
    //         #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
    //         #pragma multi_compile _ SHADOWS_SHADOWMASK
    //         #pragma multi_compile_fragment _ _SHADOWS_SOFT
    //         #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
    //         #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
    //         #pragma multi_compile_fragment _ _LIGHT_LAYERS
    //         #pragma multi_compile_fragment _ _LIGHT_COOKIES
    //         #pragma multi_compile _ _CLUSTERED_RENDERING


    //         // -------------------------------------
    //         // Unity defined keywords
    //         #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    //         #pragma multi_compile _ LIGHTMAP_ON
    //         #pragma multi_compile _ DYNAMICLIGHTMAP_ON
    //         #pragma multi_compile_fog
    //         #pragma multi_compile_fragment _ DEBUG_DISPLAY

    //         //--------------------------------------
    //         // GPU Instancing
    //         #pragma multi_compile_instancing

    //         #pragma vertex LitPassVertexSimple
    //         #pragma fragment LitPassFragmentSimple
    //         #define BUMP_SCALE_NOT_SUPPORTED 1

    //         #include "./SimpleLitInputLJ.hlsl"
    //         #include "./SimpleLitForwardPassLJ.hlsl"
    //         ENDHLSL
    //     }

    //     Pass
    //     {
    //         Name "ShadowCaster"
    //         Tags{"LightMode" = "ShadowCaster"}

    //         ZWrite On
    //         ZTest LEqual
    //         ColorMask 0
    //         Cull[_Cull]

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         // -------------------------------------
    //         // Material Keywords
    //         #pragma shader_feature_local_fragment _ALPHATEST_ON
    //         #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

    //         // -------------------------------------
    //         // Universal Pipeline keywords

    //         // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
    //         #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

    //         //--------------------------------------
    //         // GPU Instancing
    //         #pragma multi_compile_instancing

    //         #pragma vertex ShadowPassVertex
    //         #pragma fragment ShadowPassFragment

    //         #include "./SimpleLitInputLJ.hlsl"
    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
    //         ENDHLSL
    //     }

    //     Pass
    //     {
    //         Name "DepthOnly"
    //         Tags{"LightMode" = "DepthOnly"}

    //         ZWrite On
    //         ColorMask 0
    //         Cull[_Cull]

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         #pragma vertex DepthOnlyVertex
    //         #pragma fragment DepthOnlyFragment

    //         // Material Keywords
    //         #pragma shader_feature_local_fragment _ALPHATEST_ON
    //         #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

    //         //--------------------------------------
    //         // GPU Instancing
    //         #pragma multi_compile_instancing

    //         #include "./SimpleLitInputLJ.hlsl"
    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
    //         ENDHLSL
    //     }

    //     // This pass is used when drawing to a _CameraNormalsTexture texture
    //     Pass
    //     {
    //         Name "DepthNormals"
    //         Tags{"LightMode" = "DepthNormals"}

    //         ZWrite On
    //         Cull[_Cull]

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         #pragma vertex DepthNormalsVertex
    //         #pragma fragment DepthNormalsFragment

    //         // -------------------------------------
    //         // Material Keywords
    //         #pragma shader_feature_local _NORMALMAP
    //         #pragma shader_feature_local_fragment _ALPHATEST_ON
    //         #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

    //         //--------------------------------------
    //         // GPU Instancing
    //         #pragma multi_compile_instancing

    //         #include "./SimpleLitInputLJ.hlsl"
    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitDepthNormalsPass.hlsl"
    //         ENDHLSL
    //     }

    //     // This pass it not used during regular rendering, only for lightmap baking.
    //     Pass
    //     {
    //         Name "Meta"
    //         Tags{ "LightMode" =  "Meta" }

    //         Cull Off

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         #pragma vertex UniversalVertexMeta
    //         #pragma fragment UniversalFragmentMetaSimple

    //         #pragma shader_feature_local_fragment _EMISSION
    //         #pragma shader_feature_local_fragment _SPECGLOSSMAP
    //         #pragma shader_feature EDITOR_VISUALIZATION

    //         #include "./SimpleLitInputLJ.hlsl"
    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitMetaPass.hlsl"

    //         ENDHLSL
    //     }

    //     Pass
    //     {
    //         Name "Universal2D"
    //         Tags{ "LightMode" = "Universal2D" }
    //         Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         #pragma vertex vert
    //         #pragma fragment frag
    //         #pragma shader_feature_local_fragment _ALPHATEST_ON
    //         #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON

    //         #include "./SimpleLitInputLJ.hlsl"
    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
    //         ENDHLSL
    //     }
    // }
    	// Pass 
        // {
        //     Tags{"LightMode" = "ShadowCaster"}
		// 	//ZWrite Off
		// }

    Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    //CustomEditor "SimpleLitLJShader"
   CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.SimpleLitLJShader"
}
 