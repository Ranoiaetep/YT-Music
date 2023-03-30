import Foundation
import ArgumentParser
import System

@main
struct ytMusic: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        abstract: "Download Youtube Videos as Music",
        discussion: """
        Download videos by simply copying each links: `yt-music "link1..." "link2..."`.
        - Support download each videos individually, or download the entire playlist.
        - Multiple links can be appended.
        """,
        version: "0.0.2"
    )

    @Argument(
        help: .init(
            "Youtube url(s) to download",
            discussion: """
            Both individual links and playlist links are supported.

            """
        )
    )
    var urls: [YoutubeURL]
    
    @Option(
        name: [.short, .customLong("output")],
        help: .init(
            "Provide download location",
            discussion: """
            Provide a custom directory, or user's default download folder will be used.

            """,
            valueName: "dir"
        ),
        completion: .directory
    )
    var outputDirectory: URL = .downloadsDirectory

    @Option(
        name: .shortAndLong,
        help: .init(
            "Choose custom music format",
            discussion: """
            Current available formats: m4a, mp3

            """,
            valueName: "ext"
        )
    )
    var format: musicFormat = .m4a

    @Flag(
        name: .shortAndLong,
        help: "Display extra information while processing."
    )
    var verbose: Bool = false

    @Option(
        name: [.customLong("custom-homebrew")],
        help: .init(
            "Choose custom Homebrew location",
            valueName: "dir",
            visibility: .hidden
        ),
        completion: .directory
    )
    var homebrewDirectory: URL = defaultHomebrewDirectory

    static var defaultHomebrewDirectory: URL = {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(filePath: "/bin/zsh")!
        process.arguments = ["-c", "brew --prefix"]
        process.standardOutput = pipe
        try! process.run()

        let urlString = String(data: try! pipe.fileHandleForReading.readToEnd()!, encoding: .ascii)!.trimmingCharacters(in: .newlines)

        return URL(filePath: urlString.trimmingCharacters(in: .whitespaces)).appending(path: "bin", directoryHint: .isDirectory)
    }()

    @Flag(
        name: .customLong("download"),
        inversion: .prefixedNo,
        exclusivity: .exclusive,
        help: .init(
            "Toggle if the command will perform downloads",
            discussion: """
            This flag should be used only for debug purposes

            """,
            visibility: .hidden
        )
    )
    var shouldDownload: Bool = true

    func run() throws {
        let ytDlp = URL(filePath: "yt-dlp", relativeTo: homebrewDirectory).absoluteURL
        let ffmpeg = URL(filePath: "ffmpeg", relativeTo: homebrewDirectory).absoluteURL

        for (index, url) in urls.enumerated() {
            if urls.count > 1 {
                print("Task \(index + 1) of \(urls.count): ", terminator: "")
            }

            if shouldDownload {
                print("Downloading from \(url.v ?? url.list ?? "")...")
                let process = try! Process.run(ytDlp, arguments: [
                    (url.v ?? url.list)!,
                    "--paths", outputDirectory.path(),
                    "--embed-thumbnail", "--embed-metadata", "--embed-chapters",
                    "--progress", "--newline", verbose ? "--verbose" : "",
                    "--no-simulate",
                    "--print", "\n%(autonumber)02d. %(title)s.%(ext)s",
                    "-f", format.rawValue,
                    "--ffmpeg-location", ffmpeg.path()
                ].filter{ $0.count > 0 }, terminationHandler: { _ in
                    print("\nTask \(urls.count > 1 ? (index + 1).description + " " : "")Finished!\n")
                })
                process.waitUntilExit()
                print(String.init(repeating: "-", count: 40), "\n")
            }
            else {
                print(url)
            }
        }
    }

    func validate() throws {
        guard urls.count >= 1 else {
            throw ValidationError("You must add at least 1 url")
        }
    }

    enum musicFormat: String, ExpressibleByArgument {
        case m4a
        case mp3
    }
}

extension URL: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(string: argument)
    }

    public var defaultValueDescription: String {
        self.path()
    }
}
