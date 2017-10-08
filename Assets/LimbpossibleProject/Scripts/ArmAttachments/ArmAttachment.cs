using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using VRTK;

public class ArmAttachment : VRTK_InteractableObject {

    public UnityEvent eventsOnAttach;
    public UnityEvent eventsOnDetach;

    float detachLaunchSpeed = 250f;
    
    protected void Start() {
    }

    protected override void Update() {
        base.Update();

    }

    public override void OnInteractableObjectGrabbed(InteractableObjectEventArgs e) {
        base.OnInteractableObjectGrabbed(e);
        eventsOnAttach.Invoke();
    }

    public override void OnInteractableObjectUngrabbed(InteractableObjectEventArgs e) {
        base.OnInteractableObjectUngrabbed(e);
        Rigidbody rb = GetComponent<Rigidbody>();
        rb.AddForce(transform.forward * detachLaunchSpeed);
        eventsOnDetach.Invoke();
    }

    public override void StartUsing(VRTK_InteractUse usingObject) {
        base.StartUsing(usingObject);
    }

    public override void StopUsing(VRTK_InteractUse usingObject) {
        base.StopUsing(usingObject);
    }

}
