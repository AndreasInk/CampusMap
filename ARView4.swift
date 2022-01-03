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

struct RealityKitView: UIViewRepresentable {
   
    @Binding var saved: Bool
    @Binding var loaded: Bool
    @Binding var placer: Bool
    @State var boxPos = SIMD3<Float>(x: 0, y: 0, z: 0)
    let arView = ARSCNView()
    var config = ARWorldTrackingConfiguration()
    
    
    
    
    func makeUIView(context: Context) -> ARSCNView {
       

        // Start AR session


      
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
       // arView.debugOptions = [.showSceneUnderstanding, .showFeaturePoints]
        context.coordinator.view = arView
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
    func updateUIView(_ view: ARSCNView, context: Context) {
        context.coordinator.addTapGestureToSceneView()
        if saved {
            //self.arView.scene.removeAnchor(self.arView.scene.anchors.first!)
//            _ = view.snapshot(saveToHDR: false, completion: { image in
//                print(image)
//                //collect.readImage(CIImage(image: image!)!)
//            })
            
            self.saveWorldMap()
           
        }
        if loaded {
            do {
            let urlPath = Bundle.main.url(forResource: "world6", withExtension: "txt")!
            config.initialWorldMap =  try unarchive(worldMapData: Data(contentsOf: urlPath))!
                arView.session.run(config, options: [.removeExistingAnchors, .resetTracking])
                print(config.initialWorldMap?.anchors)
            //self.loadWorldMap()
            } catch {
                print(error)
            }
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

//                    let data = try! NSKeyedArchiver.archivedData(withRootObject: map,
//                                                                 requiringSecureCoding: true)
//
//                    let savedMap = UserDefaults.standard
//                    savedMap.set(data, forKey: "WorldMap")
//                    savedMap.synchronize()

                
      try  archive(worldMap: map)
            //let transformData = try JSONEncoder().encode(arView.scene.anchors.map{$0.transform.matrix})
            try actionSheet([Data(contentsOf: worldMapURL)])
               // }
                }
        } catch {
            
            //print(data)
        
    }
        }
    }
    
        var worldMapURL: URL = {
               do {
                   return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                       .appendingPathComponent("worldMapURL")
               } catch {
                   fatalError("Error getting world map URL from document directory.")
               }
           }()
        
    func actionSheet(_ data: [Data]) {
        
        let AV = UIActivityViewController(activityItems: data, applicationActivities: nil)
        AV.popoverPresentationController?.sourceView = self.arView
        UIApplication.shared.currentUIWindow()?.rootViewController?.present(AV, animated: true, completion: nil)
        
    }
    func archive(worldMap: ARWorldMap) throws {
           let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
           try data.write(to: worldMapURL, options: [.atomic])
       }
       
       func retrieveWorldMapData(from url: URL) -> Data? {
           do {
               return try Data(contentsOf:  worldMapURL)
           } catch {
               //self.setLabel(text: "Error retrieving world map data.")
               return nil
           }
       }
       
       func unarchive(worldMapData data: Data) -> ARWorldMap? {
            let unarchievedObject = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
            
           return unarchievedObject
       }
//    fileprivate func loadMapFtomFile() {
//        let urlPath = Bundle.main.url(forResource: "world3", withExtension: "txt")
//        let urlPath2 = Bundle.main.url(forResource: "trans", withExtension: "txt")!
//
//        if let unarchiver = try? NSKeyedUnarchiver.unarchivedObject(
//            ofClasses: [ARWorldMap.classForKeyedUnarchiver()],
//            from: Data(contentsOf: urlPath!)),
//           let worldMap = unarchiver as? ARWorldMap {
//            print(worldMap.rawFeaturePoints)
//            config.initialWorldMap = worldMap
//            //config.sceneReconstruction = .mesh
//            do {
//
//                let decoder = JSONDecoder()
////                /let result = try decoder.decode([simd_float4x4].self, from: Data(contentsOf: urlPath2))
////                for t in result {
////                    print(t)
////                    let box = MeshResource.generateBox(size: 0.1, cornerRadius: 0.05)
////                let material = SimpleMaterial(color: .white, isMetallic: true)
////                        let diceEntity = ModelEntity(mesh: box, materials: [material])
////                    diceEntity.transform.matrix = t
////
////                    let anchor = AnchorEntity()
////
////
////
////
////                   // self.focusEntity = FocusEntity(on: view, style: .classic(color: .Primary))
////                   // if self.updatePostion {
////
////
////                   // guard let anchor =  view.scene.anchors.first else { return }
////
////
////                    anchor.transform.matrix = t
////                    arView.scene.addAnchor(anchor)
////                    anchor.addChild(diceEntity)
////                }
//
//
//            } catch {
//                print(error)
//            }
//            arView.session.run(config, options: [.removeExistingAnchors, .resetTracking])
//        }
//
//    }

//    fileprivate func loadWorldMap() {
//
//        let storedData = UserDefaults.standard
//        var anchors = [Data]()
//        if let data = storedData.data(forKey: "WorldMap") {
//
//            if let unarchiver = try? NSKeyedUnarchiver.unarchivedObject(
//                ofClasses: [ARWorldMap.classForKeyedUnarchiver()],
//                from: data),
//               let worldMap = unarchiver as? ARWorldMap {
//                print(worldMap.rawFeaturePoints)
//                config.initialWorldMap = worldMap
//
//                arView.session.run(config)
//            }
//        }
//}
    class Coordinator: NSObject, ARSessionDelegate, ARSCNViewDelegate {
        weak var view: ARSCNView?
        var focusEntity: FocusEntity?
        var count = 0
var addedGravel = false
        
        func addTapGestureToSceneView() {
               let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnARView))
            view?.addGestureRecognizer(tapGestureRecognizer)
           }
        @objc func tapOnARView(sender: UITapGestureRecognizer) {
            guard let arView = view else { return }
            let location = sender.location(in: arView)
            if let query = arView.raycastQuery(from: location,
                                            allowing: .existingPlaneGeometry,
                                            alignment: .horizontal) {
                let results = arView.session.raycast(query)
                if let result = results.first {
                    addCircle(raycastResult: result)
                }
            }
            
        }
        private func addCircle(raycastResult: ARRaycastResult) {
            let circleNode = GeometryUtils.createCircle(fromRaycastResult: raycastResult)
//            if circles.count >= 2 {
//                for circle in circles {
//                    circle.removeFromParentNode()
//                }
//                //circles.removeAll()
//            }
            
            view?.scene.rootNode.addChildNode(circleNode)
           // circles.append(circleNode)
            
//            if circles.count == 2 {
//                let distance = GeometryUtils.calculateDistance(firstNode: circles[0], secondNode: circles[1])
//                print("distance = \(distance)")
//              ///  message = "distance " + String(format: "%.2f cm", distance)
//            }
//            else {
//               // message = "add second point"
//            }
        }
           
        @objc func didReceiveTapGesture(_ sender: UITapGestureRecognizer) {
            print("hey")
               let location = sender.location(in: view)
               guard let hitTestResult = view?.hitTest(location, types: [.featurePoint, .estimatedHorizontalPlane]).first
                   else { return }
            print("there")
               let anchor = ARAnchor(transform: hitTestResult.worldTransform)
            view?.session.add(anchor: anchor)
            print(view?.session.currentFrame?.anchors)
           }
        
        func addBox() {
            let anchor = AnchorEntity()
               
           
            if let view = self.view {
           
           // self.focusEntity = FocusEntity(on: view, style: .classic(color: .Primary))
           // if self.updatePostion {
           
              // guard let focusEntity = self.focusEntity else { return }
           // guard let anchor =  view.scene.anchors.first else { return }
            
                //var cameraTransform = self.view!.cameraTransform
            //cameraTransform.translation = focusEntity.position
//            cameraTransform.translation.x += 0.01
//            cameraTransform.translation.z += focusEntity.position.z
            //cameraTransform.translation.y = focusEntity.position
//            cameraTransform.translation.x = count % 2 == 0 ? focusEntity.position.x - 0.12 : focusEntity.position.x + 0.12
            count += 1
           
//                let anchor = ARAnchor(transform: focusEntity.transform.matrix)
//                        view.session.add(anchor: anchor)
               
                
//            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//                view.scene.removeAnchor(anchor)
//            }
           
                let box = MeshResource.generateBox(size: 0.1, cornerRadius: 0.05)
            let material = SimpleMaterial(color: .white, isMetallic: true)
                    let diceEntity = ModelEntity(mesh: box, materials: [material])
                diceEntity.name = "box"
                //anchor.addChild(diceEntity)
            if !addedGravel {
//            if let url = Bundle.main.url(forResource: "Gravel", withExtension: "usdz") {
//                if let entity = try? Entity.load(contentsOf: url) {
//                    anchor.addChild(entity)
//            }
            //}
                addedGravel = true
            }
            }
         
            
        }
        
        func generateSphereNode() -> SCNNode {
            let sphere = SCNSphere(radius: 2.0)
            sphere.radius = 10
            let sphereNode = SCNNode(geometry: sphere)
           
            return sphereNode
        }
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
               //guard !(anchor is ARPlaneAnchor) else { return }
               let sphereNode = generateSphereNode()
               DispatchQueue.main.async {
                   node.addChildNode(sphereNode)
                   print(sphereNode)
               }
           }
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
           
        }
    }
}

extension Transform: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(matrix)
    }
    
    public init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        matrix = try values.decode(float4x4.self, forKey: .matrix)
        //rotation = try values.decode(float4x4.self, forKey: .rotation)
        translation = try values.decode(SIMD3<Float>.self, forKey: .translation)
       
    }
}

enum CodingKeys: String, CodingKey {
     case matrix
     case rotation
     case scale
    case translation
    
 }
enum CodingKeys2: String, CodingKey {
     case x
     case y
     case z
    
    
 }
extension simd_float4x4: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        try self.init(container.decode([SIMD4<Float>].self))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode([columns.0,columns.1, columns.2, columns.3])
    }
}
