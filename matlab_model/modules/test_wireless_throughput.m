% TEST_WIRELESS_THROUGHPUT Test the wireless throughput function.
%
%   This script tests the wireless_throughput function by comparing its
%   outputs with expected values and the parameter registry.

% Add paths
addpath('matlab_model/parameters');
addpath('matlab_model/modules');

% Get parameters
p = get_parameters();

% Call the wireless throughput function
w = wireless_throughput(p);

% Display key results
fprintf('Wireless Throughput Test Results:\n');
fprintf('---------------------------------\n');
fprintf('Samples per packet: %d\n', w.samples_per_packet);
fprintf('Audio payload bits per packet: %d\n', w.audio_payload_bits_per_packet);
fprintf('Audio payload bytes per packet: %d\n', w.audio_payload_bytes_per_packet);
fprintf('Metadata bits per packet: %d\n', w.metadata_bits_per_packet);
fprintf('Metadata bytes per packet: %d\n', w.metadata_bytes_per_packet);
fprintf('Application frame bits per packet: %d\n', w.application_frame_bits_per_packet);
fprintf('Application frame bytes per packet: %d\n', w.application_frame_bytes_per_packet);
fprintf('Overhead header bits per packet: %d\n', w.overhead_header_bits_per_packet);
fprintf('Overhead CRC bits per packet: %d\n', w.overhead_crc_bits_per_packet);
fprintf('Total overhead bits per packet: %d\n', w.total_overhead_bits_per_packet);
fprintf('Gross bits per packet: %d\n', w.gross_bits_per_packet);
fprintf('Audio only bitrate: %f bps\n', w.audio_only_bitrate);
fprintf('Application bitrate: %f bps\n', w.application_bitrate);
fprintf('Gross bitrate: %f bps\n', w.gross_bitrate);
fprintf('Overhead header bitrate: %f bps\n', w.overhead_header_bitrate_out);
fprintf('Overhead CRC bitrate: %f bps\n', w.overhead_crc_bitrate);
fprintf('Total overhead bitrate: %f bps\n', w.total_overhead_bitrate_out);
fprintf('CC8530 nominal rate: %f bps\n', w.cc8530_nominal_rate);
fprintf('nRF54L15 nominal rate: %f bps\n', w.nrf54l15_nominal_rate);
fprintf('CC8530 usable headroom: %f\n', w.cc8530_usable_headroom);
fprintf('nRF54L15 usable headroom: %f\n', w.nrf54l15_usable_headroom);

% Compare with derived parameters from the registry
fprintf('\nComparison with parameter registry derived values:\n');
fprintf('--------------------------------------------------\n');
fprintf('PCM payload rate from registry: %f bps\n', p.pcm_payload_rate.value);
fprintf('Audio only bitrate from function: %f bps\n', w.audio_only_bitrate);
fprintf('Difference: %f bps\n', abs(p.pcm_payload_rate.value - w.audio_only_bitrate));

fprintf('Gross bits per packet from registry: %f bits\n', p.gross_bits_per_packet.value);
fprintf('Gross bits per packet from function: %d bits\n', w.gross_bits_per_packet);
fprintf('Difference: %f bits\n', abs(p.gross_bits_per_packet.value - w.gross_bits_per_packet));

fprintf('Gross data rate from registry: %f bps\n', p.gross_data_rate.value);
fprintf('Gross bitrate from function: %f bps\n', w.gross_bitrate);
fprintf('Difference: %f bps\n', abs(p.gross_data_rate.value - w.gross_bitrate));

% Check if samples per packet is integer
if mod(w.samples_per_packet, 1) == 0
    fprintf('\nSamples per packet is integer: PASS\n');
else
    fprintf('\nSamples per packet is integer: FAIL\n');
end

% Check if audio only bitrate matches PCM payload rate (within tolerance)
if abs(p.pcm_payload_rate.value - w.audio_only_bitrate) < 1e-3
    fprintf('Audio only bitrate matches PCM payload rate: PASS\n');
else
    fprintf('Audio only bitrate matches PCM payload rate: FAIL\n');
end

% Check if gross bitrate matches gross data rate from registry (within tolerance)
if abs(p.gross_data_rate.value - w.gross_bitrate) < 1e-3
    fprintf('Gross bitrate matches registry gross data rate: PASS\n');
else
    fprintf('Gross bitrate matches registry gross data rate: FAIL\n');
end
