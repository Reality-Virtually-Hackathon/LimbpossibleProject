using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ButtonPress : MonoBehaviour {

    private void OnCollisionEnter(Collision collision)
    {
        GoalManager.Instance.UnlockGoal();
    }

}
