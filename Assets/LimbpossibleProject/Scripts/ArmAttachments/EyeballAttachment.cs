﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRTK;

public class EyeballAttachment : ArmAttachment {

    public MeshRenderer eyePlane;
    public bool launchesEye = false;

    Camera eyeCam;
    RenderTexture renderTexture;
    //VRTK_TransformFollow follower;

    protected void Start() {
        base.Start();
        //follower = GetComponent<VRTK_TransformFollow>();
        eyeCam = transform.Find("EyeCam").GetComponent<Camera>();
    }

    public override void OnInteractableObjectGrabbed(InteractableObjectEventArgs e) {
        base.OnInteractableObjectGrabbed(e);
        eyeCam.gameObject.SetActive(true);
        eyePlane.gameObject.SetActive(true);
    }

    public override void OnInteractableObjectUngrabbed(InteractableObjectEventArgs e) {
        this.transform.parent = null;
        Rigidbody rb = this.GetComponent<Rigidbody>();
        if (launchesEye) {
            rb.isKinematic = false;
            rb.useGravity = true;
        } else {
            //Destroy(rb);
            //follower.followsRotation = true;
        }

        base.OnInteractableObjectUngrabbed(e);
    }

}