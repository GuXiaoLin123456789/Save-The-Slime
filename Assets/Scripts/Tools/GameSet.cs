using UnityEngine;
using System;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text;
using System.IO;
using System.Collections;
using UnityEngine.Networking;


[Serializable]
public class LevelConfig
{
    public string ID;
    public string level_Url;
}

[Serializable]
public class SkinConfig
{
    public string ID;
    public string skin_Url;
    public SkinKind kind;
    public int value;
}

public class UserSkinData {
    public string ID;
    public bool isHave;
    public int adValue;
}


//震动枚举
public enum AllShake
{
    btn,
    lit,
    tips
}
public enum SkinKind
{
    Cash,
    AD
}


//用户数据
public class UserData
{
    public SetData setData = new SetData();

    public int Coin = 0;//金币


    public int Level = 1;//关卡


    public int insertNum = 0;//看插屏的次数

    public bool clickMoreGame = false;

    public bool isDefault = true;//是不是自然用户



    //现金是否够
    //public bool Buyable_Coin(int value)
    //{
    //    return Coin >= value;
    //}
    //public void Pay_Coin(int value)
    //{
    //    if (Coin >= value)
    //    {
    //        Coin -= value;
    //    }
    //    GameSet.instance.SaveUserData();

    //}
    public void Add_Coin(int value)
    {
        Coin += value;
        //GameSet.instance.SaveUserData();
    }
}

//设置
public class SetData
{
    public bool music = true;
    public bool shake = true;

}






public enum Lan {
    CN,
    EN
}


public class GameSet
{
    public static GameSet _instance;
    public static GameSet instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = new GameSet();
            }
            return _instance;
        }
    }
    public bool isLoad = false;
    public AudioManager audioManager;
    public Matter matter;
    public GameManager gameManager;

    public UserData userData = new UserData();//玩家数据
    public Action ADDoneCall;


    public string GetMachineID()
    {
        return GetMD5String(SystemInfo.deviceUniqueIdentifier);
    }

    public string GetMD5String(string strText)
    {
        MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider();
        byte[] encryptedBytes = md5.ComputeHash(Encoding.ASCII.GetBytes(strText));
        StringBuilder data = new StringBuilder();
        for (int i = 0; i < encryptedBytes.Length; i++)
        {
            data.AppendFormat("{0:x2}", encryptedBytes[i]);
        }
        return data.ToString();
    }


    public Lan GetLan()
    {
        //string msg = LocalizationManager.GetTermTranslation("Lang");
        Lan nowLan = Lan.CN;
        //switch (msg)
        //{
        //    case "CN":
        //        nowLan = Lan.CN;
        //        break;
        //    case "EN":
        //        nowLan = Lan.EN;
        //        break;
        //}
        return nowLan;

    }

    public void SetGameConfig()
    {
        if (isLoad)
        {
            return;
        }
        else
        {
            isLoad = true;

        }


        Application.targetFrameRate = 60;

        matter = Resources.Load<Matter>("config/Matter");

        //if (matter.isDebug)
        //{
        //    SRDebug.Init();
        //}

        //if (ES3.KeyExists("GameData"))
        //{
        //    //老用户
        //    Debug.Log("拿取到了老用户数据");
        //    userData = ES3.Load("GameData") as UserData;
        //}
        //else
        //{
        //    Debug.Log("新用户数据");
        //    userData = new UserData();

        //    userData.setData = new SetData();
        //}

        //CheckUserData();
        //SaveUserData();

        //TKGSDKManager.Instance.InitSDK(() =>
        //{
        //    gameManager.SetBGMState();
        //});
        //TKGSDKManager.Instance.SetGameFocusListener((bool isOn) =>
        //{
        //    if (isOn)
        //    {
        //        gameManager.BGM.volume = 1;
        //    }
        //    else
        //    {
        //        gameManager.BGM.volume = 0;
        //    }
        //});
    }

    //效验本地数据
    public void CheckUserData() {

    }


    //保存玩家数据
    //public void SaveUserData()
    //{
    //    ES3.Save("GameData", userData);
    //}



    //手机震动
    public void Shake(AllShake kind)
    {
        if (userData.setData.shake)
        {
            switch (kind)
            {
                case AllShake.btn:
                    //按钮点击
                    break;
                case AllShake.lit:
                    break;
                case AllShake.tips:
                    break;
            }

        }

    }


    //List对象乱序
    public List<T> RandomSortList<T>(List<T> list)
    {
        var random = new System.Random();
        var newList = new List<T>();
        foreach (var item in list)
        {
            newList.Insert(random.Next(newList.Count), item);
        }
        return newList;
    }
    public float CheckAngle(float value)
    {
        float angle = value - 180;

        if (angle > 0)
            return angle - 180;

        return angle + 180;
    }

    //生成唯一ID
    public string GetID()
    {
        return Guid.NewGuid().ToString();
    }

}
