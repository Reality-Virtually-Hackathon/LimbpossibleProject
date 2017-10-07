using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RadioArmAttachment : MonoBehaviour {

    public List<AudioClip> LevelSongs = new List<AudioClip>();
    private AudioSource audioSourceReference;
    private int CurrentTrack = 0;

    private void Start()
    {
        StartCoroutine(LazyLoading());
    }

    private void Update()
    {
        if(audioSourceReference != null && !audioSourceReference.isPlaying)
        {
            GetNextSong();
        }

        if(Input.GetKeyDown(KeyCode.RightShift))
        {
            GetNextSong();
        }
    }

    public IEnumerator LazyLoading()
    {
        yield return new WaitForSeconds(1f);
        audioSourceReference = GetComponent<AudioSource>();
    }
    
    public void GetNextSong()
    {
        CurrentTrack++;
        audioSourceReference.clip = LevelSongs[CurrentTrack];
        audioSourceReference.Play();

        if(CurrentTrack == LevelSongs.Count - 1)
        {
            CurrentTrack = -1;
        }
    }

}
