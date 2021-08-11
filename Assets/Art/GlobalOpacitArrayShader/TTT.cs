using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace HideShowDemo
{
    public class TTT : MonoBehaviour
    {
        [SerializeField] private MeshRenderer meshRenderer = null;
        [SerializeField] private Vector2 size;
        [SerializeField] private List<bool> boolList;
        [SerializeField] private bool validate;
        private List<float> opacityList;

        private void Start()
        {
           RefreshList(); 
        }

        private void RefreshList()
        {
            opacityList = new List<float>();
            int index = 0;
            for (int i = 0; i < size.x; i++)
            {
                for (int j = 0; j < size.y; j++)
                {
                    opacityList.Add(boolList[index] ? 1f : 0f);
                    index++;
                }
            }
            var sb = new StringBuilder();
            foreach (var item in opacityList)
            {
                sb.AppendLine($"item => {item}");
            }
            Debug.Log(sb);
            Debug.Log(opacityList.Count);
            Shader.SetGlobalFloatArray("transperancyArray", opacityList.ToArray());
        }

        private void OnValidate()
        {
            RefreshList();
        }
    }
}