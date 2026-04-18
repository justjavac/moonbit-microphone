# justjavac/microphone

[![coverage](https://img.shields.io/codecov/c/github/justjavac/moonbit-microphone/main?label=coverage)](https://codecov.io/gh/justjavac/moonbit-microphone)
[![linux](https://img.shields.io/codecov/c/github/justjavac/moonbit-microphone/main?flag=linux&label=linux)](https://codecov.io/gh/justjavac/moonbit-microphone)
[![macos](https://img.shields.io/codecov/c/github/justjavac/moonbit-microphone/main?flag=macos&label=macos)](https://codecov.io/gh/justjavac/moonbit-microphone)
[![windows](https://img.shields.io/codecov/c/github/justjavac/moonbit-microphone/main?flag=windows&label=windows)](https://codecov.io/gh/justjavac/moonbit-microphone)

`justjavac/microphone` is a native-only MoonBit package for microphone
device discovery and capture-session metadata. It keeps all package source under
`src`, uses small C native stubs for host integration, and exposes a
focused MoonBit API that works on Windows, Linux, and macOS. The FFI string
boundary uses `justjavac/ffi`: Linux and macOS return null-terminated UTF-8,
while Windows returns null-terminated UTF-16LE wide strings.

## What It Provides

- Capture state, sample format, capture configuration, and microphone device
  types.
- A compact `CaptureConfig::new(...)` constructor for mono 48 kHz floating-point
  defaults.
- Configuration normalization before chunk sizing.
- Stable labels for logs, settings, and telemetry.
- Best-effort native device discovery through platform audio APIs.
- Deterministic parsing helpers for tests and applications that already have a
  native device listing.
- A focused public API: platform selection is an implementation detail handled
  by the native backend.

## Platform Support

The package is intentionally native-only. `moon.mod.json` sets
`"preferred-target": "native"`, and `src/moon.pkg` limits the package to the
native backend.

Discovery uses one platform audio API per operating system:

| Platform | Discovery API |
| --- | --- |
| Windows | Core Audio endpoint enumeration |
| Linux | ALSA device hints, loaded dynamically when available |
| macOS | Core Audio device properties |

The native stub returns an empty listing when the host API is unavailable.
`MicrophoneDevice::list()` therefore returns `[]` instead of raising in minimal CI images,
containers, or machines without audio services.

Platform helpers such as `current_platform` or `platform_name` are intentionally
not part of the public API. Applications usually need microphone devices, stable
labels, and capture configuration; exposing platform names would make the
backend choice harder to change later without improving microphone discovery.

## Code Layout

All MoonBit package source is in `src`.

| Path | Purpose |
| --- | --- |
| `src/types.mbt` | Public capture/device types and `Show` implementations |
| `src/config.mbt` | Capture construction, normalization, sample sizing, and voice-processing checks |
| `src/session.mbt` | State and session-label helpers |
| `src/discovery.mbt` | Device listing parsing and public discovery |
| `src/ffi_native.mbt` | Private MoonBit FFI boundary using `justjavac/ffi` for UTF-8 and UTF-16LE strings |
| `src/native_buffer.c` / `src/native_buffer.h` | Shared native listing buffer and exported FFI entry |
| `src/native_windows.c` | Windows Core Audio implementation |
| `src/native_linux.c` | Linux ALSA implementation |
| `src/native_macos.c` | macOS Core Audio implementation |
| `src/native_unsupported.c` | Empty fallback for unsupported native targets |

## Install

Add the package from the MoonBit registry when published:

```bash
moon add justjavac/microphone
```

Then import it from a package:

```moonbit
import {
  "justjavac/microphone" @microphone,
}
```

## Usage

List visible microphone-like devices:

```mbt
///|
fn main {
  let devices = @microphone.MicrophoneDevice::list()
  if devices.length() == 0 {
    println("No microphones found.")
  } else {
    for device in devices {
      println(device.session_label())
    }
  }
}
```

Normalize capture settings before using them to size buffers:

```mbt
///|
fn chunk_bytes(config : @microphone.CaptureConfig) -> Int {
  let normalized = config.normalized()
  normalized.recommended_chunk_frames() *
  normalized.channels *
  normalized.sample_format.bytes_per_sample()
}
```

Create a configuration by overriding only the fields that matter:

```mbt
///|
let config = @microphone.CaptureConfig::new(
  channels=2,
  sample_rate_hz=48_000,
  echo_cancellation=true,
).normalized()
```

Parse a known listing in tests:

```mbt
///|
test "parse listing" {
  let devices = @microphone.MicrophoneDevice::parse_listing(
    "Built-in Microphone\nmonitor-source\nUSB Studio Mic\n",
  )
  inspect(devices.length(), content="2")
  inspect(devices[0].session_label(), content="mic-0:idle:Built-in Microphone")
}
```

## Examples

Runnable examples live under `src/examples` so the repository keeps MoonBit
source in the configured source tree.

```bash
moon run src/examples/list_devices --target native
moon run src/examples/parse_listing --target native
```

## Development

Run the native checks and tests locally:

```bash
moon check --target native
moon test --target native
moon test --target native --enable-coverage
moon coverage analyze -p justjavac/microphone -- -f cobertura -o coverage.xml
```

Regenerate public interface files after API changes:

```bash
moon info --target native
```

Format before committing:

```bash
moon fmt
```

## Coverage

CI runs on Linux, macOS, and Windows. Each job generates one Cobertura report
with:

```bash
moon test --target native --enable-coverage
moon coverage analyze -p justjavac/microphone -- -f cobertura -o coverage.xml
```

Codecov uploads are flagged as `linux`, `macos`, and `windows`, and
`codecov.yml` waits for all three uploads before reporting combined status.
Badges update after the default branch has uploaded coverage for the repository.

## License

MIT.
