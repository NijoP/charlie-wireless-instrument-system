function wireless_results = wireless_throughput(params)
% WIRELESS_THROUGHPUT Compute wireless throughput and packetization metrics.
%
%   WIRELESS_RESULTS = WIRELESS_THROUGHPUT(PARAMS) takes a parameter structure
%   and returns a structure with wireless throughput results.
%
%   The input PARAMS should be the structure returned by get_parameters().
%
%   The output WIRELESS_RESULTS is a structure with fields:
%   - samples_per_packet: number of audio samples per wireless packet (must be integer)
%   - audio_payload_bits_per_packet: bits
%   - audio_payload_bytes_per_packet: bytes
%   - metadata_bits_per_packet: bits (averaged over packets, considering update interval)
%   - metadata_bytes_per_packet: bytes (averaged)
%   - application_frame_bits_per_packet: audio payload + metadata (bits)
%   - application_frame_bytes_per_packet: bytes
%   - overhead_header_bits_per_packet: bits
%   - overhead_crc_bits_per_packet: bits
%   - total_overhead_bits_per_packet: header + CRC (bits)
%   - gross_bits_per_packet: audio payload + metadata + header + CRC (bits)
%   - audio_only_bitrate: bits/s (should equal pcm_payload_rate)
%   - application_bitrate: bits/s (application frame rate)
%   - gross_bitrate: bits/s (gross rate)
%   - overhead_header_bitrate: bits/s
%   - overhead_crc_bitrate: bits/s
%   - total_overhead_bitrate: bits/s
%   - cc8530_nominal_rate: nominal radio rate for CC8530/CC8531 (bits/s)
%   - nrf54l15_nominal_rate: nominal radio rate for nRF54L15 proprietary mode (bits/s)
%   - cc8530_usable_headroom: usable throughput headroom for CC8530 (fraction)
%   - nrf54l15_usable_headroom: usable throughput headroom for nRF54l15 (fraction)
%   - notes: struct with explanations for each field
%
%   The function assumes that metadata is sent every N audio packets, where N is
%   given by params.wireless_metadata_update_interval.value.

% Validate samples per packet
samples_per_packet_exact = params.audio_sample_rate.value * params.wireless_packet_interval.value;
if abs(samples_per_packet_exact - round(samples_per_packet_exact)) > 1e-6
    error('Samples per packet is not an integer: %f. Packetization interval must be chosen such that sample_rate * packet_interval is an integer.', samples_per_packet_exact);
end
samples_per_packet = round(samples_per_packet_exact);

% Audio payload
audio_payload_bits_per_packet = params.audio_bit_depth.value * params.audio_channels.value * samples_per_packet;
audio_payload_bytes_per_packet = audio_payload_bits_per_packet / 8;

% Metadata: size per metadata packet, but sent every N audio packets
metadata_update_interval = params.wireless_metadata_update_interval.value; % packets per metadata packet
metadata_bits_per_packet = params.wireless_metadata_size.value * 8 / metadata_update_interval; % average bits per audio packet
metadata_bytes_per_packet = params.wireless_metadata_size.value / metadata_update_interval; % average bytes per audio packet

% Application frame (audio payload + metadata)
application_frame_bits_per_packet = application_frame_bits_per_packet + metadata_bits_per_packet;
application_frame_bytes_per_packet = application_frame_bytes_per_packet + metadata_bytes_per_packet;

% Overhead: header and CRC (assumed to be present in every wireless packet)
overhead_header_bits_per_packet = params.wireheader_size.value * 8;
overhead_crc_bits_per_packet = params.wireless_crc_size.value * 8;
total_overhead_bits_per_packet = overhead_header_bits_per_packet + overhead_crc_bits_per_packet;

% Gross bits per packet: audio payload + metadata + header + CRC
gross_bits_per_packet = application_frame_bits_per_packet + total_overhead_bits_per_packet;

% Bitrates
audio_only_bitrate = audio_payload_bits_per_packet / params.wireless_packet_interval.value; % should equal pcm_payload_rate
application_bitrate = application_frame_bits_per_packet / params.wireless_packet_interval.value;
gross_bitrate = gross_bits_per_packet / params.wireless_packet_interval.value;
ohb = overhead_header_bits_per_packet / params.wireless_packet_interval.value;
ocrc = overhead_crc_bits_per_packet / params.wireless_packet_interval.value;
tot = total_overhead_bits_per_packet / params.wireless_packet_interval.value;

% Nominal radio rates (from manufacturer data)
cc8530_nominal_rate = 2e6; % bps, from TI CC8530/CC8531 datasheet (up to 2 Mbps)
nrf54l15_nominal_rate = 4e6; % bps, from Nordic nRF54L15 product page (advertised 4 Mbps proprietary mode)

% Usable headroom: fraction of nominal rate that is available for application after overhead
cc8530_usable_headroom = (cc8530_nominal_rate - gross_bitrate) / cc8530_nominal_rate;
nrf54l15_usable_headroom = (nrf54l15_nominal_rate - gross_bitrate) / nrf54l15_nominal_rate;

% Additional notes
wireless_results.notes = struct( ...
    'samples_per_packet', 'Number of audio samples per wireless packet. Must be integer; validated with tolerance 1e-6.', ...
    'audio_payload_bits_per_packet', 'Bits of audio payload in each wireless packet.', ...
    'audio_payload_bytes_per_packet', 'Bytes of audio payload in each wireless packet.', ...
    'metadata_bits_per_packet', 'Average bits of metadata per wireless packet, considering update interval.', ...
    'metadata_bytes_per_packet', 'Average bytes of metadata per wireless packet, considering update interval.', ...
    'application_frame_bits_per_packet', 'Bits of application frame (audio payload + metadata) per wireless packet.', ...
    'application_frame_bytes_per_packet', 'Bytes of application frame per wireless packet.', ...
    'overhead_header_bits_per_packet', 'Bits of wireless protocol header per packet (assumed present every packet).', ...
    'overhead_crc_bits_per_packet', 'Bits of CRC per packet (assumed present every packet).', ...
    'total_overhead_bits_per_packet', 'Total overhead bits per packet (header + CRC).', ...
    'gross_bits_per_packet', 'Total bits per wireless packet (application frame + overhead).', ...
    'audio_only_bitrate', 'Audio payload bitrate (bits/s). Should equal the PCM payload rate from the parameter registry.', ...
    'application_bitrate', 'Application frame bitrate (bits/s).', ...
    'gross_bitrate', 'Gross wireless bitrate (bits/s) including all overhead.', ...
    'overhead_header_bitrate', 'Header overhead bitrate (bits/s).', ...
    'overhead_crc_bitrate', 'CRC overhead bitrate (bits/s).', ...
    'total_overhead_bitrate', 'Total overhead bitrate (bits/s).', ...
    'cc8530_nominal_rate', 'Nominal radio rate for CC8530/CC8531 (bits/s) from TI datasheet (up to 2 Mbps).', ...
    'nrf54l15_nominal_rate', 'Nominal radio rate for nRF54L15 proprietary mode (bits/s) from Nordic product page (advertised 4 Mbps).', ...
    'cc8530_usable_headroom', 'Fraction of CC8530 nominal rate available for application after overhead (1 - gross_bitrate/cc8530_nominal_rate).', ...
    'nrf54l15_usable_headroom', 'Fraction of nRF54L15 nominal rate available for application after overhead (1 - gross_bitrate/nrf54l15_nominal_rate).' ...
);

% Assign the main fields
wireless_results.samples_per_packet = samples_per_packet;
wireless_results.audio_payload_bits_per_packet = audio_payload_bits_per_packet;
wireless_results.audio_payload_bytes_per_packet = audio_payload_bytes_per_packet;
wireless_results.metadata_bits_per_packet = metadata_bits_per_packet;
wireless_results.metadata_bytes_per_packet = metadata_bytes_per_packet;
wireless_results.application_frame_bits_per_packet = application_frame_bits_per_packet;
wireless_results.application_frame_bytes_per_packet = application_frame_bytes_per_packet;
wireless_results.overhead_header_bits_per_packet = overhead_header_bits_per_packet;
wireless_results.overhead_crc_bits_per_packet = overhead_crc_bits_per_packet;
wireless_results.total_overhead_bits_per_packet = total_overhead_bits_per_packet;
wireless_results.gross_bits_per_packet = gross_bits_per_packet;
wireless_results.audio_only_bitrate = audio_only_bitrate;
wireless_results.application_bitrate = application_bitrate;
wireless_results.gross_bitrate = gross_bitrate;
wireless_results.overhead_header_bitrate_out = ohb;
wireless_results.overhead_crc_bitrate = ocrc;
wireless_results.total_overhead_bitrate_out = tot;
wireless_results.cc8530_nominal_rate = cc8530_nominal_rate;
wireless_results.nrf54l15_nominal_rate = nrf54l15_nominal_rate;
wireless_results.cc8530_usable_headroom = cc8530_usable_headroom;
wireless_results.nrf54l15_usable_headroom = nrf54l15_usable_headroom;

end
