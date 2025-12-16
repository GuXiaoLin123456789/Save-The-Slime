using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LevelSelectUI : UI
{
    public Text levelText;

    public Transform levelBtnParent;

    public GameObject levelBtnPrefab;

    public override void ShowUI()
    {
        base.ShowUI();
        GameSet.instance.gameManager.CleanNode(levelBtnParent);
        for (int i = 0; i < GameSet.instance.matter.allLevel.Count; i++)
        {
            GameObject levelBtn = Instantiate(levelBtnPrefab, levelBtnParent);
            LevelButton levelButton =levelBtn.GetComponent<LevelButton>();
            string levelNum = "1-" + (i+1);
            bool isLock = GameSet.instance.userData.Level > i ? false : true;
            levelButton.Init(levelNum, isLock);
            levelButton.nowLevelNum = i;
        }
    }
    private void FixedUpdate()
    {
        levelText.text = GameSet.instance.userData.Level + "/" + GameSet.instance.matter.allLevel.Count;
    }
}
