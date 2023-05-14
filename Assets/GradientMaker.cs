using UnityEditor;
using UnityEngine;

[ExecuteInEditMode]
public class GradientMaker : MonoBehaviour
{
    public Gradient gradient;
    public Texture2D gradientTexture;
    public int gradientSize = 256;
    public bool generate = false;

    void Update()
    {
        if (generate)
        {
            generate = false;
            Generate();
        }
    }

    private void Generate()
    {
        gradientTexture = new Texture2D(gradientSize, 1, TextureFormat.RGB24, false);

        Color[] colors = new Color[gradientSize];

        for (int g = 0; g < gradientSize; g++)
        {
            colors[g] = gradient.Evaluate((float)g / gradientSize);
        }

        gradientTexture.SetPixels(colors);
        gradientTexture.Apply();

        AssetDatabase.CreateAsset(gradientTexture, "Assets/GradientTexture.asset");
        AssetDatabase.Refresh();
    }
}
