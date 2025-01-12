import SwiftUI
import SwiftData
import SVGKit

struct BodyMapView: View {
    // Cache the SVG image
    private static let cachedSVG: SVGKImage? = {
        guard let svgURL = Bundle.main.url(forResource: "body_map", withExtension: "svg") else { return nil }
        let image = SVGKImage(contentsOf: svgURL)
        // Pre-scale the SVG to a reasonable size
        image?.size = CGSize(width: 450, height: 300)
        return image
    }()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    SVGKitView(svgImage: Self.cachedSVG)
                        .frame(width: min(geometry.size.width * 0.8, 300),
                               height: min(geometry.size.height * 0.7, 500))
                        .padding()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Body Map")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct SVGKitView: UIViewRepresentable {
    let svgImage: SVGKImage?
    
    func makeUIView(context: Context) -> SVGKFastImageView {
        let image = svgImage ?? SVGKImage()
        guard let view = SVGKFastImageView(svgkImage: image) else {
            fatalError("Could not create SVGKFastImageView")
        }
        view.contentMode = .scaleAspectFit
        
        // Additional scaling and optimization
        view.backgroundColor = .clear
        view.clipsToBounds = true
        
        return view
    }
    
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {}
}

#Preview {
    BodyMapView()
} 
