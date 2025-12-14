using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BeeSpwaner : MonoBehaviour
{
    public GameObject beePrefab;
    public int spawnCount = 5;
    public float spawnRadius = 2f;

    private List<GameObject> beeList =new List<GameObject>();
    private void Start()
    {
        GameSet.instance.gameManager.linesDrawer.OnDrawLineFinish += linesDrawer_OnDrawLineFinish;
        GameSet.instance.gameManager.timeUI.OnTimeEnd += TimeUI_OnTimeEnd;
    }

    private void TimeUI_OnTimeEnd(object sender, System.EventArgs e)
    {
        DestoryBee();
    }

    private void linesDrawer_OnDrawLineFinish(object sender, System.EventArgs e)
    {
        SpawnBee();
        GameSet.instance.gameManager.timeUI.Show();
    }

    private void SpawnBee()
    {
        for (int i = 0; i < spawnCount; i++)
        {
            Vector3 direction = GetRandomDirection();
            Vector3 spawnPos = transform.position + direction * spawnRadius;
            GameObject bee = Instantiate(beePrefab, spawnPos, Quaternion.identity);
            beeList.Add(bee);
        }
    }
    private Vector3 GetRandomDirection()
    {
        float randomAngle = Random.Range(0f,Mathf.PI * 2f);
        return new Vector3(Mathf.Cos(randomAngle),Mathf.Sin(randomAngle),0).normalized;
    }

    public void DestoryBee()
    {
        for(int i = 0;i<beeList.Count;i++)
        {            
            Destroy(beeList[i]);            
        }
        beeList.Clear();
    }
    private void OnDestroy()
    {
        GameSet.instance.gameManager.linesDrawer.OnDrawLineFinish -= linesDrawer_OnDrawLineFinish;
        GameSet.instance.gameManager.timeUI.OnTimeEnd -= TimeUI_OnTimeEnd;
    }
}
