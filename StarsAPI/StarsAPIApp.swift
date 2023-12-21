//
//  StarsAPIApp.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/7/23.
//

import SwiftUI

@main
struct StarsAPIApp: App {
    var body: some Scene {
        WindowGroup {
            Rating(value: .constant(3))
                .ratingStyle(ColoredBorderRatingStyle(color: .blue))
                .ratingStyle(ColoredBorderRatingStyle(color: .red))
                .ratingStyle(.circle)
        }
    }
}
