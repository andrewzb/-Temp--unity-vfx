// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PortalFinal"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_twistStrength("twistStrength", Range( 0 , 10)) = 0
		_VoronoiScale("VoronoiScale", Range( 0 , 10)) = 0
		_VoronoiDensity("VoronoiDensity", Range( 0 , 10)) = 0
		_Speed("Speed", Vector) = (0,0,0,0)
		_Mask("Mask", 2D) = "white" {}
		[HDR]_DisolveColor("DisolveColor", Color) = (0,0,0,0)
		_DisolveTreshold("DisolveTreshold", Range( 0 , 1)) = 0
		_TwirlTilingOffset("TwirlTilingOffset", Vector) = (0,0,0,0)
		_OffsetMask1("OffsetMask", 2D) = "white" {}
		_offsetRange1("offsetRange", Range( -1 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Overlay+0" "IgnoreProjector" = "True" }
		Cull Off
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform sampler2D _OffsetMask1;
		uniform float4 _OffsetMask1_ST;
		uniform float _offsetRange1;
		uniform float _VoronoiScale;
		uniform float _VoronoiDensity;
		uniform float4 _TwirlTilingOffset;
		uniform float _twistStrength;
		uniform float2 _Speed;
		uniform float _DisolveTreshold;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float4 _DisolveColor;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform float _Cutoff = 0.5;


		float2 voronoihash24( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi24( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash24( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			
			 		}
			 	}
			}
			return F1;
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 uv_OffsetMask1 = v.texcoord * _OffsetMask1_ST.xy + _OffsetMask1_ST.zw;
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( tex2Dlod( _OffsetMask1, float4( uv_OffsetMask1, 0, 0.0) ) * float4( ( _offsetRange1 * ase_vertexNormal ) , 0.0 ) ).rgb;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float time24 = _VoronoiDensity;
			float2 voronoiSmoothId0 = 0;
			float2 appendResult67 = (float2(_TwirlTilingOffset.x , _TwirlTilingOffset.y));
			float2 uv_TexCoord26 = i.uv_texcoord * appendResult67;
			float2 appendResult68 = (float2(_TwirlTilingOffset.z , _TwirlTilingOffset.w));
			float2 center45_g1 = appendResult68;
			float2 delta6_g1 = ( uv_TexCoord26 - center45_g1 );
			float angle10_g1 = ( length( delta6_g1 ) * _twistStrength );
			float x23_g1 = ( ( cos( angle10_g1 ) * delta6_g1.x ) - ( sin( angle10_g1 ) * delta6_g1.y ) );
			float2 break40_g1 = center45_g1;
			float2 appendResult59 = (float2(( _Time.y * _Speed.x ) , ( 0.0 * _Speed.y )));
			float2 break41_g1 = appendResult59;
			float y35_g1 = ( ( sin( angle10_g1 ) * delta6_g1.x ) + ( cos( angle10_g1 ) * delta6_g1.y ) );
			float2 appendResult44_g1 = (float2(( x23_g1 + break40_g1.x + break41_g1.x ) , ( break40_g1.y + break41_g1.y + y35_g1 )));
			float2 coords24 = appendResult44_g1 * _VoronoiScale;
			float2 id24 = 0;
			float2 uv24 = 0;
			float fade24 = 0.5;
			float voroi24 = 0;
			float rest24 = 0;
			for( int it24 = 0; it24 <4; it24++ ){
			voroi24 += fade24 * voronoi24( coords24, time24, id24, uv24, 0,voronoiSmoothId0 );
			rest24 += fade24;
			coords24 *= 2;
			fade24 *= 0.5;
			}//Voronoi24
			voroi24 /= rest24;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor45 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPosNorm.xy);
			float4 lerpResult50 = lerp( screenColor45 , _DisolveColor , voroi24);
			o.Albedo = ( voroi24 > _DisolveTreshold ? screenColor45 : lerpResult50 ).rgb;
			o.Alpha = 1;
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			clip( ( tex2D( _Mask, uv_Mask ).r >= 0.5 ? ( voroi24 > _DisolveTreshold ? 0.0 : 1.0 ) : 0.0 ) - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18912
-1920;0;1920;1019;5950.129;1818.506;3.559124;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;64;-1637.308,247.3014;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;66;-1774.987,-192.4165;Inherit;False;Property;_TwirlTilingOffset;TwirlTilingOffset;9;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;56;-1632.514,119.6983;Inherit;False;Property;_Speed;Speed;5;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1389.308,157.3014;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;67;-1398.166,-193.2639;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1391.308,254.3014;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;68;-1375.166,-66.26385;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;59;-1212.308,187.3014;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1250.579,373.9867;Inherit;False;Property;_twistStrength;twistStrength;1;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-1205.125,-141.6983;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;28;-1241.232,449.4653;Inherit;False;Property;_VoronoiDensity;VoronoiDensity;4;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1237.1,533.4918;Inherit;False;Property;_VoronoiScale;VoronoiScale;2;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;44;-1212.068,-438.4387;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;23;-978.5167,4.353943;Inherit;True;Twirl;-1;;1;90936742ac32db8449cd21ab6dd337c8;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-734.0809,774.5955;Inherit;False;Property;_offsetRange1;offsetRange;11;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;120;-728.705,861.4169;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;45;-980.5297,-434.9849;Inherit;False;Global;_GrabScreen1;Grab Screen 1;8;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VoronoiNode;24;-564.9464,-7.333423;Inherit;True;0;0;1;0;4;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;2.5;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.RangedFloatNode;49;-520.7101,-501.6703;Inherit;False;Property;_DisolveTreshold;DisolveTreshold;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;46;-882.5976,-205.4067;Inherit;False;Property;_DisolveColor;DisolveColor;7;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;50;-570.8423,-191.8592;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;36;-179.616,233.2651;Inherit;True;Property;_Mask;Mask;6;0;Create;True;0;0;0;False;0;False;-1;19b1556208bace74d95f1dd403cba9a3;19b1556208bace74d95f1dd403cba9a3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Compare;111;-195.1791,-55.89212;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-411.6342,817.4526;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;119;-422.2902,553.7454;Inherit;True;Property;_OffsetMask1;OffsetMask;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-43.30313,683.405;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;48;-203.0213,-219.4721;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-341.9774,283.5431;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;115;91.82092,53.10791;Inherit;False;3;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-325.2596,153.0994;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-691.9535,356.8101;Inherit;False;Property;_OpcaityMultiply;OpcaityMultiply;3;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;281.2191,-34.41062;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;PortalFinal;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Opaque;;Overlay;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;54;0;64;0
WireConnection;54;1;56;1
WireConnection;67;0;66;1
WireConnection;67;1;66;2
WireConnection;60;1;56;2
WireConnection;68;0;66;3
WireConnection;68;1;66;4
WireConnection;59;0;54;0
WireConnection;59;1;60;0
WireConnection;26;0;67;0
WireConnection;23;1;26;0
WireConnection;23;2;68;0
WireConnection;23;3;25;0
WireConnection;23;4;59;0
WireConnection;45;0;44;0
WireConnection;24;0;23;0
WireConnection;24;1;28;0
WireConnection;24;2;27;0
WireConnection;50;0;45;0
WireConnection;50;1;46;0
WireConnection;50;2;24;0
WireConnection;111;0;24;0
WireConnection;111;1;49;0
WireConnection;117;0;118;0
WireConnection;117;1;120;0
WireConnection;116;0;119;0
WireConnection;116;1;117;0
WireConnection;48;0;24;0
WireConnection;48;1;49;0
WireConnection;48;2;45;0
WireConnection;48;3;50;0
WireConnection;39;0;24;0
WireConnection;39;1;33;0
WireConnection;115;0;36;1
WireConnection;115;2;111;0
WireConnection;37;1;24;0
WireConnection;0;0;48;0
WireConnection;0;10;115;0
WireConnection;0;11;116;0
ASEEND*/
//CHKSM=93DEF73213D6FC87CA2D92CA75FE3716C5787F56