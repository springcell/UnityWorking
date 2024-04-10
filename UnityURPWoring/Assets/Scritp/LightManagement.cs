using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//[ExecuteInEditMode]
public class LightManagement : MonoBehaviour
{

    private Material material;
    private Material newMaterial;
  [Header("2d�ƹ����")]
    public Color LightColor = Color.white;
    [Range(1, 20)]
    public float Brightness = 1;

  [Header("�ƹⷶΧ�ɰ�")]
    public GameObject LightMask;
    public Texture2D LightMaskMap;
    void Start()
    {
        Renderer LightMaskrenderer = LightMask.GetComponent<Renderer>();
        // �� LightMask ������� LightRTLayer ��
        if (LightMask != null)
        {
            LightMask.layer = LayerMask.NameToLayer("LightRTLayer");
            // �����µĲ���
            newMaterial = new Material(Shader.Find("Babu/FX/2DLightRT"));

            // ���²���Ӧ�õ� LightMask ����� Renderer �����
            LightMaskrenderer.material = newMaterial;

            // ����Ƿ���� LightMask ����
            if (LightMask != null)
            {
                // ���²�����ͼ
                newMaterial.SetTexture("_MainTex", LightMaskMap);
                newMaterial.SetColor("_color", LightColor);
                newMaterial.SetFloat("_HDRBrightness", Brightness);

            }
            else
            {
                Debug.LogError("LightMask ����Ϊ�գ�");
            }
        }
        else
        {
            Debug.LogError("LightMask ����Ϊ�գ�");
        }

  
    }

    void Update()
    {

        Renderer renderer = GetComponent<Renderer>(); // ��ȡ��ǰ����� Renderer ���

        if (renderer != null)
        {
            material = renderer.material; // ��ȡ����Ĳ���

            if (material != null && material.shader.name == "Babu/FX/2dLight")
            {
                material.SetColor("_color", LightColor);
                material.SetFloat("Brightness", Brightness); // ���� Brightness ������ֵ
            }
            else
            {
                Debug.LogWarning("���岻��2D�ƹ�");
            }
        }
        else
        {
            Debug.LogWarning("����û��Renderer���");
        }
    }
}

