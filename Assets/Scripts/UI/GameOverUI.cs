using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameOverUI : UI
{
    public Transform winNode, loseNode;
    //public RectTransform winNativeADPos;

    public Text winCoinLab;
    private int winCoinNum;

    public Transform WinADBtnNode, WinNextLevelNode;

    public override void ShowUI(bool isWin)
    {
        base.ShowUI(isWin);
        winNode.gameObject.SetActive(isWin);
        loseNode.gameObject.SetActive(!isWin);
        if (isWin)
        {
            GameSet.instance.audioManager.PlayAudio(GameSet.instance.matter.WinAudio);
            winCoinNum = Random.Range(70, 150);
            winCoinLab.text = "+"+winCoinNum.ToString();
        }
        else
        {
            GameSet.instance.audioManager.PlayAudio(GameSet.instance.matter.LoseAudio);
        }
    }

    public void WinNextLevelClick()
    {
        GameSet.instance.audioManager.PlayAudio(GameSet.instance.matter.BtnAudio);
        GameSet.instance.gameManager.canUpDateCash = false;
        GameSet.instance.userData.Add_Coin(winCoinNum);
        GameSet.instance.gameManager.FlyObj(GameSet.instance.matter.FlyCoin, winCoinNum, WinNextLevelNode.position, GameSet.instance.gameManager.CoinNode.position, () =>
        {
            GameSet.instance.gameManager.CanUpDateCoin();
        });

        GameSet.instance.gameManager.HideAllUI();
        if (GameSet.instance.userData.Level < GameSet.instance.matter.allLevel.Count)
        {
            GameSet.instance.userData.Level++;
        }
        GameSet.instance.gameManager.LevelInit();
        GameSet.instance.gameManager.DealLevel();
    }

    public void LoseBtnClick()
    {
        GameSet.instance.audioManager.PlayAudio(GameSet.instance.matter.BtnAudio);
        GameSet.instance.gameManager.HideAllUI();
        GameSet.instance.gameManager.LevelInit();
        GameSet.instance.gameManager.DealLevel();
    }
}
