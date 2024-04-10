using UnityEngine;

public class WaterRandomY : MonoBehaviour
{
    public float moveSpeed = 0.15f; // 移动速度
    public float frequency = 4f; // 频率
    public float randomRange = 0.2f; // 随机扰动范围

    private float startTime;
    private float initialY;

    void Start()
    {
        startTime = Time.time;
        initialY = transform.position.y; // 记录初始Y轴位置
    }

    void Update()
    {
        // 计算Sin波形的基础偏移量
        float baseYOffset = Mathf.Sin(frequency * (Time.time - startTime));

        // 添加随机扰动
        float randomOffset = Random.Range(-randomRange, randomRange);
        float yOffset = initialY + baseYOffset + randomOffset;

        // 计算物体的新位置
        Vector3 newPosition = new Vector3(transform.position.x, yOffset, transform.position.z);

        // 使用Lerp平滑地移动物体
        transform.position = Vector3.Lerp(transform.position, newPosition, moveSpeed * Time.deltaTime);
    }
}
