// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BurnWorld"
{
	Properties
	{
		_Smothness("Smothness", Range( 0 , 1)) = 0
		_Float0("Float 0", Range( 0 , 1)) = 1
		_Float3("Float 3", Range( 0 , 1)) = 0.5
		_BaseAlbedo("BaseAlbedo", 2D) = "white" {}
		[HDR]_DesolveColor("DesolveColor", Color) = (0.359336,0.8018868,0.7973659,1)
		_LowerTcoord("LowerTcoord", Float) = 0
		_TopTcoord("TopTcoord", Float) = 0
		_FireRelativeheight("FireRelativeheight", Range( 0 , 1)) = 0
		_FireGap("FireGap", Range( 0 , 1)) = 0
		_fireDestorsionByheight("fireDestorsionByheight", Range( 0 , 10)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float _LowerTcoord;
		uniform float _TopTcoord;
		uniform float _FireRelativeheight;
		uniform float _FireGap;
		uniform float _fireDestorsionByheight;
		uniform float _Float0;
		uniform float _Float3;
		uniform sampler2D _BaseAlbedo;
		uniform float4 _BaseAlbedo_ST;
		uniform float4 _DesolveColor;
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
			float3 ase_worldPos = i.worldPos;
			float Height147 = _FireRelativeheight;
			float lerpResult155 = lerp( _LowerTcoord , _TopTcoord , Height147);
			float YHeightCoord156 = lerpResult155;
			float Gap148 = _FireGap;
			float temp_output_160_0 = ( Gap148 / 2.0 );
			float4 color139 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float4 White141 = color139;
			float4 color138 = IsGammaSpace() ? float4(0,0,0,1) : float4(0,0,0,1);
			float4 Black140 = color138;
			float4 FireMask162 = (( ase_worldPos.y >= ( YHeightCoord156 - temp_output_160_0 ) && ase_worldPos.y <= ( YHeightCoord156 + temp_output_160_0 ) ) ? White141 :  Black140 );
			float mulTime238 = _Time.y * 0.2;
			float2 uv_TexCoord189 = i.uv_texcoord + ( ( float2( 1,0 ) * mulTime238 ) + ( _SinTime.x * float2( 0,1 ) ) );
			float gradientNoise190 = GradientNoise(uv_TexCoord189,_fireDestorsionByheight);
			gradientNoise190 = gradientNoise190*0.5 + 0.5;
			float temp_output_203_0 = ( Gap148 / 2.0 );
			float temp_output_206_0 = ( YHeightCoord156 - temp_output_203_0 );
			float FireHeightGap246 = ( abs( ( ( YHeightCoord156 + temp_output_203_0 ) - temp_output_206_0 ) ) / abs( ( temp_output_206_0 - ase_worldPos.y ) ) );
			float temp_output_248_0 = ( FireHeightGap246 * _Float0 );
			float DesoleBorderMask196 = step( gradientNoise190 , ( temp_output_248_0 - _Float3 ) );
			float4 temp_cast_0 = (DesoleBorderMask196).xxxx;
			float4 HeightMask175 = ( ase_worldPos.y > YHeightCoord156 ? Black140 : White141 );
			float4 DesoleCompleatMask265 = ( FireMask162 == White141 ? temp_cast_0 : HeightMask175 );
			float4 color44 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float2 uv_BaseAlbedo = i.uv_texcoord * _BaseAlbedo_ST.xy + _BaseAlbedo_ST.zw;
			float4 Albedo51 = ( DesoleCompleatMask265 == color44 ? tex2D( _BaseAlbedo, uv_BaseAlbedo ) : _DesolveColor );
			o.Albedo = Albedo51.rgb;
			o.Smoothness = _Smothness;
			float OpacityMaskv2193 = step( gradientNoise190 , temp_output_248_0 );
			float4 temp_cast_2 = (OpacityMaskv2193).xxxx;
			float4 FireHeightOpacityMask187 = ( FireMask162 == White141 ? temp_cast_2 : HeightMask175 );
			o.Alpha = FireHeightOpacityMask187.r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18912
1920;1;1920;1018;3348.108;2329.53;1.783904;True;True
Node;AmplifyShaderEditor.RangedFloatNode;136;-2701.775,-867.2012;Inherit;False;Property;_FireRelativeheight;FireRelativeheight;17;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;147;-2413.497,-866.4417;Inherit;False;Height;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;-2735.317,-439.9762;Inherit;False;147;Height;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-2751.138,-656.6694;Inherit;False;Property;_LowerTcoord;LowerTcoord;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-2747.138,-572.6695;Inherit;False;Property;_TopTcoord;TopTcoord;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-2700.81,-773.7335;Inherit;False;Property;_FireGap;FireGap;18;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;148;-2414.307,-775.8547;Inherit;False;Gap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;155;-2537.552,-484.6153;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-3859.415,2949.44;Inherit;False;148;Gap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;156;-2352.951,-476.8152;Inherit;False;YHeightCoord;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;203;-3650.978,2940.222;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;-3696.815,2866.54;Inherit;False;156;YHeightCoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;254;-3682.892,2614.483;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;205;-3423.015,2934.84;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;206;-3431.978,2825.222;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;210;-3310.992,2699.885;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;208;-3266.992,2867.885;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;211;-3177.992,2701.885;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;209;-3138.992,2862.885;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;238;-2699.196,3749.932;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;235;-2704.494,3472.731;Inherit;False;Constant;_Vector5;Vector 5;20;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SinTimeNode;252;-2705.954,3604.228;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;236;-2690.395,3827.232;Inherit;False;Constant;_Vector6;Vector 6;20;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;212;-3028.992,2751.885;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;163;-2143.686,474.1425;Inherit;False;1200.457;673.5883;white - fire;11;159;157;160;158;161;144;143;145;134;162;256;FireMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;240;-2461.395,3787.232;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;246;-2891.561,2755.463;Inherit;False;FireHeightGap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;237;-2481.395,3587.232;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;-2093.686,828.3658;Inherit;False;148;Gap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;241;-2336.395,3675.232;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;138;-2703.67,-1265.047;Inherit;False;Constant;_Color1;Color 1;3;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;191;-2521.838,3240.031;Inherit;False;Property;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;139;-2695.661,-1071.016;Inherit;False;Constant;_Color0;Color 0;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;247;-2466.62,3149.271;Inherit;False;246;FireHeightGap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;160;-1885.249,819.1477;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;140;-2464.744,-1229.35;Inherit;False;Black;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;-1931.086,745.4664;Inherit;False;156;YHeightCoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;176;-2144.698,1219.349;Inherit;False;989.8214;578.5881;Black Transperant;7;170;169;165;172;174;175;255;Hight mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;197;-2060.458,3649.28;Inherit;False;Property;_Float3;Float 3;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;141;-2485.744,-1059.35;Inherit;False;White;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;248;-2021.619,3239.271;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;189;-2324.6,3310.565;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;213;-2670.542,3363.58;Inherit;False;Property;_fireDestorsionByheight;fireDestorsionByheight;19;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;256;-1728.853,523.77;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;195;-1782.584,3620.267;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;-2084.698,1681.937;Inherit;False;141;White;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;255;-1889.186,1268.569;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;143;-1910.238,951.7308;Inherit;False;141;White;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-1909.238,1031.731;Inherit;False;140;Black;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;190;-2090.3,3408.765;Inherit;True;Gradient;True;False;2;0;FLOAT2;0.5,0.5;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;161;-1666.249,704.1477;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;-2094.698,1601.937;Inherit;False;140;Black;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;-2079.545,1461.672;Inherit;False;156;YHeightCoord;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;158;-1657.286,813.7656;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareWithRange;145;-1402.934,725.6868;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;174;-1604.691,1437.375;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;194;-1627.209,3516.51;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;196;-1498.632,3537.571;Inherit;False;DesoleBorderMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;162;-1167.227,717.301;Inherit;False;FireMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;-1378.874,1443.708;Inherit;False;HeightMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;257;-2189.553,2431.138;Inherit;False;1026.831;435.6214;Comment;7;264;263;261;260;259;258;265;fireHeightOpasityMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;259;-2134.02,2481.138;Inherit;False;162;FireMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;258;-2133.064,2573.22;Inherit;False;141;White;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;260;-2149.892,2783.516;Inherit;False;196;DesoleBorderMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;264;-1803.155,2775.335;Inherit;False;175;HeightMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;261;-1628.346,2486.599;Inherit;False;0;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;192;-1749.116,3415.431;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;193;-1500.673,3338.866;Inherit;False;OpacityMaskv2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;186;-2148.159,1873.419;Inherit;False;1026.831;435.6214;Comment;7;181;187;180;179;185;178;177;fireHeightOpasityMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;265;-1402.271,2490.057;Inherit;False;DesoleCompleatMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;52;-2140.255,-1822.272;Inherit;False;1126.927;867.4808;Albedo;6;49;47;42;44;43;51;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;177;-1761.761,2217.616;Inherit;False;175;HeightMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;42;-2110.066,-1508.3;Inherit;True;Property;_BaseAlbedo;BaseAlbedo;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;185;-2108.498,2225.797;Inherit;False;193;OpacityMaskv2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;44;-2061.556,-1683.313;Inherit;False;Constant;_Color2;Color 2;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;43;-2058.325,-1767.991;Inherit;False;265;DesoleCompleatMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;179;-2091.67,2015.501;Inherit;False;141;White;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;47;-1886.543,-1203.774;Inherit;False;Property;_DesolveColor;DesolveColor;6;1;[HDR];Create;True;0;0;0;False;0;False;0.359336,0.8018868,0.7973659,1;0.359336,0.8018868,0.7973659,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;178;-2092.626,1923.419;Inherit;False;162;FireMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;49;-1444.213,-1576.339;Inherit;False;0;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;181;-1586.952,1928.88;Inherit;False;0;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;187;-1397.474,1953.199;Inherit;False;FireHeightOpacityMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;15;-2145.208,-81.23833;Inherit;False;1243.491;463.1858;Comment;10;22;32;31;29;16;21;1;38;11;12;Opacity Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-1237.328,-1569.815;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;64;-2146.162,-2692.601;Inherit;False;1114.413;676.8063;Comment;6;62;61;63;55;59;58;Emision;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;39;-2130.097,-800.1967;Inherit;False;963.3989;622.1345;Comment;6;41;34;40;20;33;76;DesolGap;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;59;-2094.191,-2566.642;Inherit;False;Constant;_Color3;Color 3;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-1384.223,-533.395;Inherit;False;DesolGap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;113;-4017.625,468.019;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;31;-1325.815,137.4408;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Exp2OpNode;251;-2189.813,3155.786;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-2085.667,-2642.601;Inherit;False;41;DesolGap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;34;-1593.035,-578.9051;Inherit;False;1;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1;-1745.905,34.69614;Inherit;True;Gradient;True;False;2;0;FLOAT2;0.5,0.5;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;112;-4320.641,380.8352;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;172;-2076.344,1269.349;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;198;-3692.614,2459.217;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;120;-3645.651,155.8095;Inherit;True;Gradient;True;False;2;0;FLOAT2;0.5,0.5;False;1;FLOAT;10.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-297.9165,39.64758;Inherit;False;62;Emision;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;55;-2089.864,-2213.023;Inherit;False;Property;_DesolveEmitionColor;DesolveEmitionColor;9;1;[HDR];Create;True;0;0;0;False;0;False;0.359336,0.8018868,0.7973659,1;0.359336,0.8018868,0.7973659,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1199.279,-40.20275;Inherit;False;OpacityMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;233;-3027.799,2271.383;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;180;-2098.159,2100.774;Inherit;False;140;Black;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;225;-3152.543,2139.23;Inherit;False;Constant;_Vector1;Vector 1;11;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Compare;61;-1584.689,-2562.54;Inherit;False;0;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;-2139.553,2658.493;Inherit;False;140;Black;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;154;-2513.178,-587.7669;Inherit;False;HierYcoord;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;110;-3048.641,268.8353;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;226;-2984.544,2155.23;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1763.442,-47.03811;Inherit;False;Property;_MaskStep;MaskStep;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-3536.641,426.8353;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-3583.641,325.8353;Inherit;False;Property;_Float1;Float 1;13;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;111;-4323.641,252.8353;Inherit;False;Constant;_Vector3;Vector 3;11;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.StepOpNode;21;-1447.722,36.36205;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;128;-4483.307,846.057;Inherit;False;Constant;_Color5;Color 5;3;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;116;-3806.56,428.496;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;223;-2999.544,1877.563;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-319.8394,164.1015;Inherit;False;Property;_Smothness;Smothness;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;76;-2015.099,-568.1543;Inherit;False;Constant;_Black;Black;3;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;132;-3963.762,1121.329;Inherit;False;Property;_HeightGap;HeightGap;12;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;115;-4007.851,161.8095;Inherit;False;Property;_Vector4;Vector 4;8;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;127;-4367.489,537.9712;Inherit;False;32;DesoleMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;153;-2518.178,-676.7668;Inherit;False;LowerYCoord;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-1232.963,-2435.144;Inherit;False;Emision;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-1994.368,-670.1589;Inherit;False;32;DesoleMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;134;-1932.885,524.1426;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;117;-3923.379,914.1541;Inherit;False;Property;_Float2;Float 2;11;0;Create;True;0;0;0;False;0;False;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;224;-3169.543,2322.23;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-1197.238,158.5021;Inherit;False;DesoleMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;131;-4341.022,658.1407;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;33;-1995.016,-750.1967;Inherit;False;16;OpacityMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;222;-3148.543,1856.563;Inherit;False;Constant;_Vector2;Vector 2;11;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;126;-3709.501,656.3038;Inherit;False;Constant;_Color4;Color 4;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-1759.064,270.2107;Inherit;False;Property;_DesoleGap;DesoleGap;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;129;-3439.767,598.9279;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-234.2365,-110.9859;Inherit;False;51;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;118;-3662.182,430.7504;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;125;-3606.679,902.3049;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;40;-2009.773,-363.1974;Inherit;False;Constant;_white;white;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;135;-2551.879,114.4842;Inherit;False;Property;_Yheight;Yheight;15;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;227;-2856.029,2038.697;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;221;-3145.543,1984.563;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;-1481.19,241.1979;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-4164.642,279.8353;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;133;-4524.197,16.3114;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;63;-2093.469,-2392.482;Inherit;False;Property;_AlbedoEmisionColor;AlbedoEmisionColor;10;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;17;-253.1302,326.0073;Inherit;False;187;FireHeightOpacityMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;11;-2108.102,40.69613;Inherit;False;Property;_Vector0;Vector 0;7;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-3414.641,207.8354;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;124;-3270.812,219.1309;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-4264.479,4.388884;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.1,0.1,0.1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-1960.205,40.49633;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;119;-3859.952,161.6098;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;103.6162,38.0631;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;BurnWorld;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;6;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;147;0;136;0
WireConnection;148;0;137;0
WireConnection;155;0;149;0
WireConnection;155;1;150;0
WireConnection;155;2;151;0
WireConnection;156;0;155;0
WireConnection;203;0;202;0
WireConnection;205;0;204;0
WireConnection;205;1;203;0
WireConnection;206;0;204;0
WireConnection;206;1;203;0
WireConnection;210;0;206;0
WireConnection;210;1;254;2
WireConnection;208;0;205;0
WireConnection;208;1;206;0
WireConnection;211;0;210;0
WireConnection;209;0;208;0
WireConnection;212;0;209;0
WireConnection;212;1;211;0
WireConnection;240;0;252;1
WireConnection;240;1;236;0
WireConnection;246;0;212;0
WireConnection;237;0;235;0
WireConnection;237;1;238;0
WireConnection;241;0;237;0
WireConnection;241;1;240;0
WireConnection;160;0;159;0
WireConnection;140;0;138;0
WireConnection;141;0;139;0
WireConnection;248;0;247;0
WireConnection;248;1;191;0
WireConnection;189;1;241;0
WireConnection;195;0;248;0
WireConnection;195;1;197;0
WireConnection;190;0;189;0
WireConnection;190;1;213;0
WireConnection;161;0;157;0
WireConnection;161;1;160;0
WireConnection;158;0;157;0
WireConnection;158;1;160;0
WireConnection;145;0;256;2
WireConnection;145;1;161;0
WireConnection;145;2;158;0
WireConnection;145;3;143;0
WireConnection;145;4;144;0
WireConnection;174;0;255;2
WireConnection;174;1;165;0
WireConnection;174;2;169;0
WireConnection;174;3;170;0
WireConnection;194;0;190;0
WireConnection;194;1;195;0
WireConnection;196;0;194;0
WireConnection;162;0;145;0
WireConnection;175;0;174;0
WireConnection;261;0;259;0
WireConnection;261;1;258;0
WireConnection;261;2;260;0
WireConnection;261;3;264;0
WireConnection;192;0;190;0
WireConnection;192;1;248;0
WireConnection;193;0;192;0
WireConnection;265;0;261;0
WireConnection;49;0;43;0
WireConnection;49;1;44;0
WireConnection;49;2;42;0
WireConnection;49;3;47;0
WireConnection;181;0;178;0
WireConnection;181;1;179;0
WireConnection;181;2;185;0
WireConnection;181;3;177;0
WireConnection;187;0;181;0
WireConnection;51;0;49;0
WireConnection;41;0;34;0
WireConnection;31;0;1;0
WireConnection;31;1;38;0
WireConnection;251;0;247;0
WireConnection;34;0;33;0
WireConnection;34;1;20;0
WireConnection;34;2;76;0
WireConnection;34;3;40;0
WireConnection;1;0;12;0
WireConnection;120;0;119;0
WireConnection;16;0;21;0
WireConnection;61;0;58;0
WireConnection;61;1;59;0
WireConnection;61;2;63;0
WireConnection;61;3;55;0
WireConnection;154;0;150;0
WireConnection;110;0;124;0
WireConnection;226;0;225;2
WireConnection;226;1;224;1
WireConnection;121;0;118;0
WireConnection;121;1;117;0
WireConnection;21;0;1;0
WireConnection;21;1;22;0
WireConnection;116;0;113;2
WireConnection;223;0;222;1
WireConnection;223;1;221;3
WireConnection;153;0;149;0
WireConnection;62;0;61;0
WireConnection;32;0;31;0
WireConnection;129;0;113;2
WireConnection;129;1;125;0
WireConnection;129;2;110;0
WireConnection;129;3;126;0
WireConnection;118;0;116;0
WireConnection;125;0;117;0
WireConnection;227;0;223;0
WireConnection;227;1;226;0
WireConnection;38;0;22;0
WireConnection;38;1;29;0
WireConnection;114;0;111;0
WireConnection;114;1;112;1
WireConnection;123;0;120;0
WireConnection;123;1;121;0
WireConnection;124;0;123;0
WireConnection;124;1;122;0
WireConnection;130;0;133;0
WireConnection;12;0;11;0
WireConnection;119;1;114;0
WireConnection;0;0;54;0
WireConnection;0;4;6;0
WireConnection;0;9;17;0
ASEEND*/
//CHKSM=C1C91AADE3BF16A78104DB1B8C7D2560B3B6903A