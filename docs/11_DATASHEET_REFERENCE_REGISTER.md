# Datasheet Reference Register

This register lists the components and component categories mentioned in the RFQ, along with references to their official manufacturer datasheets and reference manuals. It will be used to extract specifications for the MATLAB model and component selection.

## How to Use This Register
- Each entry corresponds to a component or component category.
- For exact part numbers specified in the RFQ, the datasheet is referenced directly.
- For component categories (e.g., "Audio ADC/codec"), a placeholder is used; the exact part will be selected in a later phase.
- **Verification Status**: Indicates whether the datasheet URL has been accessed and verified to resolve to the correct document.
- In this initial phase, datasheets are not fetched; verification will be performed in the next phase when the MATLAB model is implemented.
- **Relevant Specifications**: Lists the key specifications that will be extracted for the model (to be filled in during datasheet review).

## Component Entries

| Component | Manufacturer | Part Number | Document Title | Revision | URL | Relevant Specifications | RFQ Requirement | Verification Status |
|-----------|--------------|-------------|----------------|----------|-----|-------------------------|-----------------|---------------------|
| Wireless Radio (Prototype) | Texas Instruments | CC8530/CC8531 | CC8530/CC8531 Product Page | Latest | https://www.ti.com/product/CC8530 | Data rate, latency, transmit power, receiver sensitivity, packet size, power consumption | TX/RX wireless link, latency target | Not Verified |
| Wireless Radio (Production Candidate) | Nordic Semiconductor | nRF54L15 | nRF54L15 Product Specification | Latest | https://www.nordicsemi.com/Products/nRF54L15 | Data rate, latency, transmit power, receiver sensitivity, power consumption, protocol support | TX/RX wireless link, latency target | Not Verified |
| Primary MCU | STMicroelectronics | STM32H7 (TBD) | STM32H7 Series Reference Manual | Latest | https://www.st.com/resource/en/reference_manual/dm00310109-stm32h7xx-advanced-armbased-32bit-mcus-stmicroelectronics.pdf | Clock speed, MIPS, memory, peripherals (I2S, SPI, USB, SDMMC), power consumption | RX compute, DSP processing, system control | Not Verified |
| Motion Sensor | STMicroelectronics | LSM6DS3TR-C | LSM6DS3TR-C Datasheet | Latest | https://www.st.com/resource/en/datasheet/lsm6ds3tr-c.pdf | Accelerometer/gyro resolution, bandwidth, power consumption, interface (I2C/SPI) | TX IMU sensor | Not Verified |
| Audio ADC/Codec | TBD | TBD | TBD | TBD | TBD | Resolution (bits), sample rate (kHz), SNR, THD, input-referred noise, power consumption | TX audio acquisition, RX audio playback | Not Verified |
| Class-D Amplifier | TBD | TBD | TBD | TBD | TBD | Output power (W), efficiency, THD, SNR, bandwidth, supply voltage range, thermal protection | RX amplifier (~20 W target) | Not Verified |
| USB-C PD Controller | TBD | TBD | TBD | TBD | TBD | PD negotiation capabilities, voltage/current range, power switching efficiency | RX USB-C power input, PD negotiation | Not Verified |
| Battery Charger IC | TBD | TBD | TBD | TBD | TBD | Charge voltage/current, charge termination, safety features, power dissipation | TX and RX LiPo charging | Not Verified |
| Power-path Management IC | TBD | TBD | TBD | TBD | TBD | Voltage/current ratings, switching efficiency, reverse protection | RX power-path between USB-C, battery, system | Not Verified |
| DC/DC Converters (System Rails) | TBD | TBD | TBD | TBD | TBD | Efficiency, output voltage/current, ripple, transient response | RX system voltages (3.3V, 1.8V, etc.) | Not Verified |
| DC/DC Converter (Amplifier Rail) | TBD | TBD | TBD | TBD | TBD | Efficiency, output voltage/current, dynamic control capability | RX amplifier power rail (~20 W) | Not Verified |
| eMMC Storage | TBD | 16 GB | TBD | TBD | TBD | Capacity, read/write speeds, reliability, power consumption | RX storage for firmware, DSP profiles, etc. | Not Verified |
| Display (AMOLED) | TBD | TBD | TBD | TBD | TBD | Size (inch), resolution (pixels), interface (SPI/I2C), brightness, power consumption | RX UI display (1.91", 240x536) | Not Verified |

## Notes
- **TBD**: To Be Determined. Exact part numbers will be selected during the MATLAB model and component evaluation phase.
- **URLs**: Placeholder URLs point to product pages; specific datasheet links will be added during verification.
- **Verification Status**: 
  - **Not Verified**: Datasheet not yet accessed or confirmed.
  - **Verified**: URL resolved to correct datasheet and relevant specifications extracted.
  - **Partial**: Datasheet accessed but not all relevant specifications confirmed.
- **Revision**: Will be filled with the specific revision date or version number upon verification.
- **Relevant Specifications**: Will be filled during datasheet review in the next phase (e.g., for CC8530/CC8531: data rate up to 2 Mbps, typical latency figures, etc.).

## Next Steps
In the MATLAB model phase, this register will be updated with:
1. Exact component selections (where TBD).
2. Verified datasheet URLs and revision information.
3. Extracted relevant specifications for each component.
4. Notes on any discrepancies or additional findings.

This register ensures that all model inputs are traceable to manufacturer specifications and that assumptions are clearly documented.
