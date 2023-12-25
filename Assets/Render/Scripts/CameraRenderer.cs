using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
public class CameraRenderer
{
    private ScriptableRenderContext _context;
    private Camera _camera;
    private CommandBuffer _commandBuffer;
    private const string bufferName = "CameraWah";
    private CullingResults _cullingResults;
    private static readonly List<ShaderTagId> drawShaderTagId =
        new List<ShaderTagId> { new ShaderTagId("SRPDefaultUnlit"), };

    public void Render(ScriptableRenderContext context, Camera camera)
    {
        _camera = camera;
        _context = context;
        UIGO(); //домашка 
        if (!Cull(out var parameters))
        {
            return;
        }

        Settings(parameters);
        DrawVisible();
        DrawUnsupportedShaders();
        DrawGizmos();
        Submit();
    }

  

    private void DrawGizmos()
    {
        if (!Handles.ShouldRenderGizmos())
        {
            return;
        }

        _context.DrawGizmos(_camera, GizmoSubset.PreImageEffects);
        _context.DrawGizmos(_camera, GizmoSubset.PostImageEffects);
    }

    private void Settings(ScriptableCullingParameters parameters)
    {
        _commandBuffer = new CommandBuffer { name = _camera.name}; //дз 2
        _cullingResults = _context.Cull(ref parameters);
        _context.SetupCameraProperties(_camera);
        _commandBuffer.ClearRenderTarget(true, true, Color.clear);
        _commandBuffer.BeginSample(bufferName);
        _commandBuffer.SetGlobalColor("_GlobalCal", Color.blue);
        ExecuteCommandBuffer();
    }

    private void DrawVisible()
    {
        var drawingSettings = CreateDrawingSettings(drawShaderTagId, SortingCriteria.CommonOpaque, out var sortingSettings);
        var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
        _context.DrawRenderers(_cullingResults, ref drawingSettings, ref filteringSettings);
        _context.DrawSkybox(_camera);

        sortingSettings.criteria = SortingCriteria.CommonTransparent;
        drawingSettings.sortingSettings = sortingSettings;
        filteringSettings.renderQueueRange = RenderQueueRange.transparent;
        _context.DrawRenderers(_cullingResults, ref drawingSettings, ref filteringSettings);
    }

    private DrawingSettings CreateDrawingSettings(List<ShaderTagId> shaderTags, SortingCriteria sortingCriteria, out SortingSettings sortingSettings)
    {
        sortingSettings = new SortingSettings(_camera)
        {
            criteria = sortingCriteria,
        };

        var drawingSettings = new DrawingSettings(shaderTags[0], sortingSettings);

        return drawingSettings;
    }

    private void Submit()
    {
        _commandBuffer.EndSample(bufferName);
        ExecuteCommandBuffer();
        _context.Submit();
    }

    private void ExecuteCommandBuffer()
    {
        _context.ExecuteCommandBuffer(_commandBuffer);
        _commandBuffer.Clear();
    }

    private bool Cull(out ScriptableCullingParameters parameters)
    {
        return _camera.TryGetCullingParameters(out parameters);
    }


#if UNITY_EDITOR
    //home work
    private void UIGO()
    {
        if (_camera.cameraType == CameraType.SceneView)
        {
            ScriptableRenderContext.EmitWorldGeometryForSceneView(_camera);
        }
    }

    private static readonly ShaderTagId[] _legacyShaderTag =
    {
        new ShaderTagId("Always"),
        new ShaderTagId("ForwardBase"),
        new ShaderTagId("PrepassBase"),
        new ShaderTagId("Vertex"),
        new ShaderTagId("VertexLMRGBM"),
        new ShaderTagId("VertexLM")
    };

    private static Material _errorMaterial = new Material(Shader.Find("Hidden/InternalErrorShader"));

    private void DrawUnsupportedShaders()
    {
        var drawingSettings = new DrawingSettings(_legacyShaderTag[0], new SortingSettings(_camera))
        { 
            overrideMaterial = _errorMaterial,
        };

        for (int i = 0; i < _legacyShaderTag.Length; i++)
        {
            drawingSettings.SetShaderPassName(i, _legacyShaderTag[i]);
        }

        var filteringSettings = FilteringSettings.defaultValue;

        _context.DrawRenderers(_cullingResults, ref drawingSettings, ref filteringSettings);
    }

#endif
}