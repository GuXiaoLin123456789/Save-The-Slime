using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class BuildPackage : Editor
{
    [MenuItem("Tools/BuildPackage")]
    public static void BuildAllAssets() {

        string outputPath = Path.Combine(Application.streamingAssetsPath, "Package");
        AssetBundleManifest allabs = BuildPipeline.BuildAssetBundles(outputPath, BuildAssetBundleOptions.ChunkBasedCompression, BuildTarget.Android);

        foreach (var ab in allabs.GetAllAssetBundles())
        {
            var fileName = Path.Combine(outputPath, ab);

            byte[] fileData = File.ReadAllBytes(fileName);
            Encypt.DealData(fileData);
            File.WriteAllBytes(fileName, fileData);
        }
        AssetDatabase.Refresh();
    }
}
