//
//  ParameterDemo.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 1/8/24.
//

import SwiftUI
import StarRating

struct ParameterDemo: View {
    
    @State private var value: Double = 2.5
    @State private var granularity: CGFloat = 1
    @State private var spacing: CGFloat = 10
    @State private var count: Int = 5
    @State private var style: String = "circle"
    
    private let styleDict: [String: some RatingStyle] = [
        "circle" : .circle,
        "star" : .star
    ]
    
    var body: some View {
        Grid {
            
            GridRow {
                Text("Parameters")
                Text("Rating View")
            }
            .bold()
            
            GridRow {
                // MARK: Parameters
                Grid {
                    GridRow {
                        Text("Spacing:")
                            .bold()
                        Stepper("\(spacing)", value: $spacing, in: 0...100)
                            .fixedSize()
                    }
                    
                    GridRow {
                        Text("Count:")
                            .bold()
                        Stepper("\(count)", value: $count, in: 1...100)
                            .fixedSize()
                    }
                    
                    GridRow {
                        Text("Style:")
                            .bold()
                        Picker("", selection: $style) {
                            Text("Circle")
                                .tag("circle")
                            Text("Star")
                                .tag("star")
                        }
                    }
                }
                .frame(width: 200)
                .padding()
                
                // MARK: View
                Rating(value: $value,
                       granularity: granularity,
                       spacing: spacing,
                       count: count)
                .ratingStyle(styleDict[style]!)
            }
        }
    }
}

#Preview {
    ParameterDemo()
        .padding()
}
