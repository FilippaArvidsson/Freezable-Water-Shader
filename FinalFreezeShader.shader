Shader "CustomFA/FinalFreezeShader"
{
    Properties
    {
        //Textures
        _IceTex("Ice Texture", 2D) = "white" {}
        /*_WaterTex("Water Texture", 2D) = "white" {}*/
        _NormalMap("Normal Map", 2D) = "bump" {}
        _TransitionTex("Transition Texture", 2D) = "white" {}

        //Water Settings
        [Header(Water Properties)][Space]
        _WaterColor("Water Color", Color) = (0.165, 0.812, 0.698, 1)
        _WaterSmoothness("Water Smoothness", Range(0,1)) = 0.5
        _WaterMetallic("Water Metallic", Range(0,1)) = 0.0
        _WaterTransparency("Water Transparency", Range(0, 1)) = 0.0
        _WaterBrightness("Water Brightness", Range(0, 1)) = 0.5
        _RefractionStrength("Refraction Strength", Range(0, 1)) = 0.293
        _WaterSpeed("Water Flow Speed", Range(0,2)) = 0.253
        
        //Ice Settings
        [Header(Ice Properties)][Space]
        _FreezePercentage("Freeze Percentage", Range(0,1)) = 0.0
        _IceSmoothness("Ice Smoothness", Range(0,1)) = 0.437
        _IceMetallic("Ice Metallic", Range(0,1)) = 0.584
        _IceTransparency("Ice Transparency", Range(0, 1)) = 1.0

    }
        SubShader
        {
            Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
            LOD 200

            //Get background, giving this an explicit name reduces work load
            GrabPass { "_WaterBackground" }

            CGPROGRAM
            #pragma surface surf Standard alpha
            // Shader 3.0, gives nicer lighting
            #pragma target 3.0

            sampler2D _IceTex;
            sampler2D _WaterTex;
            sampler2D _NormalMap;
            sampler2D _TransitionTex;

            fixed4 _WaterColor;
            float _WaterSmoothness;
            float _WaterMetallic;
            float _WaterBrightness;
            float _WaterTransparency;
            float _RefractionStrength;
            float _WaterSpeed;

            float _FreezePercentage;
            float _IceSmoothness;
            float _IceMetallic;
            float _IceTransparency;

            sampler2D _CameraDepthTexture, _WaterBackground;
            float4 _CameraDepthTexture_TexelSize;

            struct Input
            {
                float2 uv_IceTex;
                float4 screenPos;
            };

            //inout = input and output variable
            void surf(Input IN, inout SurfaceOutputStandard o)
            {

                float3 newUV = float3(IN.uv_IceTex, 1.0);

                half blend = tex2D(_TransitionTex, newUV).r;

                if ((blend - _FreezePercentage) < 0.0f)
                {
                    //ICE

                    fixed4 color1 = tex2D(_IceTex, newUV);
                    o.Albedo = color1;
                    o.Alpha = _IceTransparency;

                    o.Metallic = _IceMetallic;
                    o.Smoothness = _IceSmoothness;

                }
                else
                {
                    //WATER

                    float2 incUV = IN.uv_IceTex;
                    
                    //Move water
                    incUV.x += _Time.y * _WaterSpeed;

                    newUV = float3(incUV, 1.0);

                    o.Normal = UnpackNormal(tex2D(_NormalMap, newUV));

                    float2 uvOffset = o.Normal * _RefractionStrength;

                    float3 screenUV = float3(((IN.screenPos.xy + uvOffset) / IN.screenPos.w), 1.0f);

                    float3 backgroundColor = tex2D(_WaterBackground, screenUV.xy).rgb;

                    o.Albedo = backgroundColor * _WaterBrightness * _WaterColor;
                    o.Alpha = _WaterTransparency;

                    o.Emission = _WaterBrightness * _WaterColor * 0.75;

                    o.Metallic = _WaterMetallic;
                    o.Smoothness = _WaterSmoothness;
                }

            }

            void ResetAlpha(Input IN, SurfaceOutputStandard o, inout fixed4 color)
            {
                //Only things within water are shown
                color.a = 1.0;
            }

            ENDCG
        }
}
