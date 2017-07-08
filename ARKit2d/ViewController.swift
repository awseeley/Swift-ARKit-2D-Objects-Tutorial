//
//  ViewController.swift
//  ARKit2d
//
//  Created by Andrew Seeley on 5/7/17.
//  Copyright © 2017 Seemu. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var ballNode = SCNNode()
    var anchors: [ARAnchor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let configuration = ARWorldTrackingSessionConfiguration()
        
        sceneView.session.run(configuration)
        sceneView.delegate = self
        
        ballNode = make2dNode(image: #imageLiteral(resourceName: "ball"), width: 0.03, height: 0.03)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if anchors.count > 1 {
            startBouncing()
            return
        }
        
        if let currentFrame = sceneView.session.currentFrame {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.3
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
            anchors.append(anchor)
        }
    }
    
    func make2dNode(image: UIImage, width: CGFloat = 0.1, height: CGFloat = 0.1) -> SCNNode {
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial!.diffuse.contents = image
        let node = SCNNode(geometry: plane)
        node.constraints = [SCNBillboardConstraint()]
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //  get back to
        let player = make2dNode(image: #imageLiteral(resourceName: "paddleblue"))
        node.addChildNode(player)
    }
    
    func startBouncing() {
        guard let first = anchors.first, let start = sceneView.node(for: first),
        let last = anchors.last, let end = sceneView.node(for: last)
        else {
            return
        }
        
        if ballNode.parent == nil {
            sceneView.scene.rootNode.addChildNode(ballNode)
        }
        
        let animation = CABasicAnimation(keyPath: #keyPath(SCNNode.transform))
        animation.fromValue = start.transform
        animation.toValue = end.transform
        animation.duration = 1
        animation.autoreverses = true
        animation.repeatCount = .infinity
        ballNode.removeAllAnimations()
        ballNode.addAnimation(animation, forKey: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

