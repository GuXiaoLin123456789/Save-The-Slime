using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UObject = UnityEngine.Object;

public class ResourceManager : D_MonoSingleton<ResourceManager>
{
    private Dictionary<string, UObject> mResDic = new Dictionary<string, UObject>();
    public T LoadRes<T>(string pPath) where T : UObject {
        if (!mResDic.ContainsKey(pPath)) {
#if UNITY_EDITOR
            mResDic[pPath] = UnityEditor.AssetDatabase.LoadAssetAtPath(pPath, typeof(T));
#else
            mResDic[pPath] =GameSet.instance.ab.LoadAsset<T>(pPath);
#endif
        }
        return mResDic[pPath] as T;
    }
}
