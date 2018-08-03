//
//  GlassesOverlay.swift
//  HajjHackathon
//
//  Created by Essa AlOwayyid on 1/8/18.
//  Copyright © 2018 Essa AlOwayyid. All rights reserved.
//

import ARKit
import SceneKit

class GlassesOverlay: SCNNode, VirtualFaceContent {
    
    
    private func addNode() -> SCNNode {

        let plate = SCNPlane(width: 80, height: 50)
        plate.firstMaterial?.isDoubleSided = true
        plate.firstMaterial?.diffuse.contents = UIColor.init(white: 1.0, alpha: 0.6)
        //        plate.eulerAngles = SCNVector3(CGFloat(-90.degreeToRadians), 0, 0)
        let plateNode = SCNNode(geometry: plate)
        plateNode.position = SCNVector3(30,25,0)

        //        plateNode.scale = SCNVector3(0.01,0.01,0.01)
        let sceneTextLegal = SCNText(string: "Valid Pilgrim \n25 Y/O \nDiabetic", extrusionDepth: 1.2)
        let sceneTextILegal = SCNText(string: "ilegal Pilgrim", extrusionDepth: 1)
        
        sceneTextLegal.firstMaterial?.diffuse.contents = UIColor.green
        
        let node = SCNNode(geometry: sceneTextLegal)
        node.addChildNode(plateNode)
        
        node.position = SCNVector3(0,0.2,-0.1)
        node.scale = SCNVector3(0.005,0.005,0.005)
        
        //        let bigNode = node use to make it look like billboard
//        let billboardConstraint = SCNBillboardConstraint()
//        billboardConstraint.freeAxes = SCNBillboardAxis.Y
//
//        node.constraints = [billboardConstraint]
        
        
        return node
    }
    
    let occlusionNode: SCNNode
    
    /// - Tag: OcclusionMaterial
    init(geometry: ARSCNFaceGeometry) {
        
        /*
         Write depth but not color and render before other objects.
         This causes the geometry to occlude other SceneKit content
         while showing the camera view beneath, creating the illusion
         that real-world objects are obscuring virtual 3D objects.
         */
        geometry.firstMaterial!.colorBufferWriteMask = []
        occlusionNode = SCNNode(geometry: geometry)
        occlusionNode.renderingOrder = -1
        
        super.init()
        
        addChildNode(occlusionNode)
        
        // Add 3D content positioned as "glasses".
        //        let faceOverlayContent = loadedContentForAsset(named: "overlayModel")
        let faceOverlayContent = addNode()
        addChildNode(faceOverlayContent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    // MARK: VirtualFaceContent
    
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        let faceGeometry = occlusionNode.geometry as! ARSCNFaceGeometry
        faceGeometry.update(from: anchor.geometry)
    }
}
