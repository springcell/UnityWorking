using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//[ExecuteInEditMode]
public class LightManagement : MonoBehaviour
{

    private Material material;
    private Material newMaterial;
  [Header("2d灯光参数")]
    public Color LightColor = Color.white;
    [Range(1, 20)]
    public float Brightness = 1;

  [Header("灯光范围蒙版")]
    public GameObject LightMask;
    public Texture2D LightMaskMap;
    void Start()
    {
        Renderer LightMaskrenderer = LightMask.GetComponent<Renderer>();
        // 将 LightMask 物体放入 LightRTLayer 层
        if (LightMask != null)
        {
            LightMask.layer = LayerMask.NameToLayer("LightRTLayer");
            // 创建新的材质
            newMaterial = new Material(Shader.Find("Babu/FX/2DLightRT"));

            // 将新材质应用到 LightMask 对象的 Renderer 组件上
            LightMaskrenderer.material = newMaterial;

            // 检查是否存在 LightMask 对象
            if (LightMask != null)
            {
                // 给新材质贴图
                newMaterial.SetTexture("_MainTex", LightMaskMap);
                newMaterial.SetColor("_color", LightColor);
                newMaterial.SetFloat("_HDRBrightness", Brightness);

            }
            else
            {
                Debug.LogError("LightMask 对象为空！");
            }
        }
        else
        {
            Debug.LogError("LightMask 对象为空！");
        }

  
    }

    void Update()
    {

        Renderer renderer = GetComponent<Renderer>(); // 获取当前物体的 Renderer 组件

        if (renderer != null)
        {
            material = renderer.material; // 获取物体的材质

            if (material != null && material.shader.name == "Babu/FX/2dLight")
            {
                material.SetColor("_color", LightColor);
                material.SetFloat("Brightness", Brightness); // 设置 Brightness 参数的值
            }
            else
            {
                Debug.LogWarning("物体不是2D灯光");
            }
        }
        else
        {
            Debug.LogWarning("物体没有Renderer组件");
        }
    }
}

