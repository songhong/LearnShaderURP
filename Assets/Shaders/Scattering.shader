Shader "Learn/Scattering"
{
    Properties
    {
        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)
        _Ambient("Ambient", Range(0, 1)) = 0.1
        _Distortion("Distortion", Range(0, 1)) = 0.5
    	_Power("Power", Range(0, 3)) = 1.0
    	_Scale("Scale", Range(0, 3)) = 1.0
    }

    SubShader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"  "ShaderModel"="3.5"}
        Blend Off

        Pass
        {
            Name "ForwardLit"
            Tags {"LightMode" = "UniversalForward"}
            
            HLSLINCLUDE
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half3 _BaseColor;
				half  _Ambient;
            	half  _Distortion;
            	half  _Power;
				half  _Scale;
				half  _Strength;
            CBUFFER_END
            
            TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
            
            struct appdata
            {
                float3 positionOS : POSITION;
                half3  normalOS : NORMAL;
                half4  tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
             };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 positionWS : TEXCOORD1;
                half3  normalWS : TEXCOORD2;
                half4  tangentWS : TEXCOORD3;
            };

            // https://www.gdcvault.com/play/1014538/Approximating-Translucency-for-a-Fast
            half CalculateSSS(half3 l, half3 n, half3 v, half thickness)
		    {
			    half3 vLTLight = l + (n * _Distortion);
            	half fLTDot = pow(saturate(dot(v, -vLTLight)), _Power) * _Scale;
            	half3 fLT = (fLTDot + _Ambient) * thickness;

			    return fLT;
		    }
            ENDHLSL
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5
            
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
                
                return o;
			}
            
            half4 frag(v2f i) : COLOR
            {
                const half3 light = GetMainLight().direction;
                const half3 view = GetWorldSpaceNormalizeViewDir(i.positionWS);
            	const half3 normal = normalize(i.normalWS);
            	
            	half thick = 1.0; // query thick map exported from SP
				half sss = CalculateSSS(light, normal, view, thick);
			
				half3 color = _BaseColor * sss;
                return half4(color, 1.0);
            }
            ENDHLSL
        }
        
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/DepthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
        UsePass "Universal Render Pipeline/Lit/Meta"
    }
    
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
