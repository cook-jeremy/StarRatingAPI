//
//  RatingStar.swift
//  StarRating
//
//  Created by Jeremy Cook on 12/24/23.
//

import SwiftUI

public struct RatingStar<V: BinaryFloatingPoint>: View {
    
    @Environment(\.ratingStyles) var ratingStyles
    
    private var configuration: RatingStyleConfiguration
    
    private var index: Int
    
    private var style: any RatingStyle {
        ratingStyles[ratingStyles.count - configuration.styleRecursionLevel - 1]
    }
    
    public init(_ configuration: RatingStyleConfiguration, index: Int) {
        self.configuration = configuration
        self.configuration.styleRecursionLevel += 1
        self.index = index
    }
    
    public var body: some View {
        AnyView(
            style.makeBody(configuration: configuration, index: index)
        )
    }
}
