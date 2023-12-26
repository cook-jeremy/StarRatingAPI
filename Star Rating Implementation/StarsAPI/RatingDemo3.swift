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
        VStack {
            Text("P: \(Double(percent))")
            StarShapeView(percent: CGFloat(percent), outerStyle: .black)
                .border(.red)
        }
    }
}

struct RatingDemo3: View {
    
    @State private var value: Double = 3
    
    var body: some View {
        Rating(value: $value, precision: 0, spacing: 10, count: 5)
            .ratingStyle(FloatingStarRatingStyle())
            .foregroundStyle(.orange)
    }
}

#Preview {
    RatingDemo3()
        .padding()
}
