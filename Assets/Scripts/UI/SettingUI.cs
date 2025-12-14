using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SettingUI : UI
{
    public Transform audioOnNode, audioOffNode;
    public Transform shakeOnNode, shakeOffNode;

    public override void ShowUI()
    {
        base.ShowUI();
        SetUIState();
    }

    public void SetUIState() {
        audioOnNode.gameObject.SetActive(false);
        audioOffNode.gameObject.SetActive(false);
        shakeOnNode.gameObject.SetActive(false);
        shakeOffNode.gameObject.SetActive(false);
        if (GameSet.instance.userData.setData.music)
        {
            audioOnNode.gameObject.SetActive(true);
        }
        else {
            audioOffNode.gameObject.SetActive(true);
        }
        if (GameSet.instance.userData.setData.shake)
        {
            shakeOnNode.gameObject.SetActive(true);
        }
        else
        {
            shakeOffNode.gameObject.SetActive(true);
        }
    }

    public void ChangeAudioClick() {
        GameSet.instance.audioManager.PlayAudio(GameSet.instance.matter.BtnAudio);
        GameSet.instance.userData.setData.music = !GameSet.instance.userData.setData.music;
        SetUIState();
        GameSet.instance.gameManager.SetBGMState();
    }

    public void ChangeShakeClick()
    {
        GameSet.instance.audioManager.PlayAudio(GameSet.instance.matter.BtnAudio);
        GameSet.instance.userData.setData.shake = !GameSet.instance.userData.setData.shake;
        SetUIState();
    }

    public void InFoClick()
    {
        GameSet.instance.audioManager.PlayAudio(GameSet.instance.matter.BtnAudio);
    }
}
