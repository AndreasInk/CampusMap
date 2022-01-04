//
//  File.swift
//  My App
//
//  Created by Andreas Ink on 1/2/22.
//


import ARKit
import SwiftUI
import RealityKit
import FocusEntity
import RKPointPin

struct RealityKitView2: UIViewRepresentable {
  
    @Binding var saved: Bool
    @Binding var loaded: Bool
    @Binding var placer: Bool
    @State var boxPos = SIMD3<Float>(x: 0, y: 0, z: 0)
    let arView = ARView()
    var config = ARWorldTrackingConfiguration()
    let rkPin = RKPointPin()
    func makeUIView(context: Context) -> ARView {
       

        // Start AR session

        
        self.arView.addSubview(rkPin)
        
        
config.planeDetection = [.horizontal]
     //   config.frameSemantics.insert(.personSegmentationWithDepth)
      //  config.frameSemantics.insert(.smoothedSceneDepth)
        config.sceneReconstruction = .mesh
      
        arView.session.run(config)

        // Add coaching overlay
let coachingOverlay = ARCoachingOverlayView()
coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
coachingOverlay.session = arView.session
        
coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        arView.debugOptions = [.showSceneUnderstanding, .showFeaturePoints]
        context.coordinator.view = arView
        context.coordinator.rkPin = rkPin
        arView.session.delegate = context.coordinator
        // Set debug options
#if DEBUG
//view.debugOptions = [.showFeaturePoints, .showAnchorOrigins, .showAnchorGeometry]
#endif
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
//        if updatePostion {
//        context.coordinator.addBox()
//        print("UPDATED")
//        }
        }
        return arView
    }
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    func updateUIView(_ view: ARView, context: Context) {
      
        if saved {
            //self.arView.scene.removeAnchor(self.arView.scene.anchors.first!)
//            _ = view.snapshot(saveToHDR: false, completion: { image in
//                print(image)
//                //collect.readImage(CIImage(image: image!)!)
//            })
            
            self.saveWorldMap()
           
        }
        if loaded {
            self.loadWorldMap()
            //self.loadWorldMap()
        }
        if placer {
           
            
            context.coordinator.addBox()
           // place(arView.cameraTransform)
          
        }
        
        
    }
    fileprivate func saveWorldMap() {
       
            arView.session.getCurrentWorldMap { (worldMap, _) in
                do {
                
                if let map: ARWorldMap = worldMap {
                    
                    let data = try! NSKeyedArchiver.archivedData(withRootObject: map,
                                                                 requiringSecureCoding: true)
                   
                    let savedMap = UserDefaults.standard
                    savedMap.set(data, forKey: "WorldMap")
                    savedMap.synchronize()
                    
                
            let transformData = try JSONEncoder().encode(arView.scene.anchors.map{$0.transform.matrix})
            actionSheet([transformData, data])
                }
            
        } catch {
            
            //print(data)
        }
    }
        }
        
    
    
    func actionSheet(_ data: [Data]) {
        
        let AV = UIActivityViewController(activityItems: data, applicationActivities: nil)
        AV.popoverPresentationController?.sourceView = self.arView
        UIApplication.shared.currentUIWindow()?.rootViewController?.present(AV, animated: true, completion: nil)
        
    }
    fileprivate func loadMapFtomFile() {
        let urlPath = Bundle.main.url(forResource: "world3", withExtension: "txt")
        let urlPath2 = Bundle.main.url(forResource: "pos", withExtension: "txt")!
        
        if let unarchiver = try? NSKeyedUnarchiver.unarchivedObject(
            ofClasses: [ARWorldMap.classForKeyedUnarchiver()],
            from: Data(contentsOf: urlPath!)),
           let worldMap = unarchiver as? ARWorldMap {
            print(worldMap.rawFeaturePoints)
            config.initialWorldMap = worldMap
            print(worldMap.anchors)
           // config.sceneReconstruction = .mesh
            do {
                  
                let decoder = JSONDecoder()
                //let result = try decoder.decode([simd_float4x4].self, from: Data(contentsOf: urlPath2))
                for anchor in worldMap.anchors {
                   
                   
                    let box = MeshResource.generateBox(size: 0.1, cornerRadius: 0.05)
                let material = SimpleMaterial(color: .white, isMetallic: true)
                        let diceEntity = ModelEntity(mesh: box, materials: [material])
                    //diceEntity.transform.matrix = t
                    
                    let anchor = AnchorEntity(anchor: anchor)
                   
                   
                   
                   // self.focusEntity = FocusEntity(on: view, style: .classic(color: .Primary))
                   // if self.updatePostion {
                   
                      
                   // guard let anchor =  view.scene.anchors.first else { return }
                    
                    
                   // anchor.transform.translation = t.translation
                    rkPin.targetEntity = diceEntity
                    arView.scene.addAnchor(anchor)
                    anchor.addChild(diceEntity)
                }
                
                
            } catch {
                print(error)
            }
            arView.session.run(config, options: [.removeExistingAnchors, .resetTracking])
        }
    
    }

    fileprivate func loadWorldMap() {
        
        let storedData = UserDefaults.standard
        var anchors = [Data]()
        if let data = storedData.data(forKey: "WorldMap") {
            
            if let unarchiver = try? NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [ARWorldMap.classForKeyedUnarchiver()],
                from: data),
               let worldMap = unarchiver as? ARWorldMap {
                print(worldMap.rawFeaturePoints)
                config.initialWorldMap = worldMap
                for anchor in worldMap.anchors {
                   
                   
                    let box = MeshResource.generateBox(size: 0.1, cornerRadius: 0.05)
                let material = SimpleMaterial(color: .white, isMetallic: true)
                        let diceEntity = ModelEntity(mesh: box, materials: [material])
                    //diceEntity.transform.matrix = t
                    if anchor.name == "HEY" {
                    let anchor = AnchorEntity(anchor: anchor)
                   
                   
                   
                   // self.focusEntity = FocusEntity(on: view, style: .classic(color: .Primary))
                   // if self.updatePostion {
                   
                      
                   // guard let anchor =  view.scene.anchors.first else { return }
                    
                    
                   // anchor.transform.translation = t.translation
                    anchor.addChild(diceEntity)
                    arView.scene.addAnchor(anchor)
                   
                    }
                }
                arView.session.run(config, options: [.removeExistingAnchors, .resetTracking])
            }
        }
}
    class Coordinator: NSObject, ARSessionDelegate {
        weak var view: ARView?
        weak var rkPin: RKPointPin?
        var focusEntity: FocusEntity?
        var count = 0
var addedGravel = false
        var collect = Collect()
        func addBox() {
            let anchor = AnchorEntity()
               
           
            guard let view = self.view else { return }
           
           // self.focusEntity = FocusEntity(on: view, style: .classic(color: .Primary))
           // if self.updatePostion {
           
               guard let focusEntity = self.focusEntity else { return }
           // guard let anchor =  view.scene.anchors.first else { return }
            
            var cameraTransform = view.cameraTransform
            cameraTransform.translation = focusEntity.position
//            cameraTransform.translation.x += 0.01
//            cameraTransform.translation.z += focusEntity.position.z
            cameraTransform.translation.y = focusEntity.position.y
            cameraTransform.translation.x = count % 2 == 0 ? focusEntity.position.x - 0.12 : focusEntity.position.x + 0.12
            count += 1
            anchor.position = cameraTransform.translation
            view.scene.addAnchor(anchor)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//                view.scene.removeAnchor(anchor)
//            }
            let textAnchor = anchor
            let modelEnt = ModelEntity(mesh: MeshResource.generateBox(size: 0.1,  cornerRadius: 0.05), materials: [SimpleMaterial(color: .white, isMetallic: false)])
            textAnchor.addChild(modelEnt)
          
            let textEntity: Entity = textAnchor.children[0]
           
            var textModelComponent: ModelComponent = (textEntity.components[ModelComponent])!

            textModelComponent.mesh = .generateText(anchor.name,
                                     extrusionDepth: 0.5,
                                               font: .systemFont(ofSize: 0.25),
                                     containerFrame: CGRect.zero,
                                          alignment: .center,
                                      lineBreakMode: .byCharWrapping)

            textAnchor.children[0].components.set(textModelComponent)
            //view.scene.anchors.append(textAnchor)
                let box = MeshResource.generateText("Hello World")
            let material = SimpleMaterial(color: .white, isMetallic: false)
                    let diceEntity = ModelEntity(mesh: box, materials: [material])
                diceEntity.name = "box"
            self.rkPin?.targetEntity = diceEntity
            view.session.add(anchor: ARAnchor(name: "HEY", transform: focusEntity.transform.matrix))
            if !addedGravel {
//            if let url = Bundle.main.url(forResource: "Gravel", withExtension: "usdz") {
//                if let entity = try? Entity.load(contentsOf: url) {
//                    anchor.addChild(entity)
//            }
            //}
                addedGravel = true
            }
           
            anchor.addChild(diceEntity)
            
        }
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
           
            guard let view = self.view else { return }
           
            self.focusEntity = FocusEntity(on: view, style: .classic(color: .yellow))
            guard let focusEntity = self.focusEntity else { return }
           
            
            
            //}
          
        }
        var i = 0
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
//             i += 1
//            if i % 10 == 0 {
//            _ = view?.snapshot(saveToHDR: false, completion: { image in
//                
//                print(image)
//                self.collect.readImage(CIImage(image: image!)!)
//            })
//            }
        }
    }
}

