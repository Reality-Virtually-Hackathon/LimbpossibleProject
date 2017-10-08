#pragma strict

import UnityEngine.SceneManagement;

var CPselGridInt : int = -1;
var CPselStrings : String[] = ["1", "2", "3"];

	
function OnGUI ()
{
    CPselGridInt = GUI.SelectionGrid (Rect (Screen.width /2 *0.025, Screen.height * 0.92, Screen.width /2 *0.15, Screen.height /16 *1), CPselGridInt, CPselStrings, 3);
			
    if (CPselGridInt == 0){
        SceneManager.LoadScene("3DScene1");
    }
         
    if (CPselGridInt == 1){
        SceneManager.LoadScene("3DScene2");
    }
         
    if (CPselGridInt == 2){
        SceneManager.LoadScene("3DScene3");
    }
         
    //         if (CPselGridInt == 3){
    //             Application.LoadLevel("Scene4");
    //         }
    //         
    //         if (CPselGridInt == 4){
    //             Application.LoadLevel("Scene5");
    //         }
    //         
    //         if (CPselGridInt == 5){
    //             Application.LoadLevel("Scene6");
    //         }
    //         
    //         if (CPselGridInt == 6){
    //             Application.LoadLevel("Scene7");
    //         }
    //         
    //         if (CPselGridInt == 7){
    //             Application.LoadLevel("Scene8");
    //         }
    //         
    //         if (CPselGridInt == 8){
    //             Application.LoadLevel("Scene9");
}