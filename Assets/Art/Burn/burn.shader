// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Disolve"
{
	Properties
	{
		_Smothness("Smothness", Range( 0 , 1)) = 0
		_Vector1("Vector 1", Vector) = (1,1,0,0)
		_Height("Height", Range( 0 , 2)) = 0
		_Float0("Float 0", Range( -1 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Overlay"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float _Height;
		uniform float2 _Vector1;
		uniform float _Float0;
		uniform float _Smothness;


		//https://www.shadertoy.com/view/XdXGW8
		float2 GradientNoiseDir( float2 x )
		{
			const float2 k = float2( 0.3183099, 0.3678794 );
			x = x * k + k.yx;
			return -1.0 + 2.0 * frac( 16.0 * k * frac( x.x * x.y * ( x.x + x.y ) ) );
		}
		
		float GradientNoise( float2 UV, float Scale )
		{
			float2 p = UV * Scale;
			float2 i = floor( p );
			float2 f = frac( p );
			float2 u = f * f * ( 3.0 - 2.0 * f );
			return lerp( lerp( dot( GradientNoiseDir( i + float2( 0.0, 0.0 ) ), f - float2( 0.0, 0.0 ) ),
					dot( GradientNoiseDir( i + float2( 1.0, 0.0 ) ), f - float2( 1.0, 0.0 ) ), u.x ),
					lerp( dot( GradientNoiseDir( i + float2( 0.0, 1.0 ) ), f - float2( 0.0, 1.0 ) ),
					dot( GradientNoiseDir( i + float2( 1.0, 1.0 ) ), f - float2( 1.0, 1.0 ) ), u.x ), u.y );
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float2 uv_TexCoord95 = i.uv_texcoord * _Vector1 + ( float2( 1,0 ) * _SinTime.x );
			float gradientNoise96 = GradientNoise(uv_TexCoord95,10.0);
			gradientNoise96 = gradientNoise96*0.5 + 0.5;
			float4 temp_cast_0 = (saturate( step( ( gradientNoise96 * ( ( ( ase_vertex3Pos.y + 1.0 ) / 2.0 ) * _Height ) ) , _Float0 ) )).xxxx;
			float4 color78 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			o.Albedo = ( ase_vertex3Pos.y > ( _Height - 1.0 ) ? temp_cast_0 : color78 ).rgb;
			o.Smoothness = _Smothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
-1920;0;1920;1019;2882.193;-374.7885;1;True;False
Node;AmplifyShaderEditor.Vector2Node;104;-2497.193,670.7885;Inherit;False;Constant;_Vector2;Vector 2;11;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SinTimeNode;100;-2494.193,798.7885;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;85;-2191.176,885.9722;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-2338.193,697.7885;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;97;-2181.402,579.7626;Inherit;False;Property;_Vector1;Vector 1;6;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;86;-1980.111,846.4492;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2096.931,1332.107;Inherit;False;Property;_Height;Height;9;0;Create;True;0;0;0;False;0;False;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;87;-1835.734,848.7036;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;95;-2033.503,579.5628;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;96;-1819.203,573.7626;Inherit;True;Gradient;True;False;2;0;FLOAT2;0.5,0.5;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-1710.193,844.7885;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-1757.193,743.7885;Inherit;False;Property;_Float0;Float 0;11;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-1588.193,625.7885;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;94;-1444.363,637.084;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;107;-1222.193,686.7885;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;64;-2146.162,-2692.601;Inherit;False;1114.413;676.8063;Comment;6;62;61;63;55;59;58;Emision;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;99;-1780.231,1320.258;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;78;-1883.053,1074.257;Inherit;False;Constant;_Color0;Color 0;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;15;-2109.18,10.03653;Inherit;False;1243.491;463.1858;Comment;10;22;32;31;29;16;21;1;38;11;12;Opacity Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;52;-2140.255,-1822.272;Inherit;False;1126.927;867.4808;Albedo;6;49;47;42;44;43;51;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;39;-2130.097,-800.1967;Inherit;False;963.3989;622.1345;Comment;6;41;34;40;20;33;76;DesolGap;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-2058.325,-1767.991;Inherit;False;41;DesolGap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-1924.175,131.7712;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;22;-1727.412,44.23675;Inherit;False;Property;_MaskStep;MaskStep;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;63;-2093.469,-2392.482;Inherit;False;Property;_AlbedoEmisionColor;AlbedoEmisionColor;8;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;58;-2085.667,-2642.601;Inherit;False;41;DesolGap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1163.249,51.07211;Inherit;False;OpacityMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;-2541.041,955.9243;Inherit;False;32;DesoleMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-297.9165,39.64758;Inherit;False;62;Emision;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;31;-1289.785,228.7158;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;79;-2642.104,1162.834;Inherit;False;Constant;_Color1;Color 1;3;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Compare;80;-1613.319,1016.881;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-2438.031,422.3418;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.1,0.1,0.1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-1384.223,-533.395;Inherit;False;DesolGap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-1994.368,-670.1589;Inherit;False;32;DesoleMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-275.1302,302.0073;Inherit;False;16;OpacityMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;71;-2614.748,199.2643;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;44;-2061.556,-1683.313;Inherit;False;Constant;_Color2;Color 2;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;83;-2514.574,1076.094;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-1237.328,-1569.815;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-319.8394,164.1015;Inherit;False;Property;_Smothness;Smothness;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;61;-1584.689,-2562.54;Inherit;False;0;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;11;-2072.074,131.971;Inherit;False;Property;_Vector0;Vector 0;5;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;33;-1995.016,-750.1967;Inherit;False;16;OpacityMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;42;-2058.066,-1507.3;Inherit;True;Property;_BaseAlbedo;BaseAlbedo;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;76;-2015.099,-568.1543;Inherit;False;Constant;_Black;Black;3;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;74;-2137.314,1539.283;Inherit;False;Property;_HeightGap;HeightGap;10;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;55;-2089.864,-2213.023;Inherit;False;Property;_DesolveEmitionColor;DesolveEmitionColor;7;1;[HDR];Create;True;0;0;0;False;0;False;0.359336,0.8018868,0.7973659,1;0.359336,0.8018868,0.7973659,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;1;-1709.875,125.971;Inherit;True;Gradient;True;False;2;0;FLOAT2;0.5,0.5;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-234.2365,-110.9859;Inherit;False;51;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;34;-1593.035,-578.9051;Inherit;False;1;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;21;-1411.692,127.6369;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;40;-2009.773,-363.1974;Inherit;False;Constant;_white;white;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;-1445.16,332.473;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;47;-2060.543,-1309.774;Inherit;False;Property;_DesolveColor;DesolveColor;4;1;[HDR];Create;True;0;0;0;False;0;False;0.359336,0.8018868,0.7973659,1;0.359336,0.8018868,0.7973659,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;59;-2094.191,-2566.642;Inherit;False;Constant;_Color3;Color 3;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-1232.963,-2435.144;Inherit;False;Emision;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-1161.208,249.7771;Inherit;False;DesoleMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;49;-1435.054,-1583.211;Inherit;False;0;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;66;-2697.748,434.2643;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;29;-1723.034,361.4858;Inherit;False;Property;_DesoleGap;DesoleGap;2;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Disolve;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Overlay;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;6;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;105;0;104;0
WireConnection;105;1;100;1
WireConnection;86;0;85;2
WireConnection;87;0;86;0
WireConnection;95;0;97;0
WireConnection;95;1;105;0
WireConnection;96;0;95;0
WireConnection;106;0;87;0
WireConnection;106;1;69;0
WireConnection;108;0;96;0
WireConnection;108;1;106;0
WireConnection;94;0;108;0
WireConnection;94;1;109;0
WireConnection;107;0;94;0
WireConnection;99;0;69;0
WireConnection;12;0;11;0
WireConnection;16;0;21;0
WireConnection;31;0;1;0
WireConnection;31;1;38;0
WireConnection;80;0;85;2
WireConnection;80;1;99;0
WireConnection;80;2;107;0
WireConnection;80;3;78;0
WireConnection;67;0;66;0
WireConnection;41;0;34;0
WireConnection;51;0;49;0
WireConnection;61;0;58;0
WireConnection;61;1;59;0
WireConnection;61;2;63;0
WireConnection;61;3;55;0
WireConnection;1;0;12;0
WireConnection;34;0;33;0
WireConnection;34;1;20;0
WireConnection;34;2;76;0
WireConnection;34;3;40;0
WireConnection;21;0;1;0
WireConnection;21;1;22;0
WireConnection;38;0;22;0
WireConnection;38;1;29;0
WireConnection;62;0;61;0
WireConnection;32;0;31;0
WireConnection;49;0;43;0
WireConnection;49;1;44;0
WireConnection;49;2;42;0
WireConnection;49;3;47;0
WireConnection;0;0;80;0
WireConnection;0;4;6;0
ASEEND*/
//CHKSM=0B4B187FA9072618F86290BFB8E0EAB8ABD07FBE