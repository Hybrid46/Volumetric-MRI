Shader "Custom/TextureModifier"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_PaintUv("PaintUv", Vector) = (0,0,0,0)
		_Radius("Radius", Range(0.01,0.5)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
		
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _Radius;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				if ( distance( i.uv, float2(0.5,0.5) ) > _Radius ) return fixed4(0, 0, 0, 1);

				return tex2D(_MainTex, i.uv);
			}
			ENDCG
		}
	}
}