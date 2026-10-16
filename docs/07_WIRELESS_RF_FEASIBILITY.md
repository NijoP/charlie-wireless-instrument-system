# Wireless RF Feasibility Analysis

## Purpose
This document analyzes the feasibility of the wireless link options proposed in the RFQ for the Charlie Wireless Instrument System, focusing on latency, bandwidth, and reliability to meet the end-to-end latency target (<5 ms ideal, 10 ms realistic) and audio quality requirements.

## RFQ Wireless Options
- **Prototype**: Texas Instruments CC8530/CC8531 (2.4 GHz proprietary link).
- **Production Candidate**: Nordic Semiconductor nRF54L15 with proprietary low-latency 2.4 GHz protocol.
- **Architecture Requirement**: The wireless technology must be replaceable without redesigning the complete sensor/audio architecture.

## Audio Bandwidth Requirements
### Uncompressed PCM Payload
- **Resolution**: 24-bit per sample.
- **Sample Rate**: 48 kHz minimum (architecture should allow 96 kHz evaluation).
- **Channels**: Mono.
- **Raw Data Rate**: 24 bits × 48,000 samples/second = 1,152,000 bits/second = 1.152 Mbps.
- For 96 kHz: 24 × 96,000 = 2,304,000 bps = 2.304 Mbps.

### Additional Overhead
The raw PCM payload must be packetized for wireless transmission. Overhead includes:
- Packet headers (wireless protocol header, e.g., 2-4 bytes).
- Metadata payload (TX intelligence: pitch, note, confidence, etc.; estimated 10-20 bytes per packet).
- Sequence number (2-4 bytes).
- Timestamp/synchronization information (4-8 bytes).
- Error detection (CRC, e.g., 2 bytes).
- Padding for alignment.
- Wireless protocol overhead (e.g., address, control fields).

### Estimated Gross Traffic
Assuming a packetization interval of 1 ms (to minimize latency):
- PCM payload per packet: 1.152 Mbps × 0.001 s = 1.152 kbits = 144 bytes.
- Metadata per packet: ~20 bytes.
- Headers/overhead: ~20 bytes (estimate).
- Total per packet: ~184 bytes.
- Gross data rate: 184 bytes × 1000 packets/second = 184,000 bytes/second = 1.472 Mbps.

If packetization interval is 0.5 ms:
- PCM payload: 72 bytes.
- Metadata: 20 bytes.
- Headers: 20 bytes.
- Total: 112 bytes.
- Gross rate: 112 × 2000 = 224,000 B/s = 1.792 Mbps.

If packetization interval is 2 ms:
- PCM payload: 288 bytes.
- Metadata: 20 bytes.
- Headers: 20 bytes.
- Total: 328 bytes.
- Gross rate: 328 × 500 = 164,000 B/s = 1.312 Mbps.

Note: Longer packetization increases latency but reduces overhead percentage; shorter packetization reduces latency but increases overhead percentage.

## Latency Budget Analysis
End-to-end latency consists of:
1. **TX Analog Front-end and ADC**: Anti-aliasing filter delay, conversion delay.
2. **TX Processing**: Audio capture, processing, metadata generation, packetization.
3. **Wireless TX**: Encoding, transmission time.
4. **Wireless Propagation**: Negligible (<1 μs for 300m).
5. **Wireless RX**: Reception, decoding.
6. **RX Processing**: Jitter buffer, depacketization, audio analysis, DSP, DAC.
7. **TX->RX Metadata Fusion**: Additional processing if fusion occurs after audio output starts.
8. **DSP Amplifier Chain**: Any additional DSP (e.g., effects) before amplifier.
9. **Amplifier and Speaker**: Group delay of amplifier and speaker.

The RFQ states:
- **TX Latency Target**: <5 ms total end-to-end system latency (ideal).
- **Realistic Expectation**: 10 ms total end-to-end latency.
- **RF Subsystem Design**: Must be designed for the lowest practical packetization and buffering latency.

Thus, the wireless link latency (TX packetization + wireless transmission + RX reception + depacketization) should be a small fraction of the total budget.

### Wireless Link Latency Components
- **Packetization Delay**: Time to fill a packet (equals packetization interval if packets are sent immediately when full).
- **Transmission Delay**: (Packet size in bits) / (wireless data rate).
- **Reception Delay**: Similar to transmission delay on RX side.
- **Depacketization Delay**: Time to unload packet (usually negligible if processed on arrival).
- **Protocol Overhead**: Time for sync, ACKs, retransmissions (if any).

For a proprietary low-latency link, we assume:
- No ACKs or retransmissions in the primary audio stream (to avoid latency spikes); instead, use forward error correction (FEC) or tolerate occasional loss.
- Fixed latency encoding/decoding.

## Option 1: TI CC8530/CC8531
### Available Information (from RFQ and typical specs)
- **Frequency Band**: 2.4 GHz ISM.
- **Data Rate**: Up to 2 Mbps (typical for proprietary 2.4 GHz radios).
- **Latency**: TI's CC8530 datasheet specifies audio latency down to 10.7 ms (one-way, uncompressed audio). This latency is for the wireless link only and does not include processing, packetization, or other system latencies. The RFQ's end-to-end latency target of <5 ms (ideal) or 10 ms (realistic) includes the entire system, so the wireless link latency alone is a significant portion of the budget.
- **Notes**: The RFQ mentions CC8530/CC8531 as prototype; production candidate is nRF54L15, suggesting CC8530/CC8531 may not meet production requirements (e.g., power, cost, or latency).

### Feasibility Assessment
- **Bandwidth**: 2 Mbps raw data rate is sufficient for estimated gross traffic (~1.5-2 Mbps) even with 96 kHz audio and metadata.
- **Latency**: Given the CC8530's wireless link latency of 10.7 ms (one-way), achieving the <5 ms end-to-end target is not possible with this radio alone, as the wireless link latency exceeds the entire system budget. The 10 ms realistic target may be achievable if the wireless link latency is 10.7 ms and the rest of the system adds minimal latency (which is unlikely).
- **Uncertainties**: The CC8530's wireless link latency is 10.7 ms (one-way) per the datasheet. We must consider how this impacts the end-to-end latency budget and whether the 10 ms realistic target is achievable.
### Required Investigation
- Consult CC8530/CC8531 datasheet for typical latency in streaming mode.
- Check if the radio supports fixed-latency transmission without ACKs.
- Verify available data rates and modulation schemes.

## Option 2: nRF54L15 with Proprietary Low-latency 2.4 GHz Protocol
### Available Information
- **Chip**: Nordic Semiconductor nRF54L15 (latest generation, likely 2023 release).
- **Features**: High-performance ARM Cortex-M33, integrated 2.4 GHz radio, support for Bluetooth 5.4, Thread, Zigbee, and proprietary protocols.
- **Proprietary Protocol**: The RFQ specifies a "proprietary low-latency 2.4 GHz protocol" to be developed or licensed.
- **Notes**: The RFQ presents nRF54L15 as a production candidate, implying it may offer better suitability for mass production (cost, power, availability) than CC8530/CC8531.

### Feasibility Assessment
- **Bandwidth**: The nRF54L15 radio can support data rates up to 2 Mbps (Bluetooth LE 2M mode) or higher with proprietary modes (e.g., Nordic's proprietary 2.4 GHz modes can go up to 4-8 Mbps).
- **Latency**: Nordic's proprietary protocols (e.g., used in wireless gaming headsets) can achieve latencies down to 1 ms one-way.
- **Uncertainties**: The exact latency achievable with a custom proprietary protocol on nRF54L15 is not specified. Development of such a protocol may require significant firmware effort.
- **Advantage**: Better integration with potential STM32H7 or ESP32-S3 (if used for wireless control) and access to Nordic's SDK and tools.

### Required Investigation
- Evaluate Nordic's proprietary 2.4 GHz SDK for latency characteristics.
- Assess development effort for custom low-latency audio streaming protocol.
- Consider coexistence with other wireless services (if any).

## Comparison and Recommendation
| Parameter | CC8530/CC8531 | nRF54L15 + Custom Protocol |
|-----------|---------------|----------------------------|
| Bandwidth Sufficiency | Likely sufficient (2 Mbps) | Sufficient (2+ Mbps) |
| Latency Potential | Unknown (needs datasheet) | Potentially low (1-2 ms) |
| Development Effort | Lower (if using reference design) | Higher (custom protocol) |
| Production Suitability | Questionable (RFQ suggests nRF54L15 for production) | High (explicit production candidate) |
| Architecture Replaceability | Must be designed for replaceability | Must be designed for replaceability |
| Power Consumption | To be compared | To be compared |

### Feasibility Verdict
Both options appear feasible from a bandwidth perspective. The latency target (<5 ms end-to-end) is challenging but achievable with careful design. The nRF54L15 option is favored for production due to explicit mention in the RFQ, but requires development of a proprietary low-latency protocol. The CC8530/CC8531 option may be suitable for prototyping to validate the audio link and DSP architecture.

### Risks and Mitigations
- **Risk**: Wireless latency exceeds budget.
  - **Mitigation**: Use minimal packetization (0.5 ms), prioritize low-latency radio modes, avoid retransmissions, use FEC if needed.
- **Risk**: Bandwidth insufficient for metadata and audio.
  - **Mitigation**: Optimize metadata size (e.g., compress intelligently, send only changed values), consider higher data rate modes.
- **Risk**: Proprietary protocol development delays.
  - **Mitigation**: Use off-the-shelf proprietary stack if available (e.g., from TI or Nordic for audio streaming), or allocate sufficient firmware time.
- **Risk**: Interference in 2.4 GHz band.
  - **Mitigation**: Implement channel agility, clear channel assessment (CCA), and consider dynamic frequency selection.

### Suggested Proof-of-concept Tests
1. **Latency Measurement**: Use oscilloscope or logic analyzer to measure time from audio input at TX to audio output at RX with a known signal (e.g., click).
2. **Packet Loss Test**: Operate in noisy environment and measure packet loss rate; ensure audio quality degrades gracefully.
3. **Range Test**: Measure maximum range at which latency and loss remain acceptable.
4. **Coexistence Test**: Test with Wi-Fi and Bluetooth devices active to ensure robustness.
5. **Throughput Test**: Verify actual gross data rate meets or exceeds required audio + metadata rate.

### Conclusion
The wireless link is feasible with either option, provided that:
- Packetization interval is minimized (0.5-1 ms).
- The radio technology supports low-latency streaming modes.
- Metadata is kept compact.
- The system design avoids unnecessary buffering and retransmissions.
The nRF54L15 option is recommended for production due to RFQ guidance, but the CC8530/CC8531 option can be used for initial prototyping to de-risk the audio link and DSP architecture.
