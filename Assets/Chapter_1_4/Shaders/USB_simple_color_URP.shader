Shader "Unlit/USB_simple_color_URP"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Space(10)]
        _Color ("Texture Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
           // "RenderPipeline" = "UniversalRenderPipeline"
        }
        
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            HLSLPROGRAM
// Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
#pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog
           // #pragma multi_compile _OPTIONS_OFF _OPTIONS_RED _OPTIONS_BLUE

            //#include "UnityCG.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata //the place where the object properties are stored - input
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL0;
            };

            struct v2f //vertex to fragment - output
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;// system value
                float3 normal : NORMAL0;
            };

            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float4 _Color;

            void FakeLight_float(in float3 Normal, out float3 Out)
            {
                Out = Normal;
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.normal = TransformObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            half4 frag(v2f i) : SV_Target
            {
                float3 n = i.normal;
                float3 col= 0;
                FakeLight_float(n, col);

                return float4(col.rgb, 1);
            }
            ENDHLSL
        }
    }
}