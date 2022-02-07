//1.Shader路径名
Shader "Shader Forge/Lanbert-BlinnPhong"{
    //2.材质面板控制参数
    Properties {
        _Occlusion      ("AO图", 2d)                 =   "white"{}
        _EnvUpCol       ("环境上部的颜色",color)       =   (1.0, 1.0, 1.0, 1.0)
        _EnvSideCol     ("环境侧面的颜色",color)       =   (0.5, 0.5, 0.5, 1.0)
        _EnvDownCol     ("环境下部的颜色",color)       =   (0.0, 0.0, 0.0, 0.0)
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
            uniform float3 _EnvUpCol;
            uniform float3 _EnvSideCol;
            uniform float3 _EnvDownCol;
            uniform sampler2D _Occlusion;
            //3.输入结构
            struct VertexInput{
                float4 vertex : POSITION;       //模型顶点信息输入
                float3 normal : NORMAL;         //模型法线信息输入
                float2 uv0 : TEXCOORD0;
            };
            
            //4.输出结构
            struct VertexOutput{
                float4 posCS : SV_POSITION;     //裁剪空间（暂时理解为屏幕空间）顶点信息
                float3 nDirWS : TEXCOORD0;      //世界空间法线方向
                float2 uv : TEXCOORD1;

            };
            
            //输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v){
                VertexOutput o = (VertexOutput)0;
                o.posCS = UnityObjectToClipPos( v.vertex );
                o.nDirWS = UnityObjectToWorldNormal( v.normal );
                o.uv = v.uv0;
                return o;                                           //将输出结构输出
            }
            
            //输出结构>>>像素
            float4 frag(VertexOutput i) : COLOR{
                float3 nDir = i.nDirWS;

                float upMask = max(0.0, nDir.g);
                float downMask = max(0.0, -nDir.g);
                float sideMask = 1.0 - upMask - downMask;

                float3 envCol = _EnvUpCol * upMask + _EnvDownCol * downMask + _EnvSideCol * sideMask;

                //采样AO纹理
                float occlusion = tex2D(_Occlusion, i.uv);

                float3 envLighting = envCol * occlusion;

                return float4(envLighting, 1.0);
            }
            ENDCG

        }
    }
    FallBack "Diffuse"
}