# RX UI, Compute, RF, and Audio PCBs

## Overview
The RX (Receiver) consists of three stacked PCBs:
- **Layer 1**: UI Board (display, controls, indicators)
- **Layer 2**: Compute/RF/Audio Board (main MCU, wireless, audio codec, DSP, storage)
- **Layer 3**: Power Board (detailed in a separate document)

This document covers Layers 1 and 2.

## Layer 1: UI Board

### Purpose
Provides user interface for system control, status monitoring, and interaction.

### Key Components
- **Display**: 1.91-inch AMOLED, 240 × 536 resolution.
- **Touch Interface**: Touch and swipe gestures supported.
- **Rotary Encoder**: With push-button function.
- **Status Indicators**: Likely LEDs for wireless status, battery level, etc.
- **Debug/Programming Interface**: UART, JTAG, or similar for firmware development and troubleshooting.
- **Inter-board Connection**: FPC (Flexible Printed Cable) to Layer 2 for low-speed control signals only.

### Functions
- Preset selection (load/save user configurations).
- Parameter adjustment (volume, effect parameters, etc.).
- Tuner (instrument tuning aid).
- CharlieAI controls (if applicable to AI features).
- Wireless status indication (link quality, connection status).
- Battery/power status indication (level, charging state).
- Menu navigation for system settings.

### Constraints
- **High-current signals prohibited**: Battery power, speaker power, and amplifier power rails must NOT be routed through the FPC to Layer 2. Only low-current control signals (e.g., I2C, SPI, UART, GPIO) and low-power signals are permitted.

## Layer 2: Compute/RF/Audio Board

### Purpose
Central processing unit handling wireless reception, audio processing, sensor fusion, DSP computations, system control, and storage.

### Key Components
- **Primary MCU**: STM32H7 series (exact part number to be selected based on performance requirements).
  - Responsible for real-time audio processing, DSP algorithms, TX/RX metadata fusion, and system control.
- **Optional Secondary MCU**: ESP32-S3 (connected directly to STM32H7 via high-speed interface; e.g., SPI, SDIO, or UART).
  - Functions when present: Wi-Fi, Bluetooth/BLE, cloud connectivity, non-critical AI processing, experimental DSP/ML, data services.
  - **Critical Constraint**: The board must operate correctly and fully without the ESP32-S3 soldered on. ESP32-S3 must NOT be in the critical audio signal path unless measurements prove it necessary for system architecture.
- **Wireless RX**:
  - **Prototype**: TI CC8530/CC8531 (2.4 GHz proprietary link).
  - **Production Candidate**: Nordic Semiconductor nRF54L15 (proprietary low-latency 2.4 GHz protocol).
  - Receives: 24-bit PCM audio, TX metadata (pitch, note, etc.), sequence number, timestamp/synchronization information.
- **Audio Codec**: To be selected; must support:
  - 24-bit resolution.
  - 48 kHz minimum sample rate (architecture should allow 96 kHz evaluation).
  - Low-noise ADC for any auxiliary audio inputs (if any).
  - High-quality DAC for audio output to amplifier.
  - Note: The RFQ does not specify if there are auxiliary audio inputs on RX; the primary audio path is from wireless receiver to DAC.
- **Storage**: 16 GB eMMC (embedded Multi-Media Card).
  - Used for: Firmware binaries, DSP profiles, amplifier models, cabinet impulse responses (IRs), audio samples, user recordings, AI/ML models, user presets, system logs, future training/analysis data.

### Responsibilities and DSP Architecture
The RX Compute/RF/Audio Board performs the following functions:

#### Audio Reception
- Receives uncompressed/lossless PCM audio (24-bit, 48 kHz, mono) from TX via wireless link.
- Receives metadata packet containing TX sensor intelligence.
- Uses sequence number and timestamp for synchronization and jitter measurement.

#### Audio Analysis (RX-side)
Independently analyzes the received audio signal to compute:
- FFT (Fast Fourier Transform) for spectral analysis.
- MFCCs (Mel-frequency cepstral coefficients).
- Pitch/F0 (fundamental frequency) and note detection.
- Spectral features (e.g., spectral centroid, flux, rolloff).
- Energy/transient analysis (attack detection, decay, sustain, release).

#### Sensor/Data Fusion
Fuses:
- **TX Sensor Intelligence**: Metadata from TX (pitch, note, confidence, RMS/energy, attack, spectral features, MFCCs, IMU-derived, microphone-derived).
- **RX Audio Analysis**: Features computed from received audio.
- Output: Enhanced understanding of instrument performance and environment for effects control, tuning, or AI features.

#### Real-Time DSP
Must provide the following audio processing capabilities (implemented in firmware on STM32H7):
- **Parametric EQ**: Adjustable center frequency, gain, Q.
- **Graphic EQ**: Where useful (e.g., fixed-band equalizer).
- **High-pass / Low-pass Filters**: For tone shaping.
- **Compression**: Dynamic range compression.
- **Limiter**: Peak limiting to prevent clipping and protect speaker.
- **Gain Staging**: Overall volume control with headroom management.
- **Resonance Compensation**: To counteract resonances in speaker/enclosure.
- **Amp Modelling**: Digital emulation of amplifier characteristics.
- **Cabinet Modelling**: Digital emulation of speaker cabinet acoustics.
- **Convolution / Speaker IR Support**: For loading impulse responses of speakers or cabinets.
- **Volume-dependent EQ**: Tone adjustment that varies with volume level (e.g., loudness contour).
- **Speaker Protection**: Algorithms to prevent overexcursion, overheating, and mechanical damage.

#### System Control
- Manages USB-C PD negotiation (via communication with Power Board).
- Controls dynamic amplifier power limit (based on telemetry from Power Board).
- Manages UI communication (via FPC to Layer 1).
- Handles storage access (eMMC).
- Oversees wireless link maintenance and reconnection.
- Manages system power states (active, sleep, etc.).

#### Critical Audio Path Constraint
The ESP32-S3 (if present) must NOT be in the critical audio signal path unless proven necessary by measured system architecture. The critical audio path includes:
- Audio input from wireless receiver.
- Audio processing algorithms (DSP).
- Audio output to DAC and amplifier.
Thus, the ESP32-S3 is limited to non-real-time or background tasks.

### Unresolved Specifications
- The exact audio codec part number is not specified; selection must meet 24-bit/48 kHz minimum and low-noise/high-quality requirements.
- The STM32H7 exact part number is not specified; must be chosen based on processing power, memory, and peripheral needs for the DSP workload.
- The wireless RX module exact part number is not fixed; CC8530/CC8531 (prototype) and nRF54L15 (production candidate) are options, but other modules meeting latency and bandwidth requirements may be considered.
- The exact interface between Layer 1 (UI) and Layer 2 (Compute) via FPC is not detailed (which signals are permitted: I2C, SPI, UART, GPIO, etc.).
- Whether the RX has any auxiliary audio inputs (e.g., for line-in or Bluetooth audio) is not specified; the RFQ focuses on the wireless audio path from TX.

### Open Questions
1. What is the maximum allowable latency for the RX audio processing chain (wireless reception to DAC output)?
2. What is the required update rate for metadata and control information between TX and RX?
3. What is the exact format of the metadata packet (field sizes, packing, error detection)?
4. What are the specific DMA and peripheral requirements for the STM32H7 to handle I2S audio at 24-bit/48 kHz while performing DSP?
5. What is the expected storage bandwidth requirement for the eMMC (e.g., for logging, AI model loading)?
6. How should the UI FPC be structured to avoid signal integrity issues while keeping low latency for controls?
