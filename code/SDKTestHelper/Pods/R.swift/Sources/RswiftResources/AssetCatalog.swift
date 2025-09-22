//
//  AssetCatalog.swift
//  RswiftResources
//
//  Created by Tom Lokhorst on 2021-06-13.
//

import Foundation

public struct AssetCatalog: Sendable {
    public let filename: String
    public let root: Namespace

    public init(filename: String, root: Namespace) {
        self.filename = filename
        self.root = root
    }
}

public extension AssetCatalog {
    struct Namespace: Sendable {
        public var subnamespaces: [String: Namespace] = [:]
        public var colors: [ColorResource] = []
        public var images: [ImageResource] = []
        public var dataAssets: [DataResource] = []

        public init() {}

        public init(
            subnamespaces: [String: Namespace],
            colors: [ColorResource],
            images: [ImageResource],
            dataAssets: [DataResource]
        ) {
            self.subnamespaces = subnamespaces
            self.colors = colors
            self.images = images
            self.dataAssets = dataAssets
        }

        public mutating func merge(_ other: Namespace) {
            subnamespaces = subnamespaces.merging(other.subnamespaces) { $0.merging($1) }
            colors += other.colors
            images += other.images
            dataAssets += other.dataAssets
        }

        public func merging(_ other: Namespace) -> Namespace {
            var new = self
            new.merge(other)
            return new
        }
    }
}
