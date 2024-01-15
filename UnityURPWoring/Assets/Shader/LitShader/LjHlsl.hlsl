#ifndef UNIVERSAL_LJSHSL_INCLUDED
#define UNIVERSAL_LJSHSL_INCLUDED
//#include "./SurfaceInputLJ.hlsl"
  //========风  
    //=========================================simple_noise===================================================
      // inline float unity_noise_randomValue (float2 uv)
      // {
      //     return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
      // }

      // inline float unity_noise_interpolate (float a, float b, float t)
      // {
      //     return (1.0-t)*a + (t*b);
      // }

      // inline float unity_valueNoise (float2 uv)
      // {
      //     float2 i = floor(uv);
      //     float2 f = frac(uv);
      //     f = f * f * (3.0 - 2.0 * f);

      //     uv = abs(frac(uv) - 0.5);
      //     float2 c0 = i + float2(0.0, 0.0);
      //     float2 c1 = i + float2(1.0, 0.0);
      //     float2 c2 = i + float2(0.0, 1.0);
      //     float2 c3 = i + float2(1.0, 1.0);
      //     float r0 = unity_noise_randomValue(c0);
      //     float r1 = unity_noise_randomValue(c1);
      //     float r2 = unity_noise_randomValue(c2);
      //     float r3 = unity_noise_randomValue(c3);

      //     float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
      //     float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
      //     float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
      //     return t;
      // }

      // float noiseUSE(float2 UV, float Scale)
      // {
      //     float t = 0.0;

      //     float freq = pow(2.0, float(0));
      //     float amp = pow(0.5, float(3-0));
      //     t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

      //     freq = pow(2.0, float(1));
      //     amp = pow(0.5, float(3-1));
      //     t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

      //     freq = pow(2.0, float(2));
      //     amp = pow(0.5, float(3-2));
      //     return t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
      // }
// float noiseUSE(float2 uv,float Scale)
// {
//   return SAMPLE_TEXTURE2D_LOD(_NoiseMap,sampler_NoiseMap,uv * Scale,1).r;
// }
// //
float hash(float3 p)  
{
    return frac(sin(dot(p,float3(71.53,13.91,43.63)))*137935.23);
}

float noiseUSE (in float2 p , float Scale)
{
    p *=Scale;
    float2 h = frac(p);
    h = h*h*(3.-2.*h);
    p=floor(p);
    float v1 = hash(float3(p,0.0));
    float v2 = hash(float3(p.x+1.0,p.y,0.0));
    float v3 = hash(float3(p.x,p.y+1.0,0.0));
    float v4 = hash(float3(p+1.0,0.0));
    float k1 = lerp(v1,v2,h.x);
    float k2 = lerp(v3,v4,h.x);
    return lerp(k1,k2,h.y);
}
  //=========================================================================風1

    float TrunkWind (float2 pos,float TreeSwaySpeed,float WindSwayScale,float WindStrength, float4 vertexColor)
    {
    TreeSwaySpeed *= _Time.y;
    pos += TreeSwaySpeed;
    float2 posB =pos + float2(2.413,2.741);
    float NoiseA = noiseUSE(pos,WindSwayScale);
    float NoiseB = noiseUSE(posB,WindSwayScale*2);
    float TrunkWindnoise = NoiseA*NoiseB;
    //WindStrength *= vertexColor.r;
    //TrunkWindnoise *=WindStrength;
    return TrunkWindnoise;
    }

    float LeavesWind (float2 pos,float WindSpeed,float WindLeavesScale,float WindLeavesStrength,float TreeSwaySpeed,float WindSwayScale,float WindStrength,float4 vertexColor)
    {
    pos.xy += WindSpeed*0.5*_Time.y;
    float NoiseA =noiseUSE(pos.xy , WindLeavesScale*1.5);
    float NoiseB =noiseUSE(pos.xy , WindLeavesScale);
    //float LeavesWindnoise = NoiseA+NoiseB;
    float LeavesWindnoise =NoiseA < 0.5 ? max(NoiseB + (2 * NoiseA) - 1, 0) : min(NoiseB + 2 * (NoiseA - 0.5), 1);
    float TrunkWindFull =TrunkWind(pos,TreeSwaySpeed,WindSwayScale,WindStrength,vertexColor);
    LeavesWindnoise *=TrunkWindFull * WindLeavesStrength * vertexColor.b * vertexColor.b;
    LeavesWindnoise += WindStrength *5 * vertexColor.r * TrunkWindFull;
    //LeavesWindnoise = TrunkWindFull < 0.5 ? max(LeavesWindnoise + (2 * TrunkWindFull) - 1, 0) : min(LeavesWindnoise + 2 * (LeavesWindnoise - 0.5), 1);
    // float WindStrengVerCol = WindStrength * vertexColor.r * TrunkWindFull;
    // WindStrengVerCol *=TrunkWindFull;
    //LeavesWindnoise +=WindStrength * vertexColor.b + TrunkWindFull;
    //return  LeavesWindnoise * TrunkWindFull * WindLeavesStrength * vertexColor.b + WindStrengVerCol;
    LeavesWindnoise = saturate(LeavesWindnoise);
    return  LeavesWindnoise;
    }

    //==============================================風2
  //   float3 GrassAnmTexture(float4 vertexColor, TEXTURE2D_PARAM(NoiseMap, samplerNoiseMap),float3 worldPos,half Speed,half4 WindDirection,half WindPower)
  // {
	// 		float3 temp_output_39_0 = float3( (WindDirection).xz ,  0.0 );
	// 		float3 ase_worldPos = worldPos.xyz;
	// 		float2 panner3 = ( 1.0 * _Time.y * ( temp_output_39_0 * Speed *0.1).xy + (ase_worldPos).xz);
	// 		float WindNoise45 =  SAMPLE_TEXTURE2D_LOD( NoiseMap, samplerNoiseMap,panner3,0) .r * WindPower;
	// 		float4 transform53 = mul(unity_WorldToObject,float4( ( WindDirection.xyz * ( ( vertexColor.r * WindNoise45 ) + (vertexColor.g * WindNoise45 ) ) ) , 0.0 ));
	// 		return transform53.xyz;
  // }
//==================================================
    float FresnelEffect(float3 Normal, float3 ViewDir, float Power)
    {
      return pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
    }
    //==============================World to local==
    float3 WorldToLocal(float3 UIObjPosition,float4 position)
    {
      float4 worldPos = mul(unity_ObjectToWorld, position);
      float3 UIpos = UIObjPosition.xyz - worldPos.xyz;
      return UIpos + position.xyz;
      // float3 UIpos = worldPos.xyz - UIObjPosition.xyz ;
      // return 1-UIpos;
    }

    //====================================
    float4 SoftLight_float4(half4 Base, half4 Blend, float Opacity)
    {
        float4 result1 = 2.0 * Base * Blend + Base * Base * (1.0 - 2.0 * Blend);
        float4 result2 = sqrt(Base) * (2.0 * Blend - 1.0) + 2.0 * Base * (1.0 - Blend);
        float4 zeroOrOne = step(0.5, Blend);
        float4 Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
        return Out = lerp(Base, Out, Opacity);
    }

    //==========================下雨===============================
            //   float3 hash3( float2 p )
            // {
            //     float3 q = float3( dot(p,float2(127.1,311.7)), 
            //                 dot(p,float2(269.5,183.3)), 
            //                 dot(p,float2(419.2,371.9)) );
            //     return frac(sin(q)*43758.5453);
            // }

            // float RainRipple( float2 x , float s,float num)
            // {
            //     float2 p = floor(x * s);
            //     float2 f = frac(x * s);
                    
            //     float va = 0.0;
            //     for( int j=-1; j<=1; j++ )
            //     for( int i=-1; i<=1; i++ )
            //     {
            //         float2 g = float2( float(i),float(j) ) ;
            //         float3 o = hash3( p + g );
            //         float2 r = g - f + o.xy;
            //         float d = sqrt(dot(r,r)) / saturate(num);
            //         float ripple = max(lerp(smoothstep(0.99,0.999,max(cos(d - _Time.y * 2. + (o.x + o.y) * 5.0), 0.)), 0., d), 0.);
            //         va += ripple;
            //     }
                
            //     return va;
            // }

    //====================================
            float4 SoftLight_float4(float4 Base, float4 Blend, float Opacity)
        {
            float4 result1 = 2.0 * Base * Blend + Base * Base * (1.0 - 2.0 * Blend);
            float4 result2 = sqrt(Base) * (2.0 * Blend - 1.0) + 2.0 * Base * (1.0 - Blend);
            float4 zeroOrOne = step(0.5, Blend);
            float4 Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            return Out = lerp(Base, Out, Opacity);
        }
      half4 gradientNoise(half2 uv)
        {
            half4 ColorA = half4(1, 0.78, 0,0);
            half4 ColorB = half4(0.051, 0.060, 0,0);
            return lerp(ColorA,ColorB,uv.x*uv.y);
            // half4 magic = half3(0.06711056, 0.00583715, 52.9829189);
            // return frac(magic.z * frac(dot(uv, magic.xy)));
        }

          float RandomRange_float(float2 Seed, float Min, float Max)
        {
            float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
            return lerp(Min, Max, randomno);
        }

        half4 ColorVariation(half4 RandomColorTint)
        {
            float2 ObjectPos = UNITY_MATRIX_M._m03_m13_m23.xy;
            float ObjectPosRandomA = RandomRange_float(ObjectPos.xy,0,1);
            float ObjectPosRandomB = RandomRange_float(ObjectPos.xy,0,2);
            float2 ObjectPosRandom = float2(ObjectPosRandomA,ObjectPosRandomB);
            
            //float4 RandomTex = SAMPLE_TEXTURE2D(_TreeColorVariation, sampler_TreeColorVariation, ObjectPosRandom);
            float4 RandomTex = gradientNoise(ObjectPosRandom);
            return RandomTex + RandomColorTint;
        }
//=============================光照================


#endif
