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
    @State private var xPos: CGFloat = 0
    @State private var width: CGFloat = 0
    @State private var starWidth: CGFloat = 0
    
    private var spacing: CGFloat = 10
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                xPos = value.location.x
                let realValue = (xPos / (starWidth + spacing)) + 1
                self.value = max(1, realValue)
            }
    }
    
    var body: some View {
        VStack {
            Text("X: \(xPos)")
            Text("Width: \(width)")
            Text("Star width: \(starWidth)")
            HStack(spacing: spacing) {
                ForEach(0 ..< 5, id: \.self) { i in
                    let isFilled = i < Int(value)
                    ZStack {
                        Image(systemName: isFilled ? "star.fill" : "star")
                    }
                        .overlay(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        starWidth = geo.size.width
                                    }
                            }
                        )
                }
            }
            .border(.red)
            .gesture(drag)
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            width = geo.size.width
                        }
                }
            )
        }
    
//            .frame(width: 130, height: 20)
//        }
        
//        Rating(value: $value)
//            .ratingStarStyle(.shadowed)
//            .ratingStarStyle(.circle)
//            .ratingStyle(.vertical)
//        
//        Rating(value: $value, count: 6) {
//            StarShapeView()
//                .shadow(radius: 3)
//        }
    }
}

#Preview {
    RatingDemo()
        .padding()
}
