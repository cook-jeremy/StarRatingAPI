//
//  Rating.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/7/23.
//
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
    
    @ViewBuilder
    public func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
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

public struct Rating: View {
    
    @Environment(\.ratingStyles) var ratingStyles
    
    @State private var configuration: RatingStyleConfiguration
    
    @Binding var value: Double
    private var count: Int
    private var spacing: CGFloat?
    private var precision: Double
    
    @State private var starWidth: CGFloat = 0
    @State private var totalWidth: CGFloat = 0
    
    internal enum TapLocation: Equatable {
        case star(index: Int, remainder: CGFloat)
        case spacer(index: Int)
        
        internal func value(precision: Double) -> Double {
            switch self {
            case .star(let index, let remainder):
                if precision != 0 {
                    let precisionIndex = Int(Double(remainder) / precision)
                    let maxPrecisionIndex = Int(1.0 / precision) - 1
                    let realPrecisionIndex = min(maxPrecisionIndex, precisionIndex)
                    let newValue = Double(index) + Double(realPrecisionIndex + 1) * precision
                    return newValue
                } else {
                    return Double(index) + Double(remainder)
                }
            case .spacer(let index):
                return Double(index + 1)
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
                let newValue = tapLocation.value(precision: precision)
                self.value = newValue
                self.configuration.value = newValue
            }
    }
    
    public init<V>(
        value: Binding<V>,
        precision: V = 1,
        spacing: CGFloat? = nil,
        count: Int = 5
    ) where V: BinaryFloatingPoint {
        precondition(count >= 0)
        self._configuration = State(
            wrappedValue: .init(
                value: Double(value.wrappedValue),
                spacing: spacing,
                count: count
            )
        )
        
        self._value = Binding {
            return Double(value.wrappedValue)
        } set: { newValue in
            if let newValue = newValue as? V {
                value.wrappedValue = newValue
            }
        }
        self.precision = Double(precision)
        self.spacing = spacing
        self.count = count
    }
    
    private var style: any RatingStyle {
        ratingStyles[ratingStyles.count - configuration.styleRecursionLevel - 1]
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0 ..< count, id: \.self) { i in
                AnyView(
                    style.makeBody(configuration: configuration, index: i)
                )
                ._measureWidth($starWidth)
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
            }
        )
    }
}
