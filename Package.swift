// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Letterpress",
    platforms: [.iOS(.v16), .macOS(.v14), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(
            name: "Letterpress",
            targets: ["Letterpress"]),
    ],
    dependencies: [
        .package(wildthink: "AEXML", in: "ThirdParty"),
        .package(wildthink: "swift-markdown", in: "ThirdParty"),
        .package(url: "https://github.com/hummingbird-project/swift-mustache.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "Letterpress",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "AEXML", package: "AEXML"),
                .product(name: "Mustache", package: "swift-mustache")            ],
            resources: [
                .process("Resources/Icons.xcassets"),
            ]
        ),
        .testTarget(
            name: "LetterpressTests",
            dependencies: ["Letterpress"]
        ),
    ]
)

// @mark(BuildRC)
import Foundation

extension Package.Dependency {
    static func package(wildthink pack: String, in dir: String = "packages"
    ) -> Package.Dependency {
        .package(path: BuildRC[pack, in: dir])
    }
}

public struct BuildRC: Sendable {
    static let shared = BuildRC()
    var _values: [String:String] = [:]
    var sources: [String] = []
    var fm: FileManager { .default }
    var home: String { fm.homeDirectoryForCurrentUser.path() }
    
    public static subscript(_ name: String, in dir: String) -> String {
        let p = BuildRC.shared._values[dir] ?? dir
        return "\(p)/\(name)"
    }
    
    public init () {
        merge(contentsOfFile: home + ".buildrc")
        merge(contentsOfFile: fm
            .currentDirectoryPath
            .appending("/.buildrc"))
    }
    
    mutating func merge(contentsOfFile path: String) {
        if let data = fm.contents(atPath: path),
           let json = try? JSONSerialization.jsonObject(with: data),
           let plist = json as? [String:String]
        {
            sources.append(path)
            for (k, var v) in plist {
                v = v.hasPrefix("~/") ? home + v.dropFirst(2) :v
                _values[k] = v
            }
        } else {
            print("BuildRC: Empty", path)
        }
    }
}
// @end(BuildRC)
