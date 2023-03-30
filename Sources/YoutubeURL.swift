import Foundation
import ArgumentParser

struct YoutubeURL {
    let v: String?
    let list: String?
    let index: Int?
}

extension YoutubeURL: ExpressibleByArgument {
    init?(argument: String) {
        guard let url = URL(string: argument),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        guard let host = components.host,
              host.contains("youtube") else { return nil }
        guard let query = components.queryItems,
              query.contains(where: { item in
                  item.name == "v" || item.name == "list"
              }) else {
            return nil
        }
        self.v = query.first{ $0.name == "v" }?.value
        self.list = query.first{ $0.name == "list" }?.value
        self.index = Int(query.first{ $0.name == "index" }?.value ?? "")
    }
}

extension YoutubeURL: Encodable {}

extension YoutubeURL: CustomStringConvertible {
    var description: String {
        String(decoding: try! JSONEncoder().encode(self), as: UTF8.self)
    }
}
