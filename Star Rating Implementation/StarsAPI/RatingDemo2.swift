//
//  RatingDemo2.swift
//  StarRating
//
//  Created by Jeremy Cook on 12/24/23.
//

import SwiftUI
import StarRating

struct CircleRatingStyle: RatingStyle {
    func makeStar(configuration: RatingStyleConfiguration<some BinaryFloatingPoint>, index: Int) -> any View {
        let isFilled = Int(configuration.value) > index
        Image(systemName: isFilled ? "circle.fill" : "circle")
            .foregroundStyle(.orange)
    }
}

struct RatingDemo2: View {
    
    @State private var value: Double = 0
    
    var body: some View {
        Rating(value: $value)
            .ratingStyle(CircleRatingStyle())
    }
}

#Preview {
    RatingDemo2()
        .padding()
}
