# Power, Battery, and Thermal PCB (Layer 3)

## Purpose
The Power Board manages all aspects of power input, conversion, distribution, battery charging, and thermal monitoring for the Charlie RX unit. It provides clean power rails to the system and amplifier, and telemetry for dynamic power control.

## Key Requirements (from RFQ)

### Input and Power Detection
- **USB-C Connector**: Standard USB-C receptacle for power input and communication.
- **USB-C PD Negotiation**: Must support USB Power Delivery to negotiate voltages up to 20V (typical for PD) and currents up to 3A or more (as per PD specification).
- **Actual Available Input Power Detection**: Firmware must measure the real-time voltage and current at the USB-C input to determine the actual power available from the source (after cable losses, etc.).

### Battery Management
- **Battery Type**: 3.7 V LiPo cell (same as TX, but exact capacity not specified for RX; assumed similar or based on system needs).
- **Charging**: Integrated LiPo charger IC with USB-C input.
- **Protection**: Over-voltage, over-current, over-temperature protection for the battery.
- **Fuel Gauge**: Accurate state-of-charge (SOC) estimation and remaining capacity reporting.
- **Simultaneous Operation**: Battery charging and system operation should occur simultaneously when the power source permits (i.e., when input power exceeds system consumption).

### Power-path Management
- **Function**: Seamlessly switch between USB-C power, battery power, or a combination.
- **Prioritization**: Prefer USB-C power when available and sufficient; supplement with battery when needed; run from battery alone when USB-C is insufficient or absent.
- **Reverse Protection**: Prevent battery from discharging back into USB-C port when no source is connected.

### DC/DC Converters
- **System Rails**: Generate logic-level voltages (e.g., 3.3V, 1.8V) for STM32H7, ESP32-S3 (if present), audio codec, wireless modules, and other peripherals.
- **Amplifier Power Rail**: Dedicated rail for the Class-D amplifier, capable of delivering up to ~20 W peak power.
  - Must be adjustable or controllable (via DC/DC converter enabling dynamic power limiting based on firmware command).
- **Efficiency**: High efficiency to minimize heat generation and maximize battery runtime.

### Thermal Monitoring
- **Sensors**: Temperature sensors placed on critical components (e.g., charger IC, DC/DC converters, amplifier, MCU).
- **Feedback to Firmware**: Temperature readings provided to the Layer 2 MCU for thermal throttling and protection.
- **Thermal Limit Action**: If temperature exceeds safe threshold, reduce amplifier output via DSP gain control (graceful reduction, not shutdown).

### Dynamic Amplifier Power Control (MUST HAVE)
This is a critical system requirement.

#### Inputs to Firmware (from Power Board)
- Measured USB-C input voltage and current (to compute available input power).
- Negotiated USB-C PD power (voltage × current).
- Battery voltage and state of charge (SOC).
- System power consumption (estimated or measured from system rails).
- Amplifier power rail voltage and current (optional, for precise control).
- Temperature sensors (for thermal limiting).

#### Firmware Calculation
1. **Available Input Power**: From USB-C source (after deducting cable losses, if measurable) or from battery (voltage × current available from battery).
2. **System Consumption**: Power used by STM32H7, ESP32-S3, wireless, audio codec, LEDs, etc.
3. **Charging Reserve**: Power allocated to battery charging (if charging is desired and source permits).
4. **Safe Amplifier Power**: Available input power − System consumption − Charging reserve.
   - This value must be non-negative; if negative, the system must reduce consumption or increase input power (not possible) → therefore, amplifier power must be reduced to keep total consumption within limits.

#### Firmware Output
- Continuously updated maximum safe amplifier power/level (in watts or as a DAC value or digital gain setting).
- This value is sent to the Layer 2 MCU (via I2C, SPI, or similar) to set the amplifier gain limit in the DSP.

#### Amplifier Response
- The amplifier gain must be adjusted in real-time (via DSP) to stay within the safe power limit.
- If available input power suddenly decreases (e.g., USB-C cable unplugged, PD negotiation downgrade), the amplifier output must be reduced gracefully through DSP gain reduction or limiting.
- **Not Allowed**: Brownout, reboot, or sudden shutdown due to insufficient power.

### Example Scenarios (from RFQ)
| Scenario | Expected Behavior |
|----------|-------------------|
| Weak charger (low voltage/current) | Reduced amplifier power to match available input after system consumption and charging reserve. |
| Normal USB-C supply (5V/500mA or 900mA) | Higher amplifier power (within limits of available input). |
| High-power USB-C PD (e.g., 20V/3A = 60W) | Maximum amplifier output (~20 W) if system consumption and charging reserve allow. |
| Battery mode (no USB-C) | Amplifier power limited by battery voltage and capacity, with safe margin to prevent deep discharge. |
| Low battery | Reduced amplifier power to extend runtime and protect battery. |
| Thermal limit (overtemperature) | Reduced amplifier power to decrease heat generation. |
| Sudden reduction in input power | Amplifier output reduced gracefully via DSP gain, no brownout/reboot. |

### Power Architecture (Preferred)
```
USB-C → USB-C PD/power detection → Power-path manager → 
   → System rails + battery charging → 
   → Amplifier power rail → ~20 W Class-D → Full-range speaker
```
- **System rails** power the STM32H7, ESP32-S3 (if present), audio codec, wireless modules, UI, etc.
- **Amplifier power rail** is dedicated and controllable.

### Constraints and Design Rules
- **High-current routing**: Battery power, USB-C power, and amplifier power rail must use appropriately sized traces and connectors. **Do not route high-current battery or speaker power through small FPCs** (FPCs are only for low-current control signals between layers).
- **Separation**: High-current paths should be separated from sensitive analog and digital signals to avoid noise coupling.
- **Thermal Dissipation**: Power components (charger, DC/DC converters) may require heat sinking or copper pours for thermal management.
- **EMI/EMC**: Proper filtering and grounding to meet regulatory requirements.

### Unresolved Specifications
- Exact LiPo battery capacity for RX is not specified (TX specifies ~600 mAh scalable to ~1000 mAh; RX may be different based on system load).
- Exact USB-C PD controller part number is not specified.
- Exact LiPo charger IC part number is not specified.
- Exact DC/DC converter part numbers for system rails and amplifier rail are not specified.
- Exact current and voltage sensor part numbers (e.g., shunt resistors, Hall-effect sensors, or dedicated ICs) are not specified.
- Exact temperature sensor type and placement are not specified.
- The communication interface between Power Board and Layer 2 MCU for telemetry is not specified (likely I2C or SPI).
- The exact format of the power limit command from Layer 2 to Power Board is not specified.

### Open Questions
1. What is the expected peak system consumption (excluding amplifier) to size the power-path manager?
2. What is the desired charging current for the battery (to balance charging time and heat)?
3. What is the minimum input voltage from USB-C that the system can operate at (for USB-C PD fallback)?
4. What is the required accuracy for the battery fuel gauge (e.g., ±5% SOC)?
5. How should the system behave when the battery is fully depleted and USB-C is connected (inrush current, charging vs. system power)?
6. What is the thermal design power (TDP) for the amplifier and power components, and what heat sinking strategy is required?
