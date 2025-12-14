using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
public class Matter : ScriptableObject
{
    public bool isDebug;
    public AudioClip CloseBtnAudio;//关闭声音
    public AudioClip BtnAudio;//按钮声音
    public AudioClip ToastAudio;//toast声音
    public AudioClip addCashAudio;
    public AudioClip WinAudio, LoseAudio;

    public ToastUI toastUI;

    public Transform FlyCoin;

    public Transform Coin;

    public List<LevelConfig> allLevel;

    public LevelConfig GetLevelConfig(string ID)
    {
        return allLevel.Find(e => e.ID == ID);
    }
}
