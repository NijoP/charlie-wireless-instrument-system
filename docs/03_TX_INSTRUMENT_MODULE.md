# TX Instrument Module

## Purpose
The TX (Transmitter) module is a compact, battery-powered unit mounted directly to the musical instrument. It captures audio from the instrument, processes sensor data, and wirelessly transmits audio and metadata to the RX receiver.

## Key Requirements (from RFQ)

### Mechanical
- Compact form factor for direct mounting on instrument.
- No specific dimensions given, but must be suitable for instrument mounting.

### Power
- **Battery**: 3.7 V LiPo cell.
  - Initial capacity: ~600 mAh.
  - Scalable to ~1000 mAh (same form factor assumed).
- **Charging**: USB-C connector.
- **Protection**: Over-voltage, over-current, over-temperature protection.
- **Fuel Gauge**: Accurate state-of-charge (SOC) estimation.

### Audio Acquisition
- **Resolution**: 24-bit PCM minimum.
- **Sample Rate**: 48 kHz minimum (architecture should allow future evaluation of 96 kHz).
- **Channels**: Mono.
- **Audio Path**:
  - Inputs: Instrument pickup (analog) and digital MEMS microphone.
  - Analog Front-end: Low-noise, high-quality, instrument-level biasing and gain.
  - No lossy compression in the real-time instrument path.
  - Must preserve transient/attack and dynamic information.

### Sensors
- **IMU**: LSM6DS3TR-C (3-axis accelerometer + 3-axis gyroscope).
  - Provides movement, orientation, angular velocity, acceleration data.
- **Digital MEMS Microphone**: For ambient sound or noise reference (exact use case not fully specified; see unresolved questions).

### Processing
- **Processor**: ESP32-S3 (prototype).
  - Responsible for real-time edge processing.
  - Tasks: Audio acquisition, initial processing, metadata generation.
- **Metadata Generation** (compact data alongside audio stream):
  - Fundamental frequency (F0) / pitch.
  - Musical note.
  - Pitch confidence.
  - Cents deviation (error from ideal note).
  - RMS/energy level.
  - Attack strength and type (e.g., pluck, bow hit).
  - Spectral features (e.g., spectral centroid, flux, rolloff).
  - MFCCs (Mel-frequency cepstral coefficients) where useful.
  - IMU-derived: Movement, orientation, angular velocity, acceleration.
  - Microphone-derived acoustic features (e.g., from MEMS mic).
- **Constraint**: Do not transmit complete FFT bins unless technically justified (to limit bandwidth).

### Wireless Transmission
- **Prototype**: CC8530/CC8531 (TI) for 2.4 GHz proprietary link.
- **Production Candidate**: nRF54L15 (Nordic Semiconductor) with proprietary low-latency 2.4 GHz protocol.
- **Architecture Requirement**: Wireless technology must be replaceable without redesigning the complete sensor/audio architecture (i.e., modular wireless interface).
- **Data Transport**:
  - Uncompressed/lossless PCM audio (24-bit, 48 kHz, mono).
  - Metadata packets (as above).
  - Sequence number and timestamp/synchronization information (explicitly required on RX side; implied on TX side for synchronization).

### Latency
- **Target End-to-End Latency**: <5 ms (ideal).
- **Realistic Expectation**: 10 ms total end-to-end latency.
- **RF Subsystem Design**: Must be designed for the lowest practical packetization and buffering latency.
- **Validation**: Actual latency must be experimentally measured.

### Unresolved Specifications (from RFQ)
- The exact use case of the digital MEMS microphone is not fully specified (is it for noise cancellation, ambient mixing, or dual-mic audio?).
- The audio-channel definition or microphone transmission behavior is left unresolved (whether the MEMS mic audio is transmitted, used locally for processing, or both).

### Component Notes
- **Audio ADC/Codec**: To be selected; must support 24-bit, 48 kHz mono, low-noise.
- **MEMS Microphone**: Digital output (likely I2S or PDM).
- **IMU**: LSM6DS3TR-C is specified exactly.
- **Processor**: ESP32-S3 is specified for prototype; production may consider other options if processing needs change.
- **Wireless**: CC8530/CC8531 and nRF54L15 are specified; alternative radios may be considered if they meet latency and bandwidth requirements.

### Open Questions
1. What is the intended use of the MEMS microphone audio? Is it mixed with instrument pickup, used for noise cancellation, or transmitted separately?
2. What is the maximum allowed audio latency budget for the TX processing alone?
3. What is the expected data rate for metadata, and what is the permissible latency contribution from metadata packetization?
4. Are there any regulatory constraints (e.g., FCC, CE) for the wireless link that must be considered in frequency selection and power output?
