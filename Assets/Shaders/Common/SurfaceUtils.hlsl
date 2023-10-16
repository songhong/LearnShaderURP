#ifndef ASTRO_COMMON_SURFACE_UTILS_INCLUDED
#define ASTRO_COMMON_SURFACE_UTILS_INCLUDED

#define DEFAULT_EPSILON 0.001
#define DEFAULT_LAYER_WEIGHT (DEFAULT_EPSILON*3.0)

inline half DoubleFrom01(half control)
{
    return control * 2.0f;
}

inline half ControlOcclusion(half ao, half control)
{
    half f = step(control, 0.5);
    half brighter = lerp(1.0, ao, saturate(control * 2.0));
    half darker = lerp(ao, pow(ao,2.0), saturate(control * 2.0 - 1.0));
    
    return darker + (brighter - darker) * f;
}

inline half4 OverlayColor(half4 baseColor, half4 overlayColor)
{
    half4 flag = step(baseColor, half4(0.5, 0.5, 0.5, 0.5));
    half4 color = flag*baseColor*overlayColor*2.0 + (1-flag)*(1- (1-baseColor)*(1-overlayColor)*2.0);
    return color;
}

inline half ScatterNdotL(half NdotL, half weight)
{
    // 0 < weight < 1    
    half scatterNdotL = saturate(NdotL + weight) / (1 + weight);
    return scatterNdotL;
}

half3 SampleNormalScale(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), half scale = half(1.0))
{
#ifdef _NORMALMAP
    half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);
    return UnpackNormalScale(n, scale);
#else
    return half3(0, 0, 1.0);
#endif
}

inline real4 NormalizeLayerWeights(real w0, real w1, real w2, real w3, real transition = 0)
{
    const real wm = saturate(max(max(w0, w1), max(w2, w3)) - max(transition, DEFAULT_EPSILON)); // use epsilon to fix zero black case
    const real d0 = max(w0 - wm, 0);
    const real d1 = max(w1 - wm, 0);
    const real d2 = max(w2 - wm, 0);
    const real d3 = max(w3 - wm, 0);

    const real dInv = rcp(d0 + d1 + d2 + d3);
    real4 f = real4(d0 * dInv, d1 * dInv, d2 * dInv, d3 * dInv);

    return f;
}
#endif