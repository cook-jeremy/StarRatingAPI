////
////  RatingPreviews.swift
////  StarRating
////
////  Created by Jeremy Cook on 12/23/23.
////
//
//import SwiftUI
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
//                Rating(value: .constant(Double(j)), count: i)
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
//struct ColoredBorderRatingStyle: RatingStyle {
//    var color: Color
//    func makeBody<V: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<V>) -> any View {
//        Rating(configuration)
//            .padding()
//            .border(color)
//    }
//}
//
//#Preview("Extend Existing Style") {
//    Rating(value: .constant(3))
//        .ratingStyle(ColoredBorderRatingStyle(color: .blue))
//        .ratingStyle(ColoredBorderRatingStyle(color: .red))
//        .ratingStyle(.circle)
//        .padding()
//}
//
//struct ResizableRatingStyle: RatingStyle {
//    func makeBody<V: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<V>) -> any View {
//        HStack(spacing: configuration.spacing) {
//            ForEach(0 ..< configuration.count, id: \.self) { i in
//                let isFilled = V(i) < configuration.value
//                Image(systemName: isFilled ? "star.fill" : "star")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//            }
//        }
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
//    @State private var value: Double = 0.0
//    
//    @State private var value2: Float = 0.0
//    
//    var body: some View {
//        VStack {
//            Rating(value: $value)
//                .foregroundColor(.orange)
//            
//            Rating(value: $value2)
//                .foregroundColor(.blue)
//        }
//        .ratingStyle(.circle)
//    }
//}
//
//#Preview("Interactive") {
//    InteractiveRatingView()
//        .padding()
//}
//
//struct HalfStarRatingStyle: RatingStyle {
//    func makeBody<V: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<V>) -> any View {
//        HStack(spacing: configuration.spacing) {
//            ForEach(0 ..< configuration.count, id: \.self) { i in
//                let starIndex = Double(i + 1)
//                Group {
//                    if configuration.value >= V(starIndex) {
//                        Image(systemName: "star.fill")
//                    } else if configuration.value + 0.5 >= V(starIndex) {
//                        Image(systemName: "star.leadinghalf.filled")
//                    } else {
//                        Image(systemName: "star")
//                    }
//                }
//                .foregroundStyle(.orange)
//                .onTapGesture {
//                    configuration.value = V(starIndex)
//                }
//            }
//        }
//    }
//}
//
//#Preview("Half-Star Rating") {
//    VStack {
//        ForEach(0 ..< 11) { i in
//            Rating(value: .constant(Double(i) / 2))
//        }
//        .ratingStyle(HalfStarRatingStyle())
//    }
//    .padding()
//}
//
//struct FPSquareRatingStyle: RatingStyle {
//    func makeBody<V: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<V>) -> any View {
//        HStack(spacing: configuration.spacing) {
//            ForEach(0 ..< configuration.count, id: \.self) { i in
//                let percent: V = configuration.value - V(i)
//                let minMax: V = min(1.0, max(0.0, percent))
//                FloatingPointSquare(percent: Double(minMax))
//            }
//        }
//    }
//}
//
//#Preview("Floating Point Square Rating") {
//    Grid {
//        ForEach(0 ..< 26) { i in
//            let value: Double = Double(i) / 5
//            GridRow {
//                Text("value: \(value)")
//                Rating(value: .constant(value))
//            }
//        }
//    }
//    .ratingStyle(FPSquareRatingStyle())
//    .frame(height: 700)
//    .padding()
//}
