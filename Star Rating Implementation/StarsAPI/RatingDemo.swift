//
//  RatingDemo.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/23/23.
//

import SwiftUI
import StarRating

struct RatingDemo: View {
    
    enum Demo: String, CaseIterable, Identifiable {
        var id: Self { self }
        
        case `default` = "Default"
        case spacing = "Spacing"
        case count = "Count"
        case circleStyle = "Circle Style"
        case modifyStyle = "Modify Style"
        case sfSymbols = "SF Symbols"
        case precision = "Precision"
    }
    
    @State private var selection: Demo = .default
    
    var body: some View {
        VStack {
            Picker("Demo", selection: $selection) {
                ForEach(Demo.allCases) { demo in
                    Text(demo.rawValue)
                        .tag(demo.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Group {
                switch selection {
                case .default:
                    Default()
                case .count:
                    Count()
                case .spacing:
                    Spacing()
                case .circleStyle:
                    CircleStyle()
                case .modifyStyle:
                    ModifyStyle()
                case .sfSymbols:
                    SFSymbol()
                case .precision:
                    Precision()
                }
            }
            
            Spacer()
        }
    }
}

struct Default: View {
    @State private var value: Double = 3.0
    var body: some View {
        Rating(value: $value)
            .padding()
    }
}

struct Spacing: View {
    @State private var value: Double = 3.0
    var body: some View {
        ForEach(0 ..< 15) { i in
            Rating(value: $value, spacing: CGFloat(i))
        }
    }
}

struct Count: View {
    var body: some View {
        VStack {
            ForEach(0 ..< 7) { i in
                ForEach(0 ... i, id: \.self) { j in
                    Rating(value: .constant(Double(j)), count: i)
                }
            }
        }
        .padding()
    }
}

struct CircleStyle: View {
    var body: some View {
        VStack {
            Rating(value: .constant(1))
            Rating(value: .constant(2))
            Rating(value: .constant(3))
        }
        .ratingStyle(.circle)
        .padding()
    }
}

struct ColoredBorderRatingStyle: RatingStyle {
    var color: Color
    func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
        RatingStar(configuration, index: index)
            .padding()
            .border(color)
    }
}

struct ModifyStyle: View {
    var body: some View {
        Rating(value: .constant(3))
            .ratingStyle(ColoredBorderRatingStyle(color: .blue))
            .ratingStyle(ColoredBorderRatingStyle(color: .red))
            .ratingStyle(.circle)
            .padding()
    }
}

struct ScaledImageRatingStyle: RatingStyle {
    var systemName: String
    func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
        Image(systemName: index < Int(configuration.value) ? "\(systemName).fill" : systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct SFSymbol: View {
    @State private var value = 3.0
    var body: some View {
        VStack(spacing: 20) {
            Rating(value: $value)
                .ratingStyle(ScaledImageRatingStyle(systemName: "star"))
                .foregroundStyle(.blue)
            
            Rating(value: $value)
                .ratingStyle(ScaledImageRatingStyle(systemName: "heart"))
                .foregroundStyle(.red)
            
            Rating(value: $value)
                .ratingStyle(ScaledImageRatingStyle(systemName: "basketball"))
                .foregroundStyle(.orange)
            
            Rating(value: $value)
                .ratingStyle(ScaledImageRatingStyle(systemName: "tennisball"))
                .foregroundStyle(.yellow)
            
            Rating(value: $value)
                .ratingStyle(ScaledImageRatingStyle(systemName: "volleyball"))
                .foregroundStyle(.green)
        }
        .padding()
    }
}

struct FloatingStarRatingStyle: RatingStyle {
    func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
        let percent = max(0, min(1, configuration.value - Double(index)))
        StarShapeView(percent: CGFloat(percent))
            .foregroundStyle(.orange)
    }
}

struct Precision: View {
    @State private var value1 = 3.0
    @State private var value05 = 2.5
    @State private var value025 = 2.25
    @State private var value0 = 2.666
    
    var body: some View {
        Grid {
            GridRow {
                Text("Precision")
                Text("Drawing")
                Text("Value")
            }
            .bold()
            GridRow {
                Text("1")
                Rating(value: $value1)
                Text("\(value1)")
            }
            GridRow {
                Text("0.5")
                Rating(value: $value05, precision: 0.5)
                Text("\(value05)")
            }
            GridRow {
                Text("0.25")
                Rating(value: $value025, precision: 0.25)
                Text("\(value025)")
            }
            GridRow {
                Text("0")
                Rating(value: $value0, precision: 0)
                Text("\(value0)")
            }
        }
        .ratingStyle(FloatingStarRatingStyle())
        .padding()
    }
}

#Preview {
    RatingDemo()
        .padding()
        .frame(height: 800)
}
