using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRTK;

public class SpinnyBlade : ArmAttachment {

    float spinSpeed = 0f;
    Transform rotator;

    protected void Start() {
        base.Start();
        rotator = transform.Find("Blades");
    }

    protected override void Update() {
        base.Update();
        rotator.transform.Rotate(new Vector3(0f, 0f, spinSpeed * Time.deltaTime));
    }

    public override void StartUsing(VRTK_InteractUse usingObject) {
        base.StartUsing(usingObject);
        spinSpeed = 720f;
    }

    public override void StopUsing(VRTK_InteractUse usingObject) {
        base.StopUsing(usingObject);
        spinSpeed = 0f;
    }

}
