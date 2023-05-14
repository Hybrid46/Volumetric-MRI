using UnityEngine;

public static class StaticUtils
{
    public static int Array3DTo1D(int x, int y, int z, int xMax, int yMax) => (z * xMax * yMax) + (y * xMax) + x;

    public static Vector3Int Array1Dto3D(int idx, int xMax, int yMax)
    {
        int z = idx / (xMax * yMax);
        idx -= (z * xMax * yMax);
        int y = idx / xMax;
        int x = idx % xMax;
        return new Vector3Int(x, y, z);
    }

    public static int Array2dTo1d(int x, int y, int width) => y * width + x;

    public static Vector2Int Array1dTo2d(int i, int width) => new Vector2Int { x = i % width, y = i / width };

    public static Texture2D RenderTexturetoTexture2D(RenderTexture rTex)
    {
        Texture2D tex = new Texture2D(rTex.width, rTex.height, TextureFormat.RGB24, false);
        RenderTexture.active = rTex;

        tex.ReadPixels(new Rect(0, 0, rTex.width, rTex.height), 0, 0);
        tex.Apply();

        return tex;
    }

    public static void SaveTextureJPG(Texture2D texture, string path) => System.IO.File.WriteAllBytes(path, texture.EncodeToJPG());
    public static void SaveTexturePNG(Texture2D texture, string path) => System.IO.File.WriteAllBytes(path, texture.EncodeToPNG());
    public static void SaveTextureTGA(Texture2D texture, string path) => System.IO.File.WriteAllBytes(path, texture.EncodeToTGA());
}
