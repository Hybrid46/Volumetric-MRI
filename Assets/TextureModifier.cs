using System.IO;
using UnityEditor;
using UnityEngine;
using static StaticUtils;

[ExecuteInEditMode]
public class TextureModifier : MonoBehaviour

{
    public Material modifierMaterial;
    public Texture2D[] textures;
    [Space(20)]
    public bool modifyTextures = false;
    [Space(20)]
    [Header("Settings")]
    [Tooltip("Radius from center. When a pixel is outside it will be discarded!")]
    [Range(0.0f, 1.0f)] public float radius = 0.5f;

    private void Update()
    {
        if (modifyTextures)
        {
            modifyTextures = false;
            ModifyTextures();
        }
    }

    private void ModifyTextures()
    {
        Vector2Int textureSize = new Vector2Int(textures[0].width, textures[0].height);

        RenderTexture renderTexture = RenderTexture.GetTemporary(textureSize.x, textureSize.y, 0);

        modifierMaterial.SetFloat("_Radius", radius);
        string savePath = Application.dataPath + "/Images/";

        if (!Directory.Exists(savePath)) Directory.CreateDirectory(savePath);

        for (int t = 0; t < textures.Length; t++)
        {
            Graphics.Blit(textures[t], renderTexture, modifierMaterial);

            //This makes assets and not textures!
            //AssetDatabase.CreateAsset(RenderTexturetoTexture2D(renderTexture), "Assets/Images/" + textures[t].name + ".asset");
            SaveTextureJPG(RenderTexturetoTexture2D(renderTexture), savePath + textures[t].name + ".jpg");
        }

        RenderTexture.active = null;
        RenderTexture.ReleaseTemporary(renderTexture);
        AssetDatabase.Refresh();
    }
}