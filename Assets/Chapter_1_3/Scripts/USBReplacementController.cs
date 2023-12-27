using System;
using UnityEngine;

namespace USB.Scripts
{
    [ExecuteInEditMode]
    public class USBReplacementController : MonoBehaviour
    {
        public Shader replacementShader;
        public Camera cam;
        private void OnEnable()
        {
            if (replacementShader && cam)
            {
                cam.SetReplacementShader(replacementShader,"RenderType");
            }
        }

        private void OnDisable()
        {
            if (cam)
            {
                cam.ResetReplacementShader();
            }
        }
    }
}