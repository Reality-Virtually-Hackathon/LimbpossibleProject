using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireZone : MonoBehaviour {

    public Cannon CannonReference;

	public void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.layer == 8)
        {
            CannonReference.EnableCannon();
        }
    }

    public void OnTriggerExit(Collider other)
    {
        if (other.gameObject.layer == 8)
        {
            CannonReference.DisableCannon();
        }
    }
}
