# Audio DSP Architecture

## Purpose
The DSP (Digital Signal Processing) subsystem in the Charlie Wireless Instrument System is responsible for high-fidelity audio processing, effects, amplifier and cabinet modelling, speaker protection, and dynamic power control. It runs primarily on the STM32H7 MCU in the RX Compute/RF/Audio Board.

## Key Requirements (from RFQ)

### General DSP Philosophy
- The DSP must be designed so that the acoustic response can be tuned later without changing the core hardware.
- Acoustic tuning should be implemented primarily in firmware/DSP during the initial development phase.
- Do not hard-code the final speaker response into the hardware.
- The system should allow experimentation with different drivers and DSP profiles before locking the final enclosure acoustics.
- DSP may compensate for a significant portion of the driver's/enclosure's frequency response, but cannot overcome fundamental physical limits (maximum excursion, maximum SPL, resonance, thermal limits, cabinet volume, port limitations, driver efficiency).
- Electronics must provide sufficient DSP flexibility to characterize and optimize the eventual speaker.

### Required DSP Capabilities
The DSP must include the following processing blocks (implemented in firmware on STM32H7):

1. **Parametric EQ**
   - Adjustable center frequency, gain, and Q (bandwidth).
   - Multiple bands可 cascaded for complex equalization.

2. **Graphic EQ** (where useful)
   - Fixed-band equalizer (e.g., 10-band octave or 1/3-octave) for intuitive tone shaping.

3. **High-pass / Low-pass Filters**
   - Adjustable cutoff frequencies and slopes (e.g., Butterworth, Linkwitz-Riley).
   - Used for removing unwanted low-frequency rumble or high-frequency hiss.

4. **Compression**
   - Dynamic range compression to control loudness and transients.
   - Parameters: threshold, ratio, attack time, release time, knee.

5. **Limiter**
   - Peak limiting to prevent clipping and protect speaker and amplifier.
   - Operates above compression threshold with fast attack and release.

6. **Gain Staging**
   - Overall volume control with proper headroom management.
   - Allows independent control of input gain, DSP processing gain, and output gain.

7. **Resonance Compensation**
   - Algorithms to identify and attenuate resonances in the speaker/enclosure system.
   - May use adaptive filtering or fixed notch filters based on measurements.

8. **Amp Modelling**
   - Digital emulation of guitar amplifier characteristics (preamp, power amp, speaker breakup).
   - May involve convolution, Volterra series, or state-space models.

9. **Cabinet Modelling**
   - Digital emulation of speaker cabinet acoustics (open-back, closed-back, ported).
   - Often implemented with convolution reverb or impulse responses.

10. **Convolution / Speaker IR Support**
    - Ability to load and convolve with impulse responses (IRs) of speakers, cabinets, or rooms.
    - IR length and resolution to be determined based on desired fidelity and processing load.

11. **Volume-dependent EQ**
    - Tone adjustment that varies with volume level (e.g., loudness contour to compensate for human hearing perception at low volumes).
    - May be implemented as a dynamic EQ controlled by overall gain.

12. **Speaker Protection**
    - Algorithms to prevent overexcursion, overheating, and mechanical damage.
    - Inputs: amplifier power, voltage, current, speaker impedance estimate, temperature.
    - Actions: reduce gain, apply high-pass filter to remove harmful low frequencies.

### Signal Flow
The DSP processes the audio signal in the following order (typical chain, but order may vary based on design):
```
[Audio Input] → [Gain Staging (Input)] → [High-pass Filter] → [Parametric EQ] → [Graphic EQ] → 
[Compression] → [Limiter] → [Gain Staging (Output)] → [Amp Modelling] → [Cabinet Modelling] → 
[Convolution / Speaker IR] → [Volume-dependent EQ] → [Resonance Compensation] → [Speaker Protection] → [Audio Output]
```
Note: The exact order is implementation-specific; some blocks may be omitted or reordered based on the desired sound.

### Processing Chain Details
#### Audio Input
- Source: 24-bit PCM audio from wireless receiver (via I2S to STM32H7).
- Sample rate: 48 kHz minimum (architecture should allow 96 kHz evaluation).
- Bit depth: 24-bit.

#### Internal Processing
- The DSP may use higher internal precision (e.g., 32-bit floating point) to avoid quantization errors in cascaded stages.
- All processing must be real-time with negligible latency (contributes to overall system latency budget).

#### Audio Output
- Output: 24-bit PCM audio to DAC (via I2S from STM32H7).
- Must maintain dynamic range and low distortion.

### Unresolved Specifications
- The exact sampling rate for internal DSP processing is not fixed; the RFQ states that architecture should allow future evaluation of 96 kHz internal DSP processing if useful.
- The specific algorithms for amp modelling, cabinet modelling, and convolution are not prescribed; selection based on fidelity and processing load.
- The amount of DSP memory and RAM available for IR storage and coefficient tables is not specified (depends on STM32H7 selection).
- The maximum convolution IR length that can be supported in real-time is not specified.
- Whether the DSP includes a noise gate or expander is not mentioned.
- Whether the DSP includes a transient designer or sustain control is not mentioned.

### Open Questions
1. What is the available MIPS (million instructions per second) of the selected STM32H7 for DSP processing after accounting for system control, wireless, and UI tasks?
2. What is the maximum FFT size that can be computed in real-time for spectral analysis (if needed for tuning or visualization)?
3. What is the buffer size and latency introduced by the DSP processing chain?
4. How will the DSP parameters be tuned and stored (e.g., via UI, stored in eMMC)?
5. What is the desired update rate for adaptive algorithms (e.g., resonance compensation)?
6. How will the speaker protection algorithm gain access to real-time amplifier output current and voltage (requires sensing on Power Board)?
7. What is the expected group delay of the DSP chain, and how does it affect the overall system latency budget?

### Validation Methods
- **Frequency Response**: Measure amplitude vs. frequency with various DSP settings.
- **THD+N**: Total harmonic distortion plus noise at different output levels.
- **SNR**: Signal-to-noise ratio.
- **Dynamic Range**: Ratio of maximum undistorted signal to noise floor.
- **Transient Response**: Rise time and settling time to step inputs.
- **Speaker Protection**: Verify that gain reduction occurs under overexcursion conditions.
- **Processing Load**: Measure CPU usage and memory utilization for the DSP chain.

### Dependencies
- STM32H7 selection must provide sufficient CPU cycles, memory, and peripheral bandwidth (I2S, DMA) for the DSP chain.
- Audio codec must support 24-bit, 48 kHz (or 96 kHz) and low latency.
- eMMC must provide sufficient storage for IR files and DSP profiles.
- Power Board must provide telemetry (voltage, current, temperature) for dynamic power limiting and speaker protection.
- UI must allow adjustment of DSP parameters (via encoder/touchscreen).
