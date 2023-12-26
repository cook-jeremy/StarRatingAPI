//
//  Rating.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/7/23.
//
import SwiftUI

public struct RatingStyleConfiguration<V: BinaryFloatingPoint> {
    @Binding public var value: V
    public let precision: V
    public let spacing: CGFloat?
    public let count: Int
    internal var styleRecursionLevel: Int = 0
}

public protocol RatingStyle {
    @ViewBuilder func makeStar(configuration: RatingStyleConfiguration<some BinaryFloatingPoint>, index: Int) -> any View
}

public struct SystemImageRatingStyle: RatingStyle {
    var systemName: String
    @ViewBuilder
    public func makeStar(configuration: RatingStyleConfiguration<some BinaryFloatingPoint>, index: Int) -> any View {
        let isFilled = Int(configuration.value) > index
        Image(systemName: isFilled ? "\(systemName).fill" : systemName)
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

public struct Rating<V: BinaryFloatingPoint>: View {
    
    @Environment(\.ratingStyles) var ratingStyles
    
    private var configuration: RatingStyleConfiguration<V>
    
    private var count: Int
    private var spacing: CGFloat?
    private var precision: V
    
    @State private var starWidth: CGFloat = 0
    @State private var totalWidth: CGFloat = 0
    
    @State private var xPos: CGFloat = 0
    
    internal enum TapLocation: Equatable {
        case star(index: Int, remainder: CGFloat)
        case spacer(index: Int)
        
        internal func value(precision: V) -> V {
            switch self {
            case .star(let index, let remainder):
                if precision != 0 {
                    let precisionIndex = Int(V(remainder) / precision)
                    return V(index) + V(precisionIndex + 1) * precision
                } else {
                    return V(index) + V(remainder)
                }
            case .spacer(let index):
                return V(index + 1)
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
                xPos = value.location.x
                let spacingWidth = spacing ?? (totalWidth - starWidth * CGFloat(count)) / CGFloat(count - 1)
                let tapLocation = location(value.location.x, starWidth: starWidth, spacingWidth: spacingWidth)
                let value = tapLocation.value(precision: precision)
                configuration.value = value
            }
    }
    
    public init(
        value: Binding<V>,
        precision: V = 1.0,
        spacing: CGFloat? = nil,
        count: Int = 5
    ) {
        precondition(count >= 0)
        self.configuration = .init(
            value: value,
            precision: precision,
            spacing: spacing,
            count: count
        )
        self.precision = precision
        self.spacing = spacing
        self.count = count
    }
    
    private var style: any RatingStyle {
        ratingStyles[ratingStyles.count - configuration.styleRecursionLevel - 1]
    }
    
    public var body: some View {
        VStack {
            Text("value: \(Double(configuration.value))")
            Text("starWidth: \(starWidth)")
            Text("totalWidth: \(totalWidth)")
            Text("xPos: \(xPos)")
            HStack(spacing: spacing) {
                ForEach(0 ..< count, id: \.self) { i in
                    AnyView(
                        style.makeStar(configuration: configuration, index: i)
                    )
                    ._measureWidth($starWidth)
                }
            }
            .contentShape(Rectangle())
            .gesture(drag)
            ._measureWidth($totalWidth)
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
            }
        )
    }
}
