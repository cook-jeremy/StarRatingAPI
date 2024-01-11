import SwiftUI

public struct RatingStyleConfiguration {
    public var value: Double
    public let spacing: CGFloat?
    public let count: Int
    internal var styleRecursionLevel: Int = 0
}

public protocol RatingStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: RatingStyleConfiguration, index: Int) -> Body
}

public struct SystemImageRatingStyle: RatingStyle {
    var systemName: String
    
    public init(systemName: String) {
        self.systemName = systemName
    }
    
    @ViewBuilder
    public func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
        Image(systemName: Int(configuration.value) > index ? "\(systemName).fill" : systemName)
    }
}

struct RatingStylesEnvironmentKey: EnvironmentKey {
    static let defaultValue: [any RatingStyle] = [.star]
}

extension RatingStyle where Self == SystemImageRatingStyle {
    public static var star: SystemImageRatingStyle {
        SystemImageRatingStyle(systemName: "star")
    }

    public static var circle: SystemImageRatingStyle {
        SystemImageRatingStyle(systemName: "circle")
    }
}

extension EnvironmentValues {
    var ratingStyles: [any RatingStyle] {
        get { self[RatingStylesEnvironmentKey.self] }
        set { self[RatingStylesEnvironmentKey.self] = newValue }
    }
}

struct RatingStyleModifier<S: RatingStyle>: ViewModifier {
    @Environment(\.ratingStyles) var styles
    var style: S
    func body(content: Content) -> some View {
        content.environment(\.ratingStyles, styles + [style])
    }
}

extension View {
    public func ratingStyle<S>(_ style: S) -> some View where S : RatingStyle {
        self.modifier(RatingStyleModifier(style: style))
    }
}

public struct Rating: View {
    
    @Environment(\.ratingStyles) var ratingStyles
    
    @State private var configuration: RatingStyleConfiguration
    
    @Binding private var value: Double
    private var granularity: CGFloat
    private var spacing: CGFloat?
    private var count: Int
    
    @State private var starWidth: CGFloat = 0
    @State private var totalWidth: CGFloat = 0
    
    internal enum TapLocation: Equatable {
        case star(index: Int, remainder: CGFloat)
        case spacer(index: Int)
        
        internal func value(granularity: CGFloat) -> CGFloat {
            switch self {
            case .star(let index, let remainder):
                if granularity != 0 {
                    let granularityIndex = Int(CGFloat(remainder) / granularity)
                    let maxGranularityIndex = Int(1.0 / granularity) - 1
                    let realGranularityIndex = min(maxGranularityIndex, granularityIndex)
                    let newValue = CGFloat(index) + CGFloat(realGranularityIndex + 1) * granularity
                    return newValue
                } else {
                    return CGFloat(index) + CGFloat(remainder)
                }
            case .spacer(let index):
                return CGFloat(index + 1)
            }
        }
    }
    
    internal func location(_ x: CGFloat, starWidth: CGFloat, spacingWidth: CGFloat) -> TapLocation {
        let starAndSpacerWidth = starWidth + spacingWidth
        let starAndSpacerIndex = Int(x / starAndSpacerWidth)
        let remainder = x - CGFloat(starAndSpacerIndex) * starAndSpacerWidth
        let totalWidth = starWidth * CGFloat(count) + spacingWidth * CGFloat(count - 1)
        if remainder > starWidth && x < totalWidth {
            return .spacer(index: starAndSpacerIndex)
        } else {
            let cappedIndex = max(0, min(count - 1, starAndSpacerIndex))
            let cappedRemainder = x < totalWidth ? max(0, min(1, remainder / starWidth)) : 1
            return .star(index: cappedIndex, remainder: cappedRemainder)
        }
    }
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let spacingWidth = spacing ?? (totalWidth - starWidth * CGFloat(count)) / CGFloat(count - 1)
                let tapLocation = location(value.location.x, starWidth: starWidth, spacingWidth: spacingWidth)
                let newValue = tapLocation.value(granularity: granularity)
                self.value = newValue
            }
    }
    
    public init<V>(
        value: Binding<V>,
        granularity: CGFloat = 1,
        spacing: CGFloat? = nil,
        count: Int = 5
    ) where V: BinaryFloatingPoint {
        precondition(granularity >= 0 && granularity <= 1)
        if let spacing {
            precondition(spacing >= 0)
        }
        precondition(count >= 0 && count <= 100)
        
        self._configuration = State(
            initialValue: .init(
                value: Double(value.wrappedValue),
                spacing: spacing,
                count: count
            )
        )
        
        self._value = Binding {
            return Double(value.wrappedValue)
        } set: { newValue in
            value.wrappedValue = V(newValue)
        }
        self.granularity = granularity
        self.spacing = spacing
        self.count = count
    }
    
    private var style: any RatingStyle {
        ratingStyles[ratingStyles.count - configuration.styleRecursionLevel - 1]
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0 ..< count, id: \.self) { i in
                if i == 0 {
                    AnyView(
                        style.makeBody(configuration: configuration, index: i)
                    )
                    ._measureWidth($starWidth)
                } else {
                    AnyView(
                        style.makeBody(configuration: configuration, index: i)
                    )
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(drag)
        ._measureWidth($totalWidth)
        .onChange(of: value) { oldValue, newValue in
            configuration.value = newValue
        }
    }
}

extension View {
    internal func _measureWidth(_ width: Binding<CGFloat>) -> some View {
        overlay(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        width.wrappedValue = geo.size.width
                    }
                    .onChange(of: geo.size.width) { _, newWidth in
                        width.wrappedValue = newWidth
                    }
            }
        )
    }
}
