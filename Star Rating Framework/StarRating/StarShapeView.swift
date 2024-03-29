//
//  StarShapeView.swift
//  StarRating
//
//  Created by Jeremy Cook on 12/23/23.
//

import SwiftUI

struct StarPoint {
    let heightToWidthRatio = 0.95513
    let unitCenter: CGPoint = CGPoint(x: 0.5, y: 0.549)
    var center: CGPoint {
        CGPoint(
            x: unitCenter.x * width,
            y: unitCenter.y * height
        )
    }
    
    var width: CGFloat
    var height: CGFloat
    
    var centerOffset: CGPoint
    
    init(rect: CGRect) {
        let width: CGFloat = min(rect.width, rect.height * (1 / heightToWidthRatio))
        let height: CGFloat = heightToWidthRatio * width
        self.centerOffset = CGPoint(
            x: (rect.width - width) / 2,
            y: (rect.height - height) / 2
        )
        self.width = width
        self.height = height
    }
    
    func point(r: Double, at degrees: Double) -> CGPoint {
        let angle: Double = Angle(degrees: degrees).radians
        let realR = r * width
        let offset = CGPoint(x: realR * cos(angle), y: realR * sin(angle))
        let result = CGPoint(x: center.x + offset.x + centerOffset.x, y: center.y + offset.y + centerOffset.y)
        return result
    }
}

struct OuterStar: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let sp = StarPoint(rect: rect)
            
            // Center of star
            path.move(to: sp.center)
            
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

struct InnerStar: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let sp = StarPoint(rect: rect)
            
            // Center of star
            path.move(to: sp.center)
            
            var armStartAngle: CGFloat = -18.4
            let bigArmLength: CGFloat = 0.411
            
            let smallArmLength: CGFloat = 0.171
            let outToInAngleOffset: CGFloat = 28.2
            
            let tipAngleOffset: CGFloat = 14.8
            let angleOffset: CGFloat = 1.5
            let curveRadius: CGFloat = 0.158
            
            let tipAngleOffset2: CGFloat = 0.8
            let angleOffset2: CGFloat = 0.02
            let curveRadius2: CGFloat = 0.415
            
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
                
                let midAngle = armStartAngle - tipAngleOffset / 2
                armStartAngle = armStartAngle - tipAngleOffset
                path.addCurve(
                    to: sp.point(r: smallArmLength, at: armStartAngle),
                    control1: sp.point(r: curveRadius, at: midAngle + angleOffset),
                    control2: sp.point(r: curveRadius, at: midAngle - angleOffset)
                )
                
                armStartAngle = armStartAngle - outToInAngleOffset
                path.addLine(
                    to: sp.point(
                        r: bigArmLength,
                        at: armStartAngle
                    )
                )
                
                let midAngle2 = armStartAngle - tipAngleOffset2 / 2
                armStartAngle = armStartAngle - tipAngleOffset2
                path.addCurve(
                    to: sp.point(r: bigArmLength, at: armStartAngle),
                    control1: sp.point(r: curveRadius2, at: midAngle2 + angleOffset2),
                    control2: sp.point(r: curveRadius2, at: midAngle2 - angleOffset2)
                )
            }
        }
    }
}

struct PartialHorizontalRectangle: Shape {
    var percent: Double
    func path(in rect: CGRect) -> Path {
        let width = percent * rect.width
        return Rectangle().path(in: CGRect(x: rect.minX, y: rect.minY, width: width, height: rect.height))
    }
}

public struct StarShapeView<S1, S2>: View, Animatable where S1: ShapeStyle, S2: ShapeStyle {
    
    var percent: CGFloat
    var outerStyle: S1
    var innerStyle: S2
    
    public var animatableData: CGFloat {
        get { percent }
        set { percent = newValue }
    }
    
    public init(percent: CGFloat, outerStyle: S1 = .foreground, innerStyle: S2 = .foreground) {
        self.percent = percent
        self.outerStyle = outerStyle
        self.innerStyle = innerStyle
    }
    
    public var body: some View {
        ZStack {
            OuterStar()
                .subtracting(
                    InnerStar()
                        .subtracting(PartialHorizontalRectangle(percent: percent))
                )
                .fill(innerStyle)
            
            OuterStar()
                .subtracting(
                    InnerStar()
                )
                .fill(outerStyle)
        }
    }
}

struct StarShapeViewPreviewer: View {
    @State private var percent = 1.0
    
    var body: some View {
        StarShapeView(percent: percent)
            .foregroundStyle(.orange)
            .contentShape(Rectangle())
            .animation(.easeInOut, value: percent)
            .frame(width: 400, height: 400)
            .onTapGesture {
                percent = percent == 0 ? 1 : 0
            }
    }
}

#Preview {
    StarShapeViewPreviewer()
}

