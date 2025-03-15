//
//  XtDocument.swift
//  CardStock
//
//  Created by Jason Jobe on 2/8/25.
//

#if canImport(AEXML)
import AEXML
#endif
public typealias XMLDocument = AEXMLDocument
@preconcurrency import Markdown

public final class XmDocument: @unchecked Sendable {
    public let document: Document
    public let tree: XMLDocument
    public let data: String?
    
    public init (_ data: String) {
        self.data = data
        let doc = Document(parsing: data, options: [.parseBlockDirectives])
        tree = XmMarkdownToXML.read(doc)
        document = doc
    }
}

extension XmDocument: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
        hasher.combine(ObjectIdentifier(tree))
        hasher.combine(data?.hashValue ?? 0)
    }
    
    public static func == (lhs: XmDocument, rhs: XmDocument) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension XMLDocument {
    func formatted() -> String {
        self.xml
//        let data = xmlData(options: .nodePrettyPrint)
//        let str:String? = String(data: data, encoding: .utf8)
//        return str ?? "<XML Document>"
    }
}

//extension XMLNode {
//    
//    enum PathComponent {
//        case anyone
//        case anypath
//        case tag(String)
//        case index(Int)
//        case condition((XMLNode) -> Bool)
//    }
//    
//    func nodes(matching path: [PathComponent]) -> [XMLNode] {
//        var result: [XMLNode] = []
////        nodes(matching: path[0...], into: &result)
//        return result
//    }
//
//    /// Returns all leaf nodes that are found matching the path component
//    /// "anyone" matches any single node, "anypath" any number intermediate nodes
////    func _nodes(matching path: ArraySlice<PathComponent>, into list: inout [XMLNode]) {
//////        print("CHECK", self.name ?? "NONE")
////        guard let cond = path.first else {
////            list.append(self)
////            return
////        }
////        let matches = switch cond {
////            case .tag(let tagName): name == tagName
////            case .index(let idx):   idx == index
////            case .condition(let predicate): predicate(self)
////            case .anyone:   true
////            case .anypath:  true
////        }
////        guard matches else { return }
////        let tail = path.dropFirst()
////        if case .anypath = cond {
////            decendents(matching: tail, into: &list)
////        } else if case .anyone = cond, let children {
////            children.forEach {
////                $0.nodes(matching: tail, into: &list)
////            }
////        } else {
////            list.append(self)
////        }
////    }
//    
////    func nodes(matching path: ArraySlice<PathComponent>, into list: inout [XMLNode]) {
////        guard let cond = path.first else {
////            list.append(self)
////            return
////        }
////        let tail = path.dropFirst()
////        
////        switch cond {
////        case .tag(let tagName):
////            let kids = children?.filter { $0.name == tagName } ?? []
////            nodes(matching: tail, into: &list)
////            case .index(let idx):
////            if idx == index {
////                
////            }
////            case .condition(let predicate):
////            if predicate(self) {
////                nodes(matching: tail, into: &list)
////            }
////            case .anyone:
////                children?.forEach {
////                    $0.nodes(matching: tail, into: &list)
////                }
////            case .anypath:
////                decendents(matching: tail, into: &list)
////        }
////     }
//
////    func decendents(matching path: ArraySlice<PathComponent>, into list: inout [XMLNode]) {
////        guard let children, !path.isEmpty else { return }
////        for child in children {
////            child.decendents(matching: path, into: &list)
//////            child.children?.forEach {
////            child.nodes(matching: path, into: &list)
//////            }
////        }
////    }
//}

//extension XmDocument {
//    
////    func nodes(forXPath xPath: String) -> [XMLMarkup] {
////        let ns = try? tree.nodes(forXPath: xPath)
////        return ns as? [XMLMarkup] ?? []
////    }
//
////    func markup(forXPath xPath: String) -> [any Markup] {
////        nodes(forXPath: xPath)
////            .compactMap(\.markup)
////    }
////    
////    func markup<M: Markup>(type: M.Type = M.self, forXPath xPath: String) -> [M] {
////        var visitor = GetNodes<M>()
////        let nodes = nodes(forXPath: xPath)
////            .compactMap(\.markup)
////        
////        return visitor.visit(nodes)
////    }
//
//    var links: [xLink] {
////        markup(type: Link.self, forXPath: "//links")
//        select("links", ofType: Link.self)
//            .compactMap(xLink.init)
//    }
//    
////    func attributedStrings(forXPath xPath: String) -> [AttributedString] {
////        var mdv = Markdownosaur()
////        let nodes = nodes(forXPath: xPath)
////            .compactMap(\.markup)
////            .compactMap(fn)
////        
////        return nodes
////        func fn(_ md: Markup) -> AttributedString {
////            mdv.visit(md).str
////        }
////    }
////
////    func attributedString() -> AttributedString {
////        var md = Markdownosaur()
////        return md.attributedString(from: document)
////    }
//}

public struct GetNodes<M: Markup>: MarkupWalker {
    public private(set) var nodes: [M] = []
    public init() {}

    mutating func visit(_ markup: [any Markup]) -> [M] {
        for node in markup {
            visit(node)
        }
        return nodes
    }
    
    mutating
    public func defaultVisit(_ markup: Markup) {
        if let markup = markup as? M {
            nodes.append(markup)
        }
       for child in markup.children {
            visit(child)
        }
    }
}

public struct XmWalker<Element>: MarkupVisitor {
    public typealias Result = ()
    public private(set) var marks: [Element] = []
    var fn: (any Markup) -> Element?
    
    public init (fn: @escaping (any Markup) -> Element?) {
        self.fn = fn
    }
    
    mutating public func apply(_ markup: Markup?) -> [Element] {
        guard let markup = markup else { return [] }
        visit(markup)
        return marks
    }
    
    mutating
    public func defaultVisit(_ markup: Markup) {
        if let mark = fn(markup) {
            marks.append(mark)
        }
       for child in markup.children {
            visit(child)
        }
    }
}

public extension XmDocument {
}

extension XmMarkdownToXML {
    static func read(_ document: Document) -> XMLDocument {
        var reader = XmMarkdownToXML()
        reader.visit(document)
        return XMLDocument(root: reader.tree)
    }
}

public extension XmDocument {
    
    func select<M: Markup>(
        _ select: String,
        ofType mt: M.Type
    ) -> some Sequence<M> {
        tree.foreach()
            .lazy
            .matching(path: select)
            .cast(to: XMLMarkup.self)
            .compactMap(\.markup)
            .nodes(ofType: M.self)
    }
    
    func select(
        _ select: String
    ) -> some Sequence<XMLMarkup> {
        tree.foreach()
            .lazy
            .matching(path: select)
            .cast(to: XMLMarkup.self)
    }

}

// MARK: Sequence<Markdown> Extenstions
//public extension LazySequence where Elements.Element: Markup {
//    func nodes<M: Markup>(ofType mt: M.Type) -> LazyFilterSequence<Elements> {
//        return self.filter { $0 is M }
//    }
//}

//public extension LazySequence where Elements.Element == XMLNode {
public extension Sequence {
    
    func select<M: Markup>(
        _ select: String,
        ofType mt: M.Type
    ) -> some Sequence<M> where Element: AEXMLElement {
        var results: [M] = []
        for item in self {
            let nodes = item
                .foreach()
                .lazy
                .matching(path: select)
                .cast(to: XMLMarkup.self)
                .compactMap(\.markup)
                .nodes(ofType: M.self)
            results.append(contentsOf: nodes)
        }
        return results
    }
    
    func nodes<M: Markup>(ofType mt: M.Type) -> [M]
    where Element: Markup {
        var visitor = GetNodes<M>()
        self.forEach({ visitor.visit($0) })
        return visitor.nodes
    }
    
    func nodes<M: Markup>(ofType mt: M.Type) -> [M]
    where Element == (any Markup)? {
        var visitor = GetNodes<M>()
        self.forEach {
            guard let it = $0 else { return }
            visitor.visit(it)
        }
        return visitor.nodes
    }
}

extension MarkupChildren.Iterator: @retroactive Sequence { }
