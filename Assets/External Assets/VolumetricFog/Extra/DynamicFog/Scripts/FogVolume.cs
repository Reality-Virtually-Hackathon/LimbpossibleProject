using UnityEngine;
using System.Collections;

namespace DynamicFogAndMist {
	public class FogVolume : MonoBehaviour {

								const float GRAY = 227f/255f;

								[Tooltip ("Target alpha for fog when camera enters this fog volume")]
								[Range (0, 1)]
								public float targetFogAlpha = 0.5f;
								[Tooltip ("Target alpha for sky haze when camera enters this fog volume")]
								[Range (0, 1)]
								public float targetSkyHazeAlpha = 0.5f;

								[Tooltip ("Target fog color 1 when gamera enters this fog folume")]
								public Color targetFogColor1 = new Color(GRAY,GRAY,GRAY);

								[Tooltip ("Target fog color 2 when gamera enters this fog folume")]
								public Color targetFogColor2 = new Color(GRAY,GRAY,GRAY);

								[Tooltip ("Set this to zero for changing fog alpha immediately upon enter/exit fog volume.")]
								public float transitionDuration = 3.0f;


								DynamicFog fog;

								bool cameraInside;

								void Start () {
												fog = DynamicFog.instance;
								}

								void OnTriggerEnter (Collider other) {
												if (cameraInside)
																return;
												// Check if other collider has the main camera attached
												if (other.gameObject.transform.GetComponentInChildren<Camera> () == fog.fogCamera) {
																cameraInside = true;
																fog.SetTargetAlpha (targetFogAlpha, targetSkyHazeAlpha, transitionDuration);
																fog.SetTargetColors (targetFogColor1, targetFogColor2, transitionDuration);
												}
								}

								void OnTriggerExit (Collider other) {
												if (!cameraInside)
																return;
												if (other.gameObject.transform.GetComponentInChildren<Camera> () == fog.fogCamera) {
																cameraInside = false;
																fog.ClearTargetAlpha (transitionDuration);
																fog.ClearTargetColors (transitionDuration);
												}
								}

	}

}