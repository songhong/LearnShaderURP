#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Shaders/LitForwardPass.hlsl"
#include "Common/SurfaceUtils.hlsl"

// @TODO: add all to const buffer
half   _Sharpen;

half4  _BaseColor01;
half   _Sharpen01;
half   _Metallic01;
half   _Smoothness01;
half   _OcclusionStrength01;
     
half4  _BaseColor02;
half   _Sharpen02;
half   _Metallic02;
half   _Smoothness02;
half   _OcclusionStrength02;

half4  _BaseColor03;
half   _Sharpen03;
half   _Metallic03;
half   _Smoothness03;
half   _OcclusionStrength03;

/* layer one */
half4  _BaseColor1;
half   _Sharpen1;
half   _Metallic1;
half   _Smoothness1;
half   _OcclusionStrength1;
half   _BumpScale1;

float4 _BaseMap1_ST;
TEXTURE2D(_BaseMap1);            SAMPLER(sampler_BaseMap1);
TEXTURE2D(_BumpMap1);            SAMPLER(sampler_BumpMap1);
TEXTURE2D(_MetallicGlossMap1);   SAMPLER(sampler_MetallicGlossMap1);       

/* layer two */
half4  _BaseColor2;
half   _Sharpen2;
half   _Metallic2;
half   _Smoothness2;
half   _OcclusionStrength2;
half   _BumpScale2;

float4 _BaseMap2_ST;
TEXTURE2D(_BaseMap2);            SAMPLER(sampler_BaseMap2);
TEXTURE2D(_BumpMap2);            SAMPLER(sampler_BumpMap2);
TEXTURE2D(_MetallicGlossMap2);   SAMPLER(sampler_MetallicGlossMap2);

/* layer three */
half4  _BaseColor3;
half   _Sharpen3;
half   _Metallic3;
half   _Smoothness3;
half   _OcclusionStrength3;
half   _BumpScale3;

float4 _BaseMap3_ST;
TEXTURE2D(_BaseMap3);            SAMPLER(sampler_BaseMap3);
TEXTURE2D(_BumpMap3);            SAMPLER(sampler_BumpMap3);
TEXTURE2D(_MetallicGlossMap3);   SAMPLER(sampler_MetallicGlossMap3);

/* global */
TEXTURE2D(_BumpMapGlobal);       SAMPLER(sampler_BumpMapGlobal);
TEXTURE2D(_SplatMapGlobal);      SAMPLER(sampler_SplatMapGlobal);
TEXTURE2D(_LayerMapGlobal);      SAMPLER(sampler_LayerMapGlobal);
TEXTURE2D(_DetailMap);           SAMPLER(sampler_DetailMap);
float4 _DetailMap_ST;
half4  _DetailColor;
half4  _DetailStrength;

half _BumpScaleGlobal;
half _TransitionStrength;
half _BaseStrength;

/**
 * Fragment Shader
 */
struct LayerSurfaceData
{
    half4 albedo;
    half3 normalTS;
    half  metallic;
    half  smoothness;
    half  occlusion;
    
    half  weight;
    half  sharpen;
};

#define SET_LAYER_DATA_FROM_VAL(layerName, suffix) \
    layerName##suffix.albedo     = _BaseColor##suffix; \
    layerName##suffix.sharpen    = saturate(_Sharpen##suffix); \
    layerName##suffix.metallic   = DoubleFrom01(_Metallic##suffix); \
    layerName##suffix.smoothness = DoubleFrom01(_Smoothness##suffix); \
    layerName##suffix.occlusion  = _OcclusionStrength##suffix; \

#define SET_LAYER_DATA_FROM_TEX(layerName, suffix, uv) \
    float2 uvLayer    = TRANSFORM_TEX(uv, _BaseMap##suffix); \
    half4 albedoAlpha = SAMPLE_TEXTURE2D(_BaseMap##suffix, sampler_BaseMap##suffix, uvLayer); \
    half4 specGloss   = SAMPLE_TEXTURE2D(_MetallicGlossMap##suffix, sampler_MetallicGlossMap##suffix, uvLayer); \
    layerName##suffix.albedo     = albedoAlpha * _BaseColor##suffix; \
    layerName##suffix.sharpen    = saturate(_Sharpen##suffix); \
    layerName##suffix.metallic   = saturate(specGloss.r * DoubleFrom01(_Metallic##suffix)); \
    layerName##suffix.smoothness = saturate(specGloss.g * DoubleFrom01(_Smoothness##suffix)); \
    layerName##suffix.occlusion  = ControlOcclusion(specGloss.b, _OcclusionStrength##suffix); \
    layerName##suffix.normalTS   = SampleNormalScale(uvLayer, TEXTURE2D_ARGS(_BumpMap##suffix, sampler_BumpMap##suffix), DoubleFrom01(_BumpScale##suffix)); \
    
inline void AdditiveLayerSurface(LayerSurfaceData baseLayer, inout LayerSurfaceData inoutAdditiveLayer)
{
    half3 albedo = OverlayColor(baseLayer.albedo, inoutAdditiveLayer.albedo).rgb;
    
    inoutAdditiveLayer.albedo = half4(albedo, baseLayer.albedo.a);
    inoutAdditiveLayer.metallic = saturate(baseLayer.metallic * inoutAdditiveLayer.metallic);
    inoutAdditiveLayer.smoothness = saturate(baseLayer.smoothness * inoutAdditiveLayer.smoothness);
    inoutAdditiveLayer.occlusion = ControlOcclusion(baseLayer.occlusion, inoutAdditiveLayer.occlusion);
    inoutAdditiveLayer.normalTS = baseLayer.normalTS;
}

inline real4 CombineLayerSurfaces(inout LayerSurfaceData inoutLayer0, LayerSurfaceData layer1, LayerSurfaceData layer2, LayerSurfaceData layer3)
{
    // https://www.gamedeveloper.com/programming/advanced-terrain-texture-splatting#close-modal
    const real4 splatW = NormalizeLayerWeights(
        inoutLayer0.weight,
        layer1.weight,
        layer2.weight,
        layer3.weight,
        _TransitionStrength);

    const real4 alphaW = NormalizeLayerWeights(
        splatW.x * inoutLayer0.albedo.a,
        splatW.y * layer1.albedo.a,
        splatW.z * layer2.albedo.a,
        splatW.w * layer3.albedo.a);

    const real sharpen = dot(alphaW, real4(inoutLayer0.sharpen, layer1.sharpen, layer2.sharpen, layer3.sharpen));
    const real4 mask = step(splatW, 1.0 - DEFAULT_EPSILON);

    const real4 f = (alphaW - splatW) * sharpen * mask + splatW;
    
    // pbr parameters
    inoutLayer0.albedo = f.x*inoutLayer0.albedo + f.y*layer1.albedo + f.z*layer2.albedo + f.w*layer3.albedo;
    inoutLayer0.metallic = f.x*inoutLayer0.metallic + f.y*layer1.metallic + f.z*layer2.metallic + f.w*layer3.metallic;
    inoutLayer0.smoothness = f.x*inoutLayer0.smoothness + f.y*layer1.smoothness + f.z*layer2.smoothness + f.w*layer3.smoothness;
    inoutLayer0.occlusion = f.x*inoutLayer0.occlusion + f.y*layer1.occlusion + f.z*layer2.occlusion + f.w*layer3.occlusion;

    inoutLayer0.normalTS = normalize(f.x*inoutLayer0.normalTS + f.y*layer1.normalTS + f.z*layer2.normalTS + f.w*layer3.normalTS);
    inoutLayer0.weight = 1.0;

    return f;
}

inline LayerSurfaceData InitializeBaseLayerFromTex(float2 uv, half4 splatMask)
{
    LayerSurfaceData baseSurface = (LayerSurfaceData)0;
    {
        SET_LAYER_DATA_FROM_TEX(baseSurface, , uv)
        baseSurface.weight = _BaseStrength;
        baseSurface.albedo.a *= _BaseStrength;
    }
    
    return baseSurface;
}

inline LayerSurfaceData InitializeLayerOneFromTex(float2 uv, half4 splatMask)
{
    LayerSurfaceData layerSurface1 = (LayerSurfaceData)0; 
    {
        SET_LAYER_DATA_FROM_TEX(layerSurface, 1, uv)
        layerSurface1.weight = splatMask.r; 
    }
    return layerSurface1;
}

inline LayerSurfaceData InitializeLayerTwoFromTex(float2 uv, half4 splatMask)
{
    LayerSurfaceData layerSurface2 = (LayerSurfaceData)0;
    {
        SET_LAYER_DATA_FROM_TEX(layerSurface, 2, uv)
        layerSurface2.weight = splatMask.g; 
    }
    return layerSurface2;
}

inline LayerSurfaceData InitializeLayerThreeFromTex(float2 uv, half4 splatMask)
{
    LayerSurfaceData layerSurface3 = (LayerSurfaceData)0;
    {
        SET_LAYER_DATA_FROM_TEX(layerSurface, 3, uv)
        layerSurface3.weight = splatMask.b; 
    }
    return layerSurface3;
}

inline LayerSurfaceData InitializeLayerOneFromVal(float2 uv, half4 splatMask)
{
    LayerSurfaceData layerSurface01 = (LayerSurfaceData)0;
    {
         SET_LAYER_DATA_FROM_VAL(layerSurface, 01)
         layerSurface01.weight = splatMask.r; 
    }
    return layerSurface01;
}

inline LayerSurfaceData InitializeLayerTwoFromVal(float2 uv, half4 splatMask)
{
    LayerSurfaceData layerSurface02 = (LayerSurfaceData)0;
    {
        SET_LAYER_DATA_FROM_VAL(layerSurface, 02)
        layerSurface02.weight = splatMask.g; 
    }
    return layerSurface02;
}

inline LayerSurfaceData InitializeLayerThreeFromVal(float2 uv, half4 splatMask)
{
    LayerSurfaceData layerSurface03 = (LayerSurfaceData)0;
    {
        SET_LAYER_DATA_FROM_VAL(layerSurface, 03)
        layerSurface03.weight = splatMask.b; 
    }
    return layerSurface03;
}


inline real4 InitializeMultiLayerSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
    // init layers
    half4 splatMask = SAMPLE_TEXTURE2D(_SplatMapGlobal, sampler_SplatMapGlobal, uv);
    LayerSurfaceData baseSurface = InitializeBaseLayerFromTex(uv, splatMask);
    
#if defined(_LAYER_TWO)
    LayerSurfaceData layerSurface1 = InitializeLayerOneFromVal(uv, splatMask);
    AdditiveLayerSurface(baseSurface, layerSurface1);
    LayerSurfaceData layerSurface2 = InitializeLayerTwoFromVal(uv, splatMask);
    AdditiveLayerSurface(baseSurface, layerSurface2);
    LayerSurfaceData layerSurface3 = InitializeLayerThreeFromTex(uv, splatMask);
    
#elif defined(_LAYER_TWO_PAIR)
    LayerSurfaceData layerSurface1 = InitializeLayerOneFromVal(uv, splatMask);
    AdditiveLayerSurface(baseSurface, layerSurface1);
    LayerSurfaceData layerSurface2 = InitializeLayerTwoFromTex(uv, splatMask);
    LayerSurfaceData layerSurface3 = InitializeLayerThreeFromVal(uv, splatMask);
    AdditiveLayerSurface(layerSurface2, layerSurface3);
    
#elif defined(_LAYER_THREE)
    LayerSurfaceData layerSurface1 = InitializeLayerOneFromVal(uv, splatMask);
    AdditiveLayerSurface(baseSurface, layerSurface1);
    LayerSurfaceData layerSurface2 = InitializeLayerTwoFromTex(uv, splatMask);
    LayerSurfaceData layerSurface3 = InitializeLayerThreeFromTex(uv, splatMask);
    
#elif defined(_LAYER_FOUR)
    LayerSurfaceData layerSurface1 = InitializeLayerOneFromTex(uv, splatMask);
    LayerSurfaceData layerSurface2 = InitializeLayerTwoFromTex(uv, splatMask);
    LayerSurfaceData layerSurface3 = InitializeLayerThreeFromTex(uv, splatMask);
    
#else
    LayerSurfaceData layerSurface1 = InitializeLayerOneFromVal(uv, splatMask);
    AdditiveLayerSurface(baseSurface, layerSurface1);
    LayerSurfaceData layerSurface2 = InitializeLayerTwoFromVal(uv, splatMask);
    AdditiveLayerSurface(baseSurface, layerSurface2);
    LayerSurfaceData layerSurface3 = InitializeLayerThreeFromVal(uv, splatMask);
    AdditiveLayerSurface(baseSurface, layerSurface3);
#endif

    // combine
    real4 mask = CombineLayerSurfaces(baseSurface, layerSurface1, layerSurface2, layerSurface3);

    half3 normalTS = SampleNormalScale(uv, TEXTURE2D_ARGS(_BumpMapGlobal, sampler_BumpMapGlobal), DoubleFrom01(_BumpScaleGlobal));
    baseSurface.normalTS = BlendNormal(normalTS, baseSurface.normalTS);
    
#if defined(_DETAILMAP)
    float2 uvDetail = TRANSFORM_TEX(uv, _DetailMap);
    half4 detailAlbedo = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, uvDetail);
    half4 overlayColor = OverlayColor(baseSurface.albedo, detailAlbedo * _DetailColor);

    half strength = dot(mask, saturate(_DetailStrength));
    baseSurface.albedo = lerp(baseSurface.albedo, overlayColor, strength);
#endif
    
    // output
    outSurfaceData = (SurfaceData)0;
    outSurfaceData.albedo = baseSurface.albedo.rgb;
    outSurfaceData.metallic = baseSurface.metallic;
    outSurfaceData.smoothness = baseSurface.smoothness;
    outSurfaceData.normalTS = baseSurface.normalTS;
    outSurfaceData.occlusion = baseSurface.occlusion;
    outSurfaceData.alpha = 1.0;
    outSurfaceData.specular = half3(0.0, 0.0, 0.0);
    outSurfaceData.emission = half3(0.0, 0.0, 0.0);;
    outSurfaceData.clearCoatMask       = half(0.0);
    outSurfaceData.clearCoatSmoothness = half(0.0);

    return mask;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    
    SurfaceData surfaceData;
    InitializeMultiLayerSurfaceData(input.uv, surfaceData);
    
    InputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

#ifdef _DBUFFER
    ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
#endif

    half4 color = UniversalFragmentPBR(inputData, surfaceData);

    color.rgb = MixFog(color.rgb, inputData.fogCoord);
    color.a = OutputAlpha(color.a, _Surface);

    return color;
}

/**
 * Vertex Shader
 */
Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    
    output.uv = input.texcoord;

    // already normalized from normal transform to WS.
    output.normalWS = normalInput.normalWS;
    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR) || defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    real sign = input.tangentOS.w * GetOddNegativeScale();
    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
    #endif
    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    output.tangentWS = tangentWS;
    #endif
    
    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    output.positionWS = vertexInput.positionWS;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    output.shadowCoord = GetShadowCoord(vertexInput);
    #endif

    output.positionCS = vertexInput.positionCS;

    return output;
}