// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASE/Base"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Texture("Texture", 2D) = "white" {}
		_HSVC("HSVC", Vector) = (0,0,0,0)
		_ShaowColor("ShaowColor", Color) = (0.5711552,0.6109352,0.8018868,1)
		_Boundry("Boundry", Range( 0 , 1)) = 0.5
		_Smooth("Smooth", Range( 0 , 1)) = 0.5
		_HLColor("HLColor", Color) = (0,0,0,1)
		_HLBoundry("HLBoundry", Range( 0 , 1)) = 0
		_HLSmooth("HLSmooth", Range( 0 , 1)) = 0.5
		[HDR]_FreColor("FreColor", Color) = (0,0,0,1)
		_FreBoundry("FreBoundry", Range( 0 , 1)) = 0.3494399
		_FreSmooth("FreSmooth", Range( 0 , 1)) = 0.4470588
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_EmissionTex("EmissionTex", 2D) = "white" {}
		_NormalTex("NormalTex", 2D) = "bump" {}
		_NormalInt("NormalInt", Range( 0 , 1)) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull [_CullMode]
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
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
		uniform float4 _HSVC;
		uniform sampler2D _Texture;
		uniform float4 _Texture_ST;
		uniform float4 _Color;
		uniform float4 _ShaowColor;
		uniform sampler2D _NormalTex;
		uniform float4 _NormalTex_ST;
		uniform float _NormalInt;
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


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

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
			float4 lerpResult4_g41 = lerp( float4( float3(0.5,0.5,0.5) , 0.0 ) , tex2D( _Texture, uv_Texture ) , ( _HSVC.w + 1.0 ));
			float3 hsvTorgb6_g41 = RGBToHSV( lerpResult4_g41.xyz );
			float3 hsvTorgb10_g41 = HSVToRGB( float3(( _HSVC.x + hsvTorgb6_g41.x ),( ( _HSVC.y + 1.0 ) * hsvTorgb6_g41.y ),( ( _HSVC.z + 1.0 ) * hsvTorgb6_g41.z )) );
			float3 appendResult11_g41 = (float3(hsvTorgb10_g41));
			float3 MainTex99 = appendResult11_g41;
			float4 MainColor97 = _Color;
			float temp_output_42_0_g42 = (-1.0 + (0.5 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float2 uv_NormalTex = i.uv_texcoord * _NormalTex_ST.xy + _NormalTex_ST.zw;
			float3 lerpResult12_g37 = lerp( float3(0,0,1) , UnpackNormal( tex2D( _NormalTex, uv_NormalTex ) ) , (0.0 + (_NormalInt - 0.0) * (3.0 - 0.0) / (1.0 - 0.0)));
			float3 normalizeResult14_g37 = normalize( lerpResult12_g37 );
			float3 temp_output_126_21 = (WorldNormalVector( i , normalizeResult14_g37 ));
			float dotResult124 = dot( ase_worldlightDir , temp_output_126_21 );
			float LightingModel85 = dotResult124;
			float temp_output_38_0_g42 = LightingModel85;
			float smoothstepResult39_g42 = smoothstep( ( temp_output_42_0_g42 - 0.5 ) , ( temp_output_42_0_g42 + 0.5 ) , temp_output_38_0_g42);
			float lerpResult46_g42 = lerp( 1.0 , 0.0 , smoothstepResult39_g42);
			float smoothstepResult56_g42 = smoothstep( 0.0 , 0.5 , ase_lightAtten);
			float temp_output_14_0_g42 = (-1.0 + (_Boundry - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
			float temp_output_37_0_g42 = _Smooth;
			float smoothstepResult20_g42 = smoothstep( ( temp_output_14_0_g42 - temp_output_37_0_g42 ) , ( temp_output_14_0_g42 + temp_output_37_0_g42 ) , temp_output_38_0_g42);
			float4 lerpResult28_g42 = lerp( _ShaowColor , float4( 1,1,1,0 ) , ( saturate( ( lerpResult46_g42 + smoothstepResult56_g42 ) ) * smoothstepResult20_g42 ));
			float4 ShadowColor88 = lerpResult28_g42;
			float temp_output_4_0_g43 = (1.0 + (_HLBoundry - 0.0) * (0.0 - 1.0) / (1.0 - 0.0));
			float temp_output_15_0_g43 = _HLSmooth;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult18_g38 = normalize( ( ase_worldlightDir + ase_worldViewDir ) );
			float dotResult125 = dot( temp_output_126_21 , normalizeResult18_g38 );
			float LightingModel_HL113 = dotResult125;
			float smoothstepResult8_g43 = smoothstep( ( temp_output_4_0_g43 - temp_output_15_0_g43 ) , ( temp_output_4_0_g43 + temp_output_15_0_g43 ) , LightingModel_HL113);
			float4 lerpResult9_g43 = lerp( float4( 0,0,0,0 ) , _HLColor , smoothstepResult8_g43);
			float4 HighLightColor90 = lerpResult9_g43;
			float temp_output_22_0_g44 = ( 1.0 - (-0.2 + (_FreBoundry - 0.0) * (1.0 - -0.2) / (1.0 - 0.0)) );
			float temp_output_30_0_g44 = _FreSmooth;
			float3 WorldNormal_NormalTex129 = temp_output_126_21;
			float fresnelNdotV26_g44 = dot( WorldNormal_NormalTex129, ase_worldViewDir );
			float fresnelNode26_g44 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV26_g44, 1.0 ) );
			float smoothstepResult28_g44 = smoothstep( ( temp_output_22_0_g44 - temp_output_30_0_g44 ) , ( temp_output_22_0_g44 + temp_output_30_0_g44 ) , fresnelNode26_g44);
			float4 temp_output_14_0_g44 = _FreColor;
			float4 Fresnel92 = ( smoothstepResult28_g44 * temp_output_14_0_g44 * (temp_output_14_0_g44).a );
			float2 uv_EmissionTex = i.uv_texcoord * _EmissionTex_ST.xy + _EmissionTex_ST.zw;
			float4 Emission94 = ( tex2D( _EmissionTex, uv_EmissionTex ) * _EmissionColor );
			c.rgb = ( ( float4( MainTex99 , 0.0 ) * MainColor97 * ShadowColor88 ) + HighLightColor90 + Fresnel92 + Emission94 ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred noambient novertexlights nolightmap  nodirlightmap noforwardadd 

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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
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
473;190;1495;1160;2972.967;1160.574;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;87;-3217.689,-1148.037;Inherit;False;1018.887;478.1857;LightingModel;8;113;125;85;124;121;107;108;129;光照模型;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;108;-3190.224,-1006.075;Inherit;True;Property;_NormalTex;NormalTex;14;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;107;-3179.323,-1092.774;Inherit;False;Property;_NormalInt;NormalInt;15;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;121;-2861.758,-1098.044;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;126;-2884.411,-951.8057;Inherit;False;LightingModel_Normal_Tex;-1;;37;199a4b449c0174475b6993902d3051f8;0;2;20;FLOAT3;0,0,0;False;17;FLOAT;0;False;1;FLOAT3;21
Node;AmplifyShaderEditor.DotProductOpNode;124;-2569.87,-1094.253;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;127;-2887.498,-762.741;Inherit;False;LightingModel_Dir_HighLight;-1;;38;7a515b594b1a08c4e8f9a74b40ac93eb;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;125;-2565.87,-787.0958;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-2399.03,-1096.883;Float;False;LightingModel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;100;-3013.909,-621.6583;Inherit;False;797.1252;444.5404;Comment;6;80;103;97;99;19;104;基础贴图和颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;30;-2818.392,-141.0116;Inherit;False;824.6014;385.3089;ShadowColor;6;88;84;82;10;9;16;暗面颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;80;-2987.909,-574.6583;Inherit;True;Property;_Texture;Texture;1;0;Create;True;0;0;0;False;0;False;-1;750b1bd7ba8bd28489650de6d0a95cc5;750b1bd7ba8bd28489650de6d0a95cc5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;84;-2492.773,-81.5411;Inherit;False;85;LightingModel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-2795.231,157.5198;Inherit;False;Property;_Smooth;Smooth;5;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;68;-2163.976,-596.7882;Inherit;False;818.8379;392.7597;Fresnel;5;92;65;66;67;131;菲涅尔;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;104;-2931.847,-360.9985;Inherit;False;Property;_HSVC;HSVC;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;9;-2794.968,78.6812;Inherit;False;Property;_Boundry;Boundry;4;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;16;-2804.346,-97.53683;Inherit;False;Property;_ShaowColor;ShaowColor;3;0;Create;True;0;0;0;False;0;False;0.5711552,0.6109352,0.8018868,1;0.5711552,0.6109352,0.8018868,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;52;-2145.453,-1078.744;Inherit;False;692.8439;415.5112;Emission;4;94;55;54;53;自发光;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-2802.948,282.1324;Inherit;False;805.474;396.9965;HighLightColor;6;90;86;73;26;28;25;高光颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;-2427.915,-765.8422;Float;False;LightingModel_HL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-2452.313,-954.9591;Inherit;False;WorldNormal_NormalTex;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-1866.317,-377.3264;Inherit;False;Property;_FreBoundry;FreBoundry;10;0;Create;True;0;0;0;False;0;False;0.3494399;0.165;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;53;-2121.681,-1029.255;Inherit;True;Property;_EmissionTex;EmissionTex;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;86;-2480.275,384.5181;Inherit;False;113;LightingModel_HL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1867.067,-299.3757;Inherit;False;Property;_FreSmooth;FreSmooth;11;0;Create;True;0;0;0;False;0;False;0.4470588;0.715;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2777.65,508.0947;Inherit;False;Property;_HLBoundry;HLBoundry;7;0;Create;True;0;0;0;False;0;False;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;82;-2501.096,6.107438;Inherit;True;Light_Shadow;-1;;42;7fd334ea8a37541079f58347518ddcb5;0;4;38;FLOAT;0;False;35;COLOR;0,0,0,0;False;36;FLOAT;0;False;37;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;54;-2075.843,-840.2601;Inherit;False;Property;_EmissionColor;EmissionColor;12;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;67;-2102.66,-388.3965;Inherit;False;Property;_FreColor;FreColor;9;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,1;0.6273585,0.7726448,1,0.5019608;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;19;-2710.322,-355.0781;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;131;-2133.967,-534.5737;Inherit;False;129;WorldNormal_NormalTex;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;28;-2738.441,338.9776;Inherit;False;Property;_HLColor;HLColor;6;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;103;-2668.847,-566.9985;Inherit;False;Image_HSVC;-1;;41;ca84aa6554d49423ca5ab36222e90165;0;5;39;FLOAT4;0,0,0,0;False;32;FLOAT;0;False;34;FLOAT;0;False;35;FLOAT;0;False;36;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2778.184,584.5659;Inherit;False;Property;_HLSmooth;HLSmooth;8;0;Create;True;0;0;0;False;0;False;0.5;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;73;-2481.554,472.6942;Inherit;False;Light_HighLight;-1;;43;0266fca0a32984b5d998165239f13ee6;0;4;16;FLOAT;0;False;13;COLOR;0,0,0,0;False;14;FLOAT;0;False;15;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;109;-1844.073,-542.9095;Inherit;False;Light_Fresnel;-1;;44;3627a339a876842a381f1d0fa05ee3fd;0;4;31;FLOAT3;0,0,0;False;14;COLOR;0,0,0,0;False;16;FLOAT;0;False;30;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;97;-2440.783,-355.9112;Inherit;False;MainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-2441.091,-570.876;Inherit;False;MainTex;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;102;-1912.767,-101.6138;Inherit;False;914.2082;680.9962;;10;93;95;91;69;31;78;89;101;98;1;最终输出区域;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-2191.62,2.532976;Float;False;ShadowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1829.974,-1026.647;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-1854.45,75.24146;Inherit;False;97;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-1855.714,-2.877853;Inherit;False;99;MainTex;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-1862.767,151.3288;Inherit;False;88;ShadowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-2208.831,467.4092;Inherit;False;HighLightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-1557.076,-547.0812;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-1647.192,-1028.881;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-1785.008,288.0561;Inherit;False;90;HighLightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1601.679,72.47892;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;-1767.085,464.3825;Inherit;False;94;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-1770.404,368.1167;Inherit;False;92;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1173.9,-51.6138;Inherit;False;Property;_CullMode;CullMode;16;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-1415.124,283.7266;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;1;-1253.559,53.61238;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;ASE/Base;False;False;False;False;True;True;True;False;True;False;False;True;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.44;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;69;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;126;20;108;0
WireConnection;126;17;107;0
WireConnection;124;0;121;0
WireConnection;124;1;126;21
WireConnection;125;0;126;21
WireConnection;125;1;127;0
WireConnection;85;0;124;0
WireConnection;113;0;125;0
WireConnection;129;0;126;21
WireConnection;82;38;84;0
WireConnection;82;35;16;0
WireConnection;82;36;9;0
WireConnection;82;37;10;0
WireConnection;103;39;80;0
WireConnection;103;32;104;1
WireConnection;103;34;104;2
WireConnection;103;35;104;3
WireConnection;103;36;104;4
WireConnection;73;16;86;0
WireConnection;73;13;28;0
WireConnection;73;14;25;0
WireConnection;73;15;26;0
WireConnection;109;31;131;0
WireConnection;109;14;67;0
WireConnection;109;16;65;0
WireConnection;109;30;66;0
WireConnection;97;0;19;0
WireConnection;99;0;103;0
WireConnection;88;0;82;0
WireConnection;55;0;53;0
WireConnection;55;1;54;0
WireConnection;90;0;73;0
WireConnection;92;0;109;0
WireConnection;94;0;55;0
WireConnection;78;0;101;0
WireConnection;78;1;98;0
WireConnection;78;2;89;0
WireConnection;31;0;78;0
WireConnection;31;1;91;0
WireConnection;31;2;93;0
WireConnection;31;3;95;0
WireConnection;1;13;31;0
ASEEND*/
//CHKSM=A2E76ECFBAE42D65B38C7988D38D045DDABB6FDF