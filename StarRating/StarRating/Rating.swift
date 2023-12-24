//
//  Rating.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/7/23.
//
import SwiftUI

public struct RatingStyleConfiguration<V: BinaryFloatingPoint> {
    @Binding public var value: V
    public let spacing: CGFloat?
    public let count: Int
    
    internal var styleRecursionLevel: Int = 0
}

public protocol RatingStyle {
    @ViewBuilder func makeStar(configuration: RatingStyleConfiguration<some BinaryFloatingPoint>, index: Int) -> any View
}

public struct StarRatingStyle: RatingStyle {
    @ViewBuilder
    public func makeStar(configuration: RatingStyleConfiguration<some BinaryFloatingPoint>, index: Int) -> any View {
        let isFilled = Int(configuration.value) > index
        Image(systemName: isFilled ? "star.fill" : "star")
    }
}

struct RatingStylesEnvironmentKey: EnvironmentKey {
    static let defaultValue: [any RatingStyle] = [StarRatingStyle()]
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
    
    @State private var starWidth: CGFloat = 0
    @State private var totalWidth: CGFloat = 0
    
    private var index: Int?
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let spacing = self.spacing ?? (totalWidth - starWidth * CGFloat(count)) / CGFloat(count - 1)
                let _value = (value.location.x / (starWidth + spacing)) + 1
                self.configuration.value = V(max(1, _value))
            }
    }
    
    public init(
        value: Binding<V>,
        spacing: CGFloat? = nil,
        count: Int = 5
    ) {
        precondition(count >= 0)
        self.configuration = .init(
            value: value,
            spacing: spacing,
            count: count
        )
        self.spacing = spacing
        self.count = count
    }
    
    private var style: any RatingStyle {
        ratingStyles[ratingStyles.count - configuration.styleRecursionLevel - 1]
    }
    
    public var body: some View {
        if configuration.styleRecursionLevel == 0 {
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
        } else {
            AnyView(
                style.makeStar(configuration: configuration, index: index ?? 0)
            )
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

extension Rating {
    public init(_ configuration: RatingStyleConfiguration<V>, index: Int) {
        self.configuration = configuration
        self.configuration.styleRecursionLevel += 1
        self.spacing = configuration.spacing
        self.count = configuration.count
        self.index = index
    }
}

//extension RatingStyle where Self == SystemImageRatingStyle {
//    public static var star: SystemImageRatingStyle {
//        SystemImageRatingStyle(systemImage: "star")
//    }
//
//    public static var circle: SystemImageRatingStyle {
//        SystemImageRatingStyle(systemImage: "circle")
//    }
//}
