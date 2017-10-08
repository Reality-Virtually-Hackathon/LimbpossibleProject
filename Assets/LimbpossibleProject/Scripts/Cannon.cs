using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class Cannon : MonoBehaviour {

    [Header("Basic References")]
    public GameObject CannonBall;
    public Transform FireLocation;
    [Space(5)]
    [Header("Configurable Attributes")]
    public float TimeBeforeShooting; // upon detection, how long the cannon will take to fire
    public float ShootingInterval; // time between shots
    public bool IsEnabled = true;
    [Space(5)]
    [Header("Sound Effects")]
    public AudioClip CannonActivated;
    public AudioClip CannonShoot;
    public AudioClip CannonDeactivated;

    private AudioSource audioSourceReference;
    private float PreviousShot = 0f;

    private void Start()
    {
        audioSourceReference = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update () {
		if(IsEnabled)
        {
            if(Time.time > PreviousShot + ShootingInterval)
            {
                audioSourceReference.clip = CannonShoot;
                audioSourceReference.Play();
                
                GameObject tempCannonBall = Instantiate(CannonBall, FireLocation.position, Quaternion.identity);
                tempCannonBall.transform.localEulerAngles = new Vector3(0f, 90f, 0f);

                PreviousShot = Time.time;
            }
        }

        if(Input.GetKeyDown(KeyCode.LeftShift))
        {
            ToggleCannon();
        }
    }

    private void ToggleCannon()
    {
        IsEnabled = !IsEnabled;
    }

    public void EnableCannon()
    {
        StartCoroutine(ChangeCannonState(true));
    }

    public void DisableCannon()
    {
        IsEnabled = false;
    }

    public IEnumerator ChangeCannonState(bool state)
    {
        yield return new WaitForSeconds(TimeBeforeShooting);
        IsEnabled = true;
    }
}
