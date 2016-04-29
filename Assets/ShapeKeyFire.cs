//Using C#

using UnityEngine;
using System.Collections;

public class ShapeKeyFire : MonoBehaviour
{
    public float blendSpeed = 1f;
    int blendShapeCount;
    SkinnedMeshRenderer skinnedMeshRenderer;
    Mesh skinnedMesh;
    bool blendOneFinished = false;
    float[] targets;
    float tolerance;

    void Awake()
    {
        skinnedMeshRenderer = GetComponent<SkinnedMeshRenderer>();
        skinnedMesh = GetComponent<SkinnedMeshRenderer>().sharedMesh;
    }

    void Start()
    {
        blendShapeCount = skinnedMesh.blendShapeCount;
        targets = new float[blendShapeCount];
        tolerance = blendSpeed * 1.5f;
    }

    void Update()
    {
        for (int i = 0; i < blendShapeCount; ++i)
        {
            float currentWeight = skinnedMeshRenderer.GetBlendShapeWeight(i);
            if (Mathf.Abs(currentWeight - targets[i]) < tolerance)
            {
                targets[i] = Random.Range(0.0f, 100.0f);
            }
            float newWeight = currentWeight > targets[i] ? currentWeight -= blendSpeed : currentWeight += blendSpeed;
            skinnedMeshRenderer.SetBlendShapeWeight(i, newWeight);
        }
    }
}