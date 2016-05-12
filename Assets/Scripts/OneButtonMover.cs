using UnityEngine;
using System.Collections;
using UnityStandardAssets.CrossPlatformInput;

public class OneButtonMover : MonoBehaviour
{
    public float MoveSpeed = 1f;
    public Vector2 LookSensitivity = new Vector2(1f, 1f);
    public float Skew = 2.71828f;
    public float Boost = 30f;

    public Transform CameraTransform;
    public Transform NeckTransform;
    public Transform BodyTransform;

    private bool _MoveInput;
    private Quaternion _NewCameraRot;
    private Quaternion _NewNeckRot;
    private Quaternion _NewBodyRot;

    private Rigidbody RB;

    void Start()
    {
        //CameraTransform = GetComponentInChildren<Camera>().transform;
        //NeckTransform = CameraTransform.parent;
        //BodyTransform = transform;
        RB = GetComponent<Rigidbody>();

        _NewCameraRot = CameraTransform.rotation;
        _NewNeckRot = NeckTransform.rotation;
        _NewBodyRot = BodyTransform.rotation;
    }

    void Update()
    {
        Debug.DrawRay(transform.position + Vector3.up * 1f, CameraTransform.forward * 2f, Color.yellow);
        Debug.DrawRay(transform.position + Vector3.up * 1f, NeckTransform.forward * 2f, Color.green);
        Debug.DrawRay(transform.position + Vector3.up * 1f, BodyTransform.forward * 2f, Color.blue);
        GetInput();
        UpdateCamLook();
        UpdateBodyHeading();
        if (_MoveInput)
        {
            transform.position += BodyTransform.forward * MoveSpeed * Time.deltaTime;
        }
    }

    private void GetInput()
    {
        float yRot = CrossPlatformInputManager.GetAxis("Mouse X") * LookSensitivity.y;
        float xRot = CrossPlatformInputManager.GetAxis("Mouse Y") * LookSensitivity.x;
        _NewCameraRot *= Quaternion.Euler(-xRot, 0f, 0f);
        _NewNeckRot *= Quaternion.Euler(0f, yRot, 0f);
        _MoveInput = Input.GetMouseButton(0);
    }

    private void UpdateCamLook()
    {
        CameraTransform.localRotation = _NewCameraRot;
        NeckTransform.localRotation = _NewNeckRot;
    }

    private void UpdateBodyHeading()
    {
        Vector3 perpVector = Vector3.Cross(Vector3.up, BodyTransform.forward);
        float angle = Vector3.Angle(NeckTransform.forward, BodyTransform.forward);
        angle *= Mathf.Sign(Vector3.Dot(perpVector, NeckTransform.forward));

        float debug1 = angle;

        angle = angle / 360f + 0.5f;
        float outAngle = Mathf.Log(angle / (1f - angle), Skew) * Boost;

        //Debug.Log("Angle : " + debug1 + "  Output : " + outAngle);
        _NewBodyRot *= Quaternion.Euler(0f, outAngle, 0f);
        BodyTransform.rotation = _NewBodyRot;
    }
}
