Shader "VRChat/Mobile/Particles/Additive"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,0.5)
        _FlowSpeed ("Flow Speed", Range(0,2)) = 0.5
        _IridescenceStrength ("Iridescence Strength", Range(0,1)) = 0.5
        _EmissionStrength ("Emission Strength", Range(0,3)) = 1.0
        _LineScale ("Line Scale", Range(1,10)) = 3.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
        LOD 100

        Blend One OneMinusSrcAlpha
        ColorMask RGB
        Cull Off Lighting Off ZWrite Off

        Pass
        {
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BaseColor;
            float _FlowSpeed;
            float _IridescenceStrength;
            float _EmissionStrength;
            float _LineScale;

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
                // Base color and texture
                fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor * i.color;
                
                // Simple flowing pattern
                float time = _Time.y * _FlowSpeed;
                float2 flowUV = i.uv * _LineScale;
                
                // Basic patterns
                float pattern1 = sin(flowUV.x * 3.14 + flowUV.y * 2.14 + time) * 0.5 + 0.5;
                float pattern2 = sin(flowUV.x * 1.57 - flowUV.y * 3.14 + time * 0.7) * 0.5 + 0.5;
                
                // Simple color blend
                float3 color1 = lerp(float3(0.0, 0.4, 1.0), float3(1.0, 0.0, 0.6), pattern1);
                float3 color2 = lerp(float3(0.0, 1.0, 0.3), float3(1.0, 0.5, 0.0), pattern2);
                float3 iridescence = lerp(color1, color2, pattern1);
                
                // View-based effect
                float ndotv = saturate(dot(normalize(i.worldNormal), normalize(i.viewDir)));
                float fresnel = pow(1.0 - ndotv, 1.7);
                
                // Apply effects
                col.rgb += iridescence * fresnel * _IridescenceStrength * _EmissionStrength;
                col.rgb *= col.a;
                
                UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0));
                return col;
            }
            ENDCG
        }
    }
}
