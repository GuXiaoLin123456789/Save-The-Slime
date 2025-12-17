using UnityEditor;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using UnityEngine.Networking;
using System.Collections;
using System.IO;

public class GameManager : MonoBehaviour
{
#if UNITY_EDITOR
    [MenuItem("EditorTools/DestoryColl", false, 1)]
    static void DestoryColl()
    {
        if (Selection.gameObjects.Length <= 0)
        {
            return;
        }

        for (int i = 0; i < Selection.gameObjects.Length; i++)
        {
            var count = Selection.gameObjects[i].transform.childCount;

            for (int j = 0; j < count; j++)
            {
                var aaaaaaa = Selection.gameObjects[i].transform.GetChild(j).GetComponentsInChildren<Collider>();
                for (int k = 0; k < aaaaaaa.Length; k++)
                {
                    DestroyImmediate(aaaaaaa[k]);
                }
            }
        }

    }
#endif

    [HideInInspector]
    public AssetBundle ab;
    public UI mainPageUI, gameUI, settingUI, storeUI, gameOverUI,levelSelectUI;
    public TimeUI timeUI;
    public AudioSource BGM;
    public Transform CoinNode;
    public Text CashLab;
    public Transform TopUINode;

    public Transform LevelNode;
    public LinesDrawer linesDrawer;

    [HideInInspector]
    public GameObject nowLevel;
    public void HideAllUI() {
        mainPageUI.HideUI();
        gameUI.HideUI();
        settingUI.HideUI();
        storeUI.HideUI();
        gameOverUI.HideUI();
        levelSelectUI.HideUI();
    }

    private void Awake()
    {
        GameSet.instance.gameManager = this;
        GameSet.instance.SetGameConfig();
        StartCoroutine(LoadAB());
    }

    private void Start()
    {
        cashV = GameSet.instance.userData.Coin;
        HideAllUI();
        mainPageUI.ShowUI();
        SetBGMState();
    }

    public void LevelInit()
    {
        linesDrawer.gameObject.SetActive(true);
        CleanNode(LevelNode);
        CleanNode(linesDrawer.transform);
        linesDrawer.currentLineCount = 0;
        gameUI.ShowUI();
    }

    public void DealLevel()
    {
        
        LevelConfig target = GameSet.instance.matter.GetLevelConfig(GameSet.instance.matter.allLevel[GameSet.instance.userData.Level-1].ID);
        nowLevel = Instantiate(ResourceManager.Instance.LoadRes<GameObject>(target.level_Url), LevelNode);
    }

    IEnumerator LoadAB()
    {
        string abPath = Path.Combine(Application.streamingAssetsPath, "Package/data");
        UnityWebRequest request = UnityWebRequest.Get(abPath);
        yield return request.SendWebRequest();
        if (request.result == UnityWebRequest.Result.Success)
        {
            byte[] byteData = request.downloadHandler.data;
            Encypt.DealData(byteData);
            ab = AssetBundle.LoadFromMemory(byteData);
            if (ab != null)
            {
                Debug.Log("AB包加载成功！");
            }
        }
    }
    public void ShowToast(string msg)
    {
        Instantiate(GameSet.instance.matter.toastUI, TopUINode).ShowUI(msg);
    }

    private int cashV;
    [HideInInspector]
    public bool canUpDateCash = true;

    public void CanUpDateCoin() {
        DOTween.To(() => cashV, x => cashV = x, GameSet.instance.userData.Coin, 1).OnUpdate(() =>
        {
            CashLab.text = cashV.ToString();
        }).OnComplete(() =>
        {
            canUpDateCash = true;
            cashV = GameSet.instance.userData.Coin;
        });
    }
    private void FixedUpdate()
    {
        if (canUpDateCash) {
            CashLab.text = GameSet.instance.userData.Coin.ToString();
        }
    }

    public void SetBGMState()
    {
        if (GameSet.instance.userData.setData.music)
        {
            BGM.Play();
        }
        else
        {
            BGM.Stop();
        }
    }

    public void FlyObj(Transform what, int value, Vector3 startPos, Vector3 endPos, System.Action call)
    {
        value = value > 30 ? 30 : value;
        for (int i = 0; i < value; i++)
        {
            int index = i;
            ExtendFun.DelayDoFrame(this, index, () =>
            {
                Transform coin = Instantiate(what, TopUINode);
                coin.position = startPos;
                Vector3 dealPos = new Vector3(startPos.x + UnityEngine.Random.Range(-200, 200), startPos.y + UnityEngine.Random.Range(-200, 200), 0);
                coin.DOMove(dealPos, 0.5f).OnComplete(() => {
                    coin.DOMove(endPos, 1).OnComplete(() =>
                    {
                        if (index == (value - 1))
                        {
                            call?.Invoke();
                        }
                        Destroy(coin.gameObject);
                    });

                });

            });
        }
    }

    public void StartGame() {
        HideAllUI();  
        LevelInit();
        DealLevel();
    }

    public void CleanNode(Transform node) {
        for (int i = 0; i < node.childCount; i++)
        {
            Destroy(node.GetChild(i).gameObject);
        }
    }
}
