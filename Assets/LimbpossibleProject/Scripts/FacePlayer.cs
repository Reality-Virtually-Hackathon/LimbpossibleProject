using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FacePlayer : MonoBehaviour
{
    public Transform Target;

    private Quaternion targetRotation;
    private Camera mainCamera;

    private void Update()
    {
        if (Target == null)
        {
            Target = GameObject.Find("Headset") ? GameObject.Find("Headset").transform : null;
        }
        else if(transform != null)
        {
            transform.LookAt(Target.position);
        }
    }
}