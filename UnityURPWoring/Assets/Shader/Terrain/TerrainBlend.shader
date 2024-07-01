Shader "Custom/TerrainBlend"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        
        Pass
        {
          Name "TerrainR"
          Tags{ "LightMode" = "TerrainR"}
           Blend One OneMinusSrcAlpha
        }
         Pass
        {
          Name "TerrainG"
          Tags{ "LightMode" = "TerrainG"}
           Blend One OneMinusSrcAlpha
        }
        Pass
        {
          Name "TerrainB"
          Tags{ "LightMode" = "TerrainB"}
          Blend One OneMinusSrcAlpha
        }        
        Pass
        {
          Name "TerrainA"
          Tags{ "LightMode" = "TerrainA"}
          Blend One OneMinusSrcAlpha
        }

    }
}