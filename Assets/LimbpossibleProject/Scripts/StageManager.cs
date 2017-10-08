using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class StageManager : Singleton<StageManager> {

    public List<string> SceneStrings = new List<string>();
    public static int CurrentScene = 0;

    private void Awake()
    {
        DontDestroyOnLoad(this);
    }

    private void Update()
    {
        if(Input.GetKeyDown(KeyCode.LeftShift))
        {
            LoadNextScene();
        }
    }

    public void LoadNextScene()
    {
        CurrentScene++;
        SceneManager.LoadScene(SceneStrings[CurrentScene], LoadSceneMode.Single);
    }
        
}
