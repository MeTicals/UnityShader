//1.Shader路径名
Shader "Shader Forge/Lambert"{
    //2.材质面板控制参数
    Properties {
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
            
            //3.输入结构
            struct VertexInput{
                float4 vertex : POSITION;       //模型顶点信息输入
                float3 normal : NORMAL;         //模型法线信息输入
            };
            
            //4.输出结构
            struct VertexOutput{
                float4 pos : SV_POSITION;       //模型定点信息计算顶点屏幕位置
                float3 nDirWS : TEXCOORD0;      //模型法线信息换算世界空间法线信息
            };
            
            //5.顶点Shader
            VertexOutput vert (VertexInput v){
                VertexOutput o = (VertexOutput)0;                   //新建一个输出结构
                o.pos = UnityObjectToClipPos(v.vertex);             //交换定点信息 赋值给输出结构
                o.nDirWS = UnityObjectToWorldNormal(v.normal);      //交换发现信息 赋值给输出结构
                return o;                                           //将输出结构输出
            }
            
            //6.像素Shader
            float4 frag(VertexOutput i) : COLOR{
                float3 nDir = i.nDirWS;                             //获取nDir
                float3 ldir = _WorldSpaceLightPos0.xyz;             //获取IDir
                float nDot1 = dot(i.nDirWS,ldir);                   //nDir点积IDir
                // float lambert = nDot1*0.5+0.5;                      //半兰伯特光照模型
                float lambert = max(0.0,nDot1);
                // return float4(lambert,lambert,lambert,1);
                return float4(lambert,lambert,lambert,lambert);
            }
            ENDCG

        }
    }
    FallBack "Diffuse"
}