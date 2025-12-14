using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Slime : MonoBehaviour
{
    private SpriteRenderer spriteRenderer;
    public BeeSpwaner BeeSpwaner;
    private bool timeStart=false;
    private bool timeEnd=false;
    private float time = 1.5f;
    private void Awake()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
    }
    private void OnCollisionEnter2D(Collision2D col)
    {
        if(col.gameObject.tag == "Enemy")
        {         
            timeStart = true;
            spriteRenderer.DOColor(Color.red, 3);
        }
    }
    
    private void Update()
    {
        if (timeStart)
        {           
            time -= Time.deltaTime;
            if (time <= 0)
            {
                timeEnd = true;
            }
        }
        if (timeEnd)
        {
            Die();
            timeEnd = false;
            timeStart = false;
            time = 1.5f;
        }
    }
    private void Die()
    {
        GameSet.instance.gameManager.gameOverUI.ShowUI(false);
        BeeSpwaner.DestoryBee();
        GameSet.instance.gameManager.timeUI.Hide();
    }
}
