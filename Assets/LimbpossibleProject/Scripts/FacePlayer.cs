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
            Target = Camera.main.transform;
        }
        else
        {
            transform.LookAt(Target.position);
        }
    }
}