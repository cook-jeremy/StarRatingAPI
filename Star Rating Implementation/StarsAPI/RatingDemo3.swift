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

struct RatingDemo3: View {
    
    @State private var value: Double = 3
    
    var body: some View {
        Rating(value: $value, precision: 0.5, spacing: 10, count: 5)
            .ratingStyle(FloatingStarRatingStyle())
    }
}

#Preview {
    RatingDemo3()
        .padding()
}
