// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASE/MatCap"
{
	Properties
	{
		_MainColor("MainColor", Color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
		_MatCapInt("MatCapInt", Range( 0 , 1)) = 0
		_MatCapTex("MatCapTex", 2D) = "white" {}
		[KeywordEnum(Additive,Multiple,AlphaBlend)] _MatBlendMode("MatBlendMode", Float) = 1
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull [_CullMode]
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#pragma shader_feature_local _MATBLENDMODE_ADDITIVE _MATBLENDMODE_MULTIPLE _MATBLENDMODE_ALPHABLEND


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _CullMode;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _MainColor;
			uniform sampler2D _MatCapTex;
			uniform float _MatCapInt;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float4 temp_cast_0 = (1.0).xxxx;
				float4 temp_cast_1 = (0.0).xxxx;
				float4 temp_cast_2 = (1.0).xxxx;
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 MainColor23 = ( tex2D( _MainTex, uv_MainTex ) * _MainColor );
				#if defined(_MATBLENDMODE_ADDITIVE)
				float4 staticSwitch32 = temp_cast_1;
				#elif defined(_MATBLENDMODE_MULTIPLE)
				float4 staticSwitch32 = temp_cast_0;
				#elif defined(_MATBLENDMODE_ALPHABLEND)
				float4 staticSwitch32 = MainColor23;
				#else
				float4 staticSwitch32 = temp_cast_0;
				#endif
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float4 lerpResult31 = lerp( staticSwitch32 , tex2D( _MatCapTex, ( ( (mul( UNITY_MATRIX_V, float4( ase_worldNormal , 0.0 ) ).xyz).xy * 0.5 ) + 0.5 ) ) , _MatCapInt);
				float4 MatCap26 = lerpResult31;
				#if defined(_MATBLENDMODE_ADDITIVE)
				float4 staticSwitch20 = ( MatCap26 + MainColor23 );
				#elif defined(_MATBLENDMODE_MULTIPLE)
				float4 staticSwitch20 = ( MatCap26 * MainColor23 );
				#elif defined(_MATBLENDMODE_ALPHABLEND)
				float4 staticSwitch20 = MatCap26;
				#else
				float4 staticSwitch20 = ( MatCap26 * MainColor23 );
				#endif
				float4 appendResult29 = (float4(staticSwitch20.rgb , 1.0));
				
				
				finalColor = appendResult29;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
-1139.2;-151.2;1139;959;-346.8738;320.8854;1;True;False
Node;AmplifyShaderEditor.WorldNormalVector;1;71.15382,-411.9058;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewMatrixNode;3;109.4169,-567.3533;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;356.3503,-511.5445;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;18;899.9388,368.9549;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;-1;None;2f82ef7b82cc1464ab3ad5154d9c3c15;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;19;948.8432,578.092;Inherit;False;Property;_MainColor;MainColor;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,0.8509804,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;6;510.6013,-516.3279;Inherit;False;True;True;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;1256.908,450.3073;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;10;561.3723,-412.1164;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;0.5;0.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;1407.73,445.792;Inherit;False;MainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;745.4161,-511.2355;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;33;946.5533,-809.9254;Inherit;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;906.2552,-511.3003;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;34;948.0431,-736.1296;Inherit;False;Constant;_Float3;Float 3;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;917.4416,-640.3223;Inherit;False;23;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;28;1055.828,-278.1168;Inherit;False;Property;_MatCapInt;MatCapInt;2;0;Create;True;0;0;0;False;0;False;0;0.973;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;32;1133.997,-710.8548;Inherit;False;Property;_Keyword0;Keyword 0;4;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;20;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;7;1057.233,-548.2619;Inherit;True;Property;_MatCapTex;MatCapTex;3;0;Create;True;0;0;0;False;0;False;-1;9f89ce14863dcc644bd03d6322ce4700;cc7770573dd1ce9448634e7aff8f7926;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;31;1433.446,-572.4129;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;1735.978,-577.3522;Inherit;False;MatCap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;819.5101,32.05409;Inherit;False;23;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;823.6438,-128.82;Inherit;False;26;MatCap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;823.5049,115.2597;Inherit;False;26;MatCap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;1051.887,5.766785;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;1053.123,-121.9782;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;30;1294.442,209.1333;Inherit;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;20;1240.863,65.5329;Inherit;False;Property;_MatBlendMode;MatBlendMode;4;0;Create;True;0;0;0;False;0;False;0;1;1;True;;KeywordEnum;3;Additive;Multiple;AlphaBlend;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;15;1684.453,-43.43958;Inherit;False;Property;_CullMode;CullMode;5;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;29;1508.642,71.1333;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1663.362,68.95717;Float;False;True;-1;2;ASEMaterialInspector;100;1;ASE/MatCap;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;0;True;15;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;2;0;3;0
WireConnection;2;1;1;0
WireConnection;6;0;2;0
WireConnection;17;0;18;0
WireConnection;17;1;19;0
WireConnection;23;0;17;0
WireConnection;8;0;6;0
WireConnection;8;1;10;0
WireConnection;9;0;8;0
WireConnection;9;1;10;0
WireConnection;32;1;33;0
WireConnection;32;0;34;0
WireConnection;32;2;37;0
WireConnection;7;1;9;0
WireConnection;31;0;32;0
WireConnection;31;1;7;0
WireConnection;31;2;28;0
WireConnection;26;0;31;0
WireConnection;21;0;27;0
WireConnection;21;1;24;0
WireConnection;22;0;27;0
WireConnection;22;1;24;0
WireConnection;20;1;22;0
WireConnection;20;0;21;0
WireConnection;20;2;38;0
WireConnection;29;0;20;0
WireConnection;29;3;30;0
WireConnection;0;0;29;0
ASEEND*/
//CHKSM=37A924FBF1EF876DFEA50628BAEA10547232A190