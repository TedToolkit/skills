# Loudness targets for tutorial narration

Use this reference to choose and explain a loudness target. Keep measurement method, delivery
target, and production role separate.

## Measurement versus target

ITU-R BS.1770-5 defines algorithms for programme loudness and true-peak measurement. It does not
define one universal delivery target. Measure integrated loudness over the complete rendered
programme or stem using a BS.1770-5-compatible meter, and use maximum true peak rather than sample
peak for headroom decisions.

LUFS and LKFS are numerically equivalent for these target comparisons. Preserve the terminology
used by the governing specification when reporting compliance.

## Choose the governing target

Use the first applicable row rather than averaging or combining targets from different delivery
systems.

| Destination or role | Loudness target | Maximum true peak | How to use it |
| --- | --- | --- | --- |
| Named course, client, broadcaster, or platform specification | Use that specification | Use that specification | It overrides every fallback below. |
| Standalone speech-only online lesson with no named specification | House default: -16 LUFS integrated, acceptable from -17 to -15 LUFS | -1.5 dBTP | Suitable for direct web playback and leaves a conservative margin below Apple's -1 dB true-peak ceiling. This is a workflow default, not an industry-wide mandate. |
| Apple Podcasts programme | About -16 LKFS, +/-1 dB | No higher than -1 dB true peak | Apply to the encoded programme's preconditioned master, not automatically to every upstream stem. |
| EBU R 128 broadcast programme | -23 LUFS | -1 dBTP | Use only when EBU delivery is requested. EBU R 128 s2 normally preserves -23 LUFS for streaming with loudness metadata; controlled distribution without metadata may use an interim -20 to -16 LUFS range. |
| ATSC A/85 content delivery or exchange without metadata | -24 LKFS, with measurement variation of about +/-2 dB | -2 dBTP | Use for the ATSC television or applicable streaming-service workflow, not as a generic web-video default. A/85:2026 recommends one streaming-service target in the -23 to -27 LKFS range unless parties agree otherwise. |
| Narration stem that will be mixed with music or effects | Project dialogue or stem target; otherwise preserve consistent speech level and headroom | Leave enough headroom for the downstream mix | Do not call the stem compliant with a final-program target. Re-measure and normalize the completed mix. |

Do not use a platform's playback-normalization folklore as a delivery specification. For example,
YouTube documents upload encoding and optional playback enhancements but does not publish a creator
loudness target in its upload specification. If the destination does not state a target, use the
house default deliberately and report it as such.

## Normalization and verification

1. Measure the edited render before deciding how much gain or dynamics processing it needs.
2. Match different takes by representative clean speech, not by peaks or sentence-by-sentence
   normalization. Avoid gain pumping and audible changes in room noise.
3. Use measured or two-pass loudness normalization for a formal master. A limiter may protect the
   true-peak ceiling, but it must not substitute for natural dynamics or repair clipped source audio.
4. Re-measure the actual rendered file after every sample-rate conversion, limiting, or lossy encode
   that can change peaks.
5. Report the governing target and version or destination, the accepted tolerance, integrated
   loudness, maximum true peak, channel layout, sample rate, and any unresolved clipping.

Integrated loudness alone does not prove comfortable speech. Also audition changes between takes,
sentence-to-sentence consistency, intelligibility, excessive compression, background-noise jumps,
and the loudest short passages. Do not invent a universal Loudness Range or short-term loudness limit
when the destination has not specified one.

## Primary references

- [ITU-R BS.1770-5 (November 2023)](https://www.itu.int/rec/R-REC-BS.1770-5-202311-I/): measurement algorithms for programme loudness and true peak.
- [EBU R 128, version 5.0 (November 2023)](https://tech.ebu.ch/publications/r128): -23 LUFS broadcast programme target and loudness descriptors.
- [EBU R 128 s2, version 3.0 (November 2023)](https://tech.ebu.ch/publications/r128s2): streaming guidance and the conditional -20 to -16 LUFS distribution range.
- [ATSC A/85:2026-07](https://www.atsc.org/atsc-documents/a85-techniques-for-establishing-and-maintaining-audio-loudness-for-digital-television/): television and streaming-service loudness guidance, including the Annex M quick reference.
- [Apple Podcasts audio requirements](https://podcasters.apple.com/support/893-audio-requirements): approximately -16 LKFS +/-1 dB and true peak no higher than -1 dB for podcast programme audio.
