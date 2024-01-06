//
//  RatingDemo3.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/25/23.
//

import SwiftUI
import StarRating

//struct FloatingStarRatingStyle: RatingStyle {
//    func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
//        let percent = max(0, min(1, configuration.value - Double(index)))
//        StarShapeView(percent: CGFloat(percent))
//            .foregroundStyle(.orange)
//    }
//}

struct HalfStarRatingStyle: RatingStyle {
    func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
        Group {
            if index < Int(configuration.value) {
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if Double(index) <= configuration.value - 0.5 {
                Image(systemName: "star.leadinghalf.filled")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "star")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .foregroundStyle(.orange)
    }
}

struct RatingDemo3: View {
    
    @State private var value: Double = 3
    
    var body: some View {
        VStack {
            Text("Rating value: \(value)")
            
            Rating(value: $value, precision: 0.5, spacing: 10, count: 5)
                .ratingStyle(HalfStarRatingStyle())
//                .ratingStyle(FloatingStarRatingStyle())
        }
    }
}

#Preview {
    RatingDemo3()
        .padding(100)
}
