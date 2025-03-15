//
//  XtMarkdownToXML.swift
//  CardStock
//
//  Created by Jason Jobe on 2/10/25.
//
import Foundation
#if canImport(AEXML)
import AEXML
#endif
import Markdown
public typealias XMLMarkup = AEXMLElement

@dynamicMemberLookup
struct BlackBox<Item>: CustomStringConvertible {
    let item: Item
    
    init(_ item: Item) {
        self.item = item
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<Item, T>) -> T {
        item[keyPath: keyPath]
    }
    
    var description: String {
        ""
//        "(\(String(describing: Item.self)))"
    }
}

     
//open class XMLMarkup: XMLElement {
extension XMLMarkup {
    public var markup: Markup? {
        get { context(Markup.self).first }
        set { /*context.update(newValue)*/ }
    }
    //    {
    //        get { (objectValue as? BlackBox<Markup>)?.item }
    //        set { objectValue = newValue.map(BlackBox.init) }
    //    }
    
    public var markdownLevel: Int {
        get { context(Int.self).first ?? 0 }
//        get { context[#function] as? Int ?? 0 }
//        set { context[#function] = newValue }
    }
    public var range: SourceRange? { markup?.range }
    public var source: SourceLocation? { range?.lowerBound }
    
//    public override init(name: String, uri URI: String? = nil) {
//        super.init(name: name, uri: URI)
//        self.uri = URI
//        self.name = name
//    }
    
    public convenience init(markup: any Markup, name: String) {
        self.init(name: name)
        self.markup = markup
//        self.objectValue = BlackBox(markup)
    }
    
    public convenience init(instruction: BlockDirective, name: String? = nil) {
        self.init(name: name ?? instruction.name)
        
        let argv = instruction.argumentText.parseNameValueArguments()
        for arg in argv {
            if arg.name.isEmpty {
                addAttribute(name: "id", value: arg.value)
            } else {
                addAttribute(name: arg.name, value: arg.value)
            }
        }

        self.markup = instruction
    }

}

extension XMLMarkup {
    func addAttribute(name: String, value: Any) {
        let sv = String(describing: value)
        self.attributes[name] = sv
//        addAttribute(XMLNode.attribute(withName: name, stringValue: sv) as! XMLNode)
    }
}

public extension XMLMarkup {
    func typeset(baseSize: CGFloat = 14) -> AttributedString? {
        guard let markup else { return nil }
        var reader = Markdownosaur(baseSize: baseSize)
        return reader.visit(markup).str
    }
    
    var attributedString: AttributedString? {
        typeset(baseSize: 14)
//        guard let markup else { return nil }
//        var reader = Markdownosaur()
//        return reader.visit(markup).str
    }
}

public struct XmMarkdownToXML: MarkupWalker {
    public typealias Result = ()
    typealias Node = any Markup
    typealias XElement = XMLMarkup
    
    private(set) var tree: XElement
    private(set) var stack: [XElement] = []

    public init() {
        tree = XElement(name: "root")
    }
    
    mutating
    public func defaultVisit(_ markup: any Markup) -> Result {
        return descendInto(markup)
    }
    
    mutating func descendInto(_ node: Node) -> Result {
        for child in node.children {
            visit(child)
        }
    }
        
    // MARK: XML Stack functions
    var top: XElement { stack.last ?? tree }

    @discardableResult mutating func pop() -> XElement? {
        stack.isEmpty ? nil : stack.removeLast()
    }
    
    mutating func push(_ node: XElement) {
        top.addChild(node)
        stack.append(node)
    }
    
    func currentHeadingLevel() -> Int {
        // Traverse the stack from the top, searching for the most recent heading node
        for element in stack.reversed() {
//            if element.kind == .element {
            if let xm = element as? XMLMarkup {
                return xm.markdownLevel
            }
        }
        return 0  // Default level when no heading is found
    }
    
    public func visitParagraph(_ paragraph: Paragraph) -> () {
        let node = XMLMarkup(markup: paragraph, name: "text")
        top.addChild(node)
    }
    
    /**
        The @id BlockDirective is a special case used to addAttributes(...) to its parent XMLElement.
        Using this can reduce annoying nesting level management.
     */
    mutating public func visitBlockDirective(_ node: BlockDirective) -> Result {
        let name = node.name.lowercased()
//        print(#function, name)
        
        push(XElement(instruction: node))
        descendInto(node)
        pop()
//        if name == "id" {
//            let xe = top
//            let argv = node.argumentText.parseNameValueArguments()
//            for arg in argv {
//                if arg.name.isEmpty {
//                    xe.addAttribute(name: "id", value: arg.value)
//                } else {
//                    xe.addAttribute(name: arg.name, value: arg.value)
//                }
//            }
//        } else {
//            let xn = XElement(instruction: node)
//            push(xn)
//            descendInto(node)
//            pop()
//        }
    }

    mutating public func visitHeading(_ heading: Heading) {
//        let xn = XElement(markup: heading, name: "section")
//        xn.markdownLevel = heading.level

        let title = XElement(markup: heading, name: "heading")
        title.addAttribute(name: "level", value: heading.level)
        title.value = heading.plainText
//        xn.addChild(title)
        
        // Pop elements until we find a proper parent
//        while let top = stack.last, top.markdownLevel >= heading.level {
//            pop()
//        }
//        if let ndxp = top.attribute(forName: "mdl")?.stringValue {
//        if let ndxp = top["mdl"].value {
//            xn.addAttribute(name: "mdl", value: "\(ndxp).\(heading.level)")
//        } else {
//            xn.addAttribute(name: "mdl", value: heading.level)
//        }
        push(title)
        descendInto(heading)
        pop()
    }
}

public extension Markup {
    func apply(_ visitor: (any Markup) -> Bool) {
        guard visitor(self) else { return }
        for child in children {
            child.apply(visitor)
        }
    }
}

public extension Markup {
    var typeName: String {
        String(describing: type(of: self))
    }

    func print(softbreak: String = " ") -> String {
        var s: String = ""
        self.print(to: &s, softbreak: softbreak)
        return s
    }
    
    func print(to cout: inout String, softbreak: String) {
        switch self {
            case is SoftBreak:
                Swift.print(softbreak, terminator: "", to: &cout)
            case is Paragraph:
                children.forEach({ $0.print(to: &cout, softbreak: softbreak)})
            case let l as Link:
                Swift.print(l.title ?? "link", l.destination ?? "dest",  terminator: "", to: &cout)
            case let p as PlainTextConvertibleMarkup:
                Swift.print(p.plainText, terminator: "", to: &cout)
            default:
                children.forEach({ $0.print(to: &cout, softbreak: softbreak)})
        }
    }
}

extension AEXMLElement {
    var level: Int { 1 + (parent?.level ?? 0) }
}

extension XMLMarkup {
    func print(_ indent: Int = 0) {
        let pad = String(repeating: " ", count: indent)
        Swift.print(pad, level, ":", markdownLevel, name)
//        guard let children else { return }
        for child in children where child is XMLMarkup {
            guard let child = child as? XMLMarkup else { continue }
            child.print(indent + 2)
        }
    }
}
