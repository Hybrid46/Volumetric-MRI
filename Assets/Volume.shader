Shader "VolumeRendering/VolumeRendering"
{
	Properties
	{
		[HDR]_Color ("Color", Color) = (1, 1, 1, 1)
		[NoScaleOffset]_Volume ("Volume", 3D) = "" {}

		[Toggle(GRADIENT)] _Fancy("Enable Gradient", Float) = 0
		[Toggle(ADDITIVEBLENDING)] _AdditiveBlending("Additive Blending", Float) = 1
		[NoScaleOffset]_Gradient("Gradient", 2D) = "white" {}

		_Intensity ("Intensity", Range(0.1, 5.0)) = 1.2
		_Threshold ("Threshold", Range(0.0, 1.0)) = 0.95
		_DiscardThreshold ("Pixel Discard Threshold", Range(0.0, 1.0)) = 0.95
		_SliceMin ("Slice min", Vector) = (0.0, 0.0, 0.0, -1.0)
		_SliceMax ("Slice max", Vector) = (1.0, 1.0, 1.0, -1.0)
		_Iterations("Iterations", Range(64,4096)) = 256
	}

	CGINCLUDE

	ENDCG

	SubShader {
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		// ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature GRADIENT
			#pragma shader_feature ADDITIVEBLENDING
			#pragma target 4.6

			#include "UnityCG.cginc" 

			half4 _Color;
			sampler3D _Volume;

			#ifdef GRADIENT
				sampler2D _Gradient;
			#endif

			half _Intensity, _Threshold, _DiscardThreshold;
			half3 _SliceMin, _SliceMax;
			float4x4 _AxisRotationMatrix;
			int _Iterations;

			struct Ray {
			  float3 origin;
			  float3 dir;
			};

			struct AABB {
			  float3 min;
			  float3 max;
			};

			bool intersect(Ray r, AABB aabb, out float t0, out float t1)
			{
				float3 invR = 1.0 / r.dir;
				float3 tbot = invR * (aabb.min - r.origin);
				float3 ttop = invR * (aabb.max - r.origin);
				float3 tmin = min(ttop, tbot);
				float3 tmax = max(ttop, tbot);
				float2 t = max(tmin.xx, tmin.yz);
				t0 = max(t.x, t.y);
				t = min(tmax.xx, tmax.yz);
				t1 = min(t.x, t.y);
				return t0 <= t1;
			}

			float3 get_uv(float3 p) { return (p + 0.5); }

			float sample_volume(float3 uv, float3 p)
			{
				float v = tex3D(_Volume, uv).r * _Intensity;

				float3 axis = mul(_AxisRotationMatrix, float4(p, 0)).xyz;
				axis = get_uv(axis);
				float min = step(_SliceMin.x, axis.x) * step(_SliceMin.y, axis.y) * step(_SliceMin.z, axis.z);
				float max = step(axis.x, _SliceMax.x) * step(axis.y, _SliceMax.y) * step(axis.z, _SliceMax.z);

				return v * min * max;
			}

			bool outside(float3 uv)
			{
				const float EPSILON = 0.01;
				float lower = -EPSILON;
				float upper = 1 + EPSILON;

				return (uv.x < lower || uv.y < lower || uv.z < lower ||
						uv.x > upper || uv.y > upper || uv.z > upper );
			}

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 world : TEXCOORD1;
				float3 local : TEXCOORD2;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.world = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.local = v.vertex.xyz;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				Ray ray;
				ray.origin = i.local;

				float3 dir = (i.world - _WorldSpaceCameraPos);
				ray.dir = normalize(mul(unity_WorldToObject, dir));

				AABB aabb;
				aabb.min = float3(-0.5, -0.5, -0.5);
				aabb.max = float3(0.5, 0.5, 0.5);

				float tnear;
				float tfar;

				intersect(ray, aabb, tnear, tfar);

				tnear = max(0.0, tnear);

				float3 start = ray.origin;
				float3 end = ray.origin + ray.dir * tfar;
				float dist = abs(tfar - tnear);
				float step_size = dist / float(_Iterations);
				float3 ds = normalize(end - start) * step_size;

				float4 dst = float4(0, 0, 0, 0);
				float3 p = start;

				[loop]
				for (int iter = 0; iter < _Iterations; iter++)
				{
					float3 uv = get_uv(p);
					float v = sample_volume(uv, p);
					float4 src = float4(v, v, v, v);

					#ifdef ADDITIVEBLENDING
						src.a *= 0.5;
						src.rgb *= src.a;

						// blend
						dst = (1.0 - dst.a) * src + dst;
					#else
						dst = src;
					#endif

					p += ds;

					dst.a *= _Color.a;

					#ifdef GRADIENT
						dst.rgb *= tex2D(_Gradient, float2(src.a * 2,0));
					#endif

					if (dst.a > _Threshold) break;
				}
					if (dst.a < _DiscardThreshold) discard;
					dst.rgb *= _Color.rgb; 

			  return saturate(dst);
			}
			ENDCG
		}
	}
}