# Mathematical Model Plan (MATLAB Simulation)

## Purpose
This document outlines the plan for a mathematical model of the Charlie Wireless Instrument System to be implemented in MATLAB in a future phase. The model will simulate key system aspects to inform component selection, BOM creation, and architecture validation before PCB design.

## Modeling Philosophy
- **Independent, Reusable Modules**: Each subsystem modeled as a separate module with well-defined inputs and outputs.
- **Parameter Registry**: All parameters sourced from datasheets, requirements, or measurements, with provenance and uncertainty tracking.
- **Replaceable Component Models**: Component-specific models (e.g., audio codec, wireless radio) can be swapped to evaluate alternatives.
- **No Fabricated Data**: Unknown values remain explicit (marked as TBD) rather than being assumed.
- **Validation**: Each module validated against known behavior, datasheet specifications, or simplified analytical results.
- **Compatibility**: Designed for Base MATLAB where possible; toolbox usage noted and justified.

## Planned Modules

### 1. Parameter Registry
- **Objective**: Central repository for all model inputs, ensuring traceability and consistency.
- **Inputs**: 
  - Parameter name, symbol, value, unit, source (datasheet/page, requirement ID), confidence level (high/medium/low), notes.
- **Outputs**: Struct or dictionary of parameters accessible by all modules.
- **Assumptions**: 
  - Parameters are constant unless modeled as variables (e.g., battery SOC, temperature).
  - Uncertainty propagated where justified (e.g., tolerance analysis).
- **Validation**: Manual review of sources; cross-check with requirements.
- **Dependencies**: None (foundational).

### 2. Audio Acquisition
- **Objective**: Model the TX audio signal path from analog input to digital samples.
- **Inputs**: 
  - Analog signal waveform (voltage vs. time).
  - Analog front-end characteristics: frequency response, noise density, THD, gain.
  - ADC specifications: resolution (bits), sample rate (Hz), SNR, SINAD, input-referred noise, bandwidth.
  - Timing jitter (if modeled).
- **Outputs**: 
  - Digitized audio stream (sampled values).
  - Quantization noise and error.
  - Analog front-end and ADC noise contribution.
- **Equations/Governing Relationships**:
  - Ideal sampling: \( x[n] = x_c(nT_s) \).
  - Quantization error: \( q[n] = \frac{V_{ref}}{2^b} \) (uniform distribution).
  - Noise addition: \( y[n] = x[n] + n_{AFE}[n] + n_{ADC}[n] \).
- **Required Datasheet Inputs**: ADC noise density, THD, SNR, input capacitance, sampling jitter.
- **Assumptions/Limitations**: 
  - Linear operation of analog front-end (no clipping modeled unless specified).
  - ADC modeled as ideal sampler plus quantization and additive noise.
- **Validation**: Compare spectral characteristics (SNR, THD) with datasheet values for a known input signal.
- **Dependencies**: Parameter registry (for ADC specs, analog front-end specs).

### 3. Wireless Link
- **Objective**: Model the transmission of audio and metadata packets from TX to RX, including latency, packet loss, and jitter.
- **Inputs**: 
  - Audio sample rate and bit depth.
  - Packetization interval (seconds).
  - Metadata size and update rate (bytes per packet, packets per second).
  - Wireless radio characteristics: data rate (bps), modulation, packet overhead (header, CRC, ACK if any), transmit power, receiver sensitivity.
  - Channel characteristics: path loss model (e.g., Friis), multipath, interference (optional).
  - Packet loss model (e.g., random loss with probability p, burst loss model).
  - Latency components: packetization delay, transmission delay, propagation delay, reception delay, depacketization delay.
- **Outputs**: 
  - Received audio stream (with possible loss, jitter, delay).
  - Received metadata stream (with possible delay and loss).
  - Latency statistics (mean, variance, percentiles).
  - Packet loss rate.
  - Jitter (delay variation).
- **Equations/Governing Relationships**:
  - Packetization delay: \( T_{pkt} = N_{samples} / f_s \) (if waiting to fill packet).
  - Transmission delay: \( T_{tx} = (PacketSize_{bits}) / R_{data} \).
  - Propagation delay: \( T_{prop} = d / c \) (negligible for <300m).
  - Reception delay: similar to transmission.
  - Total one-way latency: \( T_{wireless} = T_{pkt} + T_{tx} + T_{prop} + T_{rx} + T_{depkt} \).
  - If using ACKs: add round-trip time for retransmission (avoided in low-latency design).
  - Packet loss: \( P_{loss} = f(\text{distance, interference, obstacles}) \).
- **Required Datasheet Inputs**: Radio data rate, transmit power, receiver sensitivity, packet overhead sizes.
- **Assumptions/Limitations**: 
  - Simplified channel model (path loss only) unless multipath is significant.
  - No modeling of modulation/demodulation errors beyond packet loss.
  - Fixed latency assumed if no retransmissions.
- **Validation**: 
  - Compare latency and loss with reference designs or simple test cases.
  - Verify that gross data rate matches audio + metadata rate plus overhead.
- **Dependencies**: 
  - Parameter registry (radio specs, audio specs).
  - Audio Acquisition module (for source audio stream).
  - DSP Workload module (if metadata generation modeled).

### 4. DSP Workload
- **Objective**: Estimate the computational load of the DSP algorithms on the STM32H7 (or TX processor) to ensure real-time feasibility.
- **Inputs**: 
  - DSP algorithms enabled (EQ, compression, etc.) and their parameters.
  - Audio sample rate (Hz) and frame processing size (samples per block).
  - Algorithm complexity: operations per sample (e.g., FIR filter taps, IIR biquads, FFT size).
  - Memory access requirements (coefficients, state variables).
  - MCU clock speed (Hz) and instruction cycle count.
- **Outputs**: 
  - Estimated million instructions per second (MIPS) required.
  - Estimated memory usage (RAM and ROM).
  - Real-time feasibility (MIPS required < MIPS available).
  - Suggested block size and processing latency.
- **Equations/Governing Relationships**:
  - For each algorithm: 
    - FIR filter: \( N_{taps} \times 2 \) operations per sample (multiply-add).
    - IIR biquad: ~5 operations per sample.
    - FFT: \( N \log_2 N \) complex operations per block.
    - MFCC: additional steps (mel filterbank, DCT).
  - Total operations per second = \( \sum (\text{ops per sample} \times f_s) \) (for sample-based) or \( \sum (\text{ops per block} \times f_s / N_{block}) \) (for block-based).
  - Available MIPS = MCU clock speed / instructions per cycle (e.g., 400 MHz / 1.25 ≈ 320 MIPS for Cortex-M7 with 1.25 CPI).
- **Required Datasheet Inputs**: 
  - STM32H7 clock speed, core architecture (Cortex-M7), typical CPI for DSP instructions (if using SIMD).
  - Memory size and bandwidth (RAM, ROM).
- **Assumptions/Limitations**: 
  - Assumes ideal compiler and no OS overhead (bare-metal or RTOS with minimal tick).
  - Does not model cache misses or memory wait states (simplified).
  - Assumes algorithms are implemented efficiently.
- **Validation**: 
  - Compare estimated MIPS with simple benchmarks (e.g., FIR filter execution time measured on target hardware).
  - Verify memory usage fits within MCU RAM/ROM.
- **Dependencies**: 
  - Parameter registry (DSP algorithm specs, MCU specs).
  - Audio Acquisition module (for sample rate).
  - Wireless Link module (if metadata generation modeled).

### 5. Power-tree Model
- **Objective**: Model the power flow from USB-C input through converters to system loads and battery, enabling dynamic power control analysis.
- **Inputs**: 
  - USB-C input voltage profile (Vin(t)) and current limit (from PD negotiation).
  - Battery characteristics: open-circuit voltage vs. SOC, internal resistance, capacity (Ah).
  - Power-path management topology (diodes, MOSFETs, or ideal switches).
  - DC/DC converter efficiencies (as function of load current).
  - System load profile: 
    - Static power (MCU, wireless, codec, etc.).
    - Dynamic power (DSP processing load proportional to activity).
    - Amplifier power (function of output volume and speaker load).
  - Charging current profile (if charging enabled).
  - Thermal characteristics (power dissipation vs. temperature).
- **Outputs**: 
  - Power available at system rails and amplifier rail over time.
  - Battery SOC over time.
  - Power dissipated in each component (for thermal analysis).
  - Input power drawn from USB-C.
  - System efficiency (output power / input power).
- **Equations/Governing Relationships**:
  - Power conservation: \( P_{in} = P_{system} + P_{amplifier} + P_{charging} + P_{loss} \).
  - Buck converter efficiency: \( \eta = P_{out} / P_{in} \) (modeled as lookup table or formula).
  - Battery discharge: \( \frac{dSOC}{dt} = -\frac{I_{bat}}{C_{bat}} \) (ignoring Peukert effect).
  - Power-path loss: \( I^2 \times R_{ds(on)} \) for MOSFETs or diode drop.
  - Amplifier power: \( P_{amp} = \frac{V_{out}^2}{2R_{load}} \) for sine wave (approximate).
- **Required Datasheet Inputs**: 
  - Converter efficiency curves (from datasheets).
  - Battery capacity, internal resistance, voltage-SOC curve.
  - MOSFET Rds(on), diode forward voltage.
  - System component power datasheets (or estimates).
- **Assumptions/Limitations**: 
  - Quasi-static DC analysis (ignores switching ripple unless modeling ripple voltage).
  - Battery modeled with simple SOC model (no temperature aging).
  - Converter efficiency assumed constant for simplicity unless modeled piecewise.
- **Validation**: 
  - Compare with reference designs or simple test cases (e.g., efficiency at full load).
  - Verify power balance in steady state.
- **Dependencies**: 
  - Parameter registry (power specs, battery specs, converter specs).
  - DSP Workload module (for system load variation with DSP activity).
  - Amplifier model (if included).

### 6. Dynamic Amplifier Control
- **Objective**: Model the safe amplifier power limit computation and its effect on amplifier output.
- **Inputs**: 
  - Available input power (from Power-tree model).
  - System consumption (from Power-tree model).
  - Charging reserve (from Power-tree model).
  - Battery voltage and SOC (from Power-tree model).
  - Temperature sensors (from Power-tree model).
  - Amplifier characteristics: efficiency, voltage vs. power curve, thermal limits.
  - Speaker impedance (nominal, varies with frequency).
- **Outputs**: 
  - Maximum safe amplifier power (watts).
  - Recommended gain setting (linear or dB) for DSP.
  - Predicted amplifier output power over time.
  - Predicted speaker excursion and temperature (if coupled with thermal model).
- **Equations/Governing Relationships**:
  - Safe Amplifier Power: \( P_{amp\_safe} = \max(0, P_{in\_avail} - P_{sys} - P_{chrg}) \).
  - Amplifier Output Power: \( P_{amp\_out} = \eta_{amp} \times P_{amp\_rail} \) (if rail power is limited).
  - Gain Setting: \( G_{dB} = 10 \log_{10}(P_{amp\_out} / P_{amp\_ref}) \) (reference power).
  - Speaker Voltage: \( V_{spk} = \sqrt{2 \times P_{amp\_out} \times R_{load}} \) (RMS).
- **Required Datasheet Inputs**: 
  - Amplifier efficiency vs. power.
  - Amplifier thermal shutdown threshold.
  - Speaker nominal impedance and power handling.
- **Assumptions/Limitations**: 
  - Amplifier modeled as ideal gain block with efficiency loss.
  - Speaker impedance assumed resistive (simplified).
  - Thermal effects on speaker not modeled unless coupled with thermal model.
- **Validation**: 
  - Compare with amplifier datasheet power limits.
  - Verify that gain reduction occurs when input power drops.
- **Dependencies**: 
  - Power-tree model (for available input power, system consumption, battery status).
  - Thermal model (if speaker temperature considered).

### 7. TX Battery Model
- **Objective**: Estimate TX battery runtime based on capacity and current consumption.
- **Inputs**: 
  - Battery capacity (Ah) (600 mAh or 1000 mAh).
  - Battery voltage profile (V vs. SOC).
  - TX current consumption profile: 
    - Audio acquisition (ADC, processor).
    - Wireless transmission (TX power, duty cycle).
    - Sensors (IMU, MEMS mic).
    - Microcontroller sleep/active states.
  - Self-discharge rate (optional).
- **Outputs**: 
  - Runtime (hours) until cutoff voltage.
  - Battery voltage over time.
  - Sensitivity analysis to capacity and consumption.
- **Equations/Governing Relationships**:
  - Runtime: \( t = \frac{C_{bat} \times V_{avg}}{I_{avg} \times V_{bat}} \) (simplified) or integrate \( \frac{dSOC}{dt} = -\frac{I_{bat}(t)}{C_{bat}} \) until SOC=0.
  - More accurately: numerically integrate battery discharge with varying load.
- **Required Datasheet Inputs**: 
  - Battery capacity, cutoff voltage.
  - TX component current datasheets (or estimates).
- **Assumptions/Limitations**: 
  - Battery capacity constant (ignores Peukert effect at high currents).
  - Load profile assumed known or modeled from other modules.
  - Temperature effects on battery capacity ignored.
- **Validation**: 
  - Compare with simple constant-current discharge test.
  - Verify that runtime scales linearly with capacity for constant current.
- **Dependencies**: 
  - Parameter registry (battery specs).
  - Audio Acquisition module (for ADC current).
  - Wireless Link module (for TX transmit current).
  - DSP Workload module (if TX processing modeled).

### 8. Thermal Model
- **Objective**: Estimate steady-state temperature rise of key components based on power dissipation and thermal resistance.
- **Inputs**: 
  - Power dissipation per component (from Power-tree model and amplifier model).
  - Thermal resistance junction-to-ambient (°C/W) for each component (from datasheets).
  - Ambient temperature (°C).
  - Thermal coupling between components (if significant).
  - Heat sinking or copper pour area (if modeled).
- **Outputs**: 
  - Junction temperature for each component.
  - Case temperature.
  - Ambient temperature rise inside enclosure.
- **Equations/Governing Relationships**:
  - Steady-state: \( T_j = T_a + P \times \theta_{ja} \).
  - For heat sink: \( T_j = T_a + P \times (\theta_{jc} + \theta_{cs} + \theta_{sa}) \).
  - If multiple components share heating: superposition or numerical network.
- **Required Datasheet Inputs**: 
  - Thermal resistance junction-to-case (θjc) and case-to-sink (θcs) for components with heat sinks.
  - Thermal resistance junction-to-ambient (θja) for components without heat sinks.
  - Ambient temperature.
- **Assumptions/Limitations**: 
  - Steady-state only (no transient thermal response).
  - Linear thermal resistance (constant θja).
  - Ignores radiation and convection details (lumped into θja).
  - Assumes uniform ambient temperature.
- **Validation**: 
  - Compare with thermal camera or thermocouple measurements on reference board.
  - Verify that power dissipation matches expected values.
- **Dependencies**: 
  - Parameter registry (thermal specs, power specs).
  - Power-tree model (for component power dissipation).
  - Amplifier model (for amplifier power dissipation).

### 9. Audio/DSP Demonstration
- **Objective**: Provide a simplified end-to-end audio chain demonstration to verify model integration and basic functionality.
- **Inputs**: 
  - Test signal (e.g., sine wave, sweep, impulse, or music excerpt).
  - Parameters from all modules (audio acquisition, wireless, DSP, power, etc.).
- **Outputs**: 
  - Output audio waveform.
  - Frequency response (magnitude and phase).
  - THD+N vs. frequency.
  - Latency measurement.
  - DSP module outputs (e.g., EQ gain, compression reduction).
- **Equations/Governing Relationships**: 
  - Chain: Audio Acquisition → Wireless Link (with loss/jitter) → DSP Workload (if modeling processing effects) → Audio Output.
  - For demonstration, wireless link may be ideal (no loss, fixed delay) to focus on audio processing.
- **Required Datasheet Inputs**: None beyond module parameters.
- **Assumptions/Limitations**: 
  - Wireless link may be idealized for audio quality demonstration.
  - DSP may be simulated using MATLAB functions (e.g., filter) rather than cycle-accurate model.
- **Validation**: 
  - Compare output with expected processing (e.g., EQ boost at certain frequency).
  - Verify latency matches sum of module delays.
- **Dependencies**: All other modules (for parameter inputs).

### 10. Validation and Sensitivity Analysis
- **Objective**: Ensure model correctness and understand sensitivity to key parameters.
- **Inputs**: 
  - Base parameter set from registry.
  - List of parameters to vary (e.g., battery capacity, wireless data rate, DSP algorithm enable).
  - Range of variation (e.g., ±20%, or specific values).
- **Outputs**: 
  - Validation results (comparison with known data).
  - Sensitivity metrics: change in output (e.g., runtime, latency, temperature) per change in input.
  - Tornado diagrams or sensitivity plots.
  - Identification of critical parameters (high sensitivity).
- **Equations/Governing Relationships**: 
  - Sensitivity: \( S = \frac{\Delta Y}{\Delta X} \times \frac{X_0}{Y_0} \) (normalized) or \( \frac{\Delta Y}{\Delta X} \) (absolute).
  - Monte Carlo simulation (if uncertainty distributions defined).
- **Required Datasheet Inputs**: None beyond parameter registry.
- **Assumptions/Limitations**: 
  - Linear sensitivity assumed unless otherwise specified.
  - Interactions between parameters not captured in one-at-a-time sampling (unless using DOE).
- **Validation**: 
  - Compare model outputs with reference calculations or simple test cases.
  - Verify that known trends are reproduced (e.g., higher battery capacity → longer runtime).
- **Dependencies**: All modules (for sensitivity analysis).

## MATLAB Project Architecture
### File Structure
```
/matlab_model
  /parameters
    parameters_registry.m
  /modules
    audio_acquisition.m
    wireless_link.m
    dsp_workload.m
    power_tree.m
    dynamic_amplifier_control.m
    tx_battery_model.m
    thermal_model.m
    audio_dsp_demo.m
    validation.m
  /data
    datasheet_values.mat (optional, for storing parameters)
  /tests
    test_audio_acquisition.m
    test_wireless_link.m
    ...
  /results
    (output from simulation runs)
  README.md
  run_simulation.m (main script to execute all modules in sequence)
```

### Naming Convention
- Functions: `module_name_function` (e.g., `audio_acquisition_process`).
- Parameters: Prefixed with `param_` (e.g., `param_adc_resolution`).
- Constants: UPPERCASE with underscores (e.g., `SAMPLE_RATE`).

### Testing Strategy
- **Unit Tests**: Each module tested in isolation with known inputs.
- **Integration Tests**: Full model run with default parameters.
- **Regression Tests**: Ensure changes do not break baseline behavior.
- **Test Data**: Use simple signals (sine, square, pulse) and compare with analytical results.

### Execution Sequence
1. Load parameter registry.
2. Audio Acquisition: generate or import test audio signal.
3. Wireless Link: apply packetization, latency, loss.
4. DSP Workload: model processing effects (if applicable to audio quality).
5. Power-tree: compute power flows based on system load (from DSP and audio).
6. Dynamic Amplifier Control: compute safe amplifier power.
7. TX Battery Model: compute runtime (if TX modeled).
8. Thermal Model: compute temperatures.
9. Audio/DSP Demonstration: produce output audio and analysis.
10. Validation and Sensitivity: run checks and variations.

### Toolbox Usage
- **Base MATLAB**: Preferred for portability.
- **Signal Processing Toolbox**: For filter design, FFT, spectral analysis (justified if used for DSP demonstration).
- **Communications Toolbox**: For wireless modulation/demodulation models (optional; can model packet loss and latency without).
- **Simulink**: Not required; all modeling can be done in MATLAB scripts.
- **Simscape**: Not required; thermal and power models can be implemented with ordinary differential equations or algebraic equations.
- **Optimization Toolbox**: For sensitivity analysis (optional; can implement simple loops).

## Model Limitations and Justifications
- **Latency Modeling**: Wireless latency modeled as fixed plus random jitter; does not capture detailed protocol state machines.
- **Thermal Model**: Steady-state only; does not model thermal transients during power cycling.
- **Battery Model**: Simple Coulomb counting; does not model voltage sag under load or recovery.
- **DSP Workload**: Estimates MIPS based on operation counts; does not account for memory bottlenecks or pipeline effects.
- **Justification**: These simplifications are acceptable for architecture-level exploration and component selection, where relative comparisons are more important than absolute accuracy.

## Connection to Requirements
The model will enable verification of the following RFQ requirements:
- End-to-end latency (<5 ms ideal, 10 ms realistic) via Wireless Link and end-to-end chain.
- Battery runtime (TX: 600 mAh and 1000 mAh scenarios) via TX Battery Model.
- Amplifier power limiting via Dynamic Amplifier Control and Power-tree models.
- Thermal performance via Thermal Model.
- DSP processing load via DSP Workload model.
- Wireless feasibility via Wireless Link model (bandwidth, latency, loss).
- Power-tree validity via Power-tree model.
- Audio quality via Audio Acquisition and DSP Demonstration modules (frequency response, THD+N).

## Next Steps (Post-Documentation)
1. Implement the Parameter Registry module.
2. Implement each module sequentially, validating against datasheets or simple tests.
3. Integrate modules into a simulation script.
4. Run sensitivity analyses to identify critical parameters.
5. Use model outputs to inform component selection and BOM creation.
6. Document model assumptions and validation results.
