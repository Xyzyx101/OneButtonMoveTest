using UnityEngine;
using System.Collections;

public class GlobalToonRamp : MonoBehaviour {

    public Texture ToonRamp;

	// Use this for initialization
	void Start () {
        Shader.SetGlobalTexture("_ToonRamp", ToonRamp);
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
