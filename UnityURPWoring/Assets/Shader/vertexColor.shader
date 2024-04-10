Shader "Unlit/vertexColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [ToggleOff]_R("R",float) = 0
        [ToggleOff]_G("G",float) = 0
        [ToggleOff]_B("B",float) = 0
        [ToggleOff]_A("A",float) = 0
        [ToggleOff]_L("L",float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                float4 vertexColor : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _R;
            float _G;
            float _B;
            float _A;
            float _L;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertexColor = v.vertexColor;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
              
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                if(_R)
                {
                return i.vertexColor.r;
                }
                if(_G)
                {
                return i.vertexColor.g;
                }
                if(_B)
                {
                return i.vertexColor.b;
                }
                if(_A)
                {
                return i.vertexColor.a;
                }                
                
                if(_L)
                {
                return i.vertexColor.x;
                }

                 return i.vertexColor;
               
            }
            ENDCG
        }
    }
}
