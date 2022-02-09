//1.Shader路径名
Shader "Shader Forge/Matcap"{
    //2.材质面板控制参数
    Properties {
        _NormalMap("法线贴图", 2D) = "White"{}
        _Matcap("Matcap", 2D)= "gray"{}
        _FresnelPow("菲尼尔次幂", range(0,10)) = 1
        _EnvSpecularInt("环境镜面反射强度", range(0, 5)) = 1
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            //输入参数
            uniform sampler2D _NormalMap;
            uniform sampler2D _Matcap;
            uniform float _FresnelPow;
            uniform float _EnvSpecularInt;
            //3.输入结构
            struct VertexInput{
                float4 vertex : POSITION;       //顶点信息
                float3 normal : NORMAL;         //法线信息
                float4 tangent : TANGENT;       //切线方向
                float2 uv0 : TEXCOORD0;         //uv信息
            };
            
            //4.输出结构
            struct VertexOutput{
                float4 pos : SV_POSITION;       //pos CS
                float2 uv0 : TEXCOORD0;         //uv信息
                float3 nDirWS : TEXCOORD1;      //n WS
                float3 tDirWS : TEXCOORD2;      //t WS
                float3 bDirWS : TEXCOORD3;      //b WS
                float3 posWS : TEXCOORD4;       //pos WS
            };
            
            //5.顶点Shader
            VertexOutput vert (VertexInput v){
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.uv0;
                o.posWS = mul(unity_ObjectToWorld,v.vertex);
                o.nDirWS = UnityObjectToWorldNormal(v.normal);      //OS>>>WS
                o.tDirWS = normalize(mul( unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xzy);//OS>>>WS
                o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w);      //OS>>>WS
                o.pos = UnityObjectToClipPos(v.vertex);        //OS>>>CS
                return o;
            }
            
            //6.像素Shader
            float4 frag(VertexOutput i) : COLOR{
                //向量准备
                float3 nDirTS = UnpackNormal(tex2D(_NormalMap, i.uv0));     //切线空间的法线方向
                float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);      //TBN矩阵
                float3 nDirWS = normalize(mul(nDirTS, TBN));                //转换为世界空间方向
                float3 nDirVS = mul(UNITY_MATRIX_V, float4(nDirWS, 0.0));
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);

                //中间向量
                float2 matcapUV = nDirVS.rg * 0.5 + 0.5;
                float vDotn = dot(nDirWS, vDirWS);

                //光照模型
                float3 matcap = tex2D(_Matcap,matcapUV);
                float fresnel = pow((1.0 - vDotn), _FresnelPow);
                float3 envSpecularLighting = matcap * fresnel * _EnvSpecularInt;
                //输出
                return float4(envSpecularLighting, 1.0);
            }
            ENDCG

        }
    }
    FallBack "Diffuse"
}