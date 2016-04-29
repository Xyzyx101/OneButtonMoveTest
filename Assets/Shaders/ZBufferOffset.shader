Shader "Custom/ZBufferOffset"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_InteriorGridScale("Interior Grid Scale", Float) = 10
		_InteriorGridColor("Interior Grid Colour", Color) = ( 0, 1, 1, 1)
	}
	SubShader
	{
		Tags { "LightMode" = "ForwardBase" "RenderType" = "Opaque" "Queue" = "Geometry" }
		LOD 100
		Pass  // Main outside shader
		{
			ZTest LEqual
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog			
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

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
					fixed4 diff : COLOR0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
				nl * 0.5 + 0.5;
				nl *= nl;
				o.diff = nl * _LightColor0;
				return o;

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				col *= i.diff;

				float2 c = i.uv * 4;
				c = floor(c) / 2;
				float checker = frac(c.x + c.y) * 2;
				col += 0.1 * checker;

				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
			
		Pass // Interior Mask
		{
			Cull Front
			ZTest LEqual
			ZWrite Off
			Offset -0.05, -0.00005259 // Factor, Units - Factor scales the maximum Z slope, with respect to X or Y of the polygon, and units scale the minimum resolvable depth buffer value. Required to fix z fighting issues.
			Stencil{
				Ref 254
				Comp Always
				Pass Replace
				ZFail DecrSat
			}
			ColorMask 0
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			struct appdata {
				float4 vertex : POSITION;
			};
			struct v2f {
				float4 pos : SV_POSITION;
			};
			v2f vert(appdata v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}
			half4 frag(v2f i) : SV_Target{
				return 0;
			}
			ENDCG
		}

		//Pass
		//{
		//	Cull Off
		//	CGPROGRAM
		//	#pragma vertex vert
		//	#pragma fragment frag
		//	#include "UnityCG.cginc"

		//	sampler2D_float _CameraDepthTexture;

		//	struct v2f {
		//		float4 pos		: SV_POSITION;
		//		float4 scrPos	: TEXCOORD0;
		//	};

		//	v2f vert(appdata_base v) {
		//		v2f o;
		//		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		//		o.scrPos = ComputeScreenPos(o.pos);
		//		//for some reason, the y position of the depth texture comes out inverted
		//		//o.scrPos.y = 1 - o.scrPos.y;
		//		return o;
		//	}

		//	half4 frag(v2f i) : SV_Target{
		//		float depthValue = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r;

		//		half4 depth = Linear01Depth(depthValue);

		//		//depth.r = depthValue;
		//		//depth.g = depthValue;
		//		//depth.b = depthValue;

		//		depth.a = 1;
		//		return depth;
		//	}
		//	ENDCG
		//}

		//Pass // RED
		//{
		//	Cull Front
		//	ZTest Less
		//	Offset -0.05, -0.0000005 // Factor, Units - Factor scales the maximum Z slope, with respect to X or Y of the polygon, and units scale the minimum resolvable depth buffer value. Required to fix z fighting issues.
		//	Stencil{
		//		Ref 254
		//		Comp equal
		//	}
		//	CGPROGRAM
		//	#pragma vertex vert
		//	#pragma fragment frag
		//
		//	#include "UnityCG.cginc"
		//
		//	struct appdata
		//	{
		//		float4 vertex : POSITION;
		//		float2 uv : TEXCOORD0;
		//		float3 normal : NORMAL;
		//	};
		//
		//	struct v2f
		//	{
		//		float2 uv : TEXCOORD0;
		//		fixed4 diff : COLOR0;
		//		float4 vertex : SV_POSITION;
		//	};

		//	float4 _InteriorGridColor;
		//	float _InteriorGridScale;
		//
		//	v2f vert(appdata v)
		//	{
		//		v2f o;
		//		o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
		//		o.uv = v.uv * _InteriorGridScale;
		//		half3 worldNormal = UnityObjectToWorldNormal(v.normal);
		//		half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
		//		nl = nl * 0.25 + 0.5;
		//		o.diff = half4(1.0 * nl, 0, 0, 1.0);
		//		return o;
		//	}
		//
		//	fixed4 frag(v2f i) : SV_Target
		//	{
		//		fixed4 col = i.diff;
		//		return col;
		//	}
		//	ENDCG
		//}

		//Pass // Green
		//{
		//	Cull Front
		//	ZTest Always
		//	//Offset -1, -1 // Factor, Units - Factor scales the maximum Z slope, with respect to X or Y of the polygon, and units scale the minimum resolvable depth buffer value. Required to fix z fighting issues.
		//	Stencil{
		//		Ref 253
		//		Comp equal
		//	}
		//		CGPROGRAM
		//	#pragma vertex vert
		//	#pragma fragment frag

		//	#include "UnityCG.cginc"

		//	struct appdata
		//	{
		//		float4 vertex : POSITION;
		//		float2 uv : TEXCOORD0;
		//		float3 normal : NORMAL;
		//	};

		//	struct v2f
		//	{
		//		float2 uv : TEXCOORD0;
		//		fixed4 diff : COLOR0;
		//		float4 vertex : SV_POSITION;
		//	};

		//	float4 _InteriorGridColor;
		//	float _InteriorGridScale;

		//	v2f vert(appdata v)
		//	{
		//		v2f o;
		//		o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
		//		o.uv = v.uv * _InteriorGridScale;
		//		half3 worldNormal = UnityObjectToWorldNormal(v.normal);
		//		half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
		//		nl = nl * 0.25 + 0.5;
		//		o.diff = half4(0, 1.0 * nl, 0, 1.0);
		//		return o;
		//	}

		//	fixed4 frag(v2f i) : SV_Target
		//	{
		//		fixed4 col = i.diff;
		//		return col;
		//	}
		//	ENDCG
		//}

		Pass
		{
			Cull Front
			ZTest Less
			Offset -0.05, -0.00005259 // Factor, Units - Factor scales the maximum Z slope, with respect to X or Y of the polygon, and units scale the minimum resolvable depth buffer value. Required to fix z fighting issues.
			Stencil{
				Ref 254
				Comp equal
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
				fixed4 diff : COLOR0;
				float4 vertex : SV_POSITION;
			};
;
			float4 _InteriorGridColor;
			float _InteriorGridScale;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv * _InteriorGridScale;
				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
				nl = nl * 0.25 + 0.5;
				o.diff = _InteriorGridColor * nl;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = i.diff;
				float2 c = floor(i.uv) * 0.1;
				float gridLines = frac(c.y) * frac(c.x);
				gridLines = floor(1 - gridLines);
				col *= gridLines;
				return col;
			}
			ENDCG
		}
	

	}
	FallBack "Diffuse"
}
