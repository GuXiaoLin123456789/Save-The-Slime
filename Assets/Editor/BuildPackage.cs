using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class BuildPackage : Editor
{
    [MenuItem("Tools/BuildPackage")]
    public static void BuildAllAssets() {
        BuildPipeline.BuildAssetBundles(Application.dataPath + "/Resources/Package", BuildAssetBundleOptions.None, BuildTarget.Android);

        AssetBundleManifest allabs = BuildPipeline.BuildAssetBundles(Application.dataPath + "/Resources/Package", BuildAssetBundleOptions.None, BuildTarget.Android);

        foreach (var ab in allabs.GetAllAssetBundles())
        {
            var fileName = Path.Combine(Application.dataPath + "/Resources/Package", ab);

            byte[] fileData = File.ReadAllBytes(fileName);
            Encypt.DealData(fileData);
            File.WriteAllBytes(fileName, fileData);
        }

    }
}
