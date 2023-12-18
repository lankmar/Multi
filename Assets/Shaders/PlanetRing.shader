Shader "Custom/PlanetRing"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex("Texture", 2D) = "white" {}
        _AlphaScale("Alpha Scale", Range(0, 1)) = 1
    }
        SubShader
        {
            // ������� ������������ ������������ ����������, ������� Queue = Transparent
            // ��� RenderType �������� Unity ��������� ���� ������ � ������� ������������ ������, ����� �������, ��� ������ �������� ��������, ������������ �������� ������������
            // IgonreProjector ����� �������� True, ��� ��������� �� ��, ��� �� ���� ������ �� ������ ���������.
                    Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

                    Pass
                    {
                        Tags{ "LightMode" = "ForwardBase" }

                       Cull Front
                       ZWrite Off
            // �������� ����� ���������� � ������������� ����������� ���������� �� SrcAlpha � OneMinusSrcAlpha
                        Blend SrcAlpha OneMinusSrcAlpha

                        CGPROGRAM
                        #pragma vertex vert
                        #pragma fragment frag

                        #include "UnityCG.cginc"
                        #include "Lighting.cginc"

                        struct a2v
                        {
                            float4 vertex : POSITION;
                            float3 normal : NORMAL;
                            float4 texcoord : TEXCOORD0;
                        };

                        struct v2f
                        {
                            float4 pos : SV_POSITION;
                            float2 uv : TEXCOORD0;
                            float3 worldNormal : TEXCOORD1;
                            float3 worldPos : TEXCOORD2;
                        };

                        sampler2D _MainTex;
                        float4 _MainTex_ST;
                        fixed4 _Color;
                        fixed _AlphaScale;
                       v2f vert(a2v v)
                        {
                            v2f o;
                            o.pos = UnityObjectToClipPos(v.vertex);
                            o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                            o.worldNormal = UnityObjectToWorldNormal(v.normal);
                            o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                            return o;
                        }

                        fixed4 frag(v2f i) : SV_Target
                        {
                            fixed3 worldNormal = normalize(i.worldNormal);
                            fixed3 worldPos = normalize(i.worldPos);
                           fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                            fixed4 texColor = tex2D(_MainTex, i.uv);
                            fixed3 albedo = texColor.rgb * _Color.rgb;
                            fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                            fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                            // ���������� ����, ����� ������������ ���������� �� ������������� ���� ��������
                                            return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
                                        }
                                        ENDCG
                                    }

                                    Pass
                                    {
                                        Tags{ "LightMode" = "ForwardBase" }

                                        // �������� ������ �������� �����
                                                    Cull Back
                                            // ��������� �������� ������
                                                        ZWrite Off
                                            // �������� ����� ���������� � ������������� ����������� ���������� �� SrcAlpha � OneMinusSrcAlpha
                                                        Blend SrcAlpha OneMinusSrcAlpha

                                                        CGPROGRAM
                                                        #pragma vertex vert
                                                        #pragma fragment frag

                                                        #include "UnityCG.cginc"
                                                       #include "Lighting.cginc"

                                                        struct a2v
                                                        {
                                                            float4 vertex : POSITION;
                                                            float3 normal : NORMAL;
                                                            float4 texcoord : TEXCOORD0;
                                                        };
                                                        struct v2f
                                                        {
                                                            float4 pos : SV_POSITION;
                                                            float2 uv : TEXCOORD0;
                                                            float3 worldNormal : TEXCOORD1;
                                                           float3 worldPos : TEXCOORD2;
                                                        };

                                                        sampler2D _MainTex;
                                                        float4 _MainTex_ST;
                                                        fixed4 _Color;
                                                        // ������������ ��� ����������� ������� ������, ������������ � ����� �� ������������, ����� ���������� ������� ���������
                                                                  fixed _AlphaScale;

                                                                    v2f vert(a2v v)
                                                                    {
                                                                       v2f o;

                                                                       o.pos = UnityObjectToClipPos(v.vertex);
                                                                        o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                                                                        o.worldNormal = UnityObjectToWorldNormal(v.normal);
                                                                        o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                                                                        return o;
                                                                    }

                                                                    fixed4 frag(v2f i) : SV_Target
                                                                    {
                                                                        fixed3 worldNormal = normalize(i.worldNormal);
                                                                        fixed3 worldPos = normalize(i.worldPos);
                                                                        fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                                                                        // �������� �������
                                                                                        fixed4 texColor = tex2D(_MainTex, i.uv);
                                                                                        // ������������� �����������
                                                                                                       fixed3 albedo = texColor.rgb * _Color.rgb;
                                                                                                       // ���������� ����
                                                                                                                      fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                                                                                                                     fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                                                                                                                     // ���������� ����, ����� ������������ ���������� �� ��������, ������� �� ����������
                                                                                                                                    return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
                                                                                                                                  }
                                                                                                                                  ENDCG
                                                                                                                            }
        }
}
