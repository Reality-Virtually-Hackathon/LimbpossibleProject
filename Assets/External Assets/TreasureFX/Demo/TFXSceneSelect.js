﻿#pragma strict

import UnityEngine.SceneManagement;

var CPselGridInt : int = -1;
var CPselStrings : String[] = ["1", "2", "3", "4", "5", "6", "7", "8"];

	
function OnGUI ()
{
    CPselGridInt = GUI.SelectionGrid (Rect (Screen.width /2 *0.25, Screen.height * 0.92, Screen.width /2 *1.5, Screen.height /16 *1), CPselGridInt, CPselStrings, 8);
			
    if (CPselGridInt == 0){
        SceneManager.LoadScene("Scene1");
    }
         
    if (CPselGridInt == 1){
        SceneManager.LoadScene("Scene2");
    }
         
    if (CPselGridInt == 2){
        SceneManager.LoadScene("Scene3");
    }
         
    if (CPselGridInt == 3){
        SceneManager.LoadScene("Scene4");
    }
         
    if (CPselGridInt == 4){
        SceneManager.LoadScene("Scene5");
    }
         
    if (CPselGridInt == 5){
        SceneManager.LoadScene("Scene6");
    }
         
    if (CPselGridInt == 6){
        SceneManager.LoadScene("Scene7");
    }
         
    if (CPselGridInt == 7){
        SceneManager.LoadScene("Scene8");
    }
         
    if (CPselGridInt == 8){
        SceneManager.LoadScene("Scene9");
    }
    //         
    // 		 if (CPselGridInt == 9){
    //             Application.LoadLevel("Scene10");
    //         }
    //         
    //         if (CPselGridInt == 10){
    //             Application.LoadLevel("Scene11");
    //         }
    //         
    //         if (CPselGridInt == 11){
    //             Application.LoadLevel("Scene12");
    //         }
    //         
    //         if (CPselGridInt == 12){
    //             Application.LoadLevel("Scene13");
    //         }
    //             
    //         if (CPselGridInt == 13){
    //             Application.LoadLevel("Scene14");
    //         }
}