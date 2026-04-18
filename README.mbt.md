# justjavac/microphone

Native-only microphone discovery and capture-session helpers.

```mbt nocheck
///|
fn main {
  let devices = @microphone.MicrophoneDevice::list()
  for device in devices {
    println(device.session_label())
  }
}
```

```mbt nocheck
///|
fn example_label {
  let device = @microphone.MicrophoneDevice::{
    id: "mic-1",
    name: "Built-in Mic",
    state: Idle,
    default_config: @microphone.CaptureConfig::new(
      echo_cancellation=true,
      noise_suppression=true,
    ),
    monitor_supported: true,
  }
  println(device.session_label())
}
```

Use `MicrophoneDevice::list()` for best-effort platform API discovery,
`MicrophoneDevice::parse_listing` for deterministic tests, and
`CaptureConfig::new` plus `normalized` before sizing capture chunks.
