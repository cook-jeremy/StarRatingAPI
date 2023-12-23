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
    }
}

#Preview {
    RatingDemo()
        .padding()
}
