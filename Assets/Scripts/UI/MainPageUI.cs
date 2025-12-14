using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MainPageUI : UI
{
    public override void ShowUI()
    {
        base.ShowUI();
        
    }


    public void OpenSettingClick() {
        GameSet.instance.audioManager.PlayAudio(GameSet.instance.matter.BtnAudio);
        GameSet.instance.gameManager.settingUI.ShowUI();
    }

    public void OpenStoreClick() {
        GameSet.instance.audioManager.PlayAudio(GameSet.instance.matter.BtnAudio);
        GameSet.instance.gameManager.storeUI.ShowUI();
    }


    public void StartGameClick() {
        GameSet.instance.audioManager.PlayAudio(GameSet.instance.matter.BtnAudio);
        GameSet.instance.gameManager.StartGame();
    }
}
