//
//  FloatingPointSquare.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/16/23.
//

import SwiftUI

struct SquareCutout: Shape {
    
    let percent: Double
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
    }
}

struct MaskRectangle: Shape {
    var percent: Double

    func path(in rect: CGRect) -> Path {
        let width = rect.width * CGFloat(percent)
        return Rectangle().path(in: CGRect(x: rect.minX, y: rect.minY, width: width, height: rect.height))
    }
}

struct FloatingPointSquare: View {
    let percent: Double
    
    var body: some View {
        Rectangle()
            .foregroundStyle(.orange)
            .aspectRatio(1, contentMode: .fit)
//            .mask(MaskRectangle(percent: percent))
            .border(.black)
    }
}

#Preview {
    VStack {
        ForEach(0 ..< 11) { i in
            let percent = Double(i) / 10
            HStack {
                Text("\(percent)")
                FloatingPointSquare(percent: percent)
            }
        }
    }
}
