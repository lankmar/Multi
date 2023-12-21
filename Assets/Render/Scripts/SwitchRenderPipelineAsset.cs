using UnityEngine;
using UnityEngine.Rendering;

public class SwitchRenderPipelineAsset : MonoBehaviour
{
    public RenderPipelineAsset exampleAssetA;
    public RenderPipelineAsset exampleAssetB;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
        {
            GraphicsSettings.renderPipelineAsset = exampleAssetA;
            Debug.Log("Default render pipline asset is: " + GraphicsSettings.renderPipelineAsset.name);
        }
        else if (Input.GetKeyDown(KeyCode.B))
        {
            GraphicsSettings.renderPipelineAsset = exampleAssetB;
            Debug.Log("Default render pipline asset is: " + GraphicsSettings.renderPipelineAsset.name);
        }
    }
}
