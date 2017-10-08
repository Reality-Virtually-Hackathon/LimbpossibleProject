using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRTK;

public class ArmGun : ArmAttachment {

    private GameObject bullet;
    private float bulletSpeed = 1000f;
    private float bulletLife = 5f;

    protected void Start() {
        base.Start();
        bullet = transform.Find("Bullet").gameObject;
        bullet.SetActive(false);
    }

    private void FireBullet() {
        GameObject bulletClone = Instantiate(bullet, bullet.transform.position, bullet.transform.rotation) as GameObject;
        bulletClone.SetActive(true);
        Rigidbody rb = bulletClone.GetComponent<Rigidbody>();
        rb.AddForce(bullet.transform.forward * bulletSpeed);
        Destroy(bulletClone, bulletLife);
    }

    public override void StartUsing(VRTK_InteractUse usingObject) {
        base.StartUsing(usingObject);
        FireBullet();
    }

}
