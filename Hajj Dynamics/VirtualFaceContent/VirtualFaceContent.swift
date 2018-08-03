//
//  VirtualFaceContest.swift
//  HajjHackathon
//
//  Created by Essa AlOwayyid on 1/8/18.
//  Copyright © 2018 Essa AlOwayyid. All rights reserved.
//

import ARKit
import SceneKit

protocol VirtualFaceContent {
    func update(withFaceAnchor: ARFaceAnchor)
}

typealias VirtualFaceNode = VirtualFaceContent & SCNNode

// MARK: Loading Content

func loadedContentForAsset(named resourceName: String) -> SCNNode {
    let url = Bundle.main.url(forResource: resourceName, withExtension: "scn", subdirectory: "Models.scnassets")!
    let node = SCNReferenceNode(url: url)!
    node.load()
    
    return node
}
