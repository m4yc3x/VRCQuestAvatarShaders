Shader "VRChat/Mobile/Particles/Additive"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (0.95,0.95,1.0,0.2)
        _RefractionStrength ("Refraction Strength", Range(0,0.2)) = 0.05
        _FresnelPower ("Edge Power", Range(1,5)) = 2.0
        _Glossiness ("Highlight Strength", Range(0,1)) = 0.8
        _EdgeBrightness ("Edge Brightness", Range(0,2)) = 1.0
        _ChromaticAberration ("Chromatic Aberration", Range(0,0.1)) = 0.02
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" "PreviewType"="Plane" }
        LOD 100

        GrabPass { "_GrabTexture" }

        Pass
        {
            Blend One OneMinusSrcAlpha
            ColorMask RGB
            Cull Back
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_particles
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
                float4 grabPos : TEXCOORD1;
                UNITY_FOG_COORDS(2)
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD3;
                float3 viewDir : TEXCOORD4;
                fixed4 color : COLOR;
                float fresnel : TEXCOORD5;
            };

            sampler2D _MainTex;
            sampler2D _GrabTexture;
            float4 _MainTex_ST;
            float4 _Color;
            float _RefractionStrength;
            float _FresnelPower;
            float _Glossiness;
            float _EdgeBrightness;
            float _ChromaticAberration;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                // Calculate grab position for refraction
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                
                // Calculate view-based effects
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                
                // Enhanced fresnel for thick plastic look
                float fresnel = pow(1.0 - saturate(dot(o.worldNormal, o.viewDir)), _FresnelPower);
                o.fresnel = fresnel;
                
                o.color = v.color;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.worldNormal);
                float3 viewDir = normalize(i.viewDir);
                
                // Calculate refraction offset based on normal
                float2 refractionOffset = normal.xy * _RefractionStrength;
                
                // Sample background with chromatic aberration for thick plastic look
                float4 grabR = tex2Dproj(_GrabTexture, i.grabPos + float4(refractionOffset * (1.0 + _ChromaticAberration), 0, 0));
                float4 grabG = tex2Dproj(_GrabTexture, i.grabPos + float4(refractionOffset, 0, 0));
                float4 grabB = tex2Dproj(_GrabTexture, i.grabPos + float4(refractionOffset * (1.0 - _ChromaticAberration), 0, 0));
                
                float4 grabCol = float4(grabR.r, grabG.g, grabB.b, 1.0);
                
                // Base color with refraction
                fixed4 col = tex2D(_MainTex, i.uv) * _Color * i.color;
                
                // Enhanced edge highlighting
                float edgeHighlight = pow(i.fresnel, 2.0) * _EdgeBrightness;
                
                // Specular highlight
                float3 reflectDir = reflect(-viewDir, normal);
                float spec = pow(max(0, reflectDir.y), 32.0) * _Glossiness;
                
                // Combine everything
                col.rgb = lerp(grabCol.rgb, col.rgb, col.a * 0.5);
                col.rgb += edgeHighlight * _Color.rgb;
                col.rgb += spec * _Color.rgb;
                
                // Maintain transparency while keeping highlights
                col.a = _Color.a * i.color.a + edgeHighlight * 0.1 + spec * 0.1;
                
                UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0));
                return col;
            }
            ENDCG
        }
    }
}
