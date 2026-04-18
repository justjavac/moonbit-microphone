///|
/// Run the deterministic listing parser example.
fn main {
  let listing = "Built-in Microphone\nmonitor-source\nUSB Studio Mic\n"
  let devices = @microphone.MicrophoneDevice::parse_listing(listing)
  for device in devices {
    println(device.session_label())
  }
}
