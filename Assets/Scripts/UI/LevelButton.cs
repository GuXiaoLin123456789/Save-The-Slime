using UnityEngine;
using UnityEngine.UI;

public class LevelButton : MonoBehaviour
{
    public Text levelNum;

    public GameObject lockBg;

    [HideInInspector]
    public int nowLevelNum;
    private Button levelBtn;

    private void Awake()
    {
        levelBtn= GetComponent<Button>();
        levelBtn.onClick.AddListener(LevelOpen);
    }

    public void Init(string levelnum,bool isLock)
    {
        levelNum.text = levelnum;
        lockBg.SetActive(isLock);
        levelBtn.interactable = !isLock;
    }

    public void LevelOpen()
    {
        GameSet.instance.audioManager.PlayAudio(GameSet.instance.matter.BtnAudio);
        GameSet.instance.gameManager.HideAllUI();
        GameSet.instance.gameManager.LevelInit();
        LevelConfig target = GameSet.instance.matter.GetLevelConfig(GameSet.instance.matter.allLevel[nowLevelNum].ID);
        GameSet.instance.gameManager.nowLevel = Instantiate(ResourceManager.Instance.LoadRes<GameObject>(target.level_Url),GameSet.instance.gameManager.LevelNode);
    }
}
