using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LangIma : MonoBehaviour
{
    private Image ima;
    public Sprite CNIma,ENIma;

    private void Start()
    {
        ima = GetComponent<Image>();
        switch (GameSet.instance.GetLan())
        {
            case Lan.CN:
                ima.sprite = CNIma;
                break;
            case Lan.EN:
                ima.sprite = ENIma;
                break;
        }
        ima.SetNativeSize();
    }

}
