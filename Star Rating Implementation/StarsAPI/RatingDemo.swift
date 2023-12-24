//
//  RatingDemo.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/23/23.
//

import SwiftUI
import StarRating

struct RatingDemo: View {
    @State private var value: Double = 2.0
    
    var body: some View {
        VStack {
            Rating(value: $value)
        }
        .padding()
        
//        Rating(value: $value)
//            .ratingStarStyle(.shadowed)
//            .ratingStarStyle(.circle)
//            .ratingStyle(.vertical)
//        
//        Rating(value: $value, count: 6) {
//            RatingStar()
//                .shadow(radius: 3)
//        }
    }
}

#Preview {
    RatingDemo()
        .padding()
}
