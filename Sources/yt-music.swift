import Foundation
import ArgumentParser

@main
struct ytMusic: ParsableCommand {
    @Argument(
        help: "Youtube link(s) to download"
    )
    var links: [URL]
    /// [https://www.youtube.com/watch?v=4uqONJT6G-M, https://www.youtube.com/watch?v=4bE7use7uQc]

    @Option(
        name: [.long, .customShort("o")],
        help: "Location to save your download",
        completion: .directory
    )
    var directory: URL = .downloadsDirectory

    func run() throws {
        for (index, link) in links.enumerated() {
            if links.count > 1 {
                print("Task \(index + 1) of \(links.count): ", terminator: "")
            }
            print("Downloading from \(link.absoluteString.quoted)...")

            let baseScript = """
            yt-dlp \(link.absoluteString.quoted) --paths \(directory.path().quoted) --embed-thumbnail --embed-metadata --embed-chapters --quiet --progress --newline --print "
            %(autonumber)02d. %(title)s.%(ext)s" --no-simulate -f m4a
            """

            shell(baseScript, taskIndex: links.count > 1 ? index + 1: nil)
        }
    }

    func validate() throws {
        guard links.count >= 1 else {
            throw ValidationError("You must add at least 1 link")
        }
    }
}


extension URL: ExpressibleByArgument {
    public init?(argument: String) {
        guard let url = Self.init(string: argument) else {
            return nil
        }
        self = url
    }

    public var defaultValueDescription: String {
        return "~/Download".quoted
    }
}

func shell(_ command: String, taskIndex: Int? = nil) {
    let process = try! Process.run(URL(filePath: "/bin/zsh"), arguments: ["-c", command]) { process in
        print("\nTask \(taskIndex?.description.appending(" ") ?? "")Finished!\n")
    }

    process.waitUntilExit()
    print(String.init(repeating: "-", count: 40), "\n")
}

extension String {
    var quoted: String {
        return "\"\(self)\""
    }
}
