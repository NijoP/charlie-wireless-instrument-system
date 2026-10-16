# Engineering Execution Roadmap

## Purpose
This document proposes a phased execution plan for the Charlie Wireless Instrument System project. The roadmap is intended as a guide for engineering activities and is not a client-approved schedule. Phase gates are suggested to ensure technical readiness before proceeding to the next stage.

## Proposed Phases and Gates

### Phase 0: RFQ Analysis, Engineering Documentation, and Repository Setup
**Objective**: Complete a thorough review of the RFQ, extract requirements, create engineering documentation, and establish the project repository.
**Activities**:
- RFQ analysis and requirement traceability.
- Creation of all documentation files (this set).
- Setup of GitHub repository and initial commit.
**Gate 0 Completion Criteria**:
- All documentation files written and reviewed.
- Requirements traceability established.
- Repository initialized with documentation.
- No executable code created.
**Output**: Complete set of engineering specification documents (this repository).

### Phase 1: Datasheet Investigation and Feasibility Analysis
**Objective**: Investigate component datasheets, validate assumptions, and perform feasibility studies for critical subsystems (wireless, power, DSP).
**Activities**:
- Update Datasheet Reference Register with verified sources and extracted specifications.
- Perform wireless feasibility analysis (latency, bandwidth, coexistence) using literature and reference designs.
- Perform power feasibility analysis (dynamic amplifier control, thermal) using preliminary models.
- Perform DSP feasibility analysis (algorithm complexity, MIPS estimation) using reference implementations.
- Identify and mitigate high-risk areas (RISK-001, RISK-006, RISK-007, RISK-008).
**Gate 1 Completion Criteria**:
- Datasheet Reference Register verified for critical components (wireless ICs, MCU, audio codec, amplifier, power ICs).
- Feasibility reports completed (wireless, power, DSP).
- Risk mitigation plans in place for high-risk risks.
- Go/no-go decision based on feasibility.
**Output**: Updated datasheet register, feasibility analysis documents, risk mitigation plans.

### Phase 2: MATLAB Mathematical Model Development
**Objective**: Develop and validate the mathematical model described in 09_MATHEMATICAL_MODEL_PLAN.md to simulate system behavior and inform component selection.
**Activities**:
- Implement Parameter Registry module.
- Implement each subsystem module (Audio Acquisition, Wireless Link, DSP Workload, Power-tree, Dynamic Amplifier Control, TX Battery Model, Thermal Model, Audio/DSP Demonstration).
- Validate each module against datasheet specifications or simple analytical tests.
- Integrate modules and run simulations with default parameters.
- Perform sensitivity analysis to identify critical parameters.
- Use model to evaluate component choices and architecture options.
**Gate 2 Completion Criteria**:
- All modules implemented and unit-tested.
- Model integrated and capable of running end-to-end simulations.
- Sensitivity analysis completed.
- Model outputs used to narrow down component selections and validate architecture.
- No red flags in critical metrics (latency, power, thermal, DSP load).
**Output**: Validated MATLAB model, simulation results, sensitivity analysis report, updated BOM candidates list.

### Phase 3: Model Validation and Sensitivity Analysis (Continued)
**Objective**: Refine the MATLAB model with client feedback and additional data, and use it to derive acceptance criteria and test procedures.
**Activities**:
- Incorporate client clarifications from open questions.
- Update model with selected tentative components.
- Run simulations under various scenarios (weak charger, battery mode, thermal limit, etc.).
- Define provisional acceptance criteria based on model predictions and engineering judgment.
- Develop test procedures for prototype validation.
**Gate 3 Completion Criteria**:
- Model updated with client-resolved parameters.
- Acceptance criteria documented and agreed upon (provisional).
- Test procedures drafted for wireless, audio, DSP, power, and thermal validation.
- Readiness to proceed to BOM freeze and schematic design.
**Output**: Finalized MATLAB model, acceptance criteria document, test procedures.

### Phase 4: Candidate Component Evaluation and BOM Development
**Objective**: Evaluate shortlisted components, finalize the Bill of Materials (BOM), and perform cost analysis.
**Activities**:
- Obtain samples or evaluation kits for critical components (MCU, wireless IC, audio codec, amplifier, power ICs).
- Perform bench tests to validate key specifications (e.g., ADC SNR, wireless latency, amplifier power).
- Update Datasheet Reference Register with test results.
- Finalize BOM with part numbers, quantities, approved manufacturers, and cost estimates.
- Perform design for manufacturability (DFM) review.
**Gate 4 Completion Criteria**:
- BOM finalized and approved.
- All critical components validated via bench test or datasheet confirmation.
- Cost estimate completed.
- No unresolved component risks.
**Output**: Approved BOM, component validation report, cost analysis.

### Phase 5: Schematic Design and PCB Layout
**Objective**: Create electrical schematics and PCB layouts for all four PCBs (TX, RX UI, RX Compute/RF/Audio, RX Power).
**Activities**:
- Draw schematics based on architecture and selected components.
- Perform electrical rule checks (ERC).
- Create PCB layouts following stackup and routing rules (no high-current through FPCs, proper grounding, etc.).
- Perform design rule checks (DRC).
- Generate Gerber files and fabrication drawings.
**Gate 5 Completion Criteria**:
- Schematics complete and ERC passed.
- Layouts complete and DRC passed.
- Gerber files generated and reviewed.
- No high-current signals on FPCs/BTBs.
**Output**: Schematic PDFs, PCB layout files, Gerber package.

### Phase 6: Prototype Fabrication and Assembly
**Objective**: Fabricate and assemble prototype PCBs and procure mechanical components (enclosure, display, etc.).
**Activities**:
- Send Gerber files to PCB fab for prototype boards.
- Order components from BOM.
- Assemble prototypes (manual assembly or pilot line).
- Install firmware bootloader and basic test firmware.
- Perform initial bring-up and smoke test.
**Gate 6 Completion Criteria**:
- All prototype boards fabricated and received.
- Components assembled correctly.
- Initial power-on successful (no shorts, correct voltages).
- Basic firmware running (LED blink, USB enumeration).
**Output**: Assembled prototype units, initial bring-up log.

### Phase 7: Hardware Bring-up
**Objective**: Initialize and debug the prototype hardware to achieve basic functionality.
**Activities**:
- Load firmware onto STM32H7 (and ESP32-S3 if present).
- Establish communication between layers (UI, compute, power).
- Bring up wireless link and verify basic audio transmission.
- Bring up UI (display, touch, encoder).
- Bring up power management and battery charging.
- Debug any hardware issues (soldering faults, component defects, wiring errors).
**Gate 7 Completion Criteria**:
- Wireless link established and audio packets transmitted.
- UI responsive to touch and encoder input.
- Power management functional (USB-C input detected, battery charging).
- Basic audio path operational (signal from TX to RX audible through speaker).
- All major subsystems demonstrating basic functionality.
**Output**: Functional prototype hardware, bring-up report.

### Phase 8: Physical Validation and Design Revision
**Objective**: Conduct validation tests per the acceptance criteria and iterate on design based on results.
**Activities**:
- Execute validation tests (wireless latency, packet loss, audio quality, DSP load, power behavior, thermal performance).
- Record results and compare against acceptance criteria.
- Identify any failures or marginal performance.
- Implement design revisions (component changes, firmware adjustments, PCB tweaks) as needed.
- Re-test after revisions.
**Gate 8 Completion Criteria**:
- All validation tests meet or exceed acceptance criteria.
- No critical failures remaining.
- Design frozen for production pilot run.
**Output**: Validation test report, design revision log, frozen design files.

### Phase 9: Pilot Production and Preparation for Scale-up
**Objective**: Prepare for small-scale production run and finalize documentation for manufacturing.
**Activities**:
- Generate final production Gerbers, assembly drawings, and test procedures.
- Create final BOM with approved vendors and alternate sources.
- Develop firmware release version and documentation.
- Plan for pilot production batch (e.g., 10-50 units).
**Gate 9 Completion Criteria**:
- Production package complete.
- Firmware versioned and documented.
- Ready for pilot production.
**Output**: Production-ready files, firmware release, pilot production plan.

## Notes on Roadmap Usage
- **Iteration**: Some phases may require iteration based on findings (e.g., after Phase 8, may need to revisit Phase 5).
- **Overlap**: Certain activities can overlap (e.g., Phase 2 modeling can start while Phase 1 feasibility analysis completes).
- **Resource Loading**: The roadmap assumes a dedicated engineering team; adjust timelines based on available resources.
- **Client Review**: Phase gates 0, 2, 4, 6, and 8 are suggested points for client review and approval.
- **Flexibility**: The roadmap is a guideline; actual execution may adapt to risks, open questions, and resource availability.

## Relationship to MATLAB Model Phase
The MATLAB model development occurs in Phase 2, with model validation and refinement in Phase 3. The model is used to:
- Inform component selection in Phase 4.
- Validate feasibility before proceeding to schematic design.
- Predict whether the design will meet acceptance criteria, reducing risk in later phases.
