//
//  Proportio.swift
//  CardStock
//
//  Created by Jason Jobe on 2/5/25.
//

import SwiftUI

public struct Proportio: Sendable {
    public var baseCornerRadius: CGFloat = 4
    public var radiusScale: CGFloat = 2
    
    public func cornerRadius(level: CGFloat) -> CGFloat {
        baseCornerRadius * pow(radiusScale, level)
    }
    
    public func elevation(level: CGFloat) -> CGFloat {
        baseCornerRadius * pow(radiusScale, level)
    }
}

public extension DynamicTypeSize {

    init(name: String) {
        self = switch name {
        case "xSmall": .xSmall
        case "small": .small
        case "medium": .medium
        case "large": .large
        case "xLarge": .xLarge
        case "xxLarge": .xxLarge
        case "xxxLarge": .xxxLarge
        case "accessibility1": .accessibility1
        case "accessibility2": .accessibility2
        case "accessibility3": .accessibility3
        case "accessibility4": .accessibility4
        case "accessibility5": .accessibility5
        default:
                .medium
        }
    }
}

public struct Typography: Sendable {
    
    public var typographyScale: FontScale = .perfectFourth
    public var typographyBase: CGFloat = 12
    public var typographyMaxLevel: Int = 6
    
    
    // https://github.com/NateBaldwinDesign/proportio/
    public enum FontScale: CGFloat, CaseIterable, Sendable {
        case minorSecond = 1.067
        case majorSecond = 1.125
        case minorThird = 1.2
        case majorThird = 1.25
        case perfectFourth = 1.333
        case minorFifth = 1.5
        case majorFifth = 1.667
        case minorSixth = 1.8
        case majorSixth = 2
    }
    
    
    public func padding(level: Int, base: CGFloat? = nil) -> CGPoint {
        let pt = round(fontScale(level: level, base: base)/1.333)
        return CGPoint(x: pt, y: pt)
    }
    
    public func calculateScale(baseSize: CGFloat, scale: CGFloat, increment: CGFloat, scaleMethod: String) -> CGFloat {
        if (scaleMethod == "power") {
            baseSize * pow(scale, increment)
        } else if (scaleMethod == "linear") {
            baseSize + scale * increment
        } else { scale * baseSize }
    }
    
    public func typeIconSpace(level: Int, base: CGFloat? = nil) -> CGFloat {
        round(fontScale(level: level, base: base)/3.0)
    }
    
    public func fontScale(level: Int, base: CGFloat? = nil) -> CGFloat {
        let scale = typographyScale
        let base = base ?? typographyBase
        return if level < 1 {
            round(base * pow(1.0/scale.rawValue, CGFloat(-level)))
        } else {
            round(base * pow(scale.rawValue, CGFloat(level)))
        }
    }
    
    public func fontSize(forHeading level: Int, base: CGFloat? = nil) -> CGFloat {
        return if level > 0 {
            fontScale(level: typographyMaxLevel-level, base: base)
        } else {
            fontScale(level: level, base: base)
        }
    }
}

struct ProportioView: View {
    var pad: CGFloat = 16
    
    var body: some View {
        VStack {
            component
            container(gap: pad, Text(
        """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit.
        Maecenas non nisl ac dui gravida pellentesque. Phasellus
        et cursus dui, at fringilla risus. Vestibulum a tortor 
        euismod, fermentum tortor sed, euismod turpis.
        """)
            )
        }
    }
    
    @ViewBuilder
    var component: some View {
        container(
            Label("Hello, World!", systemImage: "star.fill")
        )
    }
    
    @ViewBuilder
    func container<C: View>(
        gap pad: CGFloat = 8,
        cornerRadius: CGFloat = 8,
        _ content: C
    ) -> some View {
        content
            .padding(pad)
            .overlay {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.gray, lineWidth: 1)
                    VStack {
                        Rectangle().frame(width: pad, height: pad)
                        Spacer()
                        Rectangle().frame(width: pad, height: pad)
                    }
                    .foregroundStyle(.orange)
                    HStack {
                        Rectangle().frame(width: pad, height: pad)
                        Spacer()
                        Rectangle().frame(width: pad, height: pad)
                    }
                    .foregroundStyle(.orange)
                }
            }
//            .overlay(alignment: .bottomTrailing) {
//                Circle().fill(Color.orange)
//                    .frame(width: pad*2)
//                    .offset(x: -1, y: -1)
//            }
        //        .shadow(radius: 8)
    }
}

#Preview {
    ProportioView()
        .padding()
    //        .preferredColorScheme(.light)
}
