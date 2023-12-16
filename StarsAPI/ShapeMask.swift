//
//  ShapeMask.swift
//  StarsAPI
//
//  Created by Jeremy Cook on 12/16/23.
//

import SwiftUI

struct RingCutout: Shape {
    
    let from: Double
    let to: Double
    var clockwise: Bool = false
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let r: CGFloat = (rect.maxX - rect.minX) / 2
            let startAngle = from * 360
            let endAngle = to * 360
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: r, startAngle: .init(degrees: -90 + startAngle), endAngle: .init(degrees: -90 + endAngle), clockwise: !clockwise)
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + r))
        }
    }
}

struct ShapeMask: View {
    var body: some View {
        ZStack {
            Image(systemName: "circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.3)
                .frame(alignment: .bottom)
                .border(.red)
                
            Image(systemName: "circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .mask {
                    RingCutout(from: 0, to: 0.5)
                }
        }
    }
}

#Preview {
    ShapeMask()
        .padding()
}


extension View {
    public dynamic func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}
