//
//  Rating.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/7/23.
//

import SwiftUI

public struct RatingStyleConfiguration {
    @Binding public var value: Double
    public var spacing: CGFloat?
    public var count: Int
}

protocol RatingStyle {
    associatedtype Body: View
    typealias Configuration = RatingStyleConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

struct SystemImageRatingStyle: RatingStyle {
    var systemImage: String
    
    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: configuration.spacing) {
            ForEach(0 ..< configuration.count, id: \.self) { i in
                let isFilled = Double(i) < configuration.value
                Image(systemName: isFilled ? "\(systemImage).fill" : systemImage)
                    .onTapGesture {
                        configuration.value = Double(i + 1)
                    }
            }
        }
    }
}

extension RatingStyle where Self == SystemImageRatingStyle {
    static var star: SystemImageRatingStyle {
        SystemImageRatingStyle(systemImage: "star")
    }
    
    static var circle: SystemImageRatingStyle {
        SystemImageRatingStyle(systemImage: "circle")
    }
}

struct RatingStyleEnvironmentKey: EnvironmentKey {
    static let defaultValue: any RatingStyle = SystemImageRatingStyle(systemImage: "star")
}

extension EnvironmentValues {
    var ratingStyle: any RatingStyle {
        get { self[RatingStyleEnvironmentKey.self] }
        set { self[RatingStyleEnvironmentKey.self] = newValue }
    }
}

struct Rating: View {
    
    @Environment(\.ratingStyle) var myStyle
    
    @Binding var value: Double
    private var count: Int
    private var spacing: CGFloat?
    
    init<V>(
        value: Binding<V>,
        spacing: CGFloat? = nil,
        count: Int = 5
    ) where V: BinaryFloatingPoint {
        precondition(count >= 0)
        self._value = Binding<Double>(
            get: { Double(value.wrappedValue) },
            set: { value.wrappedValue = V($0) }
        )
        self.spacing = spacing
        self.count = count
    }
    
    var body: some View {
        AnyView(
            myStyle.makeBody(
                configuration: .init(
                    value: $value,
                    spacing: spacing,
                    count: count
                )
            )
        )
    }
}

struct RatingStyleModifier<S: RatingStyle>: ViewModifier {
    var style: S
    func body(content: Content) -> some View {
        content.environment(\.ratingStyle, style)
    }
}

extension View {
    func ratingStyle<S>(_ style: S) -> some View where S : RatingStyle {
        return self.modifier(RatingStyleModifier(style: style))
    }
}


// TODO: Implement this
//extension Rating {
//    init(_ configuration: RatingStyleConfiguration) {
//        self.init(value: configuration.$value)
//    }
//}

// MARK: - Previews

#Preview("Default") {
    Rating(value: .constant(3))
        .padding()
}

#Preview("Count") {
    VStack {
        ForEach(0 ..< 7) { i in
            ForEach(0 ... i, id: \.self) { j in
                Rating(value: .constant(Double(j)), count: i)
            }
        }
    }
    .padding()
}

#Preview("Spacing") {
    ForEach(0 ..< 15) { i in
        Rating(value: .constant(3), spacing: CGFloat(i))
    }
}

#Preview("Custom Style") {
    VStack {
        Rating(value: .constant(1))
        Rating(value: .constant(2))
        Rating(value: .constant(3))
    }
    .ratingStyle(.circle)
    .padding()
}

struct ResizableRatingStyle: RatingStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: configuration.spacing) {
            ForEach(0 ..< configuration.count, id: \.self) { i in
                let isFilled = Double(i) < configuration.value
                Image(systemName: isFilled ? "star.fill" : "star")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}

#Preview("Bigger Frame") {
    Rating(value: .constant(3))
        .ratingStyle(ResizableRatingStyle())
    .border(.blue)
    .frame(width: 500, height: 200)
    .border(.red)
    .padding()
}

#Preview("Control Sizes") {
    Grid {
        GridRow {
            Text("mini")
            Rating(value: .constant(3))
                .controlSize(.mini)
        }
        GridRow {
            Text("small")
            Rating(value: .constant(3))
                .controlSize(.small)
        }
        GridRow {
            Text("regular")
            Rating(value: .constant(3))
                .controlSize(.regular)
        }
        GridRow {
            Text("large")
            Rating(value: .constant(3))
                .controlSize(.large)
        }
        GridRow {
            Text("extraLarge")
            Rating(value: .constant(3))
                .controlSize(.extraLarge)
        }
    }
    .padding()
}


#Preview("SF Symbols") {
    VStack(spacing: 10) {
        Rating(value: .constant(3))
            .ratingStyle(SystemImageRatingStyle(systemImage: "trophy"))
            .foregroundColor(.yellow)
        
        Rating(value: .constant(3))
            .ratingStyle(SystemImageRatingStyle(systemImage: "volleyball"))
            .foregroundStyle(.green)
        
        Rating(value: .constant(3))
            .ratingStyle(SystemImageRatingStyle(systemImage: "wineglass"))
            .foregroundStyle(.red)
        
        Rating(value: .constant(3))
            .ratingStyle(SystemImageRatingStyle(systemImage: "basketball"))
            .foregroundStyle(.orange)
    }
    .padding()
}

struct InteractiveRatingView: View {
    @State private var value = 0.0
    
    var body: some View {
        Rating(value: $value)
            .foregroundColor(.orange)
    }
}

#Preview("Interactive") {
    InteractiveRatingView()
        .padding()
}

struct NonIntegerRatingStyle: RatingStyle {
    var systemImage: String
    
    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: configuration.spacing) {
            ForEach(0 ..< configuration.count, id: \.self) { i in
                let isFilled = Double(i) < configuration.value
                Image(systemName: isFilled ? "\(systemImage).fill" : systemImage)
                    .onTapGesture {
                        configuration.value = Double(i + 1)
                    }
            }
        }
    }
}

#Preview("Non-integer Rating") {
    Rating(value: .constant(3.5))
}
