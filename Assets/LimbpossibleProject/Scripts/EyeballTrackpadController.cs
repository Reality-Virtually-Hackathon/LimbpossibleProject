using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRTK;

public class EyeballTrackpadController : MonoBehaviour {

    public EyeballAttachment eyeball;

    private void Start() {
        GetComponent<VRTK_ControllerEvents>().TouchpadAxisChanged += new ControllerInteractionEventHandler(DoTouchpadAxisChanged);
        GetComponent<VRTK_ControllerEvents>().TouchpadTouchEnd += new ControllerInteractionEventHandler(DoTouchpadTouchEnd);
        GetComponent<VRTK_ControllerEvents>().ButtonTwoPressed += new ControllerInteractionEventHandler(DoEyeReset);
    }

    private void DoTouchpadAxisChanged(object sender, ControllerInteractionEventArgs e) {
        if (eyeball == null) {
            return;
        }
        Debug.Log("one");
        eyeball.SetTouchAxis(e.touchpadAxis);
    }

    private void DoTouchpadTouchEnd(object sender, ControllerInteractionEventArgs e) {
        if (eyeball == null) {
            return;
        }
        Debug.Log("zero");
        eyeball.SetTouchAxis(Vector2.zero);
    }

    private void DoEyeReset(object sender, ControllerInteractionEventArgs e) {
        if (eyeball == null) {
            return;
        }
    }

}
