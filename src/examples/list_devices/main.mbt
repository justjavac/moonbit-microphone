///|
/// Run the native microphone discovery example.
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
