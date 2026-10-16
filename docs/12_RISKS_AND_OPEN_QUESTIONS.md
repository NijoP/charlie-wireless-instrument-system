# Risks and Open Questions

This document consolidates risks identified during RFQ analysis and lists open questions that require resolution (via client clarification, experimentation, or design decisions) before proceeding to final architecture and BOM selection.

## Risk Register

Each risk is assessed for severity (Low, Medium, High), likelihood (Low, Medium, High), and overall risk level (Severity × Likelihood). Mitigation strategies and required actions are described.

| Risk ID | Description | Severity | Likelihood | Risk Level | Mitigation / Action Required |
|---------|-------------|----------|------------|------------|------------------------------|
| RISK-001 | Wireless latency may exceed the <5 ms end-to-end target due to packetization, transmission, and buffering delays. | High | Medium | High | - Minimize packetization interval (0.5-1 ms).<br>- Select wireless radio with low-latency streaming mode.<br>- Avoid retransmissions; use FEC if needed.<br>- Measure latency early in prototyping. |
| RISK-002 | Wireless bandwidth may be insufficient for audio + metadata + overhead, especially if using 96 kHz audio or complex metadata. | Medium | Medium | Medium | - Optimize metadata size (bit-packing, send only changed values).<br>- Consider higher data rate radio modes (if available).<br>- Validate gross data rate requirement in MATLAB model. |
| RISK-003 | TX battery runtime may be insufficient for practical use due to high current draw from wireless transmission and processing. | Medium | High | Medium | - Model TX current consumption accurately in MATLAB.<br>- Test with 600 mAh and 1000 mAh batteries.<br>- Consider optimizing TX duty cycle (e.g., lower transmit power if range permits). |
| RISK-004 | RX battery runtime (if battery-powered) is not specified in RFQ; may be insufficient if RX has high power consumption (amplifier, display, processing). | Medium | Medium | Medium | - Define RX battery capacity based on system load model.<br>- Include RX battery in power-tree model.<br>- Test RX runtime with estimated load. |
| RISK-005 | Audio-channel definition or microphone transmission behavior is unresolved in RFQ (use of MEMS microphone). | Low | Medium | Low | - Clarify with client: Is MEMS mic audio transmitted, used locally for processing, or both?<br>- If transmitted, include in wireless bandwidth budget.<br>- If used locally, ensure processing latency accounted for. |
| RISK-006 | DSP scope and processor workload may exceed STM32H7 capabilities, especially with advanced algorithms (e.g., amp modelling, convolution). | High | Medium | High | - Estimate DSP MIPS requirement early in MATLAB model.<br>- Select STM32H7 with sufficient headroom (≥ 400 MHz Cortex-M7).<br>- Consider fixed-point optimization or fixed-function blocks if needed. |
| RISK-007 | USB-C PD and amplifier-power interaction may cause instability or unexpected behavior during sudden power changes. | Medium | Medium | Medium | - Implement dynamic power limiting firmware with smooth gain transition.<br>- Test power drop scenarios (cable unplug, PD downgrade).<br>- Ensure amplifier output reduces gracefully, no brownout/reboot. |
| RISK-008 | Thermal and electrical constraints may limit amplifier power delivery due to insufficient cooling or voltage drop. | Medium | Medium | Medium | - Model power dissipation in thermal model.<br>- Provide adequate heat sinking for amplifier and power ICs.<br>- Use thick traces for high-current rails. |
| RISK-009 | PCB interconnects (FPC/BTB) may not support required signals or may introduce noise if not designed carefully. | Medium | Low | Low | - Specify FPC/BTB for low-speed control signals only.<br>- Use dedicated connectors/wires for high-current power and speaker paths.<br>- Perform signal integrity checks on high-speed interfaces (e.g., I2S, SPI). |
| RISK-010 | Lack of numerical acceptance thresholds in RFQ makes validation criteria ambiguous. | Medium | Medium | Medium | - Propose provisional acceptance criteria based on engineering judgment (see 10_SIMULATION_OUTPUTS_AND_ACCEPTANCE_TESTS.md).<br>- Refine criteria with client during prototype test plan review. |
| RISK-011 | Acoustic assumptions (enclosure volume, driver) are provisional; final acoustic performance may require redesign if electronics platform cannot compensate sufficiently. | Low | High | Low | - Clearly document that acoustic optimization is post-V1.<br>- Use development speaker for V1 validation.<br>- Ensure DSP has sufficient flexibility for EQ and compensation. |
| RISK-012 | Component selection and datasheet gaps may lead to unexpected behavior if specifications are misunderstood or misapplied. | Low | Low | Low | - Maintain datasheet reference register with verified sources.<br>- Cross-check multiple sources (datasheets, application notes, reference designs).<br>- Validate critical assumptions with bench tests. |
| RISK-013 | Wireless coexistence with other 2.4 GHz devices (Wi-Fi, Bluetooth) may cause interference and increased latency or loss. | Medium | Medium | Medium | - Implement clear channel assessment (CCA) before transmission.<br>- Consider dynamic frequency selection or hopping if protocol allows.<br>- Test in realistic electromagnetic environment. |
| RISK-014 | The optional ESP32-S3 on RX Layer 2 may inadvertently be placed in the critical audio path, causing latency or glitches. | Low | Low | Low | - Enforce design rule: ESP32-S3 not in critical audio path.<br>- Route ESP32-S3 via high-speed interface for data offload only.<br>- Verify with layout inspection. |

## Open Questions (Client Clarification Required)
The following questions require written clarification from the client before final architecture and BOM selection can proceed.

| Question ID | Question | Context | Suggested Resolution Path |
|-------------|----------|---------|---------------------------|
| OQ-001 | What is the intended use of the digital MEMS microphone on the TX module? Is its audio signal transmitted to the RX, used locally for noise cancellation/feature extraction, or both? | TX -- INSTRUMENT MODULE section mentions "Digital MEMS microphone" and later "Microphone-derived acoustic features" in metadata, but does not specify if the mic audio is transmitted. | Client to clarify: Should MEMS mic audio be included in the wireless audio stream? If yes, how is it combined with instrument pickup? |
| OQ-002 | What is the expected update rate and latency tolerance for metadata (TX intelligence) used in RX-side sensor/data fusion? | RFQ lists metadata features but does not specify how frequently they should be updated or how fresh they need to be for fusion. | Client to clarify: Desired metadata update rate (e.g., 10 Hz, 50 Hz, 100 Hz) and maximum allowable age for fusion. |
| OQ-003 | What is the minimum acceptable RF range for the wireless link, and what are the typical use-case environments (e.g., stage, studio, home)? | RFQ requires RF range measurement but does not specify a target range. | Client to clarify: Desired range (e.g., 10 m, 30 m, 100 m) and whether line-of-sight or through-obstacles performance is needed. |
| OQ-004 | What is the desired battery capacity for the RX unit, if battery operation is intended? | RFQ specifies TX battery (~600 mAh scalable to ~1000 mAh) but does not mention RX battery capacity. | Client to clarify: Is the RX intended to be battery-operated, USB-C powered only, or both? If battery-operated, what capacity is desired? |
| OQ-005 | What is the maximum allowable group delay for the DSP processing chain (excluding wireless and audio conversion)? | RFQ lists DSP capabilities but does not specify a latency budget for DSP alone. | Client to clarify: Desired latency contribution from DSP (e.g., ≤ 2 ms, ≤ 5 ms) to help allocate latency budget. |
| OQ-006 | Are there any specific regulatory requirements (e.g., FCC, CE, SAR) that the wireless link must meet for the target markets? | RFQ does not mention regulatory compliance. | Client to clarify: Target markets and any required certifications (e.g., FCC Part 15, CE RED, MIC). |
| OQ-007 | What is the preferred user interaction model for the rotary encoder and touchscreen? Are there any specific UI/UX guidelines or mockups provided? | RFQ lists UI functions but does not describe interaction flow or priority. | Client to clarify: Provide UI flow diagrams or wireframes for preset selection, parameter adjustment, etc. |
| OQ-008 | Is there a preference for the audio connector type on the TX (instrument pickup) (e.g., 6.35 mm mono jack, 3.5 mm TRS, XLR)? | RFQ mentions "Instrument pickup input" but does not specify connector type. | Client to clarify: Connector type and wiring (tip/sleeve, tip/ring/sleeve) for compatibility with target instruments. |
| OQ-009 | What is the expected behavior when the USB-C source is disconnected while the RX is operating on battery? Should there be a seamless transition, and what indicators should be shown? | RFQ discusses battery mode but does not specify handover behavior. | Client to clarify: Desired transition behavior (seamless, with notification) and UI indications for power source change. |
| OQ-010 | Are there any constraints on the enclosure design for the RX unit beyond the supplied STL (e.g., maximum dimensions, accessibility for ports, thermal venting)? | RFQ supplies a preliminary enclosure STL but notes it is not final. | Client to clarify: Any hard constraints on RX enclosure size, port placement, or thermal management that must be respected in V1. |

## Dependencies Between Risks and Open Questions
- Resolving OQ-001 (MEMS mic use) affects RISK-005 (audio-channel ambiguity) and wireless bandwidth budget.
- Resolving OQ-002 (metadata update rate) affects RISK-002 (bandwidth) and RISK-006 (DSP workload if metadata processing is modeled).
- Resolving OQ-003 (RF range) affects RISK-001 (latency, as longer range may require lower data rate or more power).
- Resolving OQ-004 (RX battery) affects RISK-004 (RX battery runtime).
- Resolving OQ-005 (DSP delay) affects RISK-006 (DSP workload) and latency budget allocation.
- Resolving OQ-006 (regulatory) may affect wireless transmitter power and antenna design.
- Resolving OQ-007 (UI) may affect Layer 1 component selection and firmware.
- Resolving OQ-008 (TX connector) affects TX mechanical design and analog front-end.
- Resolving OQ-009 (USB-C disconnect) affects power-path management firmware and UI.
- Resolving OQ-010 (enclosure constraints) affects RX mechanical design and thermal modeling.

## Next Steps
1. Submit open questions to client for written clarification.
2. Use responses to update requirements and reduce ambiguities.
3. Prioritize risk mitigation activities based on risk level.
4. Initiate proof-of-concept tests for high-risk areas (wireless latency, DSP power, thermal management).
5. Update the MATLAB model with clarified parameters and assumptions.
