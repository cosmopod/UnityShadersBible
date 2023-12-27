Shader "Unlit/USB_function_SmoothStep"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Smooth("Gradient Amount", Range(0,1)) = 0.1
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Smooth;

            float smoothstep(float a, float b, float edge)
            {
                //normalization if edge == a then t== 0; if edge == b then t == 1 
                float t = saturate((edge - a) / (b - a));
                //algortimo de interpolacion
                return t * t * (3.0 - (2.0 * t));
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float edge = 0.5;
                
                //add the return value in RGB
                fixed3 sstep = 0;

                sstep = smoothstep((i.uv.y - _Smooth), (i.uv.y + _Smooth), edge);
                
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
               // UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(sstep, 1) * col;
            }
            ENDCG
        }
    }
}
