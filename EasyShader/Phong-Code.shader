//1.Shader路径名
Shader "Shader Forge/Phong-Code"{
    //2.材质面板控制参数
    Properties {
        _SpecularPow("高光次幂", range(0, 90)) = 30
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
            
            uniform float _SpecularPow;
            //3.输入结构
            struct VertexInput{
                float4 vertex : POSITION;       //模型顶点信息输入
                float3 normal : NORMAL;         //模型法线信息输入
            };
            
            //4.输出结构
            struct VertexOutput{
                float4 posCS : SV_POSITION;     //模型顶点屏幕空间
                float4 posWS : TEXCOORD0;       //模型顶点世界坐标
                float3 nDirWS : TEXCOORD1;      //模型法线信息换算世界空间法线信息
            };
            
            //5.顶点Shader
            VertexOutput vert (VertexInput v){
                VertexOutput o = (VertexOutput)0;                   //新建一个输出结构
                o.posCS = UnityObjectToClipPos(v.vertex);           //屏幕空间顶点信息
                o.posWS = mul(unity_ObjectToWorld, v.vertex);       //世界空间顶点信息
                o.nDirWS = UnityObjectToWorldNormal(v.normal);      //世界法线信息
                return o;                                           //将输出结构输出
            }
            
            //6.像素Shader
            float4 frag(VertexOutput i) : COLOR{
                float3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);           //视角向量
                float3 nDir = normalize(i.nDirWS);                                         //法线向量
                float3 lDir = normalize(_WorldSpaceLightPos0.xyz);                         //光照向量
                float rdotv = dot(reflect((lDir*(-1.0)),nDir),vDir);                       //反射方向点积视角方向
                float Phong = pow(max(rdotv,0.0),_SpecularPow);
                return float4(Phong, Phong, Phong, 1);
            }
            ENDCG

        }
    }
    FallBack "Diffuse"
}