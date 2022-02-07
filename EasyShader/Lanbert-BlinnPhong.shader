//1.Shader路径名
Shader "Shader Forge/Lanbert-BlinnPhong"{
    //2.材质面板控制参数
    Properties {
        _MainCol        ("Color",color)              =      (1.0, 1.0, 1.0, 1.0)
        _SpecularPow    ("高光次幂",range(1, 90))     =       30
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
            //uniform 共享于vert,frag
            //attibute 仅共享于vert
            //varying 用于vert,frag传数据
            uniform float3 _MainCol;            //RGB够了 float3
            uniform float _SpecularPow;         //标量 float
            //3.输入结构
            struct VertexInput{
                float4 vertex : POSITION;       //模型顶点信息输入
                float3 normal : NORMAL;         //模型法线信息输入
            };
            
            //4.输出结构
            struct VertexOutput{
                float4 posCS : SV_POSITION;     //裁剪空间（暂时理解为屏幕空间）顶点信息
                float4 posWS : TEXCOORD0;       //世界空间顶点位置
                float3 nDirWS : TEXCOORD1;      //世界空间法线方向
            };
            
            //5.顶点Shader
            VertexOutput vert (VertexInput v){
                VertexOutput o = (VertexOutput)0;                   //新建一个输出结构
                o.posCS = UnityObjectToClipPos(v.vertex);           //交换顶点信息 赋值给输出结构
                o.posWS = mul(unity_ObjectToWorld, v.vertex);       //
                o.nDirWS = UnityObjectToWorldNormal(v.normal);      //交换发现信息 赋值给输出结构
                return o;                                           //将输出结构输出
            }
            
            //6.像素Shader
            float4 frag(VertexOutput i) : COLOR{
                //准备向量
                float3 nDir = i.nDirWS;
                float3 lDir = _WorldSpaceLightPos0.xyz;
                float3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS);
                float3 hDir = normalize(vDir + lDir);
                //准备中间数据
                float ndotl = dot(nDir, lDir);
                float ndoth = dot(nDir, hDir);
                //光照模型
                float lambert = max(0.0, ndotl);
                float blinnPhong = pow(max(0.0, ndoth),_SpecularPow);
                float3 finalRGB = _MainCol * lambert + blinnPhong;
                //返回结果
                return float4(finalRGB,1.0);
            }
            ENDCG

        }
    }
    FallBack "Diffuse"
}