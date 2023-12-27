Shader "Unlit/USB_Normal_Map"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Space(10)]
        _NormalMap("Normal Map", 2D) = "white" {}
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
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float2 uv_normal : TEXCOORD1;
                float3 normal_world : TEXCOORD2;
                float4 tangent_world : TEXCOORD3;
                float3 binormal_world : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            float3 DXTCompression (float4 normalMap)
            {
                #if defined  (UNITY_NO_DXT5nm)
                    return normalMap.rgb * 2 - 1;
                #else
                    float3 normalCol;
                    //we calculate de RG channels for NormalCol using AG
                    normalCol = float3(normalMap.a * 2 - 1, normalMap.g * 2 - 1, 0);

                    //third channel of normalCol vector is calculated indp. based on previous AG coords
                    // B coor must still calculate otherwise texture will not work correctly
                    normalCol.b = sqrt(1 - (pow(normalCol.r, 2) + pow(normalCol.g, 2)));
                    return normalCol;
                #endif
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                //UNITY_TRANSFER_FOG(o,o.vertex);

                //tiling and offset to the normal map
                o.uv_normal = TRANSFORM_TEX(v.uv, _NormalMap);

                //transform the normals to world space
                o.normal_world = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0)));

                //transform tangent to world space
                o.tangent_world = normalize(mul(v.tangent, unity_WorldToObject));

                //crossProduct between normals and tangents (binormal)
                o.binormal_world = normalize(cross(o.normal_world, o.tangent_world) * v.tangent.w);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);

                fixed4 normal_map = tex2D(_NormalMap, i.uv_normal);
                fixed3 normal_map_compressed = DXTCompression(normal_map);

                float3x3 TBN_matrix = float3x3
                (
                    i.tangent_world.xyz,
                    i.binormal_world,
                    i.normal_world
                );
                fixed3 normal_color = normalize(mul(normal_map_compressed, TBN_matrix));
                
                return float4(normal_color, 1);
            }
            ENDCG
        }
    }
}
