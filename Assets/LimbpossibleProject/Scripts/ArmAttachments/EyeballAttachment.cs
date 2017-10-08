using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRTK;

public class EyeballAttachment : ArmAttachment {

    public MeshRenderer eyePlane;
    public bool launchesEye = false;

    float rotationSpeed = 45f;

    Camera eyeCam;
    RenderTexture renderTexture;
    Vector2 touchAxis;

    float timeLastRotate;

    protected void Start() {
        base.Start();
        eyeCam = transform.Find("EyeCam").GetComponent<Camera>();
        timeLastRotate = Time.time;
    }

    void Update() {
        if(touchAxis != Vector2.zero) {
            transform.Rotate(Vector3.up * touchAxis.x * rotationSpeed * Time.deltaTime);
        }
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
        e.interactingObject.GetComponent<EyeballTrackpadController>().eyeball = this;
        base.OnInteractableObjectUngrabbed(e);
    }

    private void OnTriggerEnter(Collider other) {
        if (other.tag == "Web") {
            Rigidbody rb = this.GetComponent<Rigidbody>();
            Destroy(rb);

            WebObjectCatcher web = other.GetComponent<WebObjectCatcher>();
            this.transform.LookAt(web.pointingTowards.transform);
        }
    }

    public void SetTouchAxis(Vector2 data) {
        touchAxis = data;
        float delta = Time.time - timeLastRotate;
        timeLastRotate = Time.time;
    }

}
