using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRTK;

public class ArmHand : ArmAttachment {


    public AudioClip SoundOnFist;
    public AudioClip SoundOnRelaxed;

    GameObject relaxed;
    GameObject fist;

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
    }

    public override void StopUsing(VRTK_InteractUse usingObject) {
        base.StopUsing(usingObject);
        fist.SetActive(false);
        relaxed.SetActive(true);
        if (SoundOnRelaxed != null) {
            audioSourceReference.clip = SoundOnRelaxed;
            audioSourceReference.Play();
        }
    }

}
