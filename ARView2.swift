//
//  File.swift
//  My App
//
//  Created by Andreas Ink on 1/2/22.
//

import SwiftUI
import ARKit
import RealityKit
import FocusEntity
import LocationBasedAR


class FocusedARView: LBARView {
    
    var focusEntity: FocusEntity?
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.scalingScheme = .equal
        focusEntity = FocusEntity(on: self, focus: .classic)
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FocusEntity {
    var publicLastPosition: float4x4? {
        switch state {
        case .initializing: return nil
        case .tracking(let raycastResult, _): return raycastResult.worldTransform
        }
    }
}


struct ARViewContainer: UIViewRepresentable {
    var config = ARWorldTrackingConfiguration()
    @Binding var saved: Bool
    @Binding var loaded: Bool
    @Binding var placer: Bool
    let arView = FocusedARView()
    func makeUIView(context: Context) -> FocusedARView {
        arView.focusEntity = FocusEntity(on: self.arView, focus: .classic)
        arView.focusEntity!.isEnabled = true
      //  self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self) { event in
         //   self.updateScene(for: arView)
       // }
        loadMapFtomFile()
        return arView
    }
    
    func updateUIView(_ uiView: FocusedARView, context: Context) {
        // ...
        if saved {
            //self.arView.scene.removeAnchor(self.arView.scene.anchors.first!)
            _ = uiView.snapshot(saveToHDR: false, completion: { image in
                print(image)
                //collect.readImage(CIImage(image: image!)!)
            })
            
            self.saveWorldMap()
            
        }
        if loaded {
            loadMapFtomFile()
            //self.loadWorldMap()
        }
        if placer {
           
            
            
            place(arView.cameraTransform)
          
        }
    }
    func place(_ transform: Transform) {
        
        self.arView.worldTransformToLocation(transform.matrix) { result in
            switch result {
            case .failure(let err): print("Unable to place entity due to err: \(err)")
            case .success(let location):
                let material = SimpleMaterial.init(color: .red,roughness: 1,isMetallic: false)
                let doorBox = MeshResource.generateBox(width: 0.02,height: 1, depth: 0.5)
                let doorEntity = ModelEntity(mesh: doorBox, materials: [material])
                let sphere = doorEntity
                sphere.generateCollisionShapes(recursive: true)
                let anchorEntity = AnchorEntity(world: transform.matrix)
                anchorEntity.addChild(sphere)
                self.arView.scene.addAnchor(anchorEntity)
                self.arView.add(entity: anchorEntity, with: location)
            }
        }
    }
    
    private func updateScene(for arView: FocusedARView) {
        
//        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
//        
//        if let confirmedModel = self.placementSettings.confirmedModel, let modelEntity = confirmedModel.modelEntity {
//            
//            self.arSessionManager.place(modelEntity)
//            self.placementSettings.confirmedModel = nil
//        }
//        
//        self.arSessionManager.updateAnnotations()
    }
    fileprivate func saveWorldMap() {
        
        arView.session.getCurrentWorldMap { (worldMap, _) in
            
            if let map: ARWorldMap = worldMap {
                
                let data = try! NSKeyedArchiver.archivedData(withRootObject: map,
                                                             requiringSecureCoding: true)
                actionSheet(data)
                let savedMap = UserDefaults.standard
                savedMap.set(data, forKey: "WorldMap")
                savedMap.synchronize()
                
                //print(data)
            }
        }
    }
    
    func actionSheet(_ data: Data) {
        
        let AV = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        
        UIApplication.shared.currentUIWindow()?.rootViewController?.present(AV, animated: true, completion: nil)
        
    }
    fileprivate func loadMapFtomFile() {
        let urlPath = Bundle.main.url(forResource: "data", withExtension: "txt")
        if let unarchiver = try? NSKeyedUnarchiver.unarchivedObject(
            ofClasses: [ARWorldMap.classForKeyedUnarchiver()],
            from: Data(contentsOf: urlPath!)),
           let worldMap = unarchiver as? ARWorldMap {
            print(worldMap.rawFeaturePoints)
            config.initialWorldMap = worldMap
            config.sceneReconstruction = .mesh
            arView.session.run(config, options: [.removeExistingAnchors, .resetTracking])
        }
    }
    fileprivate func loadWorldMap() {
        
        let storedData = UserDefaults.standard
        
        if let data = storedData.data(forKey: "WorldMap") {
            
            if let unarchiver = try? NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [ARWorldMap.classForKeyedUnarchiver()],
                from: data),
               let worldMap = unarchiver as? ARWorldMap {
                print(worldMap.rawFeaturePoints)
                config.initialWorldMap = worldMap
                
                arView.session.run(config)
            }
        }
}
}

