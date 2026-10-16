# Interfaces and Communication Protocol

## Purpose
This document describes the hardware interfaces between the Charlie system's PCBs and layers, and defines the communication protocol for the wireless link between TX and RX.

## Hardware Interfaces

### Inter-board Connections (RX Stack)
The RX uses three stacked PCBs connected via flexible printed cables (FPCs) or board-to-board (BTB) connectors for low-speed signals. High-current signals (power, speaker) must NOT traverse these connectors.

#### Layer 1 (UI) to Layer 2 (Compute/RF/Audio)
- **Permitted Signals** (low-current, low-voltage):
  - I2C (for display configuration, touch controller, sensor reading).
  - SPI (for display updates, if not using parallel RGB).
  - UART (for debug console, optional command interface).
  - GPIO (for buttons, encoder, LEDs, interrupts).
  - Optional: PWM (for backlight control, if needed).
- **Prohibited Signals**:
  - Battery voltage or current.
  - USB-C VBUS or PD negotiation signals.
  - Amplifier power rail voltage or current.
  - Speaker audio signals (amplified output).
- **Connector Type**: FPC with fine-pitch (e.g., 0.5 mm) or BTB connector; must be rated for signal integrity up to the highest frequency used (e.g., SPI clock for display).

#### Layer 2 (Compute/RF/Audio) to Layer 3 (Power)
- **Permitted Signals**:
  - I2C or SPI for power management IC communication (charger, fuel gauge, DC/DC converters).
  - UART for status reporting (optional).
  - GPIO for interrupts (power good, battery low, thermal alert).
  - Analog voltage sensing (via isolated amplifier or voltage divider) for input voltage, battery voltage, system rail voltages.
  - Analog current sensing (via shunt resistor and amplifier) for input current, battery current, system current.
  - Digital signals for enabling/disabling DC/DC converters (e.g., EN pins).
  - PWM signals for controlling LED drivers or fan speed (if present).
- **Prohibited Signals**:
  - High-current paths (battery power, amplifier power) must use dedicated wires or thick traces, not the FPC/BTB.
- **Connector Type**: FPC or BTB, with consideration for analog signal integrity (shielding, grounding) if needed.

### TX Internal Interfaces
- **Audio Inputs**:
  - Instrument pickup: Analog signal to audio ADC (differential or single-ended, biased).
  - MEMS microphone: Digital signal (I2S or PDM) to processor.
- **IMU**: LSM6DS3TR-C via I2C or SPI to processor.
- **Processor to Wireless Radio**: SPI for configuration and data, or parallel GPIO for high-speed data (if using proprietary mode).
- **Processor to USB-C**: USB 2.0 OTG for charging and potential debug.
- **Power Management**: Battery voltage and current monitoring (via ADC), charger status GPIO.

### RX Internal Interfaces (Layer 2)
- **Wireless Radio to MCU**: SPI for configuration and high-speed data (I2S audio data may use dedicated lines or SPI with DMA).
- **Audio Codec to MCU**: I2S for audio data, I2C for configuration.
- **eMMC to MCU**: SD/MMC interface (wide bus) for high-speed storage access.
- **ESP32-S3 (if present)**: High-speed interface to STM32H7 (e.g., SDIO, SPI, or UART) for data offload.
- **Power Board Communication**: I2C or SPI for telemetry (input power, battery status, temperature).
- **UI Communication**: I2C, SPI, UART, or GPIO to Layer 1 via FPC.
- **Debug/Programming**: JTAG or SWD for STM32H7; UART for console.

### External Interfaces
- **TX**:
  - USB-C Connector: For charging and firmware updates.
  - Instrument Pickup Jack: Standard 6.35 mm (1/4") mono jack or 3.5 mm TRS (as per instrument).
  - MEMS Mic Port: If external, small aperture with water-resistant membrane.
- **RX**:
  - USB-C Connector: For power input, USB-C PD, and potential firmware/data.
  - UI: Display, touchscreen, rotary encoder, status indicators.
  - Power Output: Speaker terminals (binding posts or screw terminals) for amplified audio.
  - Optional: Headphone jack (not specified in RFQ).
  - Optional: Line-in or Bluetooth audio (not specified; assume not present in V1).

## Wireless Communication Protocol (TX to RX)
The wireless link carries two primary data streams: audio and metadata. The protocol must be low-latency and reliable enough for real-time instrument audio.

### General Characteristics
- **Medium**: 2.4 GHz ISM band.
- **Modulation**: Proprietary (GFSK, or similar) to achieve low latency.
- **Direction**: Primarily TX → RX (audio and metadata). RX → TX may be used for control (e.g., volume, presets) but is not required for basic operation.
- **Packetization**: Fixed interval to minimize latency jitter.
- **Error Handling**: Forward Error Correction (FEC) or packet loss concealment; retransmissions avoided due to latency.
- **Synchronization**: Sequence numbers and timestamps for jitter measurement and loss detection.

### Packet Structure (Proposed)
Each wireless packet contains:
1. **Preamble** (fixed pattern for receiver synchronization, 1-2 bytes).
2. **Packet Header**:
   - Packet Type (Audio/Metadata/Control, 1 byte).
   - Sequence Number (2 bytes, wraps at 65535).
   - Timestamp (4 bytes, microsecond counter or sample count).
   - Length Field (2 bytes, payload length in bytes).
3. **Payload**:
   - **Audio Packet**:
     - PCM Audio Data: 24-bit samples, packed (e.g., 3 bytes per sample).
     - For 48 kHz and 1 ms packetization: 48 samples × 3 bytes = 144 bytes.
   - **Metadata Packet** (sent periodically, e.g., every 10 ms or when changed):
     - Pitch (F0): 2 bytes (unsigned integer, Hz, range 0-2000).
     - Note: 1 byte (0-119, representing MIDI note number).
     - Pitch Confidence: 1 byte (0-100).
     - Cents Deviation: 2 bytes (signed integer, -100 to +100).
     - RMS/Energy: 2 bytes (unsigned integer, 0-65535).
     - Attack Strength/Type: 2 bytes (strength 0-255, type enum 0-7).
     - Spectral Features: 4 bytes (e.g., spectral centroid, flux, rolloff, each 1 byte scaled).
     - MFCCs: 6 bytes (first 6 coefficients, 1 byte each).
     - IMU Data: 6 bytes (accel X,Y,Z, each 2 bytes signed; or gyro only).
     - Microphone-derived Features: 2 bytes (placeholder).
     - Total Metadata: ~24-32 bytes (variable based on inclusion).
   - **Control Packet** (RX → TX, if implemented):
     - Command ID (1 byte).
     - Parameter Value (2-4 bytes).
4. **Error Detection**: CRC-16 (2 bytes) over header and payload.
5. **Postamble** (optional, 1 byte).

### Example Packet Timing (Audio)
- **Packetization Interval**: 1 ms.
- **Audio Samples per Packet**: 48 samples (48 kHz × 0.001 s).
- **PCM Payload**: 48 samples × 3 bytes = 144 bytes.
- **Metadata**: Not in every audio packet; sent separately every 10 ms (10 audio packets).
- **Average Overhead**: Assuming 20 bytes header + 2 bytes CRC = 22 bytes per packet.
- **Total Packet Size**: 144 + 22 = 166 bytes (audio-only packet).
- **Transmission Time**: Depends on wireless data rate.
  - At 1 Mbps: 166 × 8 / 1e6 = 1.328 ms.
  - At 2 Mbps: 0.664 ms.
- **Total Latency Contribution**: Packetization delay (1 ms) + transmission delay + reception delay + depacketization delay.
  - If transmission+reception delay is 0.5 ms at 2 Mbps, total wireless latency ≈ 1 + 0.5 + 0.5 = 2 ms (one-way).

### Protocol Requirements
- **Low Latency**: Minimize packetization interval and transmission time.
- **Reliability**: Use FEC (e.g., Reed-Solomon) to correct burst errors without retransmission.
- **Loss Concealment**: Implement packet loss concealment (PLC) algorithm on RX to hide occasional lost packets.
- **Dynamic Rate Option**: Allow fallback to lower data rate if interference necessitates, but maintain latency goal.
- **Security**: Not required for V1 (no encryption needed).
- **Coexistence**: Implement clear channel assessment (CCA) before transmission to avoid collisions with Wi-Fi/Bluetooth.

### Unresolved Specifications
- The exact wireless protocol (packet format, timing, error handling) is not specified in the RFQ.
- Whether metadata is sent in every packet or periodically is not specified.
- The exact data fields and sizes for metadata are not specified (we derived from RFQ listed features).
- Whether the wireless link uses TDD (time-division duplex) or FDD (frequency-division duplex) is not specified.
- The exact radio configuration (data rate, modulation, coding) is not specified.

### Open Questions
1. What is the maximum allowable jitter in the wireless link that the DSP can tolerate?
2. What is the expected packet loss rate that the concealment algorithm should handle?
3. Should the wireless link support bidirectional communication for RX-to-TX control (e.g., volume, presets)?
4. What is the required transmit power range to achieve desired range (e.g., 10-30 meters) while meeting regulatory limits?
5. How will the wireless link be initialized and paired (TX to RX binding)?
6. What is the beaconing or connection maintenance strategy to ensure low-latency reconnection after interruption?

### Dependencies
- The wireless protocol design depends on the selected radio (CC8530/CC8531 or nRF54L15) and its capabilities.
- The metadata size and update rate affect the wireless bandwidth requirement.
- The packetization interval contributes directly to latency budget.
- The error handling strategy affects the need for retransmission buffers and latency.

### Validation Methods
- **Latency Measurement**: End-to-end latency with audio ping-pong (measure time from TX input to RX output).
- **Packet Loss Rate**: Log lost packets and correlate with audio artifacts.
- **Frequency Spectrum**: Measure occupied bandwidth and ensure compliance with ISM band regulations.
- **Coexistence Test**: Operate alongside Wi-Fi routers and Bluetooth devices.
- **Range Test**: Determine maximum range at which latency and loss remain acceptable.
- **Power Consumption**: Measure TX and RX battery life with wireless link active.
