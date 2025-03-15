//
//  xLink.swift
//  CardStock
//
//  Created by Jason Jobe on 2/13/25.
//

import SwiftUI
@preconcurrency import Markdown

/*
 message (Apple)
 bubble
 envelope emailto:jane@jetsons.com
 phone tel:199999
 globe https: http:
 mappin.and.ellipse 􀎫 geo:25.245470,51.454009
 */

// TODO: xText, Markdown.attributedText, .plainTextString, .table, .list, .listItem
        
public struct XmLink: Identifiable {
    public var id: Int { url.absoluteString.hashValue }
    public var label: String
    public var url: URL
    public var imageName: String {
        _imageName ?? commonFavicon ?? systemIconName
    }
    var _imageName: String?
//    public var customIcon: SwiftUI.Image?
    
//    public var icon: SwiftUI.Image {
//        customIcon ??
//            .init(systemName: commonFavicon ?? defaultIcon)
//    }
}

public extension XmLink {
    
    init?(_ link: Markdown.Image) {
        guard let urlString = link.source,
             let url = URL(string: urlString)
        else { return nil }
        self.url = url
        self.label = link.title ?? url.host ?? urlString
        self._imageName = nil
    }

    init?(_ link: Markdown.Link) {
        guard let urlString = link.destination,
             let url = URL(string: urlString)
        else { return nil }
        self.url = url
        self.label = link.title ?? url.host ?? urlString
        self._imageName = nil
    }
}

public extension XmLink {
    var systemIconName: String {
        switch url.scheme {
            case "https", "http": "globe"
        case "tel": "phone"
        case "geo": "mappin.and.ellipse"
        case "sms": "bubble"
            case "mailto": "envelope"
        default:
            "link"
        }
    }
    
    var commonFavicon: String? {
        guard let host = url.host else { return nil }
        let list = host.split(separator: ".")
        let key = list.count >= 2 ? String(list[list.count - 2]) : ""
        return Self.commonFaviconNames[key]
    }
    
    // WARNING: These MUST be in Letterpress Icons.xcassets
    static let commonFaviconNames: [String:String] = [
        "medium": "medium",
        "linkedin": "linkedin",
//        "google": "google",
//        "youtube": "youtube",
//        "facebook": "facebook",
//        "twitter": "twitter",
//        "instagram": "instagram",
    ]
}

extension URL {
    var commonFavicon: String? {
        guard let host = host else { return nil }
        let list = host.split(separator: ".")
        return list.count >= 2 ? String(list[list.count - 2]) : nil
    }
}

public struct LinkView: View {
    @Environment(\.openURL) var openURL
    public var model: XmLink
    
    public init(model: XmLink) {
        self.model = model
    }
    
    public var body: some View {
        LabeledContent(model.label) {
            icon
                .frame(maxWidth: 24)
        }
//        Label(title: model.label, icon: Icon())
        .contentShape(.rect)
        .onTapGesture {
            openURL(model.url)
        }
    }
    
    func icon(_ name: String) -> some View {
        ZStack {
            Image(name, bundle: .letterpress)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .border(.red)
        .background {
            Image(systemName: "link")
                .resizable()
                .padding()
                .aspectRatio(contentMode: .fit)
        }
    }

    @ViewBuilder
    var icon: some View {
        ZStack {
            Image(model.imageName, bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .border(.green)
        .background {
            Image(systemName: "link")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
                .foregroundStyle(.foreground)
        }
    }
}

//extension SwiftUI.Image {
//    init(qname: String, bundle: Bundle? = nil) {
//        let pair = qname.split(separator: "#")
//    }
//}


//extension SwiftUI.Image {
//    init?(qname: String, bundle: Bundle? = nil) {
//        #if os(macOS)
//        if let img =
//                NSImage(systemSymbolName: qname, accessibilityDescription: nil)
//        {
//            self = Image(nsImage: img)
//        } else {
//            self = Image(qname, bundle: bundle)
//        }
//        #else
//        if let img =
//            UIImage(systemName: qname) {
//            self = Image(uiImage: img)
//        } else {
//            self = Image(qname, bundle: bundle)
//        }
//        #endif
//    }
//}
