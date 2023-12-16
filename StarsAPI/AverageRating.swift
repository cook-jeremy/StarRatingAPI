////
////  AverageRating.swift
////  StarsAPI
////
////  Created by Jeremy Cook on 12/10/23.
////
////
//import SwiftUI
//
//public struct AverageRatingStyleConfiguration<V: BinaryFloatingPoint> {
//    public var starIndex: Int
//    public var value: V
//    public var count: Int
//    public var fillPercentage: V {
//        value - V(starIndex + 1)
//    }
//}
//
//protocol AverageRatingStyle {
//    associatedtype Body: View
//    associatedtype Value: BinaryFloatingPoint
//    typealias Configuration = AverageRatingStyleConfiguration<Value>
//    @ViewBuilder func makeBody(configuration: Configuration) -> Body
//}
//
//struct SystemImageAverageRatingStyle: AverageRatingStyle {
//    typealias Value = Double
//
//    var systemImage: String
//    
//    func makeBody(configuration: Configuration) -> some View {
//        Image(systemName: configuration.fillPercentage == 1 ? "\(systemImage).fill" : systemImage)
//    }
//}
//
//extension AverageRatingStyle where Self == SystemImageAverageRatingStyle {
//    static var star: SystemImageAverageRatingStyle {
//        SystemImageAverageRatingStyle(systemImage: "star")
//    }
//    
//    static var circle: SystemImageAverageRatingStyle {
//        SystemImageAverageRatingStyle(systemImage: "circle")
//    }
//}
//
//struct AverageRatingStyleEnvironmentKey: EnvironmentKey {
//    static let defaultValue: any AverageRatingStyle = SystemImageAverageRatingStyle(systemImage: "star")
//}
//
//extension EnvironmentValues {
//    var averageRatingStyle: any AverageRatingStyle {
//        get { self[AverageRatingStyleEnvironmentKey.self] }
//        set { self[AverageRatingStyleEnvironmentKey.self] = newValue }
//    }
//}
//
//struct AverageRating: View {
//    
//    @Environment(\.averageRatingStyle) var averageStyle
//    
//    private var value: any BinaryFloatingPoint
//    private var count: Int
//    private var spacing: CGFloat?
//    
//    init<V>(
//        value: V,
//        spacing: CGFloat? = nil,
//        count: Int = 5
//    ) where V: BinaryFloatingPoint {
//        precondition(count >= 0)
//        self.value = value
//        self.spacing = spacing
//        self.count = count
//    }
//    
//    var body: some View {
//        HStack(spacing: spacing) {
//            ForEach(0 ..< count, id: \.self) { i in
//                AnyView(averageStyle.makeBody(configuration: .init(starIndex: i, value: value, count: count)))
//            }
//        }
//    }
//}
//
//struct AverageRatingStyleModifier<S: AverageRatingStyle>: ViewModifier {
//    var style: S
//    func body(content: Content) -> some View {
//        content.environment(\.averageRatingStyle, style)
//    }
//}
//
//extension View {
//    func ratingStyle<S>(_ style: S) -> some View where S : AverageRatingStyle {
//        return self.modifier(AverageRatingStyleModifier(style: style))
//    }
//}
