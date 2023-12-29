////
////  RatingDemo2.swift
////  StarRating
////
////  Created by Jeremy Cook on 12/24/23.
////
//
//import SwiftUI
//import StarRating
//
//struct ColoredBorderRatingStyle: RatingStyle {
//    var color: Color
//    func makeBody(configuration: RatingStyleConfiguration<some BinaryFloatingPoint>, index: Int) -> any View {
//        RatingStar(configuration, index: index)
//            .padding(3)
//            .border(color)
//    }
//}
//
//struct RatingDemo2: View {
//    
//    @State private var value: Double = 5
//    
//    var body: some View {
//        VStack {
//            Rating(value: $value, count: 10)
//            
//            VStack {
//                Rating(value: $value, count: 10)
//            }
////            .ratingStyle(ColoredBorderRatingStyle(color: .red))
//        }
////        .ratingStyle(ColoredBorderRatingStyle(color: .blue))
//        .ratingStyle(.star)
//        .foregroundStyle(.orange)
//    }
//}
//
//#Preview {
//    RatingDemo2()
//        .padding()
//}
