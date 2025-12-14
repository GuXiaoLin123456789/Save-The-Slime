// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASE/Base/OutLine"
{
	Properties
	{
		_Color1("Color", Color) = (1,1,1,1)
		_Texture1("Texture", 2D) = "white" {}
		_HSVC1("HSVC", Vector) = (0,0,0,0)
		_ShaowColor1("ShaowColor", Color) = (0.5711552,0.6109352,0.8018868,1)
		_Boundry1("Boundry", Range( 0 , 1)) = 0.5
		_Smooth1("Smooth", Range( 0 , 1)) = 0.5
		_HLColor1("HLColor", Color) = (0,0,0,1)
		_HLBoundry1("HLBoundry", Range( 0 , 1)) = 0
		_HLSmooth1("HLSmooth", Range( 0 , 1)) = 0.5
		[HDR]_FreColor1("FreColor", Color) = (0,0,0,1)
		_FreBoundry1("FreBoundry", Range( 0 , 1)) = 0.3494399
		_FreSmooth1("FreSmooth", Range( 0 , 1)) = 0.4470588
		[HDR]_EmissionColor1("EmissionColor", Color) = (0,0,0,0)
		_OutLineColor("OutLine Color", Color) = (0.7015347,0.6714578,0.745283,1)
		[Toggle]_OulineSolidColor("OulineSolidColor", Float) = 0
		_OutLineWidth("OutLine Width", Float) = 0.03
		_EmissionTex1("EmissionTex", 2D) = "white" {}
		_NormalTex1("NormalTex", 2D) = "bump" {}
		_NormalInt1("NormalInt", Range( 0 , 1)) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode1("CullMode", Float) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float OutlineWidth201 = _OutLineWidth;
			float outlineVar = OutlineWidth201;
			v.vertex.xyz *= ( 1 + outlineVar);
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			float4 OutlineColor202 = _OutLineColor;
			float2 uv_Texture1 = i.uv_texcoord * _Texture1_ST.xy + _Texture1_ST.zw;
			float4 lerpResult4_g43 = lerp( float4( float3(0.5,0.5,0.5) , 0.0 ) , tex2D( _Texture1, uv_Texture1 ) , ( _HSVC1.w + 1.0 ));
			float3 hsvTorgb6_g43 = RGBToHSV( lerpResult4_g43.xyz );
			float3 hsvTorgb10_g43 = HSVToRGB( float3(( _HSVC1.x + hsvTorgb6_g43.x ),( ( _HSVC1.y + 1.0 ) * hsvTorgb6_g43.y ),( ( _HSVC1.z + 1.0 ) * hsvTorgb6_g43.z )) );
			float3 appendResult11_g43 = (float3(hsvTorgb10_g43));
			float3 MainTex182 = appendResult11_g43;
			float4 MainColor181 = _Color1;
			float temp_output_42_0_g42 = (-1.0 + (0.5 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float2 uv_NormalTex1 = i.uv_texcoord * _NormalTex1_ST.xy + _NormalTex1_ST.zw;
			float3 lerpResult12_g37 = lerp( float3(0,0,1) , UnpackNormal( tex2D( _NormalTex1, uv_NormalTex1 ) ) , (0.0 + (_NormalInt1 - 0.0) * (3.0 - 0.0) / (1.0 - 0.0)));
			float3 normalizeResult14_g37 = normalize( lerpResult12_g37 );
			float3 temp_output_153_21 = (WorldNormalVector( i , normalizeResult14_g37 ));
			float dotResult154 = dot( ase_worldlightDir , temp_output_153_21 );
			float LightingModel157 = dotResult154;
			float temp_output_38_0_g42 = LightingModel157;
			float smoothstepResult39_g42 = smoothstep( ( temp_output_42_0_g42 - 0.5 ) , ( temp_output_42_0_g42 + 0.5 ) , temp_output_38_0_g42);
			float lerpResult46_g42 = lerp( 1.0 , 0.0 , smoothstepResult39_g42);
			float smoothstepResult56_g42 = smoothstep( 0.0 , 0.5 , 1);
			float temp_output_14_0_g42 = (-1.0 + (_Boundry1 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
			float temp_output_37_0_g42 = _Smooth1;
			float smoothstepResult20_g42 = smoothstep( ( temp_output_14_0_g42 - temp_output_37_0_g42 ) , ( temp_output_14_0_g42 + temp_output_37_0_g42 ) , temp_output_38_0_g42);
			float4 lerpResult28_g42 = lerp( _ShaowColor1 , float4( 1,1,1,0 ) , ( saturate( ( lerpResult46_g42 + smoothstepResult56_g42 ) ) * smoothstepResult20_g42 ));
			float4 ShadowColor183 = lerpResult28_g42;
			float4 temp_output_192_0 = ( float4( MainTex182 , 0.0 ) * MainColor181 * ShadowColor183 );
			float4 OutLineColorMultiply198 = temp_output_192_0;
			o.Emission = (( _OulineSolidColor )?( OutlineColor202 ):( ( OutlineColor202 * OutLineColorMultiply198 ) )).rgb;
			o.Normal = float3(0,0,-1);
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull [_CullMode1]
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

		uniform float _CullMode1;
		uniform float4 _HSVC1;
		uniform sampler2D _Texture1;
		uniform float4 _Texture1_ST;
		uniform float4 _Color1;
		uniform float4 _ShaowColor1;
		uniform sampler2D _NormalTex1;
		uniform float4 _NormalTex1_ST;
		uniform float _NormalInt1;
		uniform float _Boundry1;
		uniform float _Smooth1;
		uniform float4 _HLColor1;
		uniform float _HLBoundry1;
		uniform float _HLSmooth1;
		uniform float _FreBoundry1;
		uniform float _FreSmooth1;
		uniform float4 _FreColor1;
		uniform sampler2D _EmissionTex1;
		uniform float4 _EmissionTex1_ST;
		uniform float4 _EmissionColor1;
		uniform float _OulineSolidColor;
		uniform float4 _OutLineColor;
		uniform float _OutLineWidth;


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

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 OutLine109 = 0;
			v.vertex.xyz += OutLine109;
			v.vertex.w = 1;
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
			float2 uv_Texture1 = i.uv_texcoord * _Texture1_ST.xy + _Texture1_ST.zw;
			float4 lerpResult4_g43 = lerp( float4( float3(0.5,0.5,0.5) , 0.0 ) , tex2D( _Texture1, uv_Texture1 ) , ( _HSVC1.w + 1.0 ));
			float3 hsvTorgb6_g43 = RGBToHSV( lerpResult4_g43.xyz );
			float3 hsvTorgb10_g43 = HSVToRGB( float3(( _HSVC1.x + hsvTorgb6_g43.x ),( ( _HSVC1.y + 1.0 ) * hsvTorgb6_g43.y ),( ( _HSVC1.z + 1.0 ) * hsvTorgb6_g43.z )) );
			float3 appendResult11_g43 = (float3(hsvTorgb10_g43));
			float3 MainTex182 = appendResult11_g43;
			float4 MainColor181 = _Color1;
			float temp_output_42_0_g42 = (-1.0 + (0.5 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float2 uv_NormalTex1 = i.uv_texcoord * _NormalTex1_ST.xy + _NormalTex1_ST.zw;
			float3 lerpResult12_g37 = lerp( float3(0,0,1) , UnpackNormal( tex2D( _NormalTex1, uv_NormalTex1 ) ) , (0.0 + (_NormalInt1 - 0.0) * (3.0 - 0.0) / (1.0 - 0.0)));
			float3 normalizeResult14_g37 = normalize( lerpResult12_g37 );
			float3 temp_output_153_21 = (WorldNormalVector( i , normalizeResult14_g37 ));
			float dotResult154 = dot( ase_worldlightDir , temp_output_153_21 );
			float LightingModel157 = dotResult154;
			float temp_output_38_0_g42 = LightingModel157;
			float smoothstepResult39_g42 = smoothstep( ( temp_output_42_0_g42 - 0.5 ) , ( temp_output_42_0_g42 + 0.5 ) , temp_output_38_0_g42);
			float lerpResult46_g42 = lerp( 1.0 , 0.0 , smoothstepResult39_g42);
			float smoothstepResult56_g42 = smoothstep( 0.0 , 0.5 , ase_lightAtten);
			float temp_output_14_0_g42 = (-1.0 + (_Boundry1 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
			float temp_output_37_0_g42 = _Smooth1;
			float smoothstepResult20_g42 = smoothstep( ( temp_output_14_0_g42 - temp_output_37_0_g42 ) , ( temp_output_14_0_g42 + temp_output_37_0_g42 ) , temp_output_38_0_g42);
			float4 lerpResult28_g42 = lerp( _ShaowColor1 , float4( 1,1,1,0 ) , ( saturate( ( lerpResult46_g42 + smoothstepResult56_g42 ) ) * smoothstepResult20_g42 ));
			float4 ShadowColor183 = lerpResult28_g42;
			float4 temp_output_192_0 = ( float4( MainTex182 , 0.0 ) * MainColor181 * ShadowColor183 );
			float temp_output_4_0_g46 = (1.0 + (_HLBoundry1 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0));
			float temp_output_15_0_g46 = _HLSmooth1;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult18_g44 = normalize( ( ase_worldlightDir + ase_worldViewDir ) );
			float dotResult156 = dot( temp_output_153_21 , normalizeResult18_g44 );
			float LightingModel_HL164 = dotResult156;
			float smoothstepResult8_g46 = smoothstep( ( temp_output_4_0_g46 - temp_output_15_0_g46 ) , ( temp_output_4_0_g46 + temp_output_15_0_g46 ) , LightingModel_HL164);
			float4 lerpResult9_g46 = lerp( float4( 0,0,0,0 ) , _HLColor1 , smoothstepResult8_g46);
			float4 HighLightColor188 = lerpResult9_g46;
			float temp_output_22_0_g47 = ( 1.0 - (-0.2 + (_FreBoundry1 - 0.0) * (1.0 - -0.2) / (1.0 - 0.0)) );
			float temp_output_30_0_g47 = _FreSmooth1;
			float3 WorldNormal_NormalTex165 = temp_output_153_21;
			float fresnelNdotV26_g47 = dot( WorldNormal_NormalTex165, ase_worldViewDir );
			float fresnelNode26_g47 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV26_g47, 1.0 ) );
			float smoothstepResult28_g47 = smoothstep( ( temp_output_22_0_g47 - temp_output_30_0_g47 ) , ( temp_output_22_0_g47 + temp_output_30_0_g47 ) , fresnelNode26_g47);
			float4 temp_output_14_0_g47 = _FreColor1;
			float4 Fresnel189 = ( smoothstepResult28_g47 * temp_output_14_0_g47 * (temp_output_14_0_g47).a );
			float2 uv_EmissionTex1 = i.uv_texcoord * _EmissionTex1_ST.xy + _EmissionTex1_ST.zw;
			float4 Emission190 = ( tex2D( _EmissionTex1, uv_EmissionTex1 ) * _EmissionColor1 );
			c.rgb = ( temp_output_192_0 + HighLightColor188 + Fresnel189 + Emission190 ).rgb;
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
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred noambient novertexlights nolightmap  nodirlightmap noforwardadd vertex:vertexDataFunc 

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
				vertexDataFunc( v, customInputData );
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
443;120;1495;859;22.26712;374.7466;1.009998;True;False
Node;AmplifyShaderEditor.CommentaryNode;143;-1452.539,-896.6485;Inherit;False;1018.887;478.1857;LightingModel;10;165;164;157;156;155;154;153;152;151;150;光照模型;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;150;-1425.074,-754.6866;Inherit;True;Property;_NormalTex1;NormalTex;17;0;Create;True;0;0;0;False;0;False;-1;None;bbab0a6f7bae9cf42bf057d8ee2755f6;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;151;-1414.173,-841.3856;Inherit;False;Property;_NormalInt1;NormalInt;18;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;152;-1096.608,-846.6555;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;153;-1119.26,-700.4174;Inherit;False;LightingModel_Normal_Tex;-1;;37;199a4b449c0174475b6993902d3051f8;0;2;20;FLOAT3;0,0,0;False;17;FLOAT;0;False;1;FLOAT3;21
Node;AmplifyShaderEditor.DotProductOpNode;154;-804.7198,-842.8646;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;144;-1248.759,-370.27;Inherit;False;797.1252;444.5404;Comment;6;182;181;177;174;161;158;基础贴图和颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;145;-1053.242,110.3768;Inherit;False;824.6014;385.3089;ShadowColor;6;183;171;163;162;160;159;暗面颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;157;-633.8799,-845.4946;Float;False;LightingModel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;-727.6228,169.8473;Inherit;False;157;LightingModel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;-1030.081,408.9082;Inherit;False;Property;_Smooth1;Smooth;5;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;158;-1222.759,-323.27;Inherit;True;Property;_Texture1;Texture;1;0;Create;True;0;0;0;False;0;False;-1;750b1bd7ba8bd28489650de6d0a95cc5;750b1bd7ba8bd28489650de6d0a95cc5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;162;-1029.818,330.0695;Inherit;False;Property;_Boundry1;Boundry;4;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;163;-1039.196,153.8516;Inherit;False;Property;_ShaowColor1;ShaowColor;3;0;Create;True;0;0;0;False;0;False;0.5711552,0.6109352,0.8018868,1;0.5711552,0.6109352,0.8018868,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;161;-1166.697,-109.6101;Inherit;False;Property;_HSVC1;HSVC;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;174;-945.1716,-103.6897;Inherit;False;Property;_Color1;Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;171;-735.9458,257.4958;Inherit;True;Light_Shadow;-1;;42;7fd334ea8a37541079f58347518ddcb5;0;4;38;FLOAT;0;False;35;COLOR;0,0,0,0;False;36;FLOAT;0;False;37;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;177;-903.6965,-315.6101;Inherit;False;Image_HSVC;-1;;43;ca84aa6554d49423ca5ab36222e90165;0;5;39;FLOAT4;0,0,0,0;False;32;FLOAT;0;False;34;FLOAT;0;False;35;FLOAT;0;False;36;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;181;-675.6328,-104.5228;Inherit;False;MainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;182;-675.9409,-319.4876;Inherit;False;MainTex;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;149;-147.6168,149.7746;Inherit;False;914.2082;680.9962;;11;196;195;194;193;192;191;187;186;185;110;198;最终输出区域;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;183;-426.4698,253.9213;Float;False;ShadowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;185;-89.29975,326.6297;Inherit;False;181;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;-90.56379,248.5104;Inherit;False;182;MainTex;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;-97.61677,402.7171;Inherit;False;183;ShadowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;155;-1122.348,-511.3527;Inherit;False;LightingModel_Dir_HighLight;-1;;44;7a515b594b1a08c4e8f9a74b40ac93eb;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;163.4713,323.8672;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;133;781.9042,317.7341;Float;False;Property;_OutLineColor;OutLine Color;13;0;Create;True;0;0;0;False;0;False;0.7015347,0.6714578,0.745283,1;0.5184674,0.5204919,0.5754717,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;202;995.3523,317.0618;Inherit;False;OutlineColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;198;317.7319,267.3582;Inherit;False;OutLineColorMultiply;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;156;-800.7198,-535.7074;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;67;480.229,-312.9416;Inherit;False;872.025;338.183;;8;109;32;33;132;199;204;205;203;描边;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;132;493.6726,-132.5023;Inherit;False;198;OutLineColorMultiply;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;165;-687.1628,-703.5707;Inherit;False;WorldNormal_NormalTex;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;530.4333,-211.3948;Inherit;False;202;OutlineColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;164;-662.7649,-514.4539;Float;False;LightingModel_HL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;793.5578,215.2531;Inherit;False;Property;_OutLineWidth;OutLine Width;15;0;Create;True;0;0;0;False;0;False;0.03;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;148;-1037.798,533.5208;Inherit;False;805.474;396.9965;HighLightColor;6;188;179;178;176;170;168;高光颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;147;-380.3026,-827.3555;Inherit;False;692.8439;415.5112;Emission;4;190;184;172;167;自发光;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;146;-398.8258,-345.3999;Inherit;False;818.8379;392.7597;Fresnel;6;189;180;175;173;169;166;菲涅尔;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;170;-1012.5,759.4832;Inherit;False;Property;_HLBoundry1;HLBoundry;7;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;-368.8168,-283.1854;Inherit;False;165;WorldNormal_NormalTex;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-101.9168,-47.98735;Inherit;False;Property;_FreSmooth1;FreSmooth;11;0;Create;True;0;0;0;False;0;False;0.4470588;0.715;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;178;-1013.034,835.9543;Inherit;False;Property;_HLSmooth1;HLSmooth;8;0;Create;True;0;0;0;False;0;False;0.5;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;173;-337.5097,-137.0081;Inherit;False;Property;_FreColor1;FreColor;9;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,1;0.6273585,0.7726448,1,0.5019608;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;172;-310.6928,-588.8717;Inherit;False;Property;_EmissionColor1;EmissionColor;12;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;166;-101.1668,-125.938;Inherit;False;Property;_FreBoundry1;FreBoundry;10;0;Create;True;0;0;0;False;0;False;0.3494399;0.165;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;167;-356.5307,-777.8665;Inherit;True;Property;_EmissionTex1;EmissionTex;16;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;176;-973.2905,590.366;Inherit;False;Property;_HLColor1;HLColor;6;0;Create;True;0;0;0;False;0;False;0,0,0,1;0.3,0.3,0.3,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;731.5823,-193.092;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;-715.1248,635.9065;Inherit;False;164;LightingModel_HL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;959.1393,217.4769;Inherit;False;OutlineWidth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;892.5957,-254.0192;Inherit;False;202;OutlineColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;754.9424,-57.69825;Inherit;False;201;OutlineWidth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;199;1134.501,-197.1484;Inherit;False;Property;_OulineSolidColor;OulineSolidColor;14;0;Create;True;0;0;0;False;0;False;0;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-64.8238,-775.2585;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;180;-78.9228,-291.5211;Inherit;False;Light_Fresnel;-1;;47;3627a339a876842a381f1d0fa05ee3fd;0;4;31;FLOAT3;0,0,0;False;14;COLOR;0,0,0,0;False;16;FLOAT;0;False;30;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;179;-716.4038,724.0826;Inherit;False;Light_HighLight;-1;;46;0266fca0a32984b5d998165239f13ee6;0;4;16;FLOAT;0;False;13;COLOR;0,0,0,0;False;14;FLOAT;0;False;15;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;32;971.6449,-85.1924;Inherit;False;1;True;None;0;0;Front;True;True;True;True;0;False;-1;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;189;208.0742,-295.6928;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;188;-443.6808,718.7977;Inherit;False;HighLightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;190;117.9582,-777.4925;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-5.253848,619.5052;Inherit;False;189;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;109;1161.243,-85.20656;Inherit;False;OutLine;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;193;-1.934755,715.7709;Inherit;False;190;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;191;-19.85785,539.4445;Inherit;False;188;HighLightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;195;350.0262,535.115;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;196;558.2501,272.7746;Inherit;False;Property;_CullMode1;CullMode;19;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;287.8197,719.8191;Inherit;False;109;OutLine;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;1;505.6253,361.338;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;ASE/Base/OutLine;False;False;False;False;True;True;True;False;True;False;False;True;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.44;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;196;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;153;20;150;0
WireConnection;153;17;151;0
WireConnection;154;0;152;0
WireConnection;154;1;153;21
WireConnection;157;0;154;0
WireConnection;171;38;159;0
WireConnection;171;35;163;0
WireConnection;171;36;162;0
WireConnection;171;37;160;0
WireConnection;177;39;158;0
WireConnection;177;32;161;1
WireConnection;177;34;161;2
WireConnection;177;35;161;3
WireConnection;177;36;161;4
WireConnection;181;0;174;0
WireConnection;182;0;177;0
WireConnection;183;0;171;0
WireConnection;192;0;186;0
WireConnection;192;1;185;0
WireConnection;192;2;187;0
WireConnection;202;0;133;0
WireConnection;198;0;192;0
WireConnection;156;0;153;21
WireConnection;156;1;155;0
WireConnection;165;0;153;21
WireConnection;164;0;156;0
WireConnection;33;0;203;0
WireConnection;33;1;132;0
WireConnection;201;0;35;0
WireConnection;199;0;33;0
WireConnection;199;1;205;0
WireConnection;184;0;167;0
WireConnection;184;1;172;0
WireConnection;180;31;175;0
WireConnection;180;14;173;0
WireConnection;180;16;166;0
WireConnection;180;30;169;0
WireConnection;179;16;168;0
WireConnection;179;13;176;0
WireConnection;179;14;170;0
WireConnection;179;15;178;0
WireConnection;32;0;199;0
WireConnection;32;1;204;0
WireConnection;189;0;180;0
WireConnection;188;0;179;0
WireConnection;190;0;184;0
WireConnection;109;0;32;0
WireConnection;195;0;192;0
WireConnection;195;1;191;0
WireConnection;195;2;194;0
WireConnection;195;3;193;0
WireConnection;1;13;195;0
WireConnection;1;11;110;0
ASEEND*/
//CHKSM=ECCBA53C4D546B3583EBA031726A5834B997716F