using UnityEngine;

public class USBComputeBuffer : MonoBehaviour
{

    [SerializeField]
    private ComputeShader m_shader;
    [Range(0f, 0.5f)] public float radius;
    [Range(0f, 1f)] public float center;
    [Range(0f, 0.5f)] public float smooth;

    public Color mainColor = new Color();

    private RenderTexture m_mainTex;
    private int m_texSize = 128;
    private Renderer m_rend;
    
    // data struct 
    struct Circle
    {
        public float center;
        public float radius;
        public float smooth;
    }

    private Circle[] m_circle;
    
    //buffer
    private ComputeBuffer m_buffer;
    private static readonly int MainTex = Shader.PropertyToID("_BaseMap");


    private void Start()
    {
        
        CreateShaderTex();
    }

    private void Update()
    {
        SetShaderTex();
    }

    private void SetShaderTex()
    {
        uint threadGroupSizeX;
        m_shader.GetKernelThreadGroupSizes(0, out threadGroupSizeX, out _, out _);
        int size = (int)threadGroupSizeX;
        m_circle = new Circle[size];

        for (int i = 0; i < size; i++)
        {
            Circle circle = m_circle[i];
            circle.center = center;
            circle.radius = radius;
            circle.smooth = smooth;
            m_circle[i] = circle;
        }

        //  buffer settings
       // the amount of scalars (center, radius, smooth) multiplied by the floating
       // variable types they are stored (float - 4 bytes)
        int stride = 12; 
        m_buffer = new ComputeBuffer(m_circle.Length, stride, ComputeBufferType.Default);
        m_buffer.SetData(m_circle);
        
        //shader settings
        m_shader.SetBuffer(0, "CircleBuffer", m_buffer);
        m_shader.SetTexture(0, "Result", m_mainTex);
        m_shader.SetVector("MainColor", mainColor);
        m_rend.material.SetTexture(MainTex, m_mainTex);
        
        // dispatch
        m_shader.Dispatch(0, m_texSize, m_texSize, 1);
        m_buffer.Release();
    }

    private void CreateShaderTex()
    {
        // create the texture
        m_mainTex = new RenderTexture(m_texSize, m_texSize, 0, RenderTextureFormat.ARGB32);
        m_mainTex.enableRandomWrite = true;
        m_mainTex.Create();

        m_rend = GetComponent<Renderer>();
        m_rend.material.color = Color.white;
        m_rend.enabled = true;

    }
}
