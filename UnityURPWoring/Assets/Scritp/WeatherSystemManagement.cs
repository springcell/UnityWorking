using System;
using UnityEngine;
using Spine.Unity;
using UnityEngine.Rendering.Universal;
using System.Linq;
using UnityEditor.Rendering;
[ExecuteInEditMode]
public class WeatherSystemManagement : MonoBehaviour
{

    public Camera SpineCamera;  
    private RenderTexture SpineRT;
    private int defaultCullingMask;
    private Material[] SpinrMAT;

    [SerializeField] private UniversalRendererData rendererData;
    private ScriptableRendererFeature Light;
    private ScriptableRendererFeature LightRT;

    [Header("��������")]
   // public int LightRTLayer = 14;
    public Material EnvironmentLightMaterial;
    public Shader SpineShader;

    [Range(1, 20)]
    public int Downsampling = 1;

    [Header("����")]
    public Color Environment = Color.white;

    [Range(1, 20)]
    public float GlobalSpineLightIntensity = 1;
    public bool OpenLight = false;
    public bool OpenFeature = false;
    private GameObject[] LightObject;

    void Start()
    {
        Light = rendererData.rendererFeatures.OfType<ScriptableRendererFeature>().FirstOrDefault(feature => feature.name == "2dLight");
        LightRT = rendererData.rendererFeatures.OfType<ScriptableRendererFeature>().FirstOrDefault(feature => feature.name == "2dLightRT");

        //SpineCamera = Camera.main;
        defaultCullingMask = Camera.main.cullingMask;
        SpineRT = new RenderTexture(Screen.width / Downsampling, Screen.height / Downsampling, 24);

        if (!Light)
        {
            Debug.LogError("Renderer Feature ��ȱ�� 2dLight ���ԣ�");
        }
        else
        {
            if (OpenFeature) { Light.SetActive(true); }
        }

        if (!LightRT)
        {
            Debug.LogError("Renderer Feature ��ȱ�� 2dLightRT ���ԣ�");
        }
        else
        {
            if (OpenFeature) { LightRT.SetActive(true); }
        }

        LightObject = GameObject.FindGameObjectsWithTag("LightObj");

    }
    void LateUpdate()
    {

        if (SpineCamera != null)
        {
            SpineCamera.cullingMask = 1 << LayerMask.NameToLayer("LightRTLayer");
            SpineCamera.backgroundColor = Color.black;
            SpineCamera.targetTexture = SpineRT;
           // Graphics.Blit(SpineCamera.targetTexture, SpineRT);
            SpineCamera.Render();
            SpineCamera.targetTexture = null;
            SpineCamera.cullingMask = defaultCullingMask;
        }
        else
        {
            Debug.LogWarning("SpineCamera未赋值");
        }

        //feature��Ϊ����ɫ�Ĳ���
        EnvironmentLightMaterial.SetColor("_AMBIENTColor", Environment);

        SpineShader = Shader.Find("Spine/BaBu/2DSpriteShadow");

        //��ȡ���������е� SkeletonAnimation ���
        SkeletonAnimation[] skeletonAnimations = FindObjectsOfType<SkeletonAnimation>();
        // ���� SkeletonAnimation �������ȡ Renderer ���
        foreach (SkeletonAnimation skeletonAnimation in skeletonAnimations)
        {
            // ��ȡ SkeletonAnimation �� MeshRenderer ���
            MeshRenderer meshRenderer = skeletonAnimation.GetComponent<MeshRenderer>();

            // ��� meshRenderer �Ƿ�Ϊnull���Է�û�� MeshRenderer ���
            if (meshRenderer != null)
            {
                SpinrMAT = meshRenderer.sharedMaterials;

                foreach (Material SpinrMAT in SpinrMAT)
                {
                    // ��鵱ǰ�����Ƿ�ʹ����Ŀ�� Shader
                    if (SpinrMAT.shader == SpineShader)
                    {
                        // �� Render Texture ���ø����ʵ���������
                        SpinrMAT.SetTexture("_LightTex", SpineRT);
                       // SpinrMAT.SetColor("_Color", Environment); 
                        SpinrMAT.SetFloat("_HDRBrightness", GlobalSpineLightIntensity);
                        if (OpenLight)
                        {
                           
                        }
                        else
                        {
                            SpinrMAT.SetFloat("_HDRBrightness", 1);
                        }
                    }
                }
            }
        }

            
    }



    //void Update()
    //{
    //    // ����ÿ���ƹ����ʾ״̬
    //    foreach (GameObject obj in LightObject)
    //    {
    //        // Debug.Log("ToggleLights: " + OpenLight);
    //        obj.SetActive(OpenLight);
    //    }
    //}

    void OnDisable()
    {
        Light.SetActive(false);
        LightRT.SetActive(false);

        if (SpineCamera != null)
        {
            // ���� targetTexture
            SpineCamera.targetTexture = null;
        }
        if (SpineRT != null)
        {
            // �ͷ� Render Texture �ڴ沢����
            SpineRT.Release();

#if UNITY_EDITOR

            DestroyImmediate(SpineRT);
#else
            Destroy(SpineRT);
#endif
        }
    }
}
