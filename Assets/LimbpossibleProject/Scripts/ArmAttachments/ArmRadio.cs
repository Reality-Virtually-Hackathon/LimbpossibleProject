using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRTK;

public class ArmRadio : ArmAttachment {

    AudioSource audio;

    protected void Start() {
        base.Start();
        audio = GetComponentInChildren<AudioSource>();
    }

    public override void StartUsing(VRTK_InteractUse usingObject) {
        base.StartUsing(usingObject);
        if (audio.isPlaying) {
            audio.Pause();
        } else {
            audio.Play();
        }
    }

}