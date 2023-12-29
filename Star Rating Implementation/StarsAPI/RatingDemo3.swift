//
//  RatingDemo3.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/25/23.
//

import SwiftUI
import StarRating

struct FloatingStarRatingStyle: RatingStyle {
    func makeStar<V: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<V>, index: Int) -> any View {
        let percent = max(0, min(1, configuration.value - V(index)))
        StarShapeView(percent: CGFloat(percent))
            .foregroundStyle(.orange)
    }
}

struct HalfStarRatingStyle: RatingStyle {
    func makeStar<V: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<V>, index: Int) -> any View {
        let starIndex = Double(index + 1)
        Group {
            if configuration.value >= V(starIndex) {
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if configuration.value + 0.5 >= V(starIndex) {
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
        Rating(value: $value, precision: 0.5, spacing: 10, count: 5)
            .ratingStyle(HalfStarRatingStyle())
//            .ratingStyle(FloatingStarRatingStyle())
    }
}

#Preview {
    RatingDemo3()
        .padding()
}
