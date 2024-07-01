using UnityEditor;
using UnityEngine;
using UnityEngine.Experimental.Rendering.Universal;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.SceneManagement;
using UnityEngine.UIElements;
[ExecuteInEditMode]
public class TerrainBlendMapsTools : MonoBehaviour
{
    public UniversalRendererData rendererData; // 在Inspector中分配
    public Material existingMaterialR; // 在Inspector中分配给TerrainR
    public Material existingMaterialG; // 在Inspector中分配给TerrainG
    public Material existingMaterialB; // 在Inspector中分配给TerrainG
    public Material existingMaterialA; // 在Inspector中分配给TerrainG

    public Texture2D TerrainMaskTexture;
    private Material newMaterial;
    public enum RenderQueueTypeSelection
    {
        Opaque,
        Transparent
    }

    public RenderQueueTypeSelection renderQueueTypeSelection;
    void Start()
    {
         newMaterial = new Material(Shader.Find("Custom/TerrainBlend"));
        // 检查是否成功找到着色器
        if (newMaterial.shader == null)
        {
            Debug.LogError("Custom/TerrainBlend 地形shader未发现");
            return;
        }
        Renderer renderer = GetComponent<Renderer>();
        if (renderer != null)
        {
            renderer.sharedMaterial = newMaterial;
        }
        else
        {
            Debug.LogError("GameObject没有meshrender");
        }
   
         // 添加TerrainR
            AddRenderFeature("TerrainR", existingMaterialR, RenderPassEvent.AfterRenderingTransparents);
        // 添加TerrainG
            AddRenderFeature("TerrainG", existingMaterialG, RenderPassEvent.AfterRenderingTransparents);
        // 添加TerrainB
            AddRenderFeature("TerrainB", existingMaterialB, RenderPassEvent.AfterRenderingTransparents);
        // 添加TerrainA
            AddRenderFeature("TerrainA", existingMaterialA, RenderPassEvent.AfterRenderingTransparents);
        
    }

    void OnGUI()
    {
        CheckAndAddRenderFeature("TerrainR", existingMaterialR);
        CheckAndAddRenderFeature("TerrainG", existingMaterialG);
        CheckAndAddRenderFeature("TerrainB", existingMaterialB);
        CheckAndAddRenderFeature("TerrainA", existingMaterialA);

        bool showButton = true;
        if (Application.isPlaying)
        {
            showButton = false;
        }
        if (showButton && GUI.Button(new Rect(10, 10, 100, 100), "刷新地形"))
        {
            rendererData.shadowTransparentReceive = false;
        }

        void CheckAndAddRenderFeature(string featureName, Material existingMaterial)
        {
            if (existingMaterial == null)
            {
                rendererData.rendererFeatures.RemoveAll(feature => feature.name == featureName);
            }
            else
            {
                AddRenderFeature(featureName, existingMaterial, RenderPassEvent.AfterRenderingTransparents);
            }
        }
    }




    private void AddRenderFeature(string featureName, Material existingMaterial, RenderPassEvent passEvent)
    {
        // 检查是否已经有一个指定名字的RenderObjects特性
        foreach (var feature in rendererData.rendererFeatures)
        {
            if (feature.name == featureName && feature is RenderObjects)
            {
              //  Debug.Log($"已经存在相同Feature");
                return; 
            }
        }

        // 创建RenderObjects特性
        var renderObjectsFeature = ScriptableObject.CreateInstance<RenderObjects>();
        renderObjectsFeature.name = featureName;
        renderObjectsFeature.settings.Event = passEvent;

        // 使用现有的材质，如果没有指定，则创建一个新的
        if (existingMaterial != null)
        {
            renderObjectsFeature.settings.overrideMaterial = existingMaterial;
            //renderObjectsFeature.settings.overrideMaterial = new Material(existingMaterial);
            if(TerrainMaskTexture == null)
            {
                Debug.LogError("没有地形蒙版材质");
            }
            else
            {
             existingMaterial.SetTexture("_Mask", TerrainMaskTexture);

            }
            // 检查并设置_MaskChannel的值
            if (existingMaterial == existingMaterialR)
            {
                existingMaterial.SetFloat("_MaskChannel", 0);
            }
            else if (existingMaterial == existingMaterialG)
            {
                existingMaterial.SetFloat("_MaskChannel", 1);
            }
            else if (existingMaterial == existingMaterialB)
            {
                existingMaterial.SetFloat("_MaskChannel", 2);
            }
            else if (existingMaterial == existingMaterialA)
            {
                existingMaterial.SetFloat("_MaskChannel", 3);
            }


            if (renderQueueTypeSelection == RenderQueueTypeSelection.Opaque)
            {
                renderObjectsFeature.settings.filterSettings.RenderQueueType = RenderQueueType.Opaque;
                //existingMaterial.renderQueue = 2000;
                newMaterial.renderQueue = 2000;
            }
            else if (renderQueueTypeSelection == RenderQueueTypeSelection.Transparent)
            {
                renderObjectsFeature.settings.filterSettings.RenderQueueType = RenderQueueType.Transparent;
                // existingMaterial.renderQueue = 3000;
                newMaterial.renderQueue = 3000;
            }
            //renderObjectsFeature.settings.filterSettings.RenderQueueType = RenderQueueType.Transparent;
            renderObjectsFeature.settings.filterSettings.LayerMask = LayerMask.NameToLayer("Everything");
            renderObjectsFeature.settings.filterSettings.PassNames = new[] { featureName };

            // 将特性添加到自定义渲染器上
            if (rendererData != null)
            {
                rendererData.rendererFeatures.Add(renderObjectsFeature);
            }
            else
            {
                Debug.LogError("找不到renderfeature设置");
            }
        }
        else
        {
            Debug.Log("找不到renderfeature设置的材质,不使用" + featureName);
           // renderObjectsFeature.settings.overrideMaterial = new Material(Shader.Find("Babu/FX/Terrain" + featureName));
        }

    }


    private void OnDestroy()
    {
        // 移除在Start中添加的所有rendererFeatures
        if (rendererData != null)
        {
            rendererData.rendererFeatures.RemoveAll(feature => feature.name == "TerrainR" || feature.name == "TerrainG" || feature.name == "TerrainB" || feature.name == "TerrainA");
        }
    }

}