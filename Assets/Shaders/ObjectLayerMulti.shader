Shader "Learn/scene/ObjectLayerMulti"
{
    Properties
    {
        [Header(Global)]
        [Normal] _BumpMapGlobal("Normal Map", 2D) = "bump" {}
        _BumpScaleGlobal("Scale", Range(0.0, 1.0)) = 0.5
        _SplatMapGlobal("Splat Map", 2D) = "black" {}
        [PowerSlider(2.0)] _TransitionStrength("Transition Strength", Range(0.0, 1.0)) = 0.382
        [PowerSlider(2.0)] _BaseStrength("Base Strength", Range(0.001, 1.0)) = 0.01
        [KeywordEnum(BASE, TWO_PAIR, TWO, THREE)] _LAYER("Splatmap Type", Float) = 0.0
        
        [Header(Base Layer)]
        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)
        _Sharpen("Sharpen", Range(0.0, 1.0)) = 0        
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.5
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _OcclusionStrength("Occlusion", Range(0.0, 1.0)) = 0.5
        [NoScaleOffset] _MetallicGlossMap("Metallic", 2D) = "white" {}
        [NoScaleOffset][Normal] _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Scale", Range(0.0, 1.0)) = 0.5
        
        [Header(R Channel)]
        _BaseColor01("Color", Color) = (1,1,1,1)
        _Sharpen01("Sharpen", Range(0.0, 1.0)) = 0
        _Metallic01("Metallic", Range(0.0, 1.0)) = 0.5
        _Smoothness01("Smoothness", Range(0.0, 1.0)) = 0.5
        _OcclusionStrength01("Occlusion", Range(0.0, 1.0)) = 0.5
 
        [Header(G Channel)]
        _BaseColor02("Color", Color) = (1,1,1,1)
        _Sharpen02("Sharpen", Range(0.0, 1.0)) = 0
        _Metallic02("Metallic", Range(0.0, 1.0)) = 0.5
        _Smoothness02("Smoothness", Range(0.0, 1.0)) = 0.5
        _OcclusionStrength02("Occlusion", Range(0.0, 1.0)) = 0.5
        
        [Header(B Channel)]
        _BaseColor03("Color", Color) = (1,1,1,1)
        _Sharpen03("Sharpen", Range(0.0, 1.0)) = 0
        _Metallic03("Metallic", Range(0.0, 1.0)) = 0.5
        _Smoothness03("Smoothness", Range(0.0, 1.0)) = 0.5
        _OcclusionStrength03("Occlusion", Range(0.0, 1.0)) = 0.5
        
        [Header(Layer One)]
        _BaseMap1("Albedo", 2D) = "white" {}
        _BaseColor1("Color", Color) = (1,1,1,1)
        _Sharpen1("Sharpen", Range(0.0, 1.0)) = 0
        _Metallic1("Metallic", Range(0.0, 1.0)) = 0.5
        _Smoothness1("Smoothness", Range(0.0, 1.0)) = 0.5
        _OcclusionStrength1("Occlusion", Range(0.0, 1.0)) = 0.5
        [NoScaleOffset] _MetallicGlossMap1("Metallic", 2D) = "white" {}
        [NoScaleOffset][Normal] _BumpMap1("Normal Map", 2D) = "bump" {}
        _BumpScale1("Scale", Range(0.0, 1.0)) = 0.5
        
        [Header(Layer Two)]
        _BaseMap2("Albedo", 2D) = "white" {}
        _BaseColor2("Color", Color) = (1,1,1,1)
        _Sharpen2("Sharpen", Range(0.0, 1.0)) = 0
        _Metallic2("Metallic", Range(0.0, 1.0)) = 0.5
        _Smoothness2("Smoothness", Range(0.0, 1.0)) = 0.5
        _OcclusionStrength2("Occlusion", Range(0.0, 1.0)) = 0.5
        [NoScaleOffset] _MetallicGlossMap2("Metallic", 2D) = "white" {}
        [NoScaleOffset][Normal] _BumpMap2("Normal Map", 2D) = "bump" {}
        _BumpScale2("Scale", Range(0.0, 1.0)) = 0.5
       
        [Header(Layer Three)]
        _BaseMap3("Albedo", 2D) = "white" {}
        _BaseColor3("Color", Color) = (1,1,1,1)
        _Sharpen3("Sharpen", Range(0.0, 1.0)) = 0
        _Metallic3("Metallic", Range(0.0, 1.0)) = 0.5
        _Smoothness3("Smoothness", Range(0.0, 1.0)) = 0.5
        _OcclusionStrength3("Occlusion", Range(0.0, 1.0)) = 0.5
        [NoScaleOffset] _MetallicGlossMap3("Metallic", 2D) = "white" {}
        [NoScaleOffset][Normal] _BumpMap3("Normal Map", 2D) = "bump" {}
        _BumpScale3("Scale", Range(0.0, 1.0)) = 0.5 
        
        [Header(Far Layer)]
        _DetailMap("Detail Map", 2D) = "white" {}
        _DetailColor("Detail Color", Color) = (1,1,1,1)
        _DetailStrength("Detail Strength", Vector) = (1,1,1,1)
        
        // Blending state
        _Cull("__cull", Float) = 2.0
        [ToggleOff(_RECEIVE_SHADOWS_OFF)] _ReceiveShadows("Receive Shadows", Float) = 1.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }

    SubShader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "Lit" "IgnoreProjector" = "True" "ShaderModel"="4.5"}
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            Blend Off
            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 3.5

            // -------------------------------------
            // Astro Material Keywords
            // omit _LAYER_FOUR
            #pragma shader_feature_local_fragment _LAYER_BASE _LAYER_TWO_PAIR _LAYER_TWO _LAYER_THREE
            #pragma shader_feature_local_fragment _ _DETAILMAP
            
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            //#pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            //#pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            //#pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            //#pragma shader_feature_local_fragment _ALPHATEST_ON
            //#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            //#pragma shader_feature_local_fragment _EMISSION
            //#pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            //#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            
            
            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            //#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _CLUSTERED_RENDERING

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            //#pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex vert
            #pragma fragment frag
            
            #include "ObjectLayerCommon.hlsl" 
            
            ENDHLSL
        }

        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/DepthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
        UsePass "Universal Render Pipeline/Lit/Meta"
    }


    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "ObjectLayerMulti" 
}
