//
//  RatingStar.swift
//  StarRating
//
//  Created by Jeremy Cook on 12/23/23.
//

import SwiftUI

struct StarParameters {
    struct Segment {
        let line: CGPoint
        let curve: CGPoint
        let control: CGPoint
    }

    static let adjustment: CGFloat = 0.085

    static let start = Segment(
        line:    CGPoint(x: 0.50, y: 0.4),
        curve:   CGPoint(x: 0.0, y: 0.0),
        control: CGPoint(x: 0.0, y: 0.0)
    )
    
    static let segments = [
        Segment(
            line:    CGPoint(x: 0.60, y: 0.05),
            curve:   CGPoint(x: 0.40, y: 0.05),
            control: CGPoint(x: 0.50, y: 0.00)
        ),
        Segment(
            line:    CGPoint(x: 0.05, y: 0.20 + adjustment),
            curve:   CGPoint(x: 0.00, y: 0.30 + adjustment),
            control: CGPoint(x: 0.00, y: 0.25 + adjustment)
        ),
        Segment(
            line:    CGPoint(x: 0.00, y: 0.70 - adjustment),
            curve:   CGPoint(x: 0.05, y: 0.80 - adjustment),
            control: CGPoint(x: 0.00, y: 0.75 - adjustment)
        ),
        Segment(
            line:    CGPoint(x: 0.40, y: 0.95),
            curve:   CGPoint(x: 0.60, y: 0.95),
            control: CGPoint(x: 0.50, y: 1.00)
        ),
        Segment(
            line:    CGPoint(x: 0.95, y: 0.80 - adjustment),
            curve:   CGPoint(x: 1.00, y: 0.70 - adjustment),
            control: CGPoint(x: 1.00, y: 0.75 - adjustment)
        ),
        Segment(
            line:    CGPoint(x: 1.00, y: 0.30 + adjustment),
            curve:   CGPoint(x: 0.95, y: 0.20 + adjustment),
            control: CGPoint(x: 1.00, y: 0.25 + adjustment)
        )
    ]
}

struct Star: Shape {
    struct StarPoint {
        var center: CGPoint
        var width: CGFloat
        var height: CGFloat
        init(center: CGPoint, width: CGFloat) {
            self.center = center
            self.width = width
            self.height = 0.95513 * width
        }
        
        func point(r: Double, at degrees: Double) -> CGPoint {
            let angle: Double = Angle(degrees: degrees).radians
            let realR = r * width
            let offset = CGPoint(x: realR * cos(angle), y: realR * sin(angle))
            let result = CGPoint(x: center.x * width + offset.x, y: center.y * height + offset.y)
            return result
        }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            var width: CGFloat = 780
            let height: CGFloat = 0.95513 * width
            
            let sp = StarPoint(center: CGPoint(x: 0.5, y: 0.549), width: width)
            
            // Center of star
            path.move(
                to: CGPoint(
                    x: 0.5 * width,
                    y: 0.549 * height
                )
            )
            
            path.addLine(
                to: sp.point(r: 0.49, at: -23.25)
            )
            
            path.addLine(
                to: CGPoint(
                    x: 0.64 * width,
                    y: 0.347 * height
                )
            )
            
            path.addLine(
                to: CGPoint(
                    x: 0.549 * width,
                    y: 0.05 * height
                )
            )
            
            let deltaWidth: CGFloat = 0.03
            let deltaHeight: CGFloat = 0.015
            path.addCurve(
                to: CGPoint(
                    x: 0.451 * width,
                    y: 0.05 * height
                ),
                control1: CGPoint(
                    x: (0.5 + deltaWidth) * width,
                    y: (0.0 - deltaHeight) * height
                ),
                control2: CGPoint(
                    x: (0.5 - deltaWidth) * width,
                    y: (0.0 - deltaHeight)  * height
                )
            )
            
            path.addLine(
                to: CGPoint(
                    x: 0.36 * width,
                    y: 0.347 * height
                )
            )
            
            path.addLine(
                to: CGPoint(
                    x: 0.06 * width,
                    y: 0.346 * height
                )
            )
            
            path.addLine(
                to: CGPoint(
                    x: 0.03 * width,
                    y: 0.44 * height
                )
            )
            
            path.addLine(
                to: CGPoint(
                    x: 0.5 * width,
                    y: 0.5 * height
                )
            )
            
            
//            path.addLine(to: point(at: -90, in: rect))
//            path.addQuadCurve(to: point(at: -90, in: rect), control: CGPoint(x: 200, y: -10))
//            path.addLine(to: point(at: -162, in: rect))
//            path.addLine(to: point(at: -234, in: rect))
//            path.addLine(to: point(at: -306, in: rect))
            
//            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
//            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
//            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
//            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
    }
}

struct RatingStar: View {
    var body: some View {
        ZStack {
            Image(systemName: "star")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
//            Image(systemName: "star")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .rotationEffect(Angle(degrees: 36))
//                .offset(x: 18, y: 21)
            
//            Rectangle()
//                .frame(width: 783, height: 750)
//                .foregroundStyle(.clear)
//                .border(.blue)
//                .frame(width: 800, alignment: .leading)
//                .frame(height: 775, alignment: .top)
//                .aspectRatio(1, contentMode: .fit)
            
            Star()
                .fill(.blue.opacity(0.5))
                .frame(width: 780, height: 745)
//                .rotationEffect(Angle(degrees: 72), anchor: .init(x: 0.5, y: 0.549))
                .border(.red)
                .frame(width: 794, alignment: .leading)
                .frame(height: 775, alignment: .top)
            
//            Star()
//                .fill(.blue.opacity(0.5))
//                .frame(width: 780, height: 745)
//                .rotationEffect(Angle(degrees: 144), anchor: .init(x: 0.5, y: 0.549))
//                .border(.red)
//                .frame(width: 794, alignment: .leading)
//                .frame(height: 775, alignment: .top)
//            
//            Star()
//                .fill(.blue.opacity(0.5))
//                .frame(width: 780, height: 745)
//                .rotationEffect(Angle(degrees: 216), anchor: .init(x: 0.5, y: 0.549))
//                .border(.red)
//                .frame(width: 794, alignment: .leading)
//                .frame(height: 775, alignment: .top)
//            
//            Star()
//                .fill(.blue.opacity(0.5))
//                .frame(width: 780, height: 745)
//                .rotationEffect(Angle(degrees: 288), anchor: .init(x: 0.5, y: 0.549))
//                .border(.red)
//                .frame(width: 794, alignment: .leading)
//                .frame(height: 775, alignment: .top)
//            
//            Star()
//                .fill(.blue.opacity(0.5))
//                .frame(width: 780, height: 745)
//                .rotationEffect(Angle(degrees: 0), anchor: .init(x: 0.5, y: 0.549))
//                .border(.red)
//                .frame(width: 794, alignment: .leading)
//                .frame(height: 775, alignment: .top)
            
            
        }
        .frame(width: 800, height: 775)
        .border(.green)
        .padding()
    }
}

#Preview {
    RatingStar()
}
