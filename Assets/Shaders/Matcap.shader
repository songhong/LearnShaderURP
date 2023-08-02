Shader "Learn/Matcap"
{
    Properties
    {
        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)
        
        _MatcapMap("Matcap", 2D) = "white" {}
        
        _ReflectionMap("Reflection Cube Map", Cube) = "" {}
        _ReflectionStrength("Reflection Strength", Range(0.0, 1.0)) = 0.5
    }

    SubShader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"  "ShaderModel"="3.5"}
        Blend Off

        Pass
        {
            Name "ForwardLit"
            Tags {"LightMode" = "UniversalForward"}
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half  _ReflectionStrength;
            CBUFFER_END
            
            TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_MatcapMap);          SAMPLER(sampler_MatcapMap);
            TEXTURECUBE(_ReflectionMap);    SAMPLER(sampler_ReflectionMap);
            
            struct appdata
            {
                real3 positionOS : POSITION;
                real3 normalOS : NORMAL;
                real4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
             };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0; // xy:uv, zw: uvView
                float4 positionWS : TEXCOORD1;
                half3 normalWS : TEXCOORD2;
                half4 tangentWS : TEXCOORD3;
            };
            
            v2f vert (appdata v)
			{
                const VertexNormalInputs   normalInputs = GetVertexNormalInputs(v.normalOS, v.tangentOS);
                const VertexPositionInputs vertexInputs = GetVertexPositionInputs(v.positionOS);
                            
                v2f o = (v2f)0;
                o.pos = vertexInputs.positionCS;
                o.positionWS.xyz = vertexInputs.positionWS;
                o.uv.xy = v.texcoord;
                
                real sign = v.tangentOS.w * GetOddNegativeScale();
                o.tangentWS = half4(normalInputs.tangentWS.xyz, sign);
                o.normalWS = normalInputs.normalWS;

                o.uv.z = mul(UNITY_MATRIX_IT_MV[0], v.normalOS);
                o.uv.w = mul(UNITY_MATRIX_IT_MV[1], v.normalOS);
                o.uv.zw = 0.5 + 0.5 * o.uv.zw;
                
                return o;
			}
            
            half4 frag(v2f i) : COLOR
            {
                const Light light = GetMainLight();
                 
                half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) * _BaseColor;
                half4 diffuse = saturate(dot(i.normalWS, light.direction)) * albedo;
                
                half4 matcap = SAMPLE_TEXTURE2D(_MatcapMap, sampler_MatcapMap, i.uv.zw);

                half3 reflectV = reflect(-GetWorldSpaceViewDir(i.positionWS), i.normalWS);
                half4 reflection = SAMPLE_TEXTURECUBE(_ReflectionMap, sampler_ReflectionMap, reflectV) * _ReflectionStrength;
                
                return reflection + albedo * matcap;
            }
            ENDHLSL
        }
    }
}
