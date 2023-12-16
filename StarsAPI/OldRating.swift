////
////  Rating.swift
////  StarsAPI
////
////  Created by Jeremy Cook on 12/7/23.
////
//
//import SwiftUI
//
//public struct RatingStyleConfiguration {
//    public var starIndex: Int
//    @Binding public var value: Int
//    public var count: Int
//    public var isFilled: Bool {
//        (starIndex + 1) <= value
//    }
//}
//
//protocol RatingStyle {
//    associatedtype Body: View
//    typealias Configuration = RatingStyleConfiguration
//    @ViewBuilder func makeBody(configuration: Configuration) -> Body
//}
//
//struct SystemImageRatingStyle: RatingStyle {
//    var systemImage: String
//    
//    func makeBody(configuration: Configuration) -> some View {
//        Image(systemName: configuration.isFilled ? "\(systemImage).fill" : systemImage)
//            .onTapGesture {
//                configuration.value = configuration.starIndex + 1
//            }
//    }
//}
//
//extension RatingStyle where Self == SystemImageRatingStyle {
//    static var star: SystemImageRatingStyle {
//        SystemImageRatingStyle(systemImage: "star")
//    }
//    
//    static var circle: SystemImageRatingStyle {
//        SystemImageRatingStyle(systemImage: "circle")
//    }
//}
//
//struct RatingStyleEnvironmentKey: EnvironmentKey {
//    static let defaultValue: any RatingStyle = SystemImageRatingStyle(systemImage: "star")
//}
//
//extension EnvironmentValues {
//    var ratingStyle: any RatingStyle {
//        get { self[RatingStyleEnvironmentKey.self] }
//        set { self[RatingStyleEnvironmentKey.self] = newValue }
//    }
//}
//
//struct Rating: View {
//    
//    @Environment(\.ratingStyle) var myStyle
//    
//    @Binding var value: Int
//    private var count: Int
//    private var spacing: CGFloat?
//    
//    init(
//        value: Binding<Int>,
//        spacing: CGFloat? = nil,
//        count: Int = 5
//    ) {
//        precondition(count >= 0)
//        self._value = value
//        self.spacing = spacing
//        self.count = count
//    }
//    
//    var body: some View {
//        HStack(spacing: spacing) {
//            ForEach(0 ..< count, id: \.self) { i in
//                AnyView(myStyle.makeBody(configuration: .init(starIndex: i, value: $value, count: count)))
//            }
//        }
//    }
//}
//
//struct RatingStyleModifier<S: RatingStyle>: ViewModifier {
//    var style: S
//    func body(content: Content) -> some View {
//        content.environment(\.ratingStyle, style)
//    }
//}
//
//extension View {
//    func ratingStyle<S>(_ style: S) -> some View where S : RatingStyle {
//        return self.modifier(RatingStyleModifier(style: style))
//    }
//}
//
//
//// TODO: Implement this
////extension Rating {
////    init(_ configuration: RatingStyleConfiguration) {
////        self.init(value: configuration.$value)
////    }
////}
//
//// MARK: - Previews
//
//#Preview("Default") {
//    Rating(value: .constant(3))
//        .padding()
//}
//
//#Preview("Count") {
//    VStack {
//        ForEach(0 ..< 7) { i in
//            ForEach(0 ... i, id: \.self) { j in
//                Rating(value: .constant(j), count: i)
//            }
//        }
//    }
//    .padding()
//}
//
//#Preview("Spacing") {
//    ForEach(0 ..< 15) { i in
//        Rating(value: .constant(3), spacing: CGFloat(i))
//    }
//}
//
//#Preview("Custom Style") {
//    VStack {
//        Rating(value: .constant(1))
//        Rating(value: .constant(2))
//        Rating(value: .constant(3))
//    }
//    .ratingStyle(.circle)
//    .padding()
//}
//
//struct ResizableRatingStyle: RatingStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        Image(systemName: configuration.isFilled ? "star.fill" : "star")
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//    }
//}
//
//#Preview("Bigger Frame") {
//    Rating(value: .constant(3))
//        .ratingStyle(ResizableRatingStyle())
//    .border(.blue)
//    .frame(width: 500, height: 200)
//    .border(.red)
//    .padding()
//}
//
//#Preview("Control Sizes") {
//    Grid {
//        GridRow {
//            Text("mini")
//            Rating(value: .constant(3))
//                .controlSize(.mini)
//        }
//        GridRow {
//            Text("small")
//            Rating(value: .constant(3))
//                .controlSize(.small)
//        }
//        GridRow {
//            Text("regular")
//            Rating(value: .constant(3))
//                .controlSize(.regular)
//        }
//        GridRow {
//            Text("large")
//            Rating(value: .constant(3))
//                .controlSize(.large)
//        }
//        GridRow {
//            Text("extraLarge")
//            Rating(value: .constant(3))
//                .controlSize(.extraLarge)
//        }
//    }
//    .padding()
//}
//
//
//#Preview("SF Symbols") {
//    VStack(spacing: 10) {
//        Rating(value: .constant(3))
//            .ratingStyle(SystemImageRatingStyle(systemImage: "trophy"))
//            .foregroundColor(.yellow)
//        
//        Rating(value: .constant(3))
//            .ratingStyle(SystemImageRatingStyle(systemImage: "volleyball"))
//            .foregroundStyle(.green)
//        
//        Rating(value: .constant(3))
//            .ratingStyle(SystemImageRatingStyle(systemImage: "wineglass"))
//            .foregroundStyle(.red)
//        
//        Rating(value: .constant(3))
//            .ratingStyle(SystemImageRatingStyle(systemImage: "basketball"))
//            .foregroundStyle(.orange)
//    }
//    .padding()
//}
//
//struct InteractiveRatingView: View {
//    @State private var value = 0
//    
//    var body: some View {
//        Rating(value: $value)
//            .foregroundColor(.orange)
//    }
//}
//
//#Preview("Interactive") {
//    InteractiveRatingView()
//        .padding()
//}
