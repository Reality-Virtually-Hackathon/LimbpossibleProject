using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRTK;

public class ArmHand : ArmAttachment {

    public HandGrab HandGrabReference;

    public AudioClip SoundOnFist;
    public AudioClip SoundOnRelaxed;

    GameObject relaxed;
    GameObject fist;

    public bool HasObjectInsideOfTrigger = false;
    public GameObject GameObjectInsideOfTrigger;

    protected void Start() {
        base.Start();
        relaxed = transform.Find("relaxed").gameObject;
        fist = transform.Find("fist").gameObject;
    }

    protected override void Update() {
        base.Update();
    }

    public override void StartUsing(VRTK_InteractUse usingObject) {
        base.StartUsing(usingObject);
        relaxed.SetActive(false);
        fist.SetActive(true);
        if (SoundOnFist != null) {
            audioSourceReference.clip = SoundOnFist;
            audioSourceReference.Play();
        }

        if (HasObjectInsideOfTrigger)
        {
            HandGrabReference.GrabObject(GameObjectInsideOfTrigger);
        }
    }

    public override void StopUsing(VRTK_InteractUse usingObject) {
        base.StopUsing(usingObject);
        fist.SetActive(false);
        relaxed.SetActive(true);
        if (SoundOnRelaxed != null) {
            audioSourceReference.clip = SoundOnRelaxed;
            audioSourceReference.Play();
        }

        HandGrabReference.ReleaseObject();

    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.layer == 9)
        {
            Debug.Log("ENTERED TRIGGER");
            HasObjectInsideOfTrigger = true;
            GameObjectInsideOfTrigger = other.gameObject;
        }
        
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.gameObject.layer == 9)

        {
            HasObjectInsideOfTrigger = true;
            GameObjectInsideOfTrigger = other.gameObject;

        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.layer == 9)
        {
            HasObjectInsideOfTrigger = false;
            GameObjectInsideOfTrigger = null;

        }


        Debug.Log("EXITED TRIGGER");

    }

}
