using UnityEngine;
using System.IO;

public static class TextureExporter
{
    public static void ExportAsTGA(Texture2D texture, string outputPath)
    {
        if (texture != null)
        {
            // 创建一个新的RGBA32格式的Texture2D，并将原Texture2D的像素复制到新Texture2D
            // Texture2D newTexture = new Texture2D(texture.width, texture.height, TextureFormat.RGBA32, false);
            // newTexture.SetPixels(texture.GetPixels());
            // newTexture.Apply();
            Texture2D newTexture = new Texture2D(texture.width, texture.height, TextureFormat.RGBA32, false);
            newTexture.SetPixels(texture.GetPixels());
            newTexture.Apply();


            // 将新Texture2D导出为TGA文件
            byte[] tgaData = EncodeAsTGA(newTexture);
            string tgaPath = Path.ChangeExtension(outputPath, ".tga");
            File.WriteAllBytes(tgaPath, tgaData);
            Debug.Log("Texture exported as TGA format: " + tgaPath);
        }
    }

    private static byte[] EncodeAsTGA(Texture2D texture)
    {
        int width = texture.width;
        int height = texture.height;

        using (MemoryStream stream = new MemoryStream())
        using (BinaryWriter writer = new BinaryWriter(stream))
        {
            // TGA头部
            writer.Write((byte)0); // ID长度
            writer.Write((byte)0); // 颜色表类型
            writer.Write((byte)2); // 图像类型码 (RGB)
            writer.Write((short)0); // 颜色表起始索引
            writer.Write((short)0); // 颜色表长度
            writer.Write((byte)0); // 颜色表项大小
            writer.Write((short)0); // X 坐标
            writer.Write((short)0); // Y 坐标
            writer.Write((short)width); // 宽度
            writer.Write((short)height); // 高度
            writer.Write((byte)32); // 图像位深度 (32 bits per pixel)
            writer.Write((byte)0); // 图像描述字节

            Color[] pixels = texture.GetPixels();

            // 镜像像素数组
            System.Array.Reverse(pixels);

            for (int i = pixels.Length - 1; i >= 0; i--)
            {
                // 将颜色值写入 TGA 文件（BGR(A) 格式）
                writer.Write((byte)(pixels[i].b * 255));
                writer.Write((byte)(pixels[i].g * 255));
                writer.Write((byte)(pixels[i].r * 255));
                writer.Write((byte)(pixels[i].a * 255));
            }

            return stream.ToArray();
        }
    }
}
