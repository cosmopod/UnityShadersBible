Shader "Unlit/USB_shadow_map"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        //shadow caster pass
        Pass
        {
            Name "Shadow Caster"
            Tags
            {
                "RenderType"="Opaque"
                "LightMode"="ShadowCaster"
            }

            Zwrite On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster


            #include "UnityCG.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_full v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }

        //default color pass - receive shadow
        Pass
        {
            Name "Shadow Map Texture"
            Tags
            {
                "RenderType"="Opaque"
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 shadowCoord : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            //sampler for store the shadow map, dont pass any texture dynamically
            //we will generate a projection which will work as a texture 
            sampler2D _ShadowMapTexture;

            // Converts Normalized Device Coords into UV coords
            float4 NDCToUV(float4 clipPos)
            {
                float4 o = clipPos * 0.5;
                #if defined(UNITY_HALF_TEXEL_OFFSET)
                o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w * _SceenParams.zw;
                #else
                o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w;
                #endif
                o.zw = clipPos.zw;
                return o;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.shadowCoord = NDCToUV(o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // uv coords for the shadow
                float2 uv_shadow = i.shadowCoord.xy / i.shadowCoord.w;
                // store the shadow texture in the internal shadow variable
                fixed shadow = tex2D(_ShadowMapTexture, uv_shadow).a;

                col *= shadow;
                return col;
            }
            ENDCG
        }
    }
}