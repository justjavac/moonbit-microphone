name = "justjavac/microphone"

version = "0.1.3"

import {
  "justjavac/ffi@0.2.3",
}

readme = "README.mbt.md"

repository = "https://github.com/justjavac/moonbit-microphone"

license = "MIT"

keywords = [ "moonbit", "native", "microphone", "audio" ]

description = "Microphone capture device and session helpers."

preferred_target = "native"

options(
  source: "src",
)
