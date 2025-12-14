// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASE/Base/Transpatrent"
{
	Properties
	{
		_Color("Color", Color) = (0.1556604,0.2891586,1,0.5960785)
		_Texture("Texture", 2D) = "white" {}
		_ShaowColor("ShaowColor", Color) = (0.5711552,0.6109352,0.8018868,1)
		_Boundry("Boundry", Range( 0 , 1)) = 0.5
		_Smooth("Smooth", Range( 0 , 1)) = 1
		_HLColor("HLColor", Color) = (0,0,0,1)
		_HLBoundry("HLBoundry", Range( 0 , 1)) = 0
		_HLSmooth("HLSmooth", Range( 0 , 1)) = 0.5
		[HDR]_FreColor("FreColor", Color) = (0,1.224054,2.670157,1)
		_FreBoundry("FreBoundry", Range( 0 , 1)) = 0.19
		_FreSmooth("FreSmooth", Range( 0 , 1)) = 1
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_EmissionTex("EmissionTex", 2D) = "white" {}
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull [_CullMode]
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _CullMode;
		uniform float4 _Color;
		uniform sampler2D _Texture;
		uniform float4 _Texture_ST;
		uniform float4 _ShaowColor;
		uniform float _Boundry;
		uniform float _Smooth;
		uniform float4 _HLColor;
		uniform float _HLBoundry;
		uniform float _HLSmooth;
		uniform float _FreBoundry;
		uniform float _FreSmooth;
		uniform float4 _FreColor;
		uniform sampler2D _EmissionTex;
		uniform float4 _EmissionTex_ST;
		uniform float4 _EmissionColor;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_Texture = i.uv_texcoord * _Texture_ST.xy + _Texture_ST.zw;
			float4 MainTex99 = tex2D( _Texture, uv_Texture );
			float4 MainColor97 = _Color;
			float temp_output_42_0_g13 = (-1.0 + (0.5 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float dotResult3_g2 = dot( ase_worldlightDir , ase_worldNormal );
			float LightingModel85 = dotResult3_g2;
			float temp_output_38_0_g13 = LightingModel85;
			float smoothstepResult39_g13 = smoothstep( ( temp_output_42_0_g13 - 0.5 ) , ( temp_output_42_0_g13 + 0.5 ) , temp_output_38_0_g13);
			float lerpResult46_g13 = lerp( 1.0 , 0.0 , smoothstepResult39_g13);
			float smoothstepResult56_g13 = smoothstep( 0.0 , 0.5 , ase_lightAtten);
			float temp_output_14_0_g13 = (-1.0 + (_Boundry - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
			float temp_output_37_0_g13 = _Smooth;
			float smoothstepResult20_g13 = smoothstep( ( temp_output_14_0_g13 - temp_output_37_0_g13 ) , ( temp_output_14_0_g13 + temp_output_37_0_g13 ) , temp_output_38_0_g13);
			float4 lerpResult28_g13 = lerp( _ShaowColor , float4( 1,1,1,0 ) , ( saturate( ( lerpResult46_g13 + smoothstepResult56_g13 ) ) * smoothstepResult20_g13 ));
			float4 ShadowColor88 = lerpResult28_g13;
			float temp_output_4_0_g18 = (1.0 + (_HLBoundry - 0.0) * (0.0 - 1.0) / (1.0 - 0.0));
			float temp_output_15_0_g18 = _HLSmooth;
			float smoothstepResult8_g18 = smoothstep( ( temp_output_4_0_g18 - temp_output_15_0_g18 ) , ( temp_output_4_0_g18 + temp_output_15_0_g18 ) , LightingModel85);
			float4 lerpResult9_g18 = lerp( float4( 0,0,0,0 ) , _HLColor , smoothstepResult8_g18);
			float4 HighLightColor90 = lerpResult9_g18;
			float temp_output_22_0_g19 = ( 1.0 - (-0.2 + (_FreBoundry - 0.0) * (1.0 - -0.2) / (1.0 - 0.0)) );
			float temp_output_30_0_g19 = _FreSmooth;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV26_g19 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode26_g19 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV26_g19, 1.0 ) );
			float smoothstepResult28_g19 = smoothstep( ( temp_output_22_0_g19 - temp_output_30_0_g19 ) , ( temp_output_22_0_g19 + temp_output_30_0_g19 ) , fresnelNode26_g19);
			float4 temp_output_14_0_g19 = _FreColor;
			float4 Fresnel92 = ( smoothstepResult28_g19 * temp_output_14_0_g19 * (temp_output_14_0_g19).a );
			float2 uv_EmissionTex = i.uv_texcoord * _EmissionTex_ST.xy + _EmissionTex_ST.zw;
			float4 Emission94 = ( tex2D( _EmissionTex, uv_EmissionTex ) * _EmissionColor );
			c.rgb = ( ( MainTex99 * MainColor97 * ShadowColor88 ) + HighLightColor90 + Fresnel92 + Emission94 ).rgb;
			c.a = ( i.vertexColor.a * _Color.a );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha fullforwardshadows exclude_path:deferred noambient novertexlights nolightmap  nodirlightmap noforwardadd 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
				float3 worldNormal : TEXCOORD3;
				half4 color : COLOR0;
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
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
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
				surfIN.worldNormal = IN.worldNormal;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
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
Version=18935
0;26;1401;1080;3198.3;970.2512;1.601445;True;False
Node;AmplifyShaderEditor.CommentaryNode;87;-2820.38,-834.4528;Inherit;False;506.4866;166.528;LightingModel;2;72;85;光照模型;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;72;-2770.38,-777.9248;Inherit;False;LightingModel_Base;-1;;2;2d69c2a75ad764b40a4077c9804cced5;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;30;-2818.392,-141.0116;Inherit;False;824.6014;385.3089;ShadowColor;6;88;84;82;10;9;16;暗面颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-2548.722,-783.0994;Float;False;LightingModel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;16;-2804.346,-97.53683;Inherit;False;Property;_ShaowColor;ShaowColor;2;0;Create;True;0;0;0;False;0;False;0.5711552,0.6109352,0.8018868,1;0.5711552,0.6109352,0.8018868,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;29;-2802.948,282.1324;Inherit;False;805.474;396.9965;HighLightColor;6;90;86;73;26;28;25;高光颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;68;-2163.976,-596.7882;Inherit;False;818.8379;392.7597;Fresnel;5;92;75;65;66;67;菲涅尔;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-2794.968,78.6812;Inherit;False;Property;_Boundry;Boundry;3;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;100;-2821.909,-621.6583;Inherit;False;605.1252;447.5404;Comment;4;99;97;19;80;基础贴图和颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-2795.231,157.5198;Inherit;False;Property;_Smooth;Smooth;4;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;52;-2145.453,-1078.744;Inherit;False;692.8439;415.5112;Emission;4;94;55;54;53;自发光;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;84;-2492.773,-81.5411;Inherit;False;85;LightingModel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;54;-2075.843,-840.2601;Inherit;False;Property;_EmissionColor;EmissionColor;11;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;53;-2121.681,-1029.255;Inherit;True;Property;_EmissionTex;EmissionTex;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;86;-2480.275,384.5181;Inherit;False;85;LightingModel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2778.184,584.5659;Inherit;False;Property;_HLSmooth;HLSmooth;7;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-2125.317,-377.3264;Inherit;False;Property;_FreBoundry;FreBoundry;9;0;Create;True;0;0;0;False;0;False;0.19;0.19;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;28;-2738.441,338.9776;Inherit;False;Property;_HLColor;HLColor;5;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;66;-2128.067,-297.3757;Inherit;False;Property;_FreSmooth;FreSmooth;10;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;80;-2771.909,-571.6583;Inherit;True;Property;_Texture;Texture;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;19;-2710.322,-355.0781;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;0;False;0;False;0.1556604,0.2891586,1,0.5960785;0.1556604,0.2891586,1,0.5960785;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-2777.65,508.0947;Inherit;False;Property;_HLBoundry;HLBoundry;6;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;67;-2060.66,-548.3965;Inherit;False;Property;_FreColor;FreColor;8;1;[HDR];Create;True;0;0;0;False;0;False;0,1.224054,2.670157,1;0,1.224054,2.670157,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;82;-2501.096,6.107438;Inherit;True;Light_Shadow;-1;;13;7fd334ea8a37541079f58347518ddcb5;0;4;38;FLOAT;0;False;35;COLOR;0,0,0,0;False;36;FLOAT;0;False;37;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;97;-2440.783,-355.9112;Inherit;False;MainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1829.974,-1026.647;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-2441.091,-570.876;Inherit;False;MainTex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;73;-2481.554,472.6942;Inherit;False;Light_HighLight;-1;;18;0266fca0a32984b5d998165239f13ee6;0;4;16;FLOAT;0;False;13;COLOR;0,0,0,0;False;14;FLOAT;0;False;15;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;102;-1820.879,-95.98801;Inherit;False;914.2082;680.9962;;11;93;95;91;69;31;78;89;101;98;1;104;最终输出区域;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;75;-1844.073,-542.9095;Inherit;False;Light_Fresnel;-1;;19;3627a339a876842a381f1d0fa05ee3fd;0;3;14;COLOR;0,0,0,0;False;16;FLOAT;0;False;30;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-2191.62,2.532976;Float;False;ShadowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-2208.831,467.4092;Inherit;False;HighLightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-1762.562,80.86726;Inherit;False;97;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-1647.192,-1028.881;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-1770.879,156.9546;Inherit;False;88;ShadowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-1557.076,-547.0812;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-1763.826,2.74794;Inherit;False;99;MainTex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;-1675.197,470.0083;Inherit;False;94;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-1693.12,293.6819;Inherit;False;90;HighLightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1509.791,78.10472;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-1678.516,373.7425;Inherit;False;92;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;104;-1447.775,-67.8504;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;69;-1082.012,-45.98801;Inherit;False;Property;_CullMode;CullMode;13;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-1250.775,142.1496;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-1323.236,289.3524;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;1;-1161.671,59.23817;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;ASE/Base/Transpatrent;False;False;False;False;True;True;True;False;True;False;False;True;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.44;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;69;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;85;0;72;0
WireConnection;82;38;84;0
WireConnection;82;35;16;0
WireConnection;82;36;9;0
WireConnection;82;37;10;0
WireConnection;97;0;19;0
WireConnection;55;0;53;0
WireConnection;55;1;54;0
WireConnection;99;0;80;0
WireConnection;73;16;86;0
WireConnection;73;13;28;0
WireConnection;73;14;25;0
WireConnection;73;15;26;0
WireConnection;75;14;67;0
WireConnection;75;16;65;0
WireConnection;75;30;66;0
WireConnection;88;0;82;0
WireConnection;90;0;73;0
WireConnection;94;0;55;0
WireConnection;92;0;75;0
WireConnection;78;0;101;0
WireConnection;78;1;98;0
WireConnection;78;2;89;0
WireConnection;103;0;104;4
WireConnection;103;1;19;4
WireConnection;31;0;78;0
WireConnection;31;1;91;0
WireConnection;31;2;93;0
WireConnection;31;3;95;0
WireConnection;1;9;103;0
WireConnection;1;13;31;0
ASEEND*/
//CHKSM=227E41B298377120012EB4EDB563B5B96B3A7188