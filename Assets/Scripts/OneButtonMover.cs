using UnityEngine;
using System.Collections;
using UnityStandardAssets.CrossPlatformInput;
using UnityStandardAssets.Characters.FirstPerson;

public class OneButtonMover : MonoBehaviour {

	public Quaternion HeadDir;
	public Quaternion BodyDir;

	public Vector2 HeadMoveSpeed = new Vector2(1f, 1f);
	public GameObject _CameraObject;
	public Vector2 LookSensitivity = new Vector2(1,1);

	private Vector2 _AimInput;
	private bool _MoveInput;
	private Camera _Camera;
	private Quaternion _CameraRot;

	void Start () {
		_Camera = _CameraObject.GetComponent<Camera>();
		_CameraRot = _CameraObject.transform.rotation;
		HeadDir = transform.rotation;
		BodyDir = transform.rotation;
	}

	void Update () {
		Debug.DrawRay(transform.position + Vector3.up * 1f, HeadDir * Vector3.forward * 2f, Color.yellow);
		Debug.DrawRay(transform.position + Vector3.up * 1f, BodyDir * Vector3.forward * 2f, Color.blue);
		//Vector3 eulerAim = new Vector3(_AimInput.y * HeadMoveSpeed.y, _AimInput.x * HeadMoveSpeed.x, 0) * Time.deltaTime;
		//Quaternion newCamRot = Quaternion.Euler(eulerAim);
		_Camera.transform.rotation = _CameraRot;
	}

	void FixedUpdate () {
		GetInput();
	}

	private void GetInput()
	{
		float horizontal = CrossPlatformInputManager.GetAxis("Horizontal");
		float vertical = CrossPlatformInputManager.GetAxis("Vertical");

		float yRot = CrossPlatformInputManager.GetAxis("Mouse X") * LookSensitivity.y;
		float xRot = CrossPlatformInputManager.GetAxis("Mouse Y") * LookSensitivity.x;
		_CameraRot *= Quaternion.Euler (-xRot, yRot, 0f);
		Debug.Log(_CameraRot);

		_AimInput = new Vector2(horizontal, vertical);
		_MoveInput = Input.GetKey(KeyCode.Space);

	}

	private void UpdateCamLook() {
		
	}
}
