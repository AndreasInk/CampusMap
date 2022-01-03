//import SwiftUI
//
//import RealityKit
//import SwiftUI
//import ARKit
//
//struct ARViewContainer: UIViewRepresentable {
//    @StateObject var collect = Collect()
//    @Binding var saved: Bool
//    @Binding var loaded: Bool
//    
//    let anchor = AnchorEntity(world: [0, 0,-2])
//    let arView = ARView(frame: .zero)
//    var config = ARWorldTrackingConfiguration()
//    
//    func makeUIView(context: Context) -> ARView {
//        arView.debugOptions = [.showSceneUnderstanding, .showFeaturePoints]
//        
//        config.sceneReconstruction = .mesh
//        
//        arView.session.run(config)
//        let sphere = MeshResource.generateSphere(radius: 1)
//        let sphereEntity = ModelEntity(mesh: sphere)
//        sphereEntity.name = "SPHERE"
//        sphereEntity.setParent(anchor)
//        //arView.scene.anchors.append(anchor)
//        return arView
//    }        
//   
//    }
//    
//  
//}


