﻿Shader "Custom/HolePrepare2"
{
	SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry+1" }
		//ColorMask 0
		ZWrite off

		CGINCLUDE
		
		ENDCG

		Pass {
			Cull Front
			ZTest Greater
			Stencil{
				Ref 2
				Comp always
				Pass replace
				ZFail DecrWrap
			}
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
				return half4(1,0,0,1);
			}
			ENDCG
		}

		Pass {
			Cull Back
			ZTest LEqual
			Stencil{
				Ref 2
				Comp Equal
				Pass Keep
				ZFail DecrWrap
			}
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
				return half4(0,1,0,1);
			}
			ENDCG
		}
	}
}
