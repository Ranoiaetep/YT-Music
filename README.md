# YT-Music

A quick tool to download YouTube videos as music file.

## Usage

Simply put each YouTube link after the command:

```sh
yt-music "https://www.youtube.com/watch?v=4uqONJT6G-M" "https://www.youtube.com/watch?v=iKfQqb3jPKQ"
```

By default, files will be downloaded to user's ***Download*** folder as ***.m4a*** files.

To change the default behaviors, you can use `-o`/`--output` to specify a output directory, and `-f`/`--format` to specify a output format:

```sh
yt-music "https://www.youtube.com/watch?v=4uqONJT6G-M" -o "~/Home" -f mp3
```

## Installation

The package can be installed via [***Homebrew***](https://brew.sh). Once Homebrew is installed, you can use the command to install:

```sh
brew tap ranoiaetep
brew install yt-music
```

## Dependencies

-   [yt-dlp](https://github.com/yt-dlp/yt-dlp): Most process were handled through *yt-dlp*.
-   [ffmpeg](https://www.ffmpeg.org): *ffmpeg* is used to convert audio format.
