Shader "Learn/FabricDiffuse"
{
    Properties
    {
        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)
        _ScatterColor("Scatter Color", Color) = (1,1,1,1)
        _Strength("Stength", Range(0, 1)) = 0.5
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
                half3 _ScatterColor;
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

            
            // https://advances.realtimerendering.com/s2016/
            // The Process of Creating Volumetric-based Materials in Uncharted 4
            half CalculateDiffuse(half3 l, half3 n, half3 v)
		    {
                half ndl = dot(n, l);
            	half3 diffuse = saturate(ndl + _Strength) / (1 + _Strength);
                half3 scatterlight = saturate(_ScatterColor + saturate(ndl)) * diffuse;
                
			    return scatterlight;
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
            	
				half scatter = CalculateDiffuse(light, normal, view);
			
				half3 color = _BaseColor * scatter;
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
