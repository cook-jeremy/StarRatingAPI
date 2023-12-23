//
//  Rating.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/7/23.
//

import SwiftUI

public struct RatingStyleConfiguration<V: BinaryFloatingPoint> {
    @Binding var value: V
    
    var spacing: CGFloat?
    var count: Int
    var styleLevel: Int = 1
}

public protocol RatingStyle {
    @ViewBuilder func makeBody(configuration: RatingStyleConfiguration<some BinaryFloatingPoint>) -> any View
}

public struct SystemImageRatingStyle: RatingStyle {
    public var systemImage: String
    
    @ViewBuilder
    public func makeBody<V: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<V>) -> any View {
        HStack(spacing: configuration.spacing) {
            ForEach(0 ..< configuration.count, id: \.self) { i in
                let isFilled = i < Int(configuration.value)
                Image(systemName: isFilled ? "\(systemImage).fill" : systemImage)
                    .onTapGesture {
                        configuration.value = V(i + 1)
                    }
            }
        }
    }
}

struct RatingStylesEnvironmentKey: EnvironmentKey {
    static let defaultValue: [any RatingStyle] = [SystemImageRatingStyle(systemImage: "star")]
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
    }
    
    public var body: some View {
        let styleIndex = ratingStyles.count - configuration.styleLevel
        let style = ratingStyles[styleIndex]
        AnyView(style.makeBody(configuration: configuration))
    }
}

extension Rating {
    public init(_ configuration: RatingStyleConfiguration<V>) {
        self.configuration = configuration
        self.configuration.styleLevel += 1
    }
}

extension RatingStyle where Self == SystemImageRatingStyle {
    public static var star: SystemImageRatingStyle {
        SystemImageRatingStyle(systemImage: "star")
    }

    public static var circle: SystemImageRatingStyle {
        SystemImageRatingStyle(systemImage: "circle")
    }
}
