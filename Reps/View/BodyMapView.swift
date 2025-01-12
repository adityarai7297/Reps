import SwiftUI
import SwiftData
import Macaw

struct BodyMapView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ExerciseHistory.timestamp, order: .reverse) private var exerciseHistories: [ExerciseHistory]
    @Query private var exercises: [Exercise]
    
    // Time window for exercise analysis (10 days)
    private let analysisTimeWindow: TimeInterval = 10 * 24 * 60 * 60
    
    // Calculate muscle group activity in the last 10 days
    private var muscleGroupActivity: [MuscleGroup: Int] {
        let now = Date()
        let cutoffDate = now.addingTimeInterval(-analysisTimeWindow)
        
        var activity: [MuscleGroup: Int] = [:]
        
        for history in exerciseHistories {
            guard history.timestamp >= cutoffDate else { continue }
            
            if let exercise = exercises.first(where: { $0.name == history.exerciseName }) {
                for muscleGroup in exercise.targetedMuscleGroups {
                    activity[muscleGroup, default: 0] += 1
                }
            }
        }
        
        return activity
    }
    
    // Get color intensity for a muscle group based on activity
    private func colorIntensity(for muscleGroup: MuscleGroup) -> Double {
        let maxActivity = muscleGroupActivity.values.max() ?? 1
        let activity = muscleGroupActivity[muscleGroup] ?? 0
        return Double(activity) / Double(maxActivity)
    }
    
    // Get highlight color for a muscle group
    private func highlightColor(for muscleGroup: MuscleGroup) -> Macaw.Color {
        let intensity = colorIntensity(for: muscleGroup)
        return Macaw.Color.red.with(a: intensity * 0.7 + 0.3) // Minimum opacity of 0.3
    }
    
    // Find nodes by group name recursively
    private func findNodesByTag(_ tag: String, in node: Macaw.Node) -> [Macaw.Node] {
        var nodes: [Macaw.Node] = []
        
        if let group = node as? Macaw.Group {
            // Check if this group has the tag we're looking for
            if group.tag.contains(tag) {
                // Add all shapes in this group
                for content in group.contents {
                    if let shape = content as? Macaw.Shape {
                        nodes.append(shape)
                    }
                }
            }
            
            // Search through all contents of the group
            for content in group.contents {
                nodes.append(contentsOf: findNodesByTag(tag, in: content))
            }
        }
        
        return nodes
    }
    
    // Helper function to print all titles in the SVG
    private func printAllTags(_ node: Macaw.Node) {
        if let group = node as? Macaw.Group {
            if let title = group.contents.first(where: { $0 is Macaw.Text }) as? Macaw.Text {
                print("Found Group with title: '\(title.text)'")
            }
            for content in group.contents {
                printAllTags(content)
            }
        }
    }
    
    // Add this helper function
    private func printAllGroupTags(_ node: Macaw.Node) {
        if let group = node as? Macaw.Group {
            print("Group tags: \(group.tag)")
            for content in group.contents {
                printAllGroupTags(content)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    SVGView(named: "body_map") { node in
                        print("Processing SVG node: \(type(of: node))")
                        // Print all group tags first
                        printAllGroupTags(node)
                        
                        for muscleGroup in MuscleGroup.allCases {
                            let nodes = findNodesByTag(muscleGroup.rawValue, in: node)
                            print("Searching for muscle group: \(muscleGroup.rawValue)")
                            print("Found \(nodes.count) nodes")
                            let color = highlightColor(for: muscleGroup)
                            
                            for node in nodes {
                                if let shape = node as? Macaw.Shape {
                                    shape.fill = color
                                }
                            }
                        }
                    }
                    .frame(width: min(geometry.size.width * 0.8, 400),
                           height: min(geometry.size.width * 0.8, 400))
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

// Custom UIView to handle SVG rendering
class SVGContainerView: UIView {
    var svgNode: Node? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let node = svgNode else { return }
        
        // Calculate scale to fit the view
        let viewSize = min(bounds.width, bounds.height)
        let scale = viewSize / 2666.6667 // Original SVG size
        
        // Clear the context and set up the coordinate system
        context.clear(rect)
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: scale, y: -scale)  // Flip the context because Core Graphics is y-flipped
        
        // Create MacawView and render
        let macawView = MacawView()
        macawView.node = node
        macawView.draw(CGRect(origin: .zero, size: rect.size))
    }
}

// Updated SVGView
struct SVGView: UIViewRepresentable {
    let named: String
    var onLoad: ((Node) -> Void)?
    
    func makeUIView(context: Context) -> SVGContainerView {
        let view = SVGContainerView(frame: .zero)
        
        if let path = Bundle.main.path(forResource: named, ofType: "svg"),
           var svgString = try? String(contentsOfFile: path, encoding: .utf8) {
            
            // First, let's modify the SVG string to add IDs based on titles
            let modifiedSVG = addIDsToGroups(svgString)
            print("Modified SVG preview: \(String(modifiedSVG.prefix(500)))")
            
            if let node = try? SVGParser.parse(text: modifiedSVG) {
                print("SVG loaded successfully")
                onLoad?(node)
                view.svgNode = node
            }
        } else {
            print("Failed to load SVG")
        }
        return view
    }
    
    func updateUIView(_ uiView: SVGContainerView, context: Context) {}
    
    // Helper function to add IDs to groups based on their titles
    private func addIDsToGroups(_ svg: String) -> String {
        var modified = svg
        
        // Regular expression to find groups with titles
        let pattern = #"<g[^>]*>\s*<title>([^<]+)</title>"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(svg.startIndex..., in: svg)
            
            // Replace each match with a group that has both an ID and the title
            modified = regex.stringByReplacingMatches(
                in: svg,
                range: range,
                withTemplate: "<g id=\"$1\">"
            )
            
            return modified
        } catch {
            print("Regex error: \(error)")
            return svg
        }
    }
}

#Preview {
    BodyMapView()
} 
