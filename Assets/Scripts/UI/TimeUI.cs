using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;

public class TimeUI: MonoBehaviour
{
    public Text timeText;
    public float times = 6f;
    private float maxTimes;
    public Image filedBg;

    private bool isStartTime;

    public event EventHandler OnTimeEnd;
    private void Awake()
    {
        maxTimes = times;
    }

    public void InitTime()
    {
        Hide();
        OnTimeEnd?.Invoke(this, EventArgs.Empty);
    }
    public void Show()
    {
        gameObject.SetActive(true);
        isStartTime=true;
        times = maxTimes;
    }
    public void Hide()
    {
        isStartTime = false;
        gameObject.SetActive(false);       
    }
    private void Update()
    {
        if (isStartTime)
        {
            times -= Time.deltaTime;
            filedBg.fillAmount = times / maxTimes;
            timeText.text=times.ToString("0");
            if(times <= 0)
            {
                GameOver();
                times = maxTimes;
                Hide();
            }
        }
    }

    private void GameOver()
    {
        OnTimeEnd?.Invoke(this,EventArgs.Empty);
        GameSet.instance.gameManager.gameOverUI.ShowUI(true);
    }
}
