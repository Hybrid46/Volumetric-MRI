using UnityEditor;
using UnityEngine;
using static StaticUtils;

[ExecuteInEditMode]
public class TextureMaker : MonoBehaviour
{
    public bool makeTexture = false;
    public Texture2D[] textures;
    [SerializeField] private Texture3D texture;
    

    private void Update()
    {
        if (makeTexture)
        {
            makeTexture= false;
            CreateTexture3D();
        }
    }

    private void CreateTexture3D()
    {
        Vector3Int textureSize = new Vector3Int(textures[0].width, textures[0].height, textures.Length);

        texture = new Texture3D(textureSize.x, textureSize.y, textureSize.z, TextureFormat.R8, false);

        Color[] colors = new Color[textureSize.x * textureSize.y * textureSize.z];

        for (int z = 0; z < textureSize.z; z++)
        {
            Color32[] pixels = textures[z].GetPixels32();

            for (int y = 0; y < textureSize.y; y++)
            {
                for (int x = 0; x < textureSize.x; x++)
                {
                    colors[Array3DTo1D(x,y,z,textureSize.x,textureSize.y)] = pixels[Array2dTo1d(x,y,textureSize.x)];
                }
            }
        }

        texture.SetPixels(colors);
        texture.Apply();

        AssetDatabase.CreateAsset(texture, "Assets/3DTexture.asset");
        AssetDatabase.Refresh();
    }
}