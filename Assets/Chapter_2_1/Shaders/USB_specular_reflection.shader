Shader "Unlit/USB_specular_reflection"
{
    Properties
    {
        //mode white
        _MainTex ("Texture", 2D) = "white" {}
        
        //mode black
        _SpecularTex ("Texture", 2D) = "black" {}
        _SpecularInt ("Specular Intensity", Range(0, 1)) = 1
        _SpecularPow ("Specular Power", Range(1, 128)) = 64

    }
    SubShader
    {
        Tags { "RenderType"="Opaque"
                "LightMode" = "ForwardBase"
             }
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal_world : TEXCOORD1;
                float3 vertex_world : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _SpecularTex; //due to its nature _SpecularTex_ST has been discarded because
            // specular maps do not need generally tiling and offset
            
            float _SpecularInt;
            float _SpecularPow;
            float4 _LightColor0;

            float3 specularShading
            (
                float3 colorRefl,
                float specularInt,
                float3 normal,
                float3 lightDir,
                float3 viewDir,
                float specularPow)
            {
                float3 halfWay = normalize(lightDir + viewDir);
                return colorRefl * specularInt * pow(max(0, dot(normal, halfWay)), specularPow);
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.vertex_world);
                half3 normal = i.normal_world;
                fixed3 colorRefl = _LightColor0.rgb;
                fixed3 specColor = tex2D(_SpecularTex, i.uv) * colorRefl;

                half3 specular = specularShading(specColor, _SpecularInt, normal, lightDir, viewDir, _SpecularPow);
                
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                col.rgb += specular;
                return col;
            }
            ENDCG
        }
    }
}
