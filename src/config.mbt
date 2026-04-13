///|
/// Clamp a channel count to the minimum usable value.
fn min_channels(value : Int) -> Int {
  if value < 1 {
    1
  } else {
    value
  }
}

///|
/// Clamp a sample rate to the minimum supported voice-capture rate.
fn min_sample_rate(value : Int) -> Int {
  if value < 8_000 {
    8_000
  } else {
    value
  }
}

///|
/// Create a capture configuration.
///
/// Every argument has a conservative default: mono, 48 kHz, floating-point
/// audio with voice-processing flags disabled. Callers can override only the
/// fields they care about, then call `normalized` before sizing buffers or
/// opening a native capture stream. This keeps common code short while still
/// making platform-sensitive options explicit at the call site.
pub fn CaptureConfig::new(
  channels? : Int = 1,
  sample_rate_hz? : Int = 48_000,
  sample_format? : SampleFormat = F32,
  echo_cancellation? : Bool = false,
  noise_suppression? : Bool = false,
) -> CaptureConfig {
  {
    channels,
    sample_rate_hz,
    sample_format,
    echo_cancellation,
    noise_suppression,
  }
}

///|
/// Return the number of bytes occupied by one sample.
///
/// This is useful when translating frame counts into byte sizes for native
/// buffers. `I16` and `U16` occupy two bytes per channel, while `F32` occupies
/// four bytes per channel.
pub fn SampleFormat::bytes_per_sample(self : SampleFormat) -> Int {
  match self {
    I16 => 2
    U16 => 2
    F32 => 4
  }
}

///|
/// Normalize a capture configuration into safe runtime bounds.
///
/// A configuration with fewer than one channel is clamped to mono, and a sample
/// rate below 8 kHz is clamped to 8 kHz. The sample format and
/// voice-processing flags are preserved so callers do not lose intent when
/// normalizing user-provided settings.
pub fn CaptureConfig::normalized(self : CaptureConfig) -> CaptureConfig {
  {
    channels: min_channels(self.channels),
    sample_rate_hz: min_sample_rate(self.sample_rate_hz),
    sample_format: self.sample_format,
    echo_cancellation: self.echo_cancellation,
    noise_suppression: self.noise_suppression,
  }
}

///|
/// Return the preferred frame count for one responsive capture chunk.
///
/// The recommendation is ten milliseconds of audio after normalization. For
/// example, 48 kHz audio yields 480 frames, while an invalid 4 kHz input first
/// normalizes to 8 kHz and then yields 80 frames.
pub fn CaptureConfig::recommended_chunk_frames(self : CaptureConfig) -> Int {
  self.normalized().sample_rate_hz / 100
}

///|
/// Whether a config requests voice-processing behavior.
///
/// This helper only checks caller intent. It does not promise that the current
/// operating system or selected device can actually provide echo cancellation
/// or noise suppression.
pub fn CaptureConfig::uses_voice_processing(self : CaptureConfig) -> Bool {
  self.echo_cancellation || self.noise_suppression
}
