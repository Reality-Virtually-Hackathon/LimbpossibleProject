using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HandGrab : MonoBehaviour {

    public GameObject GrabbedObject;
    public Rigidbody RigidbodyReference;

    private FixedJoint GrabbedObjectJoint;

    public void GrabObject(GameObject grabbableObject)
    {
        Debug.Log("Trying to grab object");
        if(GrabbedObject == null)
        {
            Debug.Log("Grabbed object!");
            GrabbedObject = grabbableObject;
            GrabbedObjectJoint = GrabbedObject.AddComponent<FixedJoint>();
            GrabbedObjectJoint.connectedBody = RigidbodyReference;
        }
    }

    public void ReleaseObject()
    {
        Debug.Log("Trying to release object");
        if (GrabbedObject != null)
        {
            Destroy(GrabbedObjectJoint);
            GrabbedObject = null;
        }
    }

}
