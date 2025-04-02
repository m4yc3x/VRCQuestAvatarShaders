Shader "VRChat/Mobile/Particles/Additive"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (0.75, 0.75, 0.75, 1.0)
        _MetallicColor ("Metallic Highlight Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _DarkColor ("Dark Metal Color", Color) = (0.2, 0.2, 0.2, 1.0)
        _FlowSpeed ("Flow Speed", Range(0,2)) = 0.5
        _FlowScale ("Flow Scale", Range(1,10)) = 4.0
        _TurbulenceStrength ("Turbulence Strength", Range(0,1)) = 0.7
        _Metallic ("Metallic", Range(0,1)) = 0.9
        _Smoothness ("Smoothness", Range(0,1)) = 0.95
        _EmissionStrength ("Emission Strength", Range(0,2)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "PreviewType"="Plane" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BaseColor;
            float4 _MetallicColor;
            float4 _DarkColor;
            float _FlowSpeed;
            float _FlowScale;
            float _TurbulenceStrength;
            float _Metallic;
            float _Smoothness;
            float _EmissionStrength;

            // 2D Gradient noise with smoother interpolation
            float2 grad(float2 p)
            {
                float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                p = mul(m, p);
                return sin(p * 6.28318530718) * 0.5 + 0.5; // Smoother sine-based noise
            }

            // Improved smooth interpolation
            float2 smootherstep(float2 x)
            {
                return x * x * x * (x * (x * 6.0 - 15.0) + 10.0);
            }

            // Fluid flow field with improved blending
            float2 flow(float2 p, float t)
            {
                float2 pi = floor(p);
                float2 pf = frac(p);
                
                // Get gradient vectors at grid points
                float2 g00 = grad(pi);
                float2 g10 = grad(pi + float2(1.0, 0.0));
                float2 g01 = grad(pi + float2(0.0, 1.0));
                float2 g11 = grad(pi + float2(1.0, 1.0));
                
                // Smoother interpolation weights
                float2 u = smootherstep(pf);
                
                // Improved gradient mixing
                float2 flow1 = lerp(g00, g10, u.x);
                float2 flow2 = lerp(g01, g11, u.x);
                return lerp(flow1, flow2, u.y) * 2.0 - 1.0;
            }

            // Organic fluid turbulence with smoother transitions
            float fluidTurbulence(float2 uv, float time)
            {
                float2 p = uv;
                float t = 0.0;
                float amp = 0.5;
                float freq = 1.0;
                
                // Smoother flow evolution
                for(int i = 0; i < 3; i++)
                {
                    float2 flowVec = flow(p * freq + time * 0.3, time);
                    
                    // Smoother advection
                    p += flowVec * (0.1 * amp);
                    
                    // Softer wave patterns
                    float2 waveDir = normalize(float2(1.324, 2.567) + flowVec * 0.2);
                    float wave = sin(dot(p, waveDir) * freq + time) * 0.5 + 0.5;
                    wave = smoothstep(0.2, 0.8, wave); // Smooth out extremes
                    
                    t += wave * amp;
                    
                    amp *= 0.6;
                    freq *= 1.8;
                    
                    // Gentler rotation
                    float2x2 rot = float2x2(0.85, -0.45, 0.45, 0.85);
                    p = mul(rot, p);
                }
                
                return saturate(t);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.color = v.color;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float time = _Time.y * _FlowSpeed;
                float2 uv = i.uv * _FlowScale;
                
                // Create smoother organic fluid flow
                float fluid1 = fluidTurbulence(uv, time);
                float fluid2 = fluidTurbulence(uv * 1.4 + float2(0.7, 1.1), time * 0.8);
                
                // Smoother fluid layer blending
                float fluidFlow = lerp(fluid1, fluid2, 0.35);
                fluidFlow = smoothstep(0.2, 0.8, fluidFlow) * _TurbulenceStrength;
                
                // Calculate view-based effects
                float3 normal = normalize(i.worldNormal);
                float3 viewDir = normalize(i.viewDir);
                float ndotv = saturate(dot(normal, viewDir));
                
                // Softer metallic fresnel
                float fresnel = pow(1.0 - ndotv, 2.5) * _Metallic;
                fresnel = smoothstep(0.1, 0.9, fresnel);
                
                // Create organic specular highlights
                float3 reflectDir = reflect(-viewDir, normal + fluidFlow * 0.12);
                float specBase = saturate(dot(reflectDir, float3(0, 1, 0)));
                float spec = pow(specBase, 8.0 * _Smoothness) * _Smoothness;
                spec = smoothstep(0.1, 0.9, spec);
                
                // Base color with metallic properties
                fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor * i.color;
                
                // Smoother fluid metal variations
                float3 darkMetal = lerp(_DarkColor.rgb, _BaseColor.rgb, smoothstep(0.2, 0.8, fluidFlow * 0.9 + 0.1));
                float3 lightMetal = lerp(_BaseColor.rgb, _MetallicColor.rgb, smoothstep(0.1, 0.9, fresnel + fluidFlow * 0.5));
                
                // Combine metal variations with fluid flow
                col.rgb = lerp(darkMetal, lightMetal, smoothstep(0.2, 0.8, fluidFlow + fresnel * 0.5));
                
                // Add smoother specular highlights and emission
                col.rgb += spec * _MetallicColor.rgb * smoothstep(0.3, 0.7, fluidFlow * 0.6 + 0.4);
                col.rgb += fresnel * _MetallicColor.rgb * 0.3;
                col.rgb += fluidFlow * _EmissionStrength * _MetallicColor.rgb * 0.1;
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
