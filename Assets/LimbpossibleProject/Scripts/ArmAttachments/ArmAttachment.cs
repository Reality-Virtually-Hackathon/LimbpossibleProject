using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using VRTK;

[RequireComponent(typeof(AudioSource))]
public class ArmAttachment : VRTK_InteractableObject {

    public UnityEvent eventsOnAttach;
    public UnityEvent eventsOnDetach;

    [Header("Audio Clips")]
    public AudioClip SoundOnAttach;
    public AudioClip SoundOnDetach;

    float detachLaunchSpeed = 500f;

    private AudioSource audioSourceReference;
    
    protected void Start() {
        audioSourceReference = GetComponent<AudioSource>();
    }

    protected override void Update() {
        base.Update();

    }

    public override void OnInteractableObjectGrabbed(InteractableObjectEventArgs e) {
        base.OnInteractableObjectGrabbed(e);
        eventsOnAttach.Invoke();
        audioSourceReference.clip = SoundOnAttach;
        audioSourceReference.Play();
    }

    public override void OnInteractableObjectUngrabbed(InteractableObjectEventArgs e) {
        base.OnInteractableObjectUngrabbed(e);
        Rigidbody rb = GetComponent<Rigidbody>();
        rb.AddForce(transform.forward * detachLaunchSpeed);
        eventsOnDetach.Invoke();
        audioSourceReference.clip = SoundOnDetach;
        audioSourceReference.Play();
    }

    public override void StartUsing(VRTK_InteractUse usingObject) {
        base.StartUsing(usingObject);
    }

    public override void StopUsing(VRTK_InteractUse usingObject) {
        base.StopUsing(usingObject);
    }

}
