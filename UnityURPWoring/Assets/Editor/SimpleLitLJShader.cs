using System;
using UnityEngine;
using UnityEditor;

namespace UnityEditor.Rendering.Universal.ShaderGUI
{
public class SimpleLitLJShader : BaseShaderGUI
{ 

    private SimpleLitGUI.SimpleLitProperties shadingModelProperties;

    protected MaterialProperty BumpMapProp { get; set; }
    protected MaterialProperty BumpMap1Prop{ get; set; }
    protected MaterialProperty BumpMap2Prop { get; set; }
    protected MaterialProperty BumpMap3Prop { get; set; }
    protected MaterialProperty baseMap1Prop { get; set; }
    protected MaterialProperty baseMap2Prop { get; set; }
    protected MaterialProperty baseMap3Prop { get; set; }
    protected MaterialProperty SplatmapOnProp { get; set; }
    protected MaterialProperty SplatmapProp { get; set; }
    protected MaterialProperty WindONop { get; set; }
    protected MaterialProperty WindSpeedop { get; set; }
    protected MaterialProperty WindLeavesScaleop { get; set; }
    protected MaterialProperty TreeSwaySpeedop { get; set; }
    protected MaterialProperty WindSwayScaleop { get; set; }
    protected MaterialProperty WindStrengthop { get; set; }
    protected MaterialProperty WindLeavesStrengthop { get; set; }
    protected MaterialProperty ObjToUIop { get; set; }
    protected MaterialProperty ObjToUILerpop { get; set; }
    protected MaterialProperty Bump1Scaleop { get; set; }
    protected MaterialProperty Bump2Scaleop { get; set; }
    protected MaterialProperty Bump3Scaleop { get; set; }
    protected MaterialProperty Bump4Scaleop { get; set; }
    protected MaterialProperty TopTintop { get; set; }
    protected MaterialProperty BottomTintop { get; set; }
    protected MaterialProperty TopTintAmountop { get; set; }
    protected MaterialProperty BottomTintAmountop { get; set; }
    protected MaterialProperty vertexColorMaskColorop { get; set; }
    // protected MaterialProperty NoiseMapop { get; set; }
    // protected MaterialProperty Speedop { get; set; }
    // protected MaterialProperty WindDirectionop { get; set; }
    // protected MaterialProperty WindPowerop { get; set; }
    // protected MaterialProperty GrassModeop { get; set; }
    protected MaterialProperty RandomColorop { get; set; }
    protected MaterialProperty RandomColorTintop { get; set; }
    protected MaterialProperty RandomColorAmountop { get; set; }
    //protected MaterialProperty InholeProp { get; set; }

    private bool Splatmapshow = true;
    private bool Windshow = true;
    private bool WindshowUIOn = true;
    private bool SplatmapshowMap = true;
    private bool ObjToUIOnBoolOn= true;
    //private bool Inhole;
     private int queueOffsetRange;
        //private int queueOffsetRange = 50;
        //public int queueValue;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            base.OnGUI(materialEditor, properties); // 调用基类的OnGUI方法

        }


        public override void FindProperties(MaterialProperty[] properties)
        {

            base.FindProperties(properties);
            shadingModelProperties = new SimpleLitGUI.SimpleLitProperties(properties);
//=====================我的覆写参数===========================================================================
            SplatmapProp = FindProperty("_Splatmap", properties, false);
            //--------------------------------------------------------
            BumpMapProp = FindProperty("_BumpMap", properties, false);
            BumpMap1Prop = FindProperty("_BumpMap1", properties, false);
            BumpMap2Prop = FindProperty("_BumpMap2", properties, false);
            BumpMap3Prop = FindProperty("_BumpMap3", properties, false);
            //--------------------------------------------------------
            baseMapProp = FindProperty("_BaseMap", properties, false);
            baseMap1Prop = FindProperty("_BaseMap1", properties, false);
            baseMap2Prop = FindProperty("_BaseMap2", properties, false);
            baseMap3Prop = FindProperty("_BaseMap3", properties, false);
            SplatmapOnProp = FindProperty("_SplatmapOn", properties, false);
            WindONop = FindProperty("_WindOn", properties, false);
            WindSpeedop = FindProperty("_WindSpeed", properties, false);
            WindLeavesScaleop = FindProperty("_WindLeavesScale", properties, false);
            TreeSwaySpeedop = FindProperty("_TreeSwaySpeed", properties, false);
            WindSwayScaleop = FindProperty("_WindSwayScale", properties, false);
            WindStrengthop = FindProperty("_WindStrength", properties, false);
            WindLeavesStrengthop = FindProperty("_WindLeavesStrength", properties, false);      
            ObjToUIop = FindProperty("_UIPosAnm", properties, false);    
            ObjToUILerpop = FindProperty("_UIPoslerp", properties, false);  
            Bump1Scaleop = FindProperty("_Bump1Scale", properties, false);      
            Bump2Scaleop = FindProperty("_Bump2Scale", properties, false);      
            Bump3Scaleop = FindProperty("_Bump3Scale", properties, false);      
            Bump4Scaleop = FindProperty("_Bump4Scale", properties, false);      
            TopTintop = FindProperty("_TopTint", properties, false);      
            BottomTintop = FindProperty("_BottomTint", properties, false);      
            TopTintAmountop = FindProperty("_TopTintAmount", properties, false);      
            BottomTintAmountop = FindProperty("_BottomTintAmount", properties, false);      
            vertexColorMaskColorop = FindProperty("_vertexColorMaskColor", properties, false);
//======================
            // NoiseMapop = FindProperty("_NoiseMap", properties, false);
            // Speedop = FindProperty("_Speed", properties, false);
            // WindDirectionop = FindProperty("_WindDirection", properties, false);
            // WindPowerop = FindProperty("_WindPower", properties, false);
            // GrassModeop = FindProperty("_GrassMode", properties, false);

            RandomColorop = FindProperty("_RandomColor", properties, false);
            RandomColorTintop = FindProperty("_RandomColorTint", properties, false);
            RandomColorAmountop = FindProperty("_RandomColorAmount", properties, false);
        }
 //========================我的类===============================================
        public static class LJStyles
        {
            public static GUIContent Splatmap = new GUIContent("Splatmap Texture");
            //-----------------------------------------------
            public static GUIContent baseMap = new GUIContent("Texture1");
            public static GUIContent BumpMap = new GUIContent("BumpMap1");
            public static GUIContent baseMap1 = new GUIContent("Texture2");
            public static GUIContent BumpMap1 = new GUIContent("BumpMap2");
            public static GUIContent baseMap2 = new GUIContent("Texture3");
            public static GUIContent BumpMap2 = new GUIContent("BumpMap3");
            public static GUIContent baseMap3 = new GUIContent("Texture4");
            public static GUIContent BumpMap3 = new GUIContent("BumpMap4");
            public static GUIContent SplatmapOn = new GUIContent("Splatmap");
            public static GUIContent WindON = new GUIContent("Wind");
            public static GUIContent WindSpeed = new GUIContent("WindSpeed");
            public static GUIContent WindLeavesScale = new GUIContent("WindLeavesScale");
            public static GUIContent TreeSwaySpeed = new GUIContent("TreeSwaySpeed");
            public static GUIContent WindSwayScale = new GUIContent("WindSwayScale");
            public static GUIContent WindStrength = new GUIContent("WindStrength");
            public static GUIContent WindLeavesStrength = new GUIContent("WindLeavesStrength");
            public static GUIContent ObjToUI = new GUIContent("Obj to UI");
            public static GUIContent ObjToUILerp = new GUIContent("Mix Position");
            public static GUIContent Bump1Scale = new GUIContent("NormalMaps Scale");
            public static GUIContent Bump2Scale = new GUIContent("NormalMaps Scale");
            public static GUIContent Bump3Scale = new GUIContent("NormalMaps Scale");
            public static GUIContent Bump4Scale = new GUIContent("NormalMaps Scale");
            public static GUIContent TopTint = new GUIContent("Top Color");
            public static GUIContent BottomTint = new GUIContent("Bottom Color");
            public static GUIContent TopTintAmount = new GUIContent("Top Amount");
            public static GUIContent BottomTintAmount = new GUIContent("Bottom Amount");
            public static GUIContent vertexColorMaskColor = new GUIContent("VertexColor MaskColor");
            // public static GUIContent NoiseMap = new GUIContent("Noise Map");
            // public static GUIContent Speed = new GUIContent("Wind Speed");
            // public static GUIContent WindDirection = new GUIContent("Wind Direction");
            // public static GUIContent WindPower = new GUIContent("Wind Power");
            // public static GUIContent GrassMode = new GUIContent("Grass Mode");
            public static GUIContent RandomColor = new GUIContent("Random Color");
            public static GUIContent RandomColorTint = new GUIContent("Color");
            public static GUIContent RandomColorAmount = new GUIContent("Random Color Amount");

        }
//========================我的类===============================================       

        // material changed check
        public override void ValidateMaterial(Material material)
        {
            SetMaterialKeywords(material, SimpleLitGUI.SetMaterialKeywords);
        }

        // material main surface options
        public override void DrawSurfaceOptions(Material material)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            // Use default labelWidth
            EditorGUIUtility.labelWidth = 0f;
           
            base.DrawSurfaceOptions(material);
        }

        // material main surface inputs
        public override void DrawSurfaceInputs(Material material)
        {

            if(SplatmapshowMap == false)
            { 
            base.DrawSurfaceInputs(material);
             DrawTileOffset(materialEditor, baseMapProp);
            }
            SimpleLitGUI.Inputs(shadingModelProperties, materialEditor, material);
            if(SplatmapshowMap == false)
            {
            materialEditor.ShaderProperty(Bump1Scaleop, LJStyles.Bump1Scale); 
            }
            DrawEmissionProperties(material, true);
//顶点色蒙版

    materialEditor.ShaderProperty(vertexColorMaskColorop, LJStyles.vertexColorMaskColor);    
    if(vertexColorMaskColorop.floatValue > 0)
    {
GUILayout.BeginHorizontal();
        materialEditor.ShaderProperty(TopTintop, LJStyles.TopTint);  
       // materialEditor.ShaderProperty(TopTintAmountop, LJStyles.TopTintAmount);  
        float TopTintA = TopTintAmountop.floatValue;
        EditorGUILayout.LabelField("", GUILayout.Width(1));//Slider
        TopTintAmountop.floatValue = EditorGUILayout.Slider(TopTintA, 0f,5f);//Slider
GUILayout.EndHorizontal();//横向布局、

GUILayout.BeginHorizontal();
        materialEditor.ShaderProperty(BottomTintop, LJStyles.BottomTint);  
       // materialEditor.ShaderProperty(BottomTintAmountop, LJStyles.BottomTintAmount);  
        float BottomTintA = BottomTintAmountop.floatValue;
        EditorGUILayout.LabelField("", GUILayout.Width(1));//Slider
        BottomTintAmountop.floatValue = EditorGUILayout.Slider(BottomTintA, 0f, 5f);//Slider
GUILayout.EndHorizontal();//横向布局、      
    }  
//=========================================隨機顔色
    materialEditor.ShaderProperty(RandomColorop, LJStyles.RandomColor);    
    if(RandomColorop.floatValue > 0)
    {
GUILayout.BeginHorizontal();
        materialEditor.ShaderProperty(RandomColorTintop, LJStyles.RandomColorTint);  
       // materialEditor.ShaderProperty(TopTintAmountop, LJStyles.TopTintAmount);  
        float ColorAmount = RandomColorAmountop.floatValue;
        EditorGUILayout.LabelField("", GUILayout.Width(1));//Slider
        RandomColorAmountop.floatValue = EditorGUILayout.Slider(ColorAmount, 0f,1f);//Slider
GUILayout.EndHorizontal();//横向布局、
     
    }  

//===========================地表=============================
Rect rectSplatmapshow = EditorGUILayout.BeginVertical();
Color colorSplatmapshow = Color.black; // 设置范围框的颜色（使用RGB值）
EditorGUI.DrawRect(rectSplatmapshow, colorSplatmapshow);
        Splatmapshow = EditorGUILayout.Foldout(Splatmapshow, "Terrain");
EditorGUILayout.EndVertical();
            SplatmapshowMap = SplatmapOnProp.floatValue > 0;
            if(Splatmapshow)
            {   
                materialEditor.ShaderProperty(SplatmapOnProp, LJStyles.SplatmapOn.text, (int)MaterialProperty.PropType.Float);
                if(SplatmapshowMap)
                {
                materialEditor.TexturePropertySingleLine(LJStyles.Splatmap, SplatmapProp);                            
Rect lineRect = EditorGUILayout.GetControlRect(false, 1);
EditorGUI.DrawRect(lineRect,new Color(0.0f,0.0f,0.0f, 0.3f));
                materialEditor.TexturePropertySingleLine(LJStyles.baseMap, baseMapProp);
                materialEditor.TexturePropertySingleLine(LJStyles.BumpMap, BumpMapProp);    
                materialEditor.ShaderProperty(Bump1Scaleop, LJStyles.Bump1Scale);    
                DrawTileOffset(materialEditor, baseMapProp);
Rect lineRect2 = EditorGUILayout.GetControlRect(false, 1);
EditorGUI.DrawRect(lineRect2,new Color(0.0f,0.0f,0.0f, 0.3f));
                materialEditor.TexturePropertySingleLine(LJStyles.baseMap1, baseMap1Prop);
                materialEditor.TexturePropertySingleLine(LJStyles.BumpMap1, BumpMap1Prop);  
                materialEditor.ShaderProperty(Bump2Scaleop, LJStyles.Bump2Scale);   
                DrawTileOffset(materialEditor, baseMap1Prop);
Rect lineRect3 = EditorGUILayout.GetControlRect(false, 1);
EditorGUI.DrawRect(lineRect3,new Color(0.0f,0.0f,0.0f, 0.3f));
                materialEditor.TexturePropertySingleLine(LJStyles.baseMap2, baseMap2Prop);
                materialEditor.TexturePropertySingleLine(LJStyles.BumpMap2, BumpMap2Prop); 
                materialEditor.ShaderProperty(Bump3Scaleop, LJStyles.Bump3Scale);    
                DrawTileOffset(materialEditor, baseMap2Prop);
Rect lineRect4 = EditorGUILayout.GetControlRect(false, 1);
EditorGUI.DrawRect(lineRect4,new Color(0.0f,0.0f,0.0f, 0.3f));
                materialEditor.TexturePropertySingleLine(LJStyles.baseMap3, baseMap3Prop);
                materialEditor.TexturePropertySingleLine(LJStyles.BumpMap3, BumpMap3Prop);
                materialEditor.ShaderProperty(Bump4Scaleop, LJStyles.Bump4Scale);   
                DrawTileOffset(materialEditor, baseMap3Prop);  
                } 
            }
//====================风=========================================
Rect rectWindshow = EditorGUILayout.BeginVertical();
Color colorWindshow = Color.black; // 设置范围框的颜色（使用RGB值）
EditorGUI.DrawRect(rectWindshow, colorWindshow);
                Windshow = EditorGUILayout.Foldout(Windshow, "Animation");
EditorGUILayout.EndVertical();
        WindshowUIOn =WindONop.floatValue >0;

        if(Windshow)
        {
          materialEditor.ShaderProperty(WindONop, LJStyles.WindON);
          if(WindshowUIOn)
          {
           
             //GrassModeop.floatValue = 0;
            materialEditor.ShaderProperty(WindSpeedop, LJStyles.WindSpeed);
            materialEditor.ShaderProperty(WindLeavesScaleop, LJStyles.WindLeavesScale);
            materialEditor.ShaderProperty(TreeSwaySpeedop, LJStyles.TreeSwaySpeed);
            materialEditor.ShaderProperty(WindSwayScaleop, LJStyles.WindSwayScale);
            materialEditor.ShaderProperty(WindStrengthop, LJStyles.WindStrength);
            materialEditor.ShaderProperty(WindLeavesStrengthop, LJStyles.WindLeavesStrength);
          }
        //    else
        //   {
            
        //     materialEditor.ShaderProperty(GrassModeop, LJStyles.GrassMode);
        //    // GrassModeop.floatValue = 1;
        //     materialEditor.TexturePropertySingleLine(LJStyles.NoiseMap, NoiseMapop);
        //     materialEditor.ShaderProperty(Speedop, LJStyles.Speed);
        //     materialEditor.ShaderProperty(WindDirectionop, LJStyles.WindDirection);
        //     materialEditor.ShaderProperty(WindPowerop, LJStyles.WindPower);
        //   }

        }


//=======================UiAnm======================================
Rect UIWindshow = EditorGUILayout.BeginVertical();
Color UIcolorWindshow = Color.black; // 设置范围框的颜色（使用RGB值）
EditorGUI.DrawRect(UIWindshow, UIcolorWindshow);
          materialEditor.ShaderProperty(ObjToUIop, LJStyles.ObjToUI);
EditorGUILayout.EndVertical();
        
         ObjToUIOnBoolOn = ObjToUIop.floatValue >0;
         
        if(ObjToUIOnBoolOn)
        {
        materialEditor.ShaderProperty(ObjToUILerpop, LJStyles.ObjToUILerp);
        }

        }

        public override void DrawAdvancedOptions(Material material)
        {

            SimpleLitGUI.Advanced(shadingModelProperties);
            
            Material targetMat = materialEditor.target as Material;            
            EditorGUILayout.LabelField("*** Surface:Opaque , Sorting : Inhole:-452 , other :0");
            DrawQueueOffsetField();
            
           // base.DrawAdvancedOptions(material);

            materialEditor.EnableInstancingField();
        
            EditorGUILayout.LabelField("Render Queue: " + targetMat.renderQueue);
        }

        public new void DrawQueueOffsetField()
        {
            queueOffsetRange = 1100; 
            if (queueOffsetProp != null)         
            materialEditor.IntSliderShaderProperty(queueOffsetProp, -queueOffsetRange, queueOffsetRange, Styles.queueSlider);
        }
        

        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            // _Emission property is lost after assigning Standard shader to the material
            // thus transfer it before assigning the new shader
            if (material.HasProperty("_Emission"))
            {
                material.SetColor("_EmissionColor", material.GetColor("_Emission"));
            }

            base.AssignNewShaderToMaterial(material, oldShader, newShader);

            if (oldShader == null || !oldShader.name.Contains("Legacy Shaders/"))
            {
                SetupMaterialBlendMode(material);
                return;
            }

            SurfaceType surfaceType = SurfaceType.Opaque;
            BlendMode blendMode = BlendMode.Alpha;
            if (oldShader.name.Contains("/Transparent/Cutout/"))
            {
                surfaceType = SurfaceType.Opaque;
                material.SetFloat("_AlphaClip", 1);
            }
            else if (oldShader.name.Contains("/Transparent/"))
            {
                // NOTE: legacy shaders did not provide physically based transparency
                // therefore Fade mode
                surfaceType = SurfaceType.Transparent;
                blendMode = BlendMode.Alpha;
            }
            material.SetFloat("_Surface", (float)surfaceType);
            material.SetFloat("_Blend", (float)blendMode);

        }


}



}