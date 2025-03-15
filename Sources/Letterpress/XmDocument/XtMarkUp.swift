//
//  Markdown.swift
//  CardStock
//
//  Created by Jason Jobe on 8/7/24.
//
/*
 https://fatbobman.com/en/posts/attributedstring/
 */
import Foundation
import SwiftUI
import Markdown

#if os(macOS)
extension NSFont: @unchecked @retroactive Sendable {}
#endif

enum TextBreak {
    case none
    case space
    case soft
    case line
    case paragraph
    case thematicBreak
    case list
    case listItem
    case section(index: IndexPath)
    
    static func section(index: Int) -> TextBreak {
        section(index: [index])
    }
}


extension RichText {
    init(_ str: String, spacing: TextBreak) {
        self.str = AttributedString(str)
        self.str.textBreak = spacing
    }
}

struct StringDesign: Sendable {
    enum Style { case emphasis, strong, strikethrough, code }

    var typography: Typography = Typography()
    var plain: AttributeContainer = AttributeContainer()
    var baseFontSize: CGFloat = 14

    // FIXME: Change to use NSParagraph spacing
    func vspace(for type: TextBreak) -> RichText {
        var rtf = switch type {
        case .none:
            RichText()
        case .space:
            RichText(" ")
        case .soft:
            RichText(" ")
        case .line:
            RichText("\n")
        case .paragraph:
            RichText("\n")
        case .thematicBreak:
            thematicBreak
        case .list:
            RichText("\n")
        case .listItem:
            RichText("\n")
        case .section(index: _):
            RichText("\n")
        }
        rtf.str.textBreak = type
        return rtf
    }
    
    var thematicBreak: RichText = {
        // FIXME: Change to use NSParagraph spacing
        var str = AttributedString("\n\u{00A0} \u{0009} \u{00A0}\n")
        str.underlineStyle = .double
        str.underlineColor = .gray
        str.foregroundColor = .gray
        return RichText(str)
    }()

    func paragraphStyle(for list: ListItemContainer) -> NSParagraphStyle {
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.headIndent = 0
        
        style.tabStops[0] = NSTextTab(textAlignment: .right, location: style.tabStops[0].location)
        style.tabStops[1] = NSTextTab(textAlignment: .left, location: style.tabStops[0].location + 10)
        style.headIndent += style.tabStops[1].location
        style.paragraphSpacing = 0 // Remove spacing between list items
//        style.lineSpacing
        return style
    }

    func paragraphStyle(for blockQuote: BlockQuote) -> NSParagraphStyle {
        let ps = NSMutableParagraphStyle()
        
        let baseLeftMargin: CGFloat = 15.0
        let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(blockQuote.quoteDepth))
        
        ps.tabStops = [NSTextTab(textAlignment: .left, location: leftMarginOffset)]
        ps.headIndent = leftMarginOffset
        return ps
    }
    
    func attributes(for node: InlineAttributes) -> AttributeContainer {
        // FIXME: Check for URL's vs other parameters (eg style)
        var container = AttributeContainer()
//        container.merge(self.container) stack??
        container.foregroundColor = .red
        if !node.attributes.isEmpty {
            let url = URL(string: node.attributes)
//            print(node.attributes, "=>", url)
            container.link = url
        }
        return container
    }
    
    func attributes(forHeading heading: Heading) -> AttributeContainer {
        var container = AttributeContainer()
//        container.merge(self.container) stack??
        container.font = .systemFont(ofSize: typography.fontSize(forHeading: heading.level))
        container.font = .largeTitle
//        container.foregroundColor = .white
//        container.backgroundColor = .red
        return container
    }
        
    func attributed(code: String, language: String? = nil) -> RichText {
        var txt = RichText(code)
        return if language != nil {
            // TODO: Real Code Styling
            apply(.code, to: &txt)
        } else {
            txt
        }
    }

    func attributedString(for code: String, style: Style) -> RichText {
        var txt = RichText(code)
        return apply(style, to: &txt)
    }
    
    func apply(_ style: Style, to txt: inout RichText) -> RichText {
        switch style {
        case .emphasis:
            txt.underlineStyle = .single
        case .strong:
            txt.underlineStyle = .double
        case .strikethrough:
            txt.strikethroughStyle = .single
//            txt.strikethroughColor = .controlAccentColor
        case .code:
            txt.foregroundColor = .systemGray
            txt.font = .monospacedSystemFont(ofSize: baseFontSize, weight: .regular)
        }
        return txt
    }
}

#if os(macOS)
//@preconcurrency import Cocoa
//public typealias XColor = NSColor
//public typealias XFont = NSFont

#elseif os(iOS)
import UIKit
public typealias XColor = UIColor
public typealias XFont = UIFont

public extension XColor {
    static var textColor: XColor { UIColor.darkText }
    static var gray: XColor { UIColor.systemGray }
}

typealias NSFontDescriptor = UIFontDescriptor
extension NSFontDescriptor.SymbolicTraits {
    static let bold: NSFontDescriptor.SymbolicTraits = .traitBold
    static let italic: NSFontDescriptor.SymbolicTraits = .traitItalic
}
#endif
public protocol UIElement {}

//typealias XFontDescriptor = NSFontDescriptor

//public typealias RichText = AttributedString
//extension RichText: UIElement {}
//extension AttributedString: UIElement {}
@dynamicMemberLookup
public struct RichText: Sendable {
    var str: AttributedString
    var isEmpty: Bool { str.characters.isEmpty }
    
    init(_ str: AttributedString) {
        self.str = str
    }
    
    init(_ str: String = "", with attributes: AttributeContainer? = nil) {
        self.str = AttributedString(str)
        if let attributes {
            self.str.setAttributes(attributes)
        }
    }

    mutating func append(_ other: RichText) {
        str.append(other.str)
    }
    mutating func append(_ other: AttributedString) {
        str.append(other)
    }
    
    @discardableResult
    mutating func mergeAttributes(_ ac: AttributeContainer) -> RichText {
        str.mergeAttributes(ac)
        return self
    }

    static func +=(lhs: inout RichText, rhs: RichText) {
        lhs.append(rhs)
    }
    
    static func +=(lhs: inout RichText, rhs: String) {
        lhs.append(RichText(rhs))
    }

    subscript<V>(dynamicMember keyPath: WritableKeyPath<AttributedString, V>) -> V {
        get { str[keyPath: keyPath] }
        set { str[keyPath: keyPath] = newValue }
    }
}

public struct Markdownosaur: MarkupVisitor {
//    public typealias Result = UIElement
    
//    let baseFontSize: CGFloat = 15.0
    var design: StringDesign
    var metadata: [String: Any] = [:]
    
    public init(baseSize: CGFloat = 14) {
        design = StringDesign(baseFontSize: baseSize)
    }
    
    public mutating func attributedString(from document: Document) -> AttributedString {
        return visit(document).str
    }
    
    mutating public func defaultVisit(_ markup: Markup) -> RichText {
        richText(for: markup.children)
    }
    
    mutating public
    func richText(for children: MarkupChildren, seperator: RichText? = nil) -> RichText {
        var result = RichText()
        
        for child in children {
            result.append(visit(child))
            if let seperator {
                result.append(seperator)
            }
        }
        return result
    }
    
    mutating public func visitText(_ text: Markdown.Text) -> RichText {
        RichText(text.plainText, with: design.plain)
    }
    
    mutating public func visitEmphasis(_ emphasis: Emphasis) -> RichText {
        var txt = richText(for: emphasis.children)
        return design.apply(.emphasis, to: &txt)
    }
    
    mutating public func visitStrong(_ strong: Strong) -> RichText {
        var txt = richText(for: strong.children)
        return design.apply(.strong, to: &txt)
    }
    
    mutating public func visitParagraph(_ paragraph: Paragraph) -> RichText {
        var result = richText(for: paragraph.children)
        
        if paragraph.hasSuccessor {
            result += (paragraph.isContainedInList
                       ? design.vspace(for: .listItem)
                       : design.vspace(for: .paragraph))
        }
        
        return result
    }
    
    // MARK: Markdown Line Breaks
    public func visitSoftBreak(_ softBreak: SoftBreak) -> RichText {
        design.vspace(for: .soft)
    }
    
    public func visitLineBreak(_ lineBreak: LineBreak) -> RichText {
        return design.vspace(for: .line)
    }

    public func visitThematicBreak(_ thematicBreak: ThematicBreak) -> RichText {
        return design.vspace(for: .thematicBreak)
    }

    mutating public func visitHeading(_ heading: Heading) -> RichText {
        var result = richText(for: heading.children)
        result.mergeAttributes(design.attributes(forHeading: heading))
        return result
    }
    
    mutating public
    func visitBlockDirective(_ node: BlockDirective) -> RichText {
        // TODO: Make the drill-down optional
//        RichText()
        guard node.name.lowercased() != "comment"
        else { return RichText() }
        
        if node.name.lowercased() == "meta" {
            var rtf = RichText("")
            rtf.str.scope = node.name
            return rtf
        }

        return richText(for: node.children)

//        var label: String
//        if !node.argumentText.isEmpty {
//            let segs = node.argumentText.segments
//            let args = segs.compactMap(\.trimmedText).joined(separator: " ")
//            label = "@\(node.name)(\(args))"
//        } else {
//            label = "@\(node.name)"
//        }
    }

    mutating public
    func visitInlineAttributes(_ attributes: InlineAttributes) -> RichText {
        var result = richText(for: attributes.children)
        result.mergeAttributes(design.attributes(for: attributes))
        return result
    }
    
    mutating public func visitLink(_ link: Markdown.Link) -> RichText {
        var result = richText(for: link.children)

        let url = link.destination != nil ? URL(string: link.destination!) : nil
        
        if result.isEmpty, let url {
            result = RichText(url.host ?? url.absoluteString)
        }
        
        if result.isEmpty { return result }
        
        result.link = url
//        result.foregroundColor = .purple
        
        return result
    }
    
    public mutating func visitImage(_ image: Markdown.Image) -> RichText {
        let title = switch image.title {
            case .some(let string) where !string.isEmpty:
                string
            default:
                image.plainText.isEmpty ? "<image placeholder>" : image.plainText
        }
        var result = RichText(title)
        if let src = image.source, let url = URL(string: src) {
            result.imageURL = url
        }
        result.custom = "image"
        return result
    }
        
    // MARK: Inline Markup
    public mutating func visitInlineHTML(_ inlineHTML: InlineHTML) -> RichText {
        RichText(inlineHTML.rawHTML)
    }
    
    mutating public func visitInlineCode(_ inlineCode: InlineCode) -> RichText {
        design.attributedString(for: inlineCode.code, style: .code)
    }

    mutating public func visitStrikethrough(_ strikethrough: Strikethrough) -> RichText {
        var result = richText(for: strikethrough.children)
        return design.apply(.strikethrough, to: &result)
    }
    
    // MARK: List Support
    mutating public
    func visitOrderedList(_ orderedList: OrderedList) -> RichText {
        visit(list: orderedList)
    }

    mutating public
    func visitUnorderedList(_ unorderedList: UnorderedList) -> RichText {
        visit(list: unorderedList)
    }

    mutating private func visit(list: ListItemContainer) -> RichText {

        let isOrdered = list is OrderedList
        var result = RichText()
        
        for (item, number) in zip(list.listItems, 1...) {

            let prefix: String = switch item.checkbox {
                case .checked: "[x]"
                case .unchecked: "[  ]"
                case _ where isOrdered:
                    "\(number)."
                default:
                "•"  // TODO: design.bullet
            }
            let indent = String(repeating: "\t", count: item.listDepth)
            result.append(AttributedString("\(indent)\(prefix) "))
            result.append(visit(item))
            if item.hasSuccessor {
                result += design.vspace(for: .listItem)
            }
        }
        result.paragraphStyle = design.paragraphStyle(for: list)
        return result
    }
    
    mutating public
    func visitListItem(_ listItem: ListItem) -> RichText {
        richText(for: listItem.children)
//        var result = RichText()
//        
//        for child in listItem.children {
//            result.append(visit(child))
//        }
//        return result
    }
    
    public func visitCodeBlock(_ codeBlock: CodeBlock) -> RichText {
        var result = design.attributed(code: codeBlock.code, language: codeBlock.language)
        
        if codeBlock.hasSuccessor {
            result += design.vspace(for: .paragraph)
        }
        
        return result
    }

    mutating public func visitBlockQuote(_ blockQuote: BlockQuote) -> RichText {
        var result = RichText()
        
        for child in blockQuote.children {
            result.append(design.vspace(for: .line))
            result.append(visit(child))
        }
        if blockQuote.hasSuccessor {
            result += design.vspace(for: .line)
        }
        result.paragraphStyle = design.paragraphStyle(for: blockQuote)
        return result
    }
}

// MARK: - Extensions Land
/*
 By declaring new attributes that conform to MarkdownDecodableAttributedStringKey,
 you can add attributes that you invoke by using Apple’s Markdown extension
 syntax: ^[text](name:value, name:value, …). See the sample code project Building
 a Localized Food-Ordering App for an example of creating custom attributes and
 using them with Markdown.
 */

extension TextBreak: Hashable, AttributedStringKey {
    typealias Value = TextBreak
    static var name: String { "TextBreak" }
}

enum RichTextScope: Hashable, AttributedStringKey {
    typealias Value = String
    static var name: String { "RichTextScope" }
}

enum RichTextCustom: Hashable, AttributedStringKey {
    typealias Value = String
    static var name: String { "RichTextCustom" }
}

extension AttributeScopes {
    struct RichTextAttributes: AttributeScope {
        var textBreak: TextBreak
        var scope: RichTextScope
        var custom: RichTextCustom
    }
    
    var richText: RichTextAttributes.Type { RichTextAttributes.self }
}

extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.RichTextAttributes, T>) -> T {
        return self[T.self]
    }
}

// MARK: Example
enum SwapAttribute : AttributedStringKey {
    typealias Value = String
    static let name = "swap"
}

extension AttributeScopes {
    struct MyTextStyleAttributes: AttributeScope {
        let swap: SwapAttribute
    }
}

extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.MyTextStyleAttributes, T>) -> T {
        return self[T.self]
    }
}

extension Markup {
    var listDepth: Int {
        (parent is ListItemContainer ? 1:0) + (parent?.listDepth ?? 0)
    }
    
    /// Depth of the quote if nested within others. Index starts at 0.
    var quoteDepth: Int {
        (parent is BlockQuote ? 1:0) + (parent?.quoteDepth ?? 0)
    }
    
    /// Returns true if this element has sibling elements after it.
    var hasSuccessor: Bool {
        guard let childCount = parent?.childCount else { return false }
        return indexInParent < childCount - 1
    }
    
    var isContainedInList: Bool {
        (parent is ListItemContainer) || (parent?.isContainedInList ?? false)
    }
}
