using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class ExplodeOnImpact : MonoBehaviour {

    public GameObject Explosion;
    public GameObject HittingBladeSparks;
    public AudioClip SpinningBladeHitClip;

    private AudioSource audioSourceReference;

    private void Start()
    {
        audioSourceReference = GetComponent<AudioSource>();
    }

    private void OnCollisionEnter(Collision collision)
    {
        // If it's the rotating blades, DEFLECT
        if(collision.gameObject.layer == 9)
        {
            audioSourceReference.clip = SpinningBladeHitClip;
            audioSourceReference.Play();
            GameObject sparks = Instantiate(HittingBladeSparks, collision.contacts[0].point, Quaternion.identity);
            Destroy(sparks, 2f);
            GetComponent<MeshRenderer>().enabled = false;
            GetComponent<SphereCollider>().enabled = false;
            Destroy(gameObject, 2f);
            return;
        }

        GameObject tempExplosion = Instantiate(Explosion, transform.position, Quaternion.identity);
        Destroy(tempExplosion, 2f);
        Destroy(gameObject);
    }
}
