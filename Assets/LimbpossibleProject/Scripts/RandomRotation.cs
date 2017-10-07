using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomRotation : MonoBehaviour
{
    public Vector3 Axis;
    public float Speed;

    private void Start()
    {
        transform.rotation = Quaternion.Euler(Random.Range(0.0f, 360.0f), Random.Range(0.0f, 360.0f), Random.Range(0.0f, 360.0f));
        Axis = new Vector3(Random.Range(-1f, 1f), Random.Range(-1f, 1f), Random.Range(-1f, 1f));
    }

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(Axis * Speed * Time.deltaTime, Space.World);
    }
}