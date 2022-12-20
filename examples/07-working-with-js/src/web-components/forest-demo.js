// 
// This code was taken from this Three.js example:
// https://github.com/mrdoob/three.js/blob/master/examples/webgl_lightprobe.html
//

import * as THREE from 'three'
import { OrbitControls } from 'three/addons/controls/OrbitControls.js'

window.customElements.define('forest-demo', class extends HTMLElement {
  connectedCallback() {
    let size = {
      width: 800,
      height: 450
    }

    let camera, controls, scene, renderer
    let self = this

    init()
    animate()

    function init() {
      scene = new THREE.Scene()
      scene.background = new THREE.Color(0xcccccc)
      scene.fog = new THREE.FogExp2(0xcccccc, 0.002)

      renderer = new THREE.WebGLRenderer({ antialias: true })
      renderer.setPixelRatio(window.devicePixelRatio)
      renderer.setSize(size.width, size.height)

      self.appendChild(renderer.domElement)

      camera = new THREE.PerspectiveCamera(60, size.width / size.height, 1, 1000)
      camera.position.set(400, 200, 0)

      // controls
      controls = new OrbitControls(camera, renderer.domElement)
      controls.listenToKeyEvents(window)

      controls.enableDamping = true
      controls.dampingFactor = 0.05

      controls.screenSpacePanning = false

      controls.minDistance = 100
      controls.maxDistance = 500

      controls.maxPolarAngle = Math.PI / 2

      // world
      const geometry = new THREE.CylinderGeometry(0, 10, 30, 4, 1)
      const material = new THREE.MeshPhongMaterial({ color: 0xffffff, flatShading: true })

      for (let i = 0; i < 500; i++) {
        const mesh = new THREE.Mesh(geometry, material)
        mesh.position.x = Math.random() * 1600 - 800
        mesh.position.y = 0
        mesh.position.z = Math.random() * 1600 - 800
        mesh.updateMatrix()
        mesh.matrixAutoUpdate = false
        scene.add(mesh)
      }

      // lights

      const dirLight1 = new THREE.DirectionalLight(0xffffff)
      dirLight1.position.set(1, 1, 1)
      scene.add(dirLight1)

      const dirLight2 = new THREE.DirectionalLight(0x002288)
      dirLight2.position.set(-1, -1, -1)
      scene.add(dirLight2)

      const ambientLight = new THREE.AmbientLight(0x222222)
      scene.add(ambientLight)

      window.addEventListener('resize', onWindowResize)
    }

    function onWindowResize() {
      camera.aspect = size.width / size.height
      camera.updateProjectionMatrix()
      renderer.setSize(size.width, size.height)
    }

    function animate() {
      requestAnimationFrame(animate)
      controls.update()
      render()
    }

    function render() {
      renderer.render(scene, camera)
    }

  }
})