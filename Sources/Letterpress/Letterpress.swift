//@_exported import MarkdownUI
//@_exported import Markdown
import Foundation

public struct Letterpress: Sendable {
    public static let version = "2024.12.v1"
}

public extension Bundle {
    static var letterpress: Bundle {
        .module ?? .main
    }
}
