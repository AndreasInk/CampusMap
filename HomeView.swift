import SwiftUI
import MapKit
import BottomSheet

struct HomeView: View {
    @State private var saver = false
    @State private var loader = false
    @State private var placer = false
    @State private var isPresented = true
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    var body: some View {
        ZStack {
            VStack {
                RealityKitView2(saved: $saver, loaded: $loader, placer: $placer)
                    .frame(height: 500)
                HStack {
                    Spacer()
                    Button(action: { self.saver.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.saver = false
                        }
                    }) {
                        Text("Save")
                    }
                    Spacer()
                    Button(action: { self.loader.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.loader = false
                        }
                    }) {
                        Text("Load")
                    }
                    Spacer()
                    Button(action: { self.placer.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.placer = false
                        }
                    }) {
                        Text("Place")
                    }
                    Button(action: { self.isPresented.toggle() }) {
                        Text("Toggle")
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    //Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow))
                    //.frame(maxWidth: 125, maxHeight: 175)
                    //.cornerRadius(25)
                    //.padding()
                }
                
            }
        }
        .bottomSheet(
            isPresented: $isPresented,
            detents: [.medium(), .large()],
            largestUndimmedDetentIdentifier: .medium,
            prefersGrabberVisible: true,
            prefersScrollingExpandsWhenScrolledToEdge: true,
            prefersEdgeAttachedInCompactHeight: false,
            widthFollowsPreferredContentSizeWhenEdgeAttached: false
        ) {
            ZStack {
                Color.white
                Text("Hello World")
            }
        }
    }
  
}
