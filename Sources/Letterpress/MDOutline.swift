//
//  LinkCounter.swift
//  pal
//
//  Created by Jason Jobe on 11/8/24.
//

import Markdown

@dynamicMemberLookup
struct MDOutline: MarkupWalker {
    var stack: [MDNode] = [MDNode(.root, "<root>", level: 0)]
    var top: MDNode { stack.last! }

    subscript<V>(dynamicMember m: WritableKeyPath<MDNode, V>) -> V {
        get { stack.last![keyPath: m] }
        set {
            var it = stack.removeLast()
            it[keyPath: m] = newValue
            stack.append(it)
        }
    }
    
    mutating
    func visitText(_ text: Text) -> () {
        self.text = text.string
    }
    
    mutating
    func visitListItem(_ item: ListItem) -> () {
        stack.append(MDNode(.item))
        self.seq = item.indexInParent
        descendInto(item)
        let it = stack.removeLast()
        self.kids.append(it)
    }
    
    mutating
    func visitOrderedList(_ list: OrderedList) -> () {
        stack.append(MDNode(.list))
        descendInto(list)
        let it = stack.removeLast()
        self.kids.append(it)
    }
    
    mutating
    func visitUnorderedList(_ list: UnorderedList) -> () {
        stack.append(MDNode(.list))
        descendInto(list)
        let it = stack.removeLast()
        self.kids.append(it)
    }

    mutating func visitHeading(_ h: Heading) {
        stack.append(MDNode(.heading))
        self.level = h.level
        descendInto(h)
        let it = stack.removeLast()
        self.kids.append(it)
    }
}

public enum MDKind {
    case root, heading, list, item
}

public struct MDNode {
    public var text: String
    public var level: Int = -1
    public var seq: Int = 0
    public var kids: [MDNode] = []
    public var kind: MDKind
    
    public init(_  kind: MDKind, _ text: String = "", level: Int = -1) {
        self.text = text
        self.level = level
        self.kind = kind
    }
    
    public func add(_ kid:  MDNode) {
        var kid = kid
        kid.seq = kids.count
    }
}

// MARK: Test

let dev_doc = """

# Main
## dev
- Projects
- Packages
    - Carbon14 - git:carbon
    - CardStock
    - Letterpress
    - InterfaceBuilder - git:interface-builder
- ThirdParty
- Tools
    - pal - git:pal
- Lab
- Database

- Demo
    - 1
        - a
    - 2

    - A
    - B

## providers

Git List
- git:*   => github.com/wildthink
- gist:* => gist.github/wildthink

"""

extension MDNode {
    func pp(_ tab: Int = 0) {
        pr(tab)
        for k in kids {
            k.pp(tab + 1)
        }
    }
    
    func pr(_ tab: Int = 0) {
        print(String(repeating: " ", count: tab * 2)
              , terminator: "")

        switch kind {
            case .root:
                print("\(text)")
            case .heading:
                print("H[\(level).\(seq)] \(text)")
            case .list:
                print("L[\(level).\(seq)] \(text)")
            case .item:
                print("[\(seq)] \(text)")
        }
    }
}

func devDocTest() {
    let document = Document(parsing: dev_doc)
    print(document.debugDescription())
    print("===")
    var mdo = MDOutline()
    mdo.visit(document)
    mdo.top.pp()
}
