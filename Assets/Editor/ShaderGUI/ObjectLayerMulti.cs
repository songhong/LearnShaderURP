using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ObjectLayerMulti : BaseShaderGUI
{ 
    protected static class StylesD
    {
        public static GUIContent BumpMapGlobalText = EditorGUIUtility.TrTextContent("Global Normal",
            "Global normal on the surface.");

        public static GUIContent SplatMapGlobalText = EditorGUIUtility.TrTextContent("Splat Map",
            "Determine weight in different channels");

        public static GUIContent DetailMapText = EditorGUIUtility.TrTextContent("Detail Map",
            "Far layer tiling details");

        public static GUIContent BaseStrengthText = EditorGUIUtility.TrTextContent("Base",
            "Base layer tiling strength");
        
        public static GUIContent DetailStrengthText = EditorGUIUtility.TrTextContent("Strength",
            "Far layer tiling strength");
        
        public static readonly GUIContent BaseColor = EditorGUIUtility.TrTextContent("Base Color",
            "Specifies the base Color of the surface.");
        
        public static GUIContent SharpenText = EditorGUIUtility.TrTextContent("Sharpen", 
            "Controls the strength of sharpen on the surface by alpha.");
        
        public static readonly GUIContent PBRMaskText = EditorGUIUtility.TrTextContent("PBR Mask [Metallic(R) Smoothness(G) Occlusion(B)]", 
            "These are standard PBR parameters");
        
        public static GUIContent MetallicText = EditorGUIUtility.TrTextContent("Metallic", 
            "Controls the strength of metallic on the surface.");
        
        public static GUIContent SmoothnessText = EditorGUIUtility.TrTextContent("Smoothness",
            "Controls the spread of highlights and reflections on the surface.");
         
        public static GUIContent OcclusionText = EditorGUIUtility.TrTextContent("Occlusion",
            "Controls the strength of occlusion on the surface.");
         
        public static readonly GUIContent BaseLayerInputs = EditorGUIUtility.TrTextContent("Base",
            "These settings define the surface details as default layer.");

        public static readonly GUIContent FarLayerInputs = EditorGUIUtility.TrTextContent("Far Layer",
            "These settings define the surface details of far layer.");
        
        public static readonly GUIContent RChannelInputs = EditorGUIUtility.TrTextContent("R Channel",
            "These settings define the surface details controlled by R channel of splat map.");
         
        public static readonly GUIContent GChannelInputs = EditorGUIUtility.TrTextContent("G Channel",
            "These settings define the surface details controlled by G channel of splat map.");
         
        public static readonly GUIContent BChannelInputs = EditorGUIUtility.TrTextContent("B Channel",
            "These settings define the surface details controlled by B channel of splat map.");           
    }

    
    /* Surface Input Props */
    // base layer 
    protected MaterialProperty bumpMapGlobal;
    protected MaterialProperty bumpScaleGlobal;
    protected MaterialProperty splatMapGlobal;
    protected MaterialProperty transitionStrength;
    protected MaterialProperty baseStrength;
    protected MaterialProperty splatLayerType;

    protected MaterialProperty sharpen;
    protected MaterialProperty metallic;
    protected MaterialProperty metallicGlossMap;
    protected MaterialProperty smoothness;
    protected MaterialProperty occlusionStrength;
    protected MaterialProperty bumpMapProp;
    
    protected MaterialProperty baseColor01;
    protected MaterialProperty sharpen01;
    protected MaterialProperty metallic01;
    protected MaterialProperty smoothness01;
    protected MaterialProperty occlusionStrength01;
    protected MaterialProperty bumpScale;
    
    protected MaterialProperty baseColor02;
    protected MaterialProperty sharpen02;
    protected MaterialProperty metallic02;
    protected MaterialProperty smoothness02;
    protected MaterialProperty occlusionStrength02;
    
    protected MaterialProperty baseColor03;
    protected MaterialProperty sharpen03;
    protected MaterialProperty metallic03;
    protected MaterialProperty smoothness03;
    protected MaterialProperty occlusionStrength03;
    
    // layer one
    protected MaterialProperty baseMap1Prop;
    protected MaterialProperty baseColor1Prop; 
    protected MaterialProperty sharpen1;
    protected MaterialProperty metallic1;
    protected MaterialProperty metallicGlossMap1;
    protected MaterialProperty smoothness1;
    protected MaterialProperty occlusionStrength1;
    protected MaterialProperty bumpMap1Prop;
    protected MaterialProperty bumpScale1;
    
    // layer two
    protected MaterialProperty baseMap2Prop;
    protected MaterialProperty baseColor2Prop; 
    protected MaterialProperty sharpen2;
    protected MaterialProperty metallic2;
    protected MaterialProperty metallicGlossMap2;
    protected MaterialProperty smoothness2;
    protected MaterialProperty occlusionStrength2;
    protected MaterialProperty bumpMap2Prop;
    protected MaterialProperty bumpScale2;
    
    // layer three
    protected MaterialProperty baseMap3Prop;
    protected MaterialProperty baseColor3Prop; 
    protected MaterialProperty sharpen3;
    protected MaterialProperty metallic3;
    protected MaterialProperty metallicGlossMap3;
    protected MaterialProperty smoothness3;
    protected MaterialProperty occlusionStrength3;
    protected MaterialProperty bumpMap3Prop;
    protected MaterialProperty bumpScale3;
    
    // far layer
    protected MaterialProperty detailMap;
    protected MaterialProperty detailColor;
    protected MaterialProperty detailStrength;
    
    // Advanced Props
    public MaterialProperty highlights;
    public MaterialProperty reflections;

    private int _layerTypeValue;

    public override void FindProperties(MaterialProperty[] properties)
    {
        base.FindProperties(properties);
        
        /* Surface Input Props */
        bumpMapGlobal = FindProperty("_BumpMapGlobal", properties);
        bumpScaleGlobal = FindProperty("_BumpScaleGlobal", properties);
        splatMapGlobal = FindProperty("_SplatMapGlobal", properties);
        transitionStrength = FindProperty("_TransitionStrength", properties);
        baseStrength = FindProperty("_BaseStrength", properties);
        splatLayerType = FindProperty("_LAYER", properties);

        // base layer
        sharpen = FindProperty("_Sharpen", properties);
        metallic = FindProperty("_Metallic", properties);
        metallicGlossMap = FindProperty("_MetallicGlossMap", properties);
        smoothness = FindProperty("_Smoothness", properties);
        occlusionStrength = FindProperty("_OcclusionStrength", properties);
        bumpMapProp = FindProperty("_BumpMap", properties);
        bumpScale = FindProperty("_BumpScale", properties);
        
        baseColor01 = FindProperty("_BaseColor01", properties, false);
        sharpen01 = FindProperty("_Sharpen01", properties, false);
        metallic01 = FindProperty("_Metallic01", properties, false);
        smoothness01 = FindProperty("_Smoothness01", properties, false);
        occlusionStrength01 = FindProperty("_OcclusionStrength01", properties, false);

        baseColor02 = FindProperty("_BaseColor02", properties, false);
        sharpen02 = FindProperty("_Sharpen02", properties, false);
        metallic02 = FindProperty("_Metallic02", properties, false);
        smoothness02 = FindProperty("_Smoothness02", properties, false);
        occlusionStrength02 = FindProperty("_OcclusionStrength02", properties, false);
        
        baseColor03 = FindProperty("_BaseColor03", properties, false);
        sharpen03 = FindProperty("_Sharpen03", properties, false);
        metallic03 = FindProperty("_Metallic03", properties, false);
        smoothness03 = FindProperty("_Smoothness03", properties, false);
        occlusionStrength03 = FindProperty("_OcclusionStrength03", properties, false);
        
        // layer one
        baseMap1Prop = FindProperty("_BaseMap1", properties, false);
        baseColor1Prop = FindProperty("_BaseColor1", properties, false);
        sharpen1 = FindProperty("_Sharpen1", properties, false);
        metallic1 = FindProperty("_Metallic1", properties, false);
        metallicGlossMap1 = FindProperty("_MetallicGlossMap1", properties, false);
        smoothness1 = FindProperty("_Smoothness1", properties, false);
        occlusionStrength1 = FindProperty("_OcclusionStrength1", properties, false);
        bumpMap1Prop = FindProperty("_BumpMap1", properties, false);
        bumpScale1 = FindProperty("_BumpScale1", properties, false);

        // layer two
        baseMap2Prop = FindProperty("_BaseMap2", properties, false);
        baseColor2Prop = FindProperty("_BaseColor2", properties, false);
        sharpen2 = FindProperty("_Sharpen2", properties, false);
        metallic2 = FindProperty("_Metallic2", properties, false);
        metallicGlossMap2 = FindProperty("_MetallicGlossMap2", properties, false);
        smoothness2 = FindProperty("_Smoothness2", properties, false);
        occlusionStrength2 = FindProperty("_OcclusionStrength2", properties, false);
        bumpMap2Prop= FindProperty("_BumpMap2", properties, false); 
        bumpScale2 = FindProperty("_BumpScale2", properties, false);
        
        // layer three
        baseMap3Prop = FindProperty("_BaseMap3", properties, false);
        baseColor3Prop = FindProperty("_BaseColor3", properties, false);
        sharpen3 = FindProperty("_Sharpen3", properties, false);
        metallic3 = FindProperty("_Metallic3", properties, false);
        metallicGlossMap3 = FindProperty("_MetallicGlossMap3", properties, false);
        smoothness3 = FindProperty("_Smoothness3", properties, false);
        occlusionStrength3 = FindProperty("_OcclusionStrength3", properties, false);
        bumpMap3Prop= FindProperty("_BumpMap3", properties, false); 
        bumpScale3 = FindProperty("_BumpScale3", properties, false);
        
        // far layer
        detailMap = FindProperty("_DetailMap", properties);
        detailColor = FindProperty("_DetailColor", properties, false);
        detailStrength = FindProperty("_DetailStrength", properties, false);
        
        // Advanced Props
        highlights = FindProperty("_SpecularHighlights", properties, false);
        reflections = FindProperty("_EnvironmentReflections", properties, false);
    }

    public override void DrawSurfaceOptions(Material material)
    {
        base.DrawSurfaceOptions(material);
        
        materialEditor.ShaderProperty(splatLayerType, "Splat Type");
    }
    
    public override void DrawSurfaceInputs(Material material)
    {
        materialEditor.TexturePropertySingleLine(StylesD.BumpMapGlobalText, bumpMapGlobal, bumpScaleGlobal);

        if (splatMapGlobal != null)
        {
             materialEditor.TexturePropertySingleLine(StylesD.SplatMapGlobalText, splatMapGlobal,
                 CanSplatChannels(material) ? transitionStrength : null);
             EditorGUI.indentLevel += 2;
             {
                 materialEditor.ShaderProperty(baseStrength, StylesD.BaseStrengthText);
             }
             EditorGUI.indentLevel -= 2;
        }
        
    }

    public override void FillAdditionalFoldouts(MaterialHeaderScopeList materialScopesList)
    {
        materialScopesList.RegisterHeaderScope(StylesD.BaseLayerInputs, Expandable.Details, DrawBaseLayer);
        
        materialScopesList.RegisterHeaderScope(StylesD.RChannelInputs, Expandable.Details, DrawChannelR);  
        materialScopesList.RegisterHeaderScope(StylesD.GChannelInputs, Expandable.Details, DrawChannelG); 
        materialScopesList.RegisterHeaderScope(StylesD.BChannelInputs, Expandable.Details, DrawChannelB);
        
        materialScopesList.RegisterHeaderScope(StylesD.FarLayerInputs, Expandable.Details, DrawFayLayer);
    }

    public void DrawBaseLayer(Material material)
    {
        // Base Channel
        materialEditor.TexturePropertySingleLine(Styles.baseMap, baseMapProp, baseColorProp);
        DrawAlphaSharpen(sharpen);
        materialEditor.TexturePropertySingleLine(Styles.normalMapText, bumpMapProp, bumpScale);
        DrawPBRMaskArea(metallicGlossMap, metallic, smoothness, occlusionStrength);
        DrawTileOffset(materialEditor, baseMapProp);
    }
    
    public void DrawChannelR(Material material)
    {
        if (splatLayerType.floatValue == 4) // _LAYER_FOUR
        {
            materialEditor.TexturePropertySingleLine(Styles.baseMap, baseMap1Prop, baseColor1Prop);
            DrawAlphaSharpen(sharpen1);
            materialEditor.TexturePropertySingleLine(Styles.normalMapText, bumpMap1Prop, bumpScale1);
            DrawPBRMaskArea(metallicGlossMap1, metallic1, smoothness1, occlusionStrength1);
            DrawTileOffset(materialEditor, baseMap1Prop);                
        }
        else
        {
            materialEditor.ShaderProperty(baseColor01, StylesD.BaseColor);
            DrawAlphaSharpen(sharpen01);
            DrawPBRMaskArea(null, metallic01, smoothness01, occlusionStrength01);
        }
    }
    
    public void DrawChannelG(Material material)
    {
        if (splatLayerType.floatValue == 1 || splatLayerType.floatValue == 3 || splatLayerType.floatValue == 4) // _LAYER_TWO_PAIR, _LAYER_THREE, _LAYER_FOUR
        {
            materialEditor.TexturePropertySingleLine(Styles.baseMap, baseMap2Prop, baseColor2Prop);
            DrawAlphaSharpen(sharpen2);
            materialEditor.TexturePropertySingleLine(Styles.normalMapText, bumpMap2Prop, bumpScale2);
            DrawPBRMaskArea(metallicGlossMap2, metallic2, smoothness2, occlusionStrength2);
            DrawTileOffset(materialEditor, baseMap2Prop);
        }
        else
        {
            materialEditor.ShaderProperty(baseColor02, StylesD.BaseColor);
            DrawAlphaSharpen(sharpen02);
            DrawPBRMaskArea(null, metallic02, smoothness02, occlusionStrength02);
        }
    }
    
    public void DrawChannelB(Material material)
    {
        if (splatLayerType.floatValue == 2 || splatLayerType.floatValue == 3 || splatLayerType.floatValue == 4) // _LAYER_TWO, _LAYER_THREE, _LAYER_FOUR
        {
            materialEditor.TexturePropertySingleLine(Styles.baseMap, baseMap3Prop, baseColor3Prop);
            DrawAlphaSharpen(sharpen3);
            materialEditor.TexturePropertySingleLine(Styles.normalMapText, bumpMap3Prop, bumpScale3);
            DrawPBRMaskArea(metallicGlossMap3, metallic3, smoothness3, occlusionStrength3);
            DrawTileOffset(materialEditor, baseMap3Prop);
        }
        else
        {
            materialEditor.ShaderProperty(baseColor03, StylesD.BaseColor);
            DrawAlphaSharpen(sharpen03);
            DrawPBRMaskArea(null, metallic03, smoothness03, occlusionStrength03);
        }
    }

    public void DrawFayLayer(Material material)
    {
        materialEditor.TexturePropertySingleLine(StylesD.DetailMapText, detailMap, detailColor);
        EditorGUI.indentLevel += 2;   
        {
            materialEditor.ShaderProperty(detailStrength, StylesD.DetailStrengthText);
        }
        EditorGUI.indentLevel -= 2;
        DrawTileOffset(materialEditor, detailMap);
    }

    private void DrawAlphaSharpen(MaterialProperty sharpen)
    {
        EditorGUI.indentLevel += 2;   
        {
            materialEditor.ShaderProperty(sharpen, StylesD.SharpenText);
        }
        EditorGUI.indentLevel -= 2;
    }
    
    private void DrawPBRMaskArea(MaterialProperty metallicGlossMap, MaterialProperty metallic, MaterialProperty smoothness, MaterialProperty occlusion)
    {
        bool hasLayerMap = metallicGlossMap != null;
        if (hasLayerMap)
        {
            materialEditor.TexturePropertySingleLine(StylesD.PBRMaskText, metallicGlossMap);
        }
        
        EditorGUI.indentLevel += 2;   
        {
            materialEditor.ShaderProperty(metallic, StylesD.MetallicText);   
            materialEditor.ShaderProperty(smoothness, StylesD.SmoothnessText);
            materialEditor.ShaderProperty(occlusion, StylesD.OcclusionText);
        }
        EditorGUI.indentLevel -= 2;
    }
    
    public override void ValidateMaterial(Material material)
    {
        SetMaterialKeywords(material, ObjectLayerMulti.SetMaterialKeywords, null);
    }

    public static void SetMaterialKeywords(Material material)
    {
        if (material.HasProperty("_BumpMapGlobal"))
        {
            CoreUtils.SetKeyword(material, ShaderKeywordStrings._NORMALMAP, material.GetTexture("_BumpMapGlobal"));
        }

        if (material.HasProperty("_DetailMap"))
        {
            CoreUtils.SetKeyword(material, "_DETAILMAP", material.GetTexture("_DetailMap"));
        }

        if (material.HasProperty("_SpecularHighlights"))
        {
            CoreUtils.SetKeyword(material, "_SPECULARHIGHLIGHTS_OFF", material.GetFloat("_SpecularHighlights") == 0.0f);
        }

        if (material.HasProperty("_EnvironmentReflections"))
        {
            CoreUtils.SetKeyword(material, "_ENVIRONMENTREFLECTIONS_OFF", material.GetFloat("_EnvironmentReflections") == 0.0f);
        }
    }
    
    private static bool CanSplatChannels(Material material)
    {
        if (material.GetTexture("_SplatMapGlobal") == null)
        {
            return false;
        }

        return true;
    }
}


