using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GoalManager : MonoBehaviour {

    public bool IsGoalActive = false;

    [Header("What gets activated if the goal is active?")]
    public List<Animator> ThingsToActivate;
   
	public void UnlockGoal()
    {
        foreach(Animator anim in ThingsToActivate)
        {
            anim.SetTrigger("Active");
        }
    }

    public void Update()
    {
        if(Input.GetKeyDown(KeyCode.Space))
        {
            if(!IsGoalActive)
            {
                UnlockGoal();
            }
        }
    }
}
