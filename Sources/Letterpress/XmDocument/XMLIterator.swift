//
//  XMLIterator.swift
//  CardStock
//
//  Created by Jason Jobe on 2/15/25.
//

#if canImport(AEXML)
import AEXML
#endif

/*
public typealias XMLNode = AEXMLElement

public extension XMLNode {

    func foreach() -> XMLIterator {
        XMLIterator(self)
    }

    func matches(path: String) -> Bool {
        let p = path.split(separator: "/", omittingEmptySubsequences: false)
        return matches(path: p[0...])
    }
    
    func matches(path: ArraySlice<String.SubSequence>) -> Bool {
        let name = self.name
        guard let key = path.last, name.caseInsensitiveEqual(key)
        else { return false }

        let rest = path.dropLast()
        if rest.isEmpty { return true }
        // No parent but expects one => false / no match
        return parent?.matches(path: rest) ?? false
    }
}

public struct XMLIterator: IteratorProtocol, Sequence {
    public typealias Element = XMLNode
    private var queue: [XMLNode]
    private var prune: ((XMLNode) -> Bool)?
    
    public init(_ parent: XMLNode) {
        queue = parent.children
    }

    public init(_ nodes: [XMLNode]) {
        queue = nodes
    }

    mutating func enqueue(_ nodes: [XMLNode]?) {
        guard let nodes else { return }
        if let prune = prune {
            queue.append(contentsOf: nodes.filter(prune))
        } else {
            queue.append(contentsOf: nodes)
        }
    }
    
    public mutating func next() -> XMLNode? {
        guard !queue.isEmpty else { return nil }
        
        let node = queue.removeFirst()
        enqueue(node.children)
        return node
    }
}

// MARK: Sequence<XMLNode> Extenstions
public extension LazySequence where Elements.Element == XMLNode {
    func nodes(named name: String) -> LazyFilterSequence<Elements> {
        return self.filter { name.caseInsensitiveEqual($0.name) }
    }
    
//    func matching(path: String) -> LazyFilterSequence<Elements> {
//        filter { name.caseInsensitiveEqual($0.name) }
//    }
}

public extension Sequence where Element == XMLNode {
    func nodes(named name: String) -> [Element] {
        filter { name.caseInsensitiveEqual($0.name) }
    }
    
    func matching(path: String) -> [Element] {
        let list = filter { $0.matches(path: path) }
        return list
    }
}
*/

// LazyFilterSequence
public extension Sequence {
//public extension LazySequence {
    func nth(_ ndx: Int) -> Element? {
        guard ndx > 0 else {
            return nil
        }
        var count = 1
        for x in self {
            if count == ndx {
                return x
            }
            count += 1
        }
        return nil
    }
}

//public extension XMLNode {
//    
//    var stringValue: String? { value }
//    
//    func child(at ndx: Int) -> XMLNode? {
//        guard ndx >= 0, ndx < children.count
//        else { return nil }
//        return children[ndx]
//    }
//    
//    func format() -> String {
//        var str = ""
//        self.format(to: &str)
//        return str
//    }
//
//    var formattedName: (name: String, includesChild: Bool) {
//        let tag = self.name // ?? self.stringValue ?? "(null)"
//        
//        return if let tch = child(at: 0),
////                    tch.kind == .text,
//                    let txt = tch.stringValue
//        {
//            ("\(tag) '\(txt)'", true)
//        } else {
//            (tag, false)
//        }
//    }
//    
//    func format<OS: TextOutputStream>(_ level: Int = 0, to str: inout OS, isLast: Bool = true, prefix: String = "") {
//        
//        let connector = isLast ? "└── " : "├── "
//        let newPrefix = prefix + (isLast ? String(repeating: " ", count: level * 2) : "│   ")
//        
////        let name = self.name ?? self.stringValue ?? "(null)"
//        let (name, includesChild) = formattedName
//        if level == 0 {
//            Swift.print(name, separator: "", terminator: "\n", to: &str)
//        } else {
//            Swift.print(prefix, connector, name, separator: "", terminator: "\n", to: &str)
//        }
//
////        guard let children = self.children, !children.isEmpty else { return }
//        
//        // If I am a Heading with a single Text Node then don't drill down
////        if includesChild { return }
//        
//        for (index, child) in children.enumerated() {
//            let isLastChild = index == children.count - 1
//            child.format(level + 1, to: &str, isLast: isLastChild, prefix: newPrefix)
//        }
//    }
//}
