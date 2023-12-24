////
////  Rating.swift
////  StarsAPI
////
////  Created by Jeremy Cook on 12/7/23.
////
//import SwiftUI
//
//public struct RatingStyleConfiguration<V: BinaryFloatingPoint, Star: View> {
//    @Binding var value: V
//    
//    var spacing: CGFloat?
//    var count: Int
//    var starContent: (Int, V) -> Star
//    
//    internal var styleLevel: Int = 1
//}
//
//public protocol RatingStyle {
//    @ViewBuilder func makeBody(configuration: RatingStyleConfiguration<some BinaryFloatingPoint, some View>) -> any View
//}
//
//public struct SystemImageRatingStyle: RatingStyle {
//    public var systemImage: String
//    
//    @ViewBuilder
//    public func makeBody(configuration: RatingStyleConfiguration<some BinaryFloatingPoint, some View>) -> any View {
//        HStack(spacing: configuration.spacing) {
//            ForEach(0 ..< configuration.count, id: \.self) { i in
//                configuration.starContent(i, configuration.value)
//            }
//        }
//    }
//}
//
//struct RatingStylesEnvironmentKey: EnvironmentKey {
//    static let defaultValue: [any RatingStyle] = [SystemImageRatingStyle(systemImage: "star")]
//}
//
//extension EnvironmentValues {
//    var ratingStyles: [any RatingStyle] {
//        get { self[RatingStylesEnvironmentKey.self] }
//        set { self[RatingStylesEnvironmentKey.self] = newValue }
//    }
//}
//
//struct RatingStyleModifier<S: RatingStyle>: ViewModifier {
//    @Environment(\.ratingStyles) var styles
//    var style: S
//    func body(content: Content) -> some View {
//        content.environment(\.ratingStyles, styles + [style])
//    }
//}
//
//extension View {
//    public func ratingStyle<S>(_ style: S) -> some View where S : RatingStyle {
//        self.modifier(RatingStyleModifier(style: style))
//    }
//}
//
//public struct Rating<V: BinaryFloatingPoint, Star: View>: View {
//    
//    @Environment(\.ratingStyles) var ratingStyles
//    
//    private var configuration: RatingStyleConfiguration<V, Star>
//    
//    var drag: some Gesture {
//        DragGesture(minimumDistance: 0)
//            .onChanged { value in
//                let starWidth = 19.5
//                self.configuration.value = V((value.location.x / starWidth) + 1)
//            }
//    }
//    
//    public init(
//        value: Binding<V>,
//        spacing: CGFloat? = nil,
//        count: Int = 5,
//        @ViewBuilder starContent: @escaping (Int, V) -> Star = { (i: Int, v: V) in Image(systemName: "star") }
//    ) {
//        precondition(count >= 0)
//        self.configuration = .init(
//            value: value,
//            spacing: spacing,
//            count: count,
//            starContent: starContent
//        )
//    }
//    
//    public var body: some View {
//        let style = ratingStyles[ratingStyles.count - configuration.styleLevel]
//        AnyView(style.makeBody(configuration: configuration))
//            .gesture(drag)
//    }
//}
//
//extension Rating {
//    public init(_ configuration: RatingStyleConfiguration<V, Star>) {
//        self.configuration = configuration
//        self.configuration.styleLevel += 1
//    }
//}
//
//extension RatingStyle where Self == SystemImageRatingStyle {
//    public static var star: SystemImageRatingStyle {
//        SystemImageRatingStyle(systemImage: "star")
//    }
//
//    public static var circle: SystemImageRatingStyle {
//        SystemImageRatingStyle(systemImage: "circle")
//    }
//}
//
