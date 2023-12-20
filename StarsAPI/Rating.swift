//
//  Rating.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/7/23.
//

import SwiftUI

struct RatingStyleConfiguration<Value: BinaryFloatingPoint> {
    @Binding var value: Value
    var spacing: CGFloat?
    var count: Int
}

protocol RatingStyle {
    @ViewBuilder 
    func makeBody<V: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<V>) -> AnyView
}

struct SystemImageRatingStyle: RatingStyle {
    var systemImage: String
    
    @ViewBuilder
    func makeBody<V: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<V>) -> AnyView {
        AnyView(
            HStack(spacing: configuration.spacing) {
                ForEach(0 ..< configuration.count, id: \.self) { i in
                    let isFilled = i < Int(configuration.value)
                    Image(systemName: isFilled ? "\(systemImage).fill" : systemImage)
                        .onTapGesture {
                            configuration.value = V(i + 1)
                        }
                }
            }
        )
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

struct Rating<Value: BinaryFloatingPoint>: View {
    
    @Environment(\.ratingStyle) var myStyle
    
    private var configuration: RatingStyleConfiguration<Value>
    
    init(
        value: Binding<Value>,
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
    
    var body: some View {
        myStyle.makeBody(configuration: configuration)
    }
}

extension Rating {
    init(_ configuration: RatingStyleConfiguration<Value>) {
        self.configuration = configuration
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

struct RedBorderRatingStyle: RatingStyle {
    func makeBody<V: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<V>) -> AnyView {
        AnyView(
            Rating(configuration)
                .padding()
                .border(.red)
        )
    }
}

#Preview("Extend Existing Style") {
    Rating(value: .constant(3))
        .ratingStyle(RedBorderRatingStyle())
        .ratingStyle(.circle)
}

struct ResizableRatingStyle: RatingStyle {
    func makeBody<V: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<V>) -> AnyView {
        AnyView(
            HStack(spacing: configuration.spacing) {
                ForEach(0 ..< configuration.count, id: \.self) { i in
                    let isFilled = V(i) < configuration.value
                    Image(systemName: isFilled ? "star.fill" : "star")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        )
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

struct HalfStarRatingStyle: RatingStyle {
    func makeBody<V: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<V>) -> AnyView {
        AnyView(
            HStack(spacing: configuration.spacing) {
                ForEach(0 ..< configuration.count, id: \.self) { i in
                    let starIndex = Double(i + 1)
                    Group {
                        if configuration.value >= V(starIndex) {
                            Image(systemName: "star.fill")
                        } else if configuration.value + 0.5 >= V(starIndex) {
                            Image(systemName: "star.leadinghalf.filled")
                        } else {
                            Image(systemName: "star")
                        }
                    }
                    .foregroundStyle(.orange)
                    .onTapGesture {
                        configuration.value = V(starIndex)
                    }
                }
            }
        )
    }
}

#Preview("Half-Star Rating") {
    ForEach(0 ..< 11) { i in
        Rating(value: .constant(Double(i) / 2))
    }
    .ratingStyle(HalfStarRatingStyle())
}

struct FPSquareRatingStyle: RatingStyle {
    func makeBody<V: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<V>) -> AnyView {
        AnyView(
            HStack(spacing: configuration.spacing) {
                ForEach(0 ..< configuration.count, id: \.self) { i in
                    let percent: V = configuration.value - V(i)
                    let minMax: V = min(1.0, max(0.0, percent))
                    FloatingPointSquare(percent: Double(minMax))
                }
            }
        )
    }
}

#Preview("Floating Point Square Rating") {
    Grid {
        ForEach(0 ..< 26) { i in
            let value: Double = Double(i) / 5
            GridRow {
                Text("value: \(value)")
                Rating(value: .constant(value))
            }
        }
    }
    .ratingStyle(FPSquareRatingStyle())
    .frame(height: 1000)
    .padding()
}
