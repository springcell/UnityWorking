using UnityEngine;

public class WaterRandomY : MonoBehaviour
{    
    public float floatSpeed = 1f; // 浮动速度
    public float floatAmplitude = 1f; // 浮动振幅
    public float perlinScale = 0.1f; // Perlin噪声的缩放值

    private Vector3 originalPosition; // 初始位置

    void Start()
    {
        // 保存初始位置
        originalPosition = transform.position;
    }

    void Update()
    {
        // 计算基于Perlin噪声的浮动偏移量
        float yOffset = Mathf.PerlinNoise(Time.time * floatSpeed, 0) * 0.5f + 0.5f; // 调整Perlin噪声值在[0.5, 1]之间

        // 应用浮动偏移量到物体的Y坐标，并乘以振幅
        yOffset *= floatAmplitude;

        // 应用Perlin噪声浮动到物体的当前Y坐标
        transform.position = new Vector3(originalPosition.x, originalPosition.y + yOffset, originalPosition.z);
    }
}
