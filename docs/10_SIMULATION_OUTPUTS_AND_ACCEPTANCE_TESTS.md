# Simulation Outputs and Acceptance Tests

## Purpose
This document describes the expected outputs from the MATLAB mathematical model (to be implemented in a future phase) and the acceptance criteria that will be used to validate the model and system architecture.

## Expected Simulation Outputs
The MATLAB model will produce the following categories of outputs, which can be used to assess system feasibility and inform design decisions.

### 1. Audio Quality Metrics
- **Frequency Response**: Magnitude (dB) and phase (degrees) vs. frequency (Hz) for the end-to-end audio chain (TX audio input → RX audio output) under various DSP settings.
- **THD+N**: Total Harmonic Distortion plus Noise (%) at different output power levels and frequencies.
- **Signal-to-Noise Ratio (SNR)**: Ratio of full-scale signal to noise floor (dB).
- **Dynamic Range**: Ratio of maximum undistorted signal to noise floor (dB).
- **Transient Response**: Rise time, fall time, settling time, and overshoot for step inputs.
- **Intermodulation Distortion (IMD)**: For multi-tone signals.
- **Frequency Response Flatness**: Variation in passband (e.g., 20 Hz - 20 kHz) under nominal DSP settings.

### 2. Wireless Link Performance
- **End-to-End Latency**: 
  - Mean latency (ms).
  - Latency jitter (standard deviation, ms).
  - Percentile latencies (50th, 90th, 95th, 99th).
  - Maximum observed latency.
- **Packet Loss Rate**: 
  - Overall percentage of lost packets.
  - Burst loss characteristics (average burst length).
- **Throughput**: 
  - Effective audio data rate (kbps) after accounting for packet loss and overhead.
  - Metadata update rate (Hz).
- **Link Reliability**: 
  - Connection establishment time.
  - Reconnection time after link loss.
  - Error-free seconds (EFS) under test conditions.

### 3. DSP Processing Load
- **MIPS Utilization**: 
  - Estimated million instructions per second required for active DSP algorithms.
  - Percentage of available MCU MIPS utilized.
- **Memory Usage**: 
  - RAM usage (bytes) for buffers, coefficients, state variables.
  - ROM usage (bytes) for code and constant tables.
- **Execution Time**: 
  - Worst-case execution time (WCET) per audio block (microseconds).
  - Jitter in execution time (if applicable).

### 4. Power and Battery Performance
- **Power Consumption**: 
  - Total system power (watts) under various scenarios (idle, audio playback, max volume).
  - Amplifier power (watts) vs. volume setting.
  - USB-C input power (watts) vs. source capability.
  - Battery discharge current (milliamps) over time.
- **Battery Runtime**: 
  - Estimated hours of operation for TX (600 mAh and 1000 mAh batteries).
  - Estimated hours of operation for RX (battery capacity to be defined).
  - Runtime vs. volume level and wireless usage.
- **Charging Behavior**: 
  - Time to charge from empty to full (hours).
  - Charging efficiency (percentage).
  - Simultaneous charging and operation feasibility.

### 5. Thermal Performance
- **Component Temperatures**: 
  - Junction temperature (°C) for key components (MCU, amplifier, wireless IC, power ICs).
  - Case temperature (°C) for heat-sinked components.
  - Internal ambient temperature rise (°C) inside enclosure.
- **Thermal Throttling Points**: 
  - Temperature at which amplifier power limiting activates.
  - Temperature at which system performance may be reduced (if modeled).

### 6. System-Level Metrics
- **End-to-End System Latency**: 
  - From instrument audio input to speaker audio output (includes TX processing, wireless, RX processing, DSP, DAC, amplifier, speaker group delay).
  - Must meet <5 ms ideal, <10 ms realistic target.
- **Power Efficiency**: 
  - Overall system efficiency (audio output power / USB-C input power) at various operating points.
- **Speaker Excursion**: 
  - Estimated peak cone displacement (mm) under maximum safe power (if coupled with speaker model).
- **Metadata Accuracy**: 
  - Error between transmitted and received metadata values (if modeled).

## Acceptance Tests
Acceptance tests are derived from the RFQ's required validation sections and will be used to evaluate the prototype hardware. The MATLAB model should be able to predict whether the design will pass these tests.

### RFQ Required Validation Areas
The RFQ specifies that the prototype must measure the following:

#### Wireless
- TX/RX latency
- Packet loss
- RF range
- Jitter
- Synchronization accuracy

#### Audio
- Frequency response
- THD+N
- SNR
- Dynamic range
- ADC/DAC performance
- Transient response

#### DSP
- FFT processing load
- MFCC processing load
- Pitch detection latency
- TX/RX metadata synchronization
- CPU/RAM utilization

#### Power
- Battery runtime
- Charging behaviour
- USB-C input power
- PD negotiation
- Maximum amplifier output
- Dynamic power limiting
- Thermal performance

#### Acoustic (Preliminary Only)
- Measure the development speaker in the supplied enclosure.
- **Note**: Do not treat the first speaker/enclosure combination as final. The goal of V1 is to establish the electronics, wireless, DSP, and power platform so that different acoustic configurations can subsequently be evaluated through DSP and physical testing.

### Proposed Acceptance Criteria
Each validation area should have defined acceptance criteria. Since the RFQ does not provide numerical thresholds, we will propose criteria based on engineering judgment and typical targets for similar systems. These criteria will be refined during the MATLAB model phase and finalized during prototype testing.

#### Wireless Acceptance Criteria (Proposed)
- **End-to-End Latency**: ≤ 10 ms (95th percentile) for audio packet; ≤ 5 ms ideal target.
- **Packet Loss Rate**: ≤ 1% under normal operating conditions (no excessive interference).
- **RF Range**: ≥ 10 meters line-of-sight with acceptable latency and loss.
- **Jitter**: ≤ 1 ms variance in packet arrival time.
- **Synchronization Accuracy**: Timestamp error ≤ 100 microseconds between TX and RX audio streams.

#### Audio Acceptance Criteria (Proposed)
- **Frequency Response**: ±3 dB from 20 Hz to 20 kHz (relative to 1 kHz) with flat EQ.
- **THD+N**: ≤ 0.5% at 1 kHz, 90% of maximum undistorted output.
- **SNR**: ≥ 85 dBA (A-weighted) at full scale.
- **Dynamic Range**: ≥ 80 dB.
- **Transient Response**: Rise time ≤ 10 microseconds (for electrical output); speaker transient limited by mechanics.
- **ADC/DAC Performance**: 
  - ADC: ENOB ≥ 22 bits at 48 kHz.
  - DAC: ENOB ≥ 21 bits at 48 kHz.

#### DSP Acceptance Criteria (Proposed)
- **FFT Processing Load**: ≤ 10% of available MIPS for 1024-point FFT at 48 kHz.
- **MFCC Processing Load**: ≤ 5% of available MIPS for 13 coefficients.
- **Pitch Detection Latency**: ≤ 2 ms from audio input to pitch output.
- **TX/RX Metadata Synchronization**: Metadata age ≤ 5 ms when used for fusion.
- **CPU/RAM Utilization**: 
  - Total CPU usage ≤ 80% to allow headroom for interrupts and background tasks.
  - RAM usage ≤ 70% of available memory.

#### Power Acceptance Criteria (Proposed)
- **Battery Runtime**: 
  - TX: ≥ 4 hours continuous operation at moderate volume with 600 mAh battery.
  - TX: ≥ 6 hours continuous operation at moderate volume with 1000 mAh battery.
  - RX: ≥ 6 hours continuous operation (battery capacity TBD).
- **Charging Behaviour**: 
  - Charge from 0% to 80% in ≤ 2 hours with 5V/2A USB-C input.
  - Charge from 0% to 100% in ≤ 3 hours with 5V/2A USB-C input.
  - Simultaneous charging and operation possible when input power > system consumption.
- **USB-C Input Power**: 
  - Operate correctly with USB-C sources from 5V/500mA (USB 2.0) to 20V/3A (USB-C PD).
  - Detect and negotiate PD contracts correctly.
- **PD Negotiation**: 
  - Successfully negotiate 5V, 9V, 15V, 20V contracts as offered by source.
  - Default to 5V/500mA if no PD source detected.
- **Maximum Amplifier Output**: 
  - Deliver ≥ 18 W RMS into 8 Ω load (90% of 20 W target) with THD+N ≤ 1%.
  - Peak power ≥ 20 W for short bursts.
- **Dynamic Power Limiting**: 
  - Amplifier output reduces proportionally to available input power within 10 ms of power drop.
  - No brownout, reboot, or audible glitch during power reduction.
  - Minimum output power during limiting: ≥ 1 W (to maintain usability).
- **Thermal Performance**: 
  - No component exceeds its maximum junction temperature rating during continuous operation at maximum volume.
  - Surface temperature of enclosure ≤ 45 °C (comfortable to touch).
  - Thermal throttling activates before any component reaches unsafe temperature.

#### Acoustic Acceptance Criteria (Preliminary, Proposed)
- **Frequency Response**: Measurable and repeatable within the supplied enclosure.
- **THD+N**: ≤ 2% at 1 kHz, 90% of maximum undistorted output (development speaker).
- **Note**: These criteria are for validation of the electronics platform only; final acoustic tuning will occur later.

## Validation Methodology
The MATLAB model will be used to predict whether a given set of component choices and architecture parameters will likely pass the acceptance tests. The model outputs will be compared against the proposed criteria.

### Model Validation Steps
1. **Component Selection**: Choose tentative components (audio codec, wireless IC, MCU, amplifier, etc.).
2. **Parameter Input**: Enter component specifications into the parameter registry.
3. **Model Execution**: Run the simulation with default test signals and operating conditions.
4. **Output Analysis**: 
   - Compare audio quality metrics with audio acceptance criteria.
   - Compare wireless link metrics with wireless acceptance criteria.
   - Compare power and thermal metrics with power acceptance criteria.
   - Compare DSP load with DSP acceptance criteria.
5. **Iteration**: If any metric fails to meet criteria, adjust component choices or architecture parameters and re-run.
6. **Sensitivity Analysis**: Identify which parameters have the greatest impact on failing metrics.

### Sign-off Process
Upon completion of the MATLAB model phase, the model outputs and a summary of how they relate to the acceptance criteria will be reviewed. A decision will be made to proceed to BOM creation if the model indicates a high likelihood of passing the acceptance tests.

## Limitations
- The MATLAB model is a simulation and cannot replace hardware testing.
- Acceptance criteria are provisional and will be finalized based on engineering judgment and prototype testing.
- Some factors (e.g., antenna placement, enclosure effects on thermals, RF interference in specific environments) are not fully modeled.
