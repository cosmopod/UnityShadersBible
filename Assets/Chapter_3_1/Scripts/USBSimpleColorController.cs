using UnityEngine;

namespace USB.Scripts
{
    public class USBSimpleColorController : MonoBehaviour
    {

        [SerializeField]
        private ComputeShader m_shader;

        [SerializeField] private Texture m_tex;

        [SerializeField] private RenderTexture m_mainTex;

        private int m_texSize = 256;

        private Renderer m_renderer;
       
        //properties 
        private static readonly int MainTex = Shader.PropertyToID("_BaseMap");

        // Start is called before the first frame update
        void Start()
        {
            // init the texture
            m_mainTex = new RenderTexture(m_texSize, m_texSize, 0, RenderTextureFormat.ARGB32);
            
            // enable rnd writing
            m_mainTex.enableRandomWrite = true;
            
            //create texture
            m_mainTex.Create();
            
            // renderer
            m_renderer = GetComponent<Renderer>();
            m_renderer.enabled = true;
            
            // set the texture to the compute shader
            m_shader.SetTexture(0, "Result", m_mainTex);
            m_shader.SetTexture(0, "ColTex", m_tex);
            
            // send the texture to the quad's material
            m_renderer.material.SetTexture(MainTex, m_mainTex);
            
            //generate the thread group to process the texture
            m_shader.Dispatch(0, m_texSize/8, m_texSize/8, 1);
        }

        // Update is called once per frame
        void Update()
        {
        
        }
    }
}
