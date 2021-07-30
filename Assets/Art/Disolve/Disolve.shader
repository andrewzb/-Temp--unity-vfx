// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Disolve"
{
	Properties
	{
		_Smothness("Smothness", Range( 0 , 1)) = 0
		_MaskStep("MaskStep", Range( 0 , 1)) = 0.5
		_DesoleGap("DesoleGap", Range( 0 , 1)) = 0.5
		_BaseAlbedo("BaseAlbedo", 2D) = "white" {}
		_DesoleGapTexture("DesoleGapTexture", 2D) = "white" {}
		[Toggle(_DESOLVECOLORORTEXTURE_ON)] _DesolveColororTexture("Desolve Color or Texture", Float) = 1
		_DesolveColor("DesolveColor", Color) = (0.359336,0.8018868,0.7973659,1)
		_DesolveEmitionColor("DesolveEmitionColor", Color) = (0.359336,0.8018868,0.7973659,1)
		_AlbedoEmisionColor("AlbedoEmisionColor", Color) = (0,0,0,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Overlay"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma shader_feature_local _DESOLVECOLORORTEXTURE_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _MaskStep;
		uniform float _DesoleGap;
		uniform sampler2D _BaseAlbedo;
		uniform float4 _BaseAlbedo_ST;
		uniform float4 _DesolveColor;
		uniform sampler2D _DesoleGapTexture;
		uniform float4 _DesoleGapTexture_ST;
		uniform float4 _AlbedoEmisionColor;
		uniform float4 _DesolveEmitionColor;
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
			float2 uv_TexCoord12 = i.uv_texcoord * float2( 1,1 );
			float gradientNoise1 = GradientNoise(uv_TexCoord12,10.0);
			gradientNoise1 = gradientNoise1*0.5 + 0.5;
			float OpacityMask16 = step( gradientNoise1 , _MaskStep );
			float DesoleMask32 = step( gradientNoise1 , ( _MaskStep - _DesoleGap ) );
			float4 color26 = IsGammaSpace() ? float4(0,0,0,1) : float4(0,0,0,1);
			float4 color40 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float4 DesolGap41 = ( OpacityMask16 != DesoleMask32 ? color26 : color40 );
			float4 color44 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float2 uv_BaseAlbedo = i.uv_texcoord * _BaseAlbedo_ST.xy + _BaseAlbedo_ST.zw;
			float2 uv_DesoleGapTexture = i.uv_texcoord * _DesoleGapTexture_ST.xy + _DesoleGapTexture_ST.zw;
			#ifdef _DESOLVECOLORORTEXTURE_ON
				float4 staticSwitch46 = tex2D( _DesoleGapTexture, uv_DesoleGapTexture );
			#else
				float4 staticSwitch46 = _DesolveColor;
			#endif
			float4 Albedo51 = ( DesolGap41 == color44 ? tex2D( _BaseAlbedo, uv_BaseAlbedo ) : staticSwitch46 );
			o.Albedo = Albedo51.rgb;
			float4 color59 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float4 Emision62 = ( DesolGap41 == color59 ? _AlbedoEmisionColor : _DesolveEmitionColor );
			o.Emission = Emision62.rgb;
			o.Smoothness = _Smothness;
			o.Alpha = 1;
			clip( OpacityMask16 - _Smothness );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18912
1920;0;1920;1019;3095.076;2721.753;1.519084;True;True
Node;AmplifyShaderEditor.CommentaryNode;15;-2121.838,-182.9987;Inherit;False;1243.491;463.1858;Comment;10;22;32;31;29;16;21;1;12;11;38;Opacity Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;11;-2087.232,-64.46404;Inherit;False;Constant;_Vector0;Vector 0;4;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-1930.232,-59.46402;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-1657.691,180.1505;Inherit;False;Property;_DesoleGap;DesoleGap;2;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1662.069,-137.0985;Inherit;False;Property;_MaskStep;MaskStep;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1;-1652.231,-56.664;Inherit;True;Gradient;True;False;2;0;FLOAT2;0.5,0.5;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;-1379.817,151.1377;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;21;-1346.349,-53.69836;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;31;-1224.442,47.38063;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1166.669,-48.90171;Inherit;False;OpacityMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-1095.865,69.74196;Inherit;False;DesoleMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;39;-2104.781,-898.2963;Inherit;False;963.3989;622.1345;Comment;6;41;34;40;26;20;33;DesolGap;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;40;-1984.457,-461.2973;Inherit;False;Constant;_Color0;Color 0;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;20;-1969.052,-768.2585;Inherit;False;32;DesoleMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-1969.7,-848.2963;Inherit;False;16;OpacityMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;26;-1979.592,-666.5364;Inherit;False;Constant;_Color1;Color 1;3;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;52;-2121.268,-1815.943;Inherit;False;1126.927;867.4808;Albedo;8;49;45;47;42;46;44;43;51;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Compare;34;-1567.719,-677.0047;Inherit;False;1;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;64;-2146.162,-2784.373;Inherit;False;1114.413;676.8063;Comment;6;62;61;63;55;59;58;Emision;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;45;-2081.54,-1161.465;Inherit;True;Property;_DesoleGapTexture;DesoleGapTexture;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;47;-2067.242,-1373.366;Inherit;False;Property;_DesolveColor;DesolveColor;6;0;Create;True;0;0;0;False;0;False;0.359336,0.8018868,0.7973659,1;0.359336,0.8018868,0.7973659,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-1358.907,-631.4946;Inherit;False;DesolGap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;55;-2089.864,-2304.795;Inherit;False;Property;_DesolveEmitionColor;DesolveEmitionColor;7;0;Create;True;0;0;0;False;0;False;0.359336,0.8018868,0.7973659,1;0.359336,0.8018868,0.7973659,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;59;-2094.191,-2658.414;Inherit;False;Constant;_Color3;Color 3;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;42;-1811.946,-1501.464;Inherit;True;Property;_BaseAlbedo;BaseAlbedo;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;63;-2093.469,-2484.254;Inherit;False;Property;_AlbedoEmisionColor;AlbedoEmisionColor;8;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;43;-2027.922,-1765.943;Inherit;False;41;DesolGap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;46;-1811.832,-1295.581;Inherit;False;Property;_DesolveColororTexture;Desolve Color or Texture;5;0;Create;True;0;0;0;False;0;False;0;1;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;44;-2042.569,-1676.984;Inherit;False;Constant;_Color2;Color 2;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;58;-2084.544,-2734.373;Inherit;False;41;DesolGap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;49;-1416.067,-1576.882;Inherit;False;0;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;61;-1430.689,-2540.312;Inherit;False;0;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-1218.341,-1563.486;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-1232.963,-2526.916;Inherit;False;Emision;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-234.2365,-110.9859;Inherit;False;51;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-275.1302,302.0073;Inherit;False;16;OpacityMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-319.8394,164.1015;Inherit;False;Property;_Smothness;Smothness;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-297.9165,39.64758;Inherit;False;62;Emision;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Disolve;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Overlay;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;6;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;12;0;11;0
WireConnection;1;0;12;0
WireConnection;38;0;22;0
WireConnection;38;1;29;0
WireConnection;21;0;1;0
WireConnection;21;1;22;0
WireConnection;31;0;1;0
WireConnection;31;1;38;0
WireConnection;16;0;21;0
WireConnection;32;0;31;0
WireConnection;34;0;33;0
WireConnection;34;1;20;0
WireConnection;34;2;26;0
WireConnection;34;3;40;0
WireConnection;41;0;34;0
WireConnection;46;1;47;0
WireConnection;46;0;45;0
WireConnection;49;0;43;0
WireConnection;49;1;44;0
WireConnection;49;2;42;0
WireConnection;49;3;46;0
WireConnection;61;0;58;0
WireConnection;61;1;59;0
WireConnection;61;2;63;0
WireConnection;61;3;55;0
WireConnection;51;0;49;0
WireConnection;62;0;61;0
WireConnection;0;0;54;0
WireConnection;0;2;65;0
WireConnection;0;4;6;0
WireConnection;0;10;17;0
ASEEND*/
//CHKSM=4E0D69502C7DF6943F532D57184C05670C8D79CA