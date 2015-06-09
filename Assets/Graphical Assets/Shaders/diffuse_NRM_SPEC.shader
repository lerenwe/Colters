// Shader created with Shader Forge Beta 0.30 
// Shader Forge (c) Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:0.30;sub:START;pass:START;ps:flbk:,lico:1,lgpr:1,nrmq:1,limd:1,uamb:True,mssp:True,lmpd:False,lprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,hqsc:True,hqlp:False,blpr:0,bsrc:0,bdst:1,culm:0,dpts:2,wrdp:True,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5025951,fgcg:0.5924681,fgcb:0.6102941,fgca:1,fgde:0.02,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:1,x:32350,y:32762|diff-2-RGB,spec-3-RGB,normal-4-RGB,emission-40-OUT;n:type:ShaderForge.SFN_Tex2d,id:2,x:33051,y:32620,ptlb:diffuse,ptin:_diffuse,ntxv:0,isnm:False|UVIN-10-UVOUT;n:type:ShaderForge.SFN_Tex2d,id:3,x:33058,y:32829,ptlb:spec,ptin:_spec,ntxv:0,isnm:False|UVIN-11-UVOUT;n:type:ShaderForge.SFN_Tex2d,id:4,x:32712,y:32802,ptlb:nrml,ptin:_nrml,ntxv:3,isnm:False|UVIN-12-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:10,x:33244,y:32586,uv:1;n:type:ShaderForge.SFN_TexCoord,id:11,x:33251,y:32833,uv:1;n:type:ShaderForge.SFN_TexCoord,id:12,x:33280,y:33077,uv:1;n:type:ShaderForge.SFN_Lerp,id:40,x:32597,y:32986|A-41-OUT,B-42-OUT,T-46-OUT;n:type:ShaderForge.SFN_Multiply,id:41,x:32777,y:32967|A-44-OUT,B-47-RGB;n:type:ShaderForge.SFN_Vector1,id:42,x:32777,y:33195,v1:0;n:type:ShaderForge.SFN_Fresnel,id:44,x:33214,y:33255|EXP-45-OUT;n:type:ShaderForge.SFN_Slider,id:45,x:33373,y:33255,ptlb:node_45,ptin:_node_45,min:0,cur:0.9548872,max:5;n:type:ShaderForge.SFN_Slider,id:46,x:32722,y:33289,ptlb:node_46,ptin:_node_46,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Color,id:47,x:33077,y:33286,ptlb:node_47,ptin:_node_47,glob:False,c1:0.5,c2:0.5,c3:1,c4:1;proporder:2-3-4-45-46-47;pass:END;sub:END;*/

Shader "Custom/diffuse_NRM_SPEC" {
    Properties {
        _diffuse ("diffuse", 2D) = "white" {}
        _spec ("spec", 2D) = "white" {}
        _nrml ("nrml", 2D) = "bump" {}
        _node_45 ("node_45", Range(0, 5)) = 0.9548872
        _node_46 ("node_46", Range(0, 1)) = 0
        _node_47 ("node_47", Color) = (0.5,0.5,1,1)
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        LOD 200
        Pass {
            Name "ForwardBase"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _diffuse; uniform float4 _diffuse_ST;
            uniform sampler2D _spec; uniform float4 _spec_ST;
            uniform sampler2D _nrml; uniform float4 _nrml_ST;
            uniform float _node_45;
            uniform float _node_46;
            uniform float4 _node_47;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 uv1 : TEXCOORD1;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 uv1 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 binormalDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv1 = v.uv1;
                o.normalDir = mul(float4(v.normal,0), _World2Object).xyz;
                o.tangentDir = normalize( mul( _Object2World, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.binormalDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(_Object2World, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.binormalDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
/////// Normals:
                float2 node_12 = i.uv1;
                float3 normalLocal = tex2D(_nrml,TRANSFORM_TEX(node_12.rg, _nrml)).rgb;
                float3 normalDirection =  normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
/////// Diffuse:
                float NdotL = dot( normalDirection, lightDirection );
                float3 diffuse = max( 0.0, NdotL) * attenColor + UNITY_LIGHTMODEL_AMBIENT.xyz;
////// Emissive:
                float node_42 = 0.0;
                float3 emissive = lerp((pow(1.0-max(0,dot(normalDirection, viewDirection)),_node_45)*_node_47.rgb),float3(node_42,node_42,node_42),_node_46);
///////// Gloss:
                float gloss = exp2(0.5*10.0+1.0);
////// Specular:
                NdotL = max(0.0, NdotL);
                float2 node_11 = i.uv1;
                float3 specularColor = tex2D(_spec,TRANSFORM_TEX(node_11.rg, _spec)).rgb;
                float3 specular = (floor(attenuation) * _LightColor0.xyz) * pow(max(0,dot(halfDirection,normalDirection)),gloss) * specularColor;
                float3 finalColor = 0;
                float3 diffuseLight = diffuse;
                float2 node_10 = i.uv1;
                finalColor += diffuseLight * tex2D(_diffuse,TRANSFORM_TEX(node_10.rg, _diffuse)).rgb;
                finalColor += specular;
                finalColor += emissive;
/// Final Color:
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "ForwardAdd"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            
            Fog { Color (0,0,0,0) }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _diffuse; uniform float4 _diffuse_ST;
            uniform sampler2D _spec; uniform float4 _spec_ST;
            uniform sampler2D _nrml; uniform float4 _nrml_ST;
            uniform float _node_45;
            uniform float _node_46;
            uniform float4 _node_47;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 uv1 : TEXCOORD1;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 uv1 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 binormalDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv1 = v.uv1;
                o.normalDir = mul(float4(v.normal,0), _World2Object).xyz;
                o.tangentDir = normalize( mul( _Object2World, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.binormalDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(_Object2World, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.binormalDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
/////// Normals:
                float2 node_12 = i.uv1;
                float3 normalLocal = tex2D(_nrml,TRANSFORM_TEX(node_12.rg, _nrml)).rgb;
                float3 normalDirection =  normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
/////// Diffuse:
                float NdotL = dot( normalDirection, lightDirection );
                float3 diffuse = max( 0.0, NdotL) * attenColor;
///////// Gloss:
                float gloss = exp2(0.5*10.0+1.0);
////// Specular:
                NdotL = max(0.0, NdotL);
                float2 node_11 = i.uv1;
                float3 specularColor = tex2D(_spec,TRANSFORM_TEX(node_11.rg, _spec)).rgb;
                float3 specular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),gloss) * specularColor;
                float3 finalColor = 0;
                float3 diffuseLight = diffuse;
                float2 node_10 = i.uv1;
                finalColor += diffuseLight * tex2D(_diffuse,TRANSFORM_TEX(node_10.rg, _diffuse)).rgb;
                finalColor += specular;
/// Final Color:
                return fixed4(finalColor * 1,0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
