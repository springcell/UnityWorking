 Shader "Unlit/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaterRT ("WaterRT", 2D) = "white" {}
        WaterNormal("WaterNormal",float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
       // Zwrite Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 scrPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _WaterRT;
            float4 _WaterRT_ST;
            float WaterNormal;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.scrPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            half3 NormalMaps (half3 Color, float Str  )
            {
                float lum = dot(Color,half3(0.333,0.333,0.333));
                float f =1-fwidth( lum );
                half3 nor = normalize(half3( ddx(lum), max(0.05,1-Str), ddy(lum) )).xzy + 0.5;
                return nor;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 screenPos = i.scrPos.xy / i.scrPos.w;
                
                fixed4 Water = tex2D(_WaterRT, screenPos);

                Water.rgb = NormalMaps(saturate(Water.rgb),WaterNormal);
                
                fixed4 col = tex2D(_MainTex, i.uv + Water.rg);

                return Water;
            }
            ENDCG
        }
    }
}
