using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bee : MonoBehaviour
{   
    private Transform slime;
    private SpriteRenderer spriteRenderer;

    public float speed;  
    private float currentSpeed;

    private void Awake()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
        currentSpeed = speed;
    }
    private void Start()
    {
        slime = GameObject.Find("Slime").transform;
    }
    private void Update()
    {
        transform.localPosition = Vector3.MoveTowards(transform.localPosition, slime.localPosition, speed * Time.deltaTime);

        if (transform.localPosition.x >= slime.localPosition.x)
        {
            spriteRenderer.flipX = true;
        }
        else
        {
            spriteRenderer.flipX = false;
        }
    }
    private void OnCollisionEnter2D(Collision2D col)
    {
        if (col.gameObject.tag == "Line")
        {
            speed = 1f;
        }
        else
        {
            speed = currentSpeed;
        }
        
    }
}
