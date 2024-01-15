using System.Security.Cryptography;
using UnityEngine;

//[ExecuteInEditMode]
public class WaterRTToShader : MonoBehaviour
{
    private Camera waterCamera;  // 使用渲染水层的相机
    private RenderTexture waterRT;  // 水层的 RenderTexture
    public int waterLayer = 13;  // 水层的 LayerMask

    [Range(1, 20)]
    public int Downsampling = 1;

    private void InitializewaterCamera()
    {
        // 创建一个新的 RenderTexture，设置格式为带有 alpha 通道的格式
        waterRT = new RenderTexture(Screen.width / Downsampling, Screen.height / Downsampling, 24);

        // 获取或创建一个用于渲染的相机
        if (waterCamera == null)
        {
            waterCamera = new GameObject("waterCamera").AddComponent<Camera>();
            // 获取主相机的参数
            Camera mainCamera = Camera.main;
            Vector3 position = mainCamera.transform.position;
            Quaternion rotation = mainCamera.transform.rotation;
            Vector3 scale = mainCamera.transform.localScale;

            // 设置相机的位置、旋转、缩放与主相机相同
            waterCamera.transform.position = position;
            waterCamera.transform.rotation = rotation;
            waterCamera.transform.localScale = scale;

            waterCamera.fieldOfView = mainCamera.fieldOfView;
            waterCamera.nearClipPlane = mainCamera.nearClipPlane;
            waterCamera.farClipPlane = mainCamera.farClipPlane;
            waterCamera.clearFlags = CameraClearFlags.SolidColor;
            waterCamera.backgroundColor= Color.black;
           // waterCamera.enabled = false; // 禁用相机，确保它不会渲染到屏幕上

            // 将相机的 cullingMask 设置为指定层
            waterCamera.cullingMask = 1 << waterLayer;
                                    
            waterCamera.targetTexture = waterRT;
        }
    }

    void Start()
    {


        InitializewaterCamera();

        // 获取当前物体的 Renderer 组件
        Renderer renderer = GetComponent<Renderer>();
        if (renderer != null)
        {
            // 获取当前物体的共享材质
            Material sharedMaterial = renderer.sharedMaterial;

            // 将 RT 传入 Shader
            if (sharedMaterial != null)
            {

                sharedMaterial.SetTexture("_WaterRT", waterRT);
            }
            else
            {
                Debug.LogError("没有找到水材质");
            }
        }
        else
        {
            Debug.LogError("当前没有渲染的对象");
        }
    }

    void OnDisable()
    {
        // 检查 waterCamera 是否为 null
        if (waterCamera != null)
        {
            // 重置水层相机的 targetTexture
            waterCamera.targetTexture = null;
        }
    }
}
