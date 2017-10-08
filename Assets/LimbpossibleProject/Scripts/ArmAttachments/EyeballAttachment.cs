using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRTK;

public class EyeballAttachment : ArmAttachment {

    public MeshRenderer eyePlane;
    public bool launchesEye = false;

    Camera eyeCam;
    RenderTexture renderTexture;

    protected void Start() {
        base.Start();
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
        }
        base.OnInteractableObjectUngrabbed(e);
    }

    private void OnTriggerEnter(Collider other) {
        if (other.tag == "Web") {
            Rigidbody rb = this.GetComponent<Rigidbody>();
            rb.useGravity = false;
            WebObjectCatcher web = other.GetComponent<WebObjectCatcher>();
            this.transform.LookAt(web.pointingTowards.transform);
            rb.isKinematic = true;
        }
    }

}
