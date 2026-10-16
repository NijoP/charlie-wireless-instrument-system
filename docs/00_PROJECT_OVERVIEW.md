# Project Overview

## Product Name
Charlie — Wireless Instrument System

## RFQ Reference
Charlie — Wireless Instrument System, Electronics Engineering RFQ — V1

## Project Objective
Develop the electronics platform for Charlie, an intelligent low-latency wireless instrument system consisting of:
1. **TX — Instrument-mounted wireless intelligence module**
2. **RX — Portable Charlie receiver / amplifier**

The first development phase should prioritize the electronics, wireless link, real-time DSP, sensor fusion, and power architecture.
**Acoustic optimization is NOT the primary objective of V1.**

## Key Points
- The supplied enclosure STL is only a preliminary mechanical reference.
- Preliminary Enclosure Reference Supplied STL estimated mesh volume: ~153 cm³.
- For conservative engineering allocation, assume: ~115 cm³ usable design volume (approximately 75% of the estimated mesh volume).
- The final internal acoustic volume, driver selection, porting, and acoustic tuning will be addressed in a later phase.
- The system should allow evaluation of different acoustic configurations through DSP and physical testing after the electronics platform is validated.

## Scope of Version 1 (V1)
V1 focuses on:
- Electronics platform development
- Wireless link establishment
- Real-time DSP implementation
- Sensor fusion (audio and IMU)
- Power architecture and management
- Audio amplifier and speaker interface (with development speaker)
- Storage (eMMC)
- User interface (AMOLED display, controls)
- Firmware architecture

Acoustic optimization, final speaker selection, enclosure design, and advanced audio tuning are deferred to later phases.

## Deliverables (as per RFQ)
The engineering team is expected to provide:
1. Complete system block diagram
2. Component selection + justification
3. TX schematic
4. RX Layer 1 schematic (UI)
5. RX Layer 2 schematic (compute/RF/audio)
6. RX Layer 3 schematic (power)
7. PCB layouts
8. Complete BOM
9. Power-tree calculations
10. RF architecture
11. Audio signal chain
12. TX/RX communication protocol
13. Metadata packet structure
14. DSP architecture
15. USB-C PD implementation
16. Dynamic amplifier power-control implementation
17. Battery/runtime calculations
18. Thermal analysis
19. Test points
20. Firmware hardware interfaces
21. Prototype assembly
22. Bring-up procedure
23. Validation report

## Validation Requirements (as per RFQ)
The prototype must measure:
- **Wireless**: TX/RX latency, packet loss, RF range, jitter, synchronization accuracy.
- **Audio**: Frequency response, THD+N, SNR, dynamic range, ADC/DAC performance, transient response.
- **DSP**: FFT processing load, MFCC processing load, pitch detection latency, TX/RX metadata synchronization, CPU/RAM utilization.
- **Power**: Battery runtime, charging behavior, USB-C input power, PD negotiation, maximum amplifier output, dynamic power limiting, thermal performance.
- **Acoustic** (preliminary only): Measure the development speaker in the supplied enclosure, but do not treat the first speaker/enclosure combination as final. The goal of V1 is to establish the electronics, wireless, DSP, and power platform so that different acoustic configurations can subsequently be evaluated through DSP and physical testing.
