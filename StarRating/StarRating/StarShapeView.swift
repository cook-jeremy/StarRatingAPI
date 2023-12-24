//
//  StarShapeView.swift
//  StarRating
//
//  Created by Jeremy Cook on 12/23/23.
//

import SwiftUI

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
            let width: CGFloat = 780
            let height: CGFloat = 0.95513 * width
            
            let sp = StarPoint(center: CGPoint(x: 0.5, y: 0.549), width: width)
            
            // Center of star
            path.move(
                to: CGPoint(
                    x: 0.5 * width,
                    y: 0.549 * height
                )
            )
            
            let outToInAngleOffset: CGFloat = 30.5
            let tipAngleOffset: CGFloat = 11
            var armStartAngle: CGFloat = -23.5
            let bigArmLength: CGFloat = 0.485
            let smallArmLength: CGFloat = 0.238
            let angleOffset: CGFloat = 2.7
            let curveRadius: CGFloat = 0.537
            for _ in 0 ..< 5 {
                path.addLine(
                    to: sp.point(
                        r: bigArmLength,
                        at: armStartAngle
                    )
                )
                
                armStartAngle = armStartAngle - outToInAngleOffset
                path.addLine(
                    to: sp.point(
                        r: smallArmLength,
                        at: armStartAngle
                    )
                )
                
                armStartAngle = armStartAngle - outToInAngleOffset
                path.addLine(
                    to: sp.point(
                        r: bigArmLength,
                        at: armStartAngle
                    )
                )
                
                let midAngle = armStartAngle - tipAngleOffset / 2
                armStartAngle = armStartAngle - tipAngleOffset
                path.addCurve(
                    to: sp.point(r: bigArmLength, at: armStartAngle),
                    control1: sp.point(r: curveRadius, at: midAngle + angleOffset),
                    control2: sp.point(r: curveRadius, at: midAngle - angleOffset)
                )
            }
        }
    }
}

struct StarShapeView: View {
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
    StarShapeView()
}
