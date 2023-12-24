//
//  Rating.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/7/23.
//
import SwiftUI

public struct RatingStyleConfiguration<V: BinaryFloatingPoint> {
    @Binding public var value: V
    
//    var index: Int
//    
//    var fillPercent: V {
//        value - V(index)
//    }
//    
//    var isFilled: Bool {
//        value > V(index)
//    }
    
    public let spacing: CGFloat
    public let count: Int
    
    internal var styleLevel: Int = 1
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
    private var spacing: CGFloat
    
    @State private var starWidth: CGFloat = 0
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let xPos = value.location.x
                let realValue = (xPos / (starWidth + spacing)) + 1
                self.configuration.value = V(max(1, realValue))
            }
    }
    
    public init(
        value: Binding<V>,
        spacing: CGFloat = 10,
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
    
    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0 ..< count, id: \.self) { i in
                let style = ratingStyles[ratingStyles.count - configuration.styleLevel]
                AnyView(
                    style.makeStar(configuration: configuration, index: i)
                )
                .overlay(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                starWidth = geo.size.width
                            }
                    }
                )
            }
        }
        .gesture(drag)
    }
}

extension Rating {
    public init(_ configuration: RatingStyleConfiguration<V>) {
        self.configuration = configuration
        self.configuration.styleLevel += 1
        self.spacing = configuration.spacing
        self.count = configuration.count
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
