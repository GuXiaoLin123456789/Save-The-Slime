using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameUI : UI
{
    public JoysticksPanel touch;

    public override void ShowUI()
    {
        gameObject.SetActive(true);
    }

    public override void CloseMe()
    {
        GameSet.instance.audioManager.PlayAudio(GameSet.instance.matter.BtnAudio);
        gameObject.SetActive(false);
        GameSet.instance.gameManager.levelSelectUI.ShowUI();
        GameSet.instance.gameManager.timeUI.InitTime();
    }

    public void ResetLevel()
    {
        GameSet.instance.audioManager.PlayAudio(GameSet.instance.matter.BtnAudio);
        GameSet.instance.gameManager.LevelInit();
        GameSet.instance.gameManager.DealLevel();
        GameSet.instance.gameManager.timeUI.InitTime();
    }
}
