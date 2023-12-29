//
//  RatingDemo3.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/25/23.
//

import SwiftUI
import StarRating

struct FloatingStarRatingStyle: RatingStyle {
    func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
        let percent = max(0, min(1, configuration.value - Double(index)))
        StarShapeView(percent: CGFloat(percent))
            .animation(.easeInOut, value: configuration.value)
            .foregroundStyle(.orange)
    }
}

struct HalfStarRatingStyle: RatingStyle {
    func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
        let starIndex = Double(index + 1)
        Group {
            if configuration.value >= Double(starIndex) {
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if configuration.value + 0.5 >= Double(starIndex) {
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
            
            Button(action: {
                value = Double.random(in: 0 ..< 5)
            }, label: {
                Text("Change Value")
            })
            
            Rating(value: $value, precision: 0.5, spacing: 10, count: 5)
                .animation(.easeInOut, value: value)
//                .ratingStyle(HalfStarRatingStyle())
                .ratingStyle(FloatingStarRatingStyle())
        }
    }
}

#Preview {
    RatingDemo3()
        .padding(100)
}
