using UnityEngine;
using UnityEngine.UI;
[ExecuteInEditMode]
public class UIImageScaler : MonoBehaviour
{
    private Material material;
    private RectTransform rectTransform;

    void Start()
    {
        // 获取Image组件的Material
        Image image = GetComponent<Image>();
        material = image.material;

        // 获取RectTransform组件
        rectTransform = GetComponent<RectTransform>();
    }

    void Update()
    {
        // 获取UI元素的缩放值
        Vector3 uiScale = rectTransform.localScale;

        // 设置缩放值到Shader中
        material.SetVector("_UIScale", new Vector4(uiScale.x, uiScale.y, uiScale.z, 1.0f));
        //Debug.Log("UIScale: " + uiScale);
    }
}
