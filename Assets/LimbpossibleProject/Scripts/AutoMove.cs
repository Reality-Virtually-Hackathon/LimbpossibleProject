using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoMove : MonoBehaviour
{
    public bool IsEnabled = false;
    public bool UseForce = true;
    public Rigidbody rb;
    public float speed = 100f;
    public Vector3 direction;

    void LateUpdate()
    {
        if (IsEnabled)
        {
            if (UseForce)
            {
                rb.AddForce(transform.forward * speed * Time.deltaTime);
            }
            else
            {
                rb.velocity = transform.forward * speed * Time.deltaTime;
            }
        }
    }

    public void StopMoving()
    {
        IsEnabled = false;
    }

    public void StartMoving()
    {
        IsEnabled = true;
    }
}
