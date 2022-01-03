import SwiftUI
import MapKit

struct HomeView: View {
    @State private var saver = false
    @State private var loader = false
    @State private var placer = false
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    var body: some View {
        ZStack {
            VStack {
                RealityKitView2(saved: $saver, loaded: $loader, placer: $placer)
                    .frame(height: 500)
                HStack {
                    Spacer()
                    Button(action: { self.saver.toggle() }) {
                        Text("Save")
                    }
                    Spacer()
                    Button(action: { self.loader.toggle() }) {
                        Text("Load")
                    }
                    Spacer()
                    Button(action: { self.placer.toggle() }) {
                        Text("Place")
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
    }
}
