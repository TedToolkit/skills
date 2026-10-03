#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const DEFAULT_ENDPOINT = "https://api.fish.audio/v1/tts";
const API_KEY_ENV = "FISH_API_KEY";
const VOICE_ID_ENV = "FISH_VOICE_ID";
const SUPPORTED_MODELS = new Set([
  "s1",
  "s2-pro",
  "s2.1-pro",
  "s2.1-pro-free",
  "drama-3-preview",
]);

function usage() {
  console.error(
    "usage: fish-tts.mjs <narration.txt> <output.wav> [--model <name>] [--replace] [--dry-run]",
  );
  process.exit(2);
}

function parseArgs(argv) {
  if (argv.length < 2) usage();
  const positional = argv.slice(0, 2);
  const options = {
    model: "s2.1-pro",
    replace: false,
    dryRun: false,
  };
  for (let index = 2; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--replace") options.replace = true;
    else if (argument === "--dry-run") options.dryRun = true;
    else if (argument === "--model") {
      if (index + 1 >= argv.length) usage();
      const value = argv[index + 1];
      options.model = value;
      index += 1;
    } else usage();
  }
  return { positional, options };
}

function timestamp() {
  return new Date().toISOString().replaceAll(":", "-").replaceAll(".", "-");
}

function isWave(buffer) {
  return buffer.length >= 12 &&
    buffer.subarray(0, 4).toString("ascii") === "RIFF" &&
    buffer.subarray(8, 12).toString("ascii") === "WAVE";
}

const { positional, options } = parseArgs(process.argv.slice(2));

try {
  if (!SUPPORTED_MODELS.has(options.model)) {
    throw new Error(`unsupported Fish TTS model: ${options.model}`);
  }

  const inputPath = path.resolve(positional[0]);
  const outputPath = path.resolve(positional[1]);
  if (!fs.existsSync(inputPath) || !fs.statSync(inputPath).isFile()) {
    throw new Error(`missing narration text: ${inputPath}`);
  }
  const narrationText = fs.readFileSync(inputPath, "utf8").trim();
  if (!narrationText) throw new Error("narration text is empty");
  if (fs.existsSync(outputPath) && !options.replace) {
    throw new Error(`output already exists; inspect it or pass --replace: ${outputPath}`);
  }

  const requestSummary = {
    endpoint: DEFAULT_ENDPOINT,
    model: options.model,
    input: inputPath,
    output: outputPath,
    textUtf8Bytes: Buffer.byteLength(narrationText, "utf8"),
    apiKeyEnv: API_KEY_ENV,
    voiceIdEnv: VOICE_ID_ENV,
    format: "wav",
    sampleRate: 48000,
    sendsReferenceAudio: false,
  };
  if (options.dryRun) {
    console.log(JSON.stringify(requestSummary, null, 2));
    process.exit(0);
  }

  const apiKey = process.env[API_KEY_ENV];
  const voiceId = process.env[VOICE_ID_ENV];
  if (!apiKey) throw new Error(`missing API key in ${API_KEY_ENV}`);
  if (!voiceId) throw new Error(`missing saved Fish voice ID in ${VOICE_ID_ENV}`);

  const response = await fetch(DEFAULT_ENDPOINT, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      model: options.model,
    },
    body: JSON.stringify({
      text: narrationText,
      reference_id: voiceId,
      format: "wav",
      sample_rate: 48000,
      normalize: true,
      latency: "normal",
      prosody: {
        speed: 1,
        volume: 0,
        normalize_loudness: true,
      },
    }),
  });
  if (!response.ok) {
    const detail = (await response.text())
      .replaceAll(apiKey, "[redacted-api-key]")
      .replaceAll(voiceId, "[redacted-voice-id]")
      .slice(0, 1000);
    throw new Error(`Fish Audio returned ${response.status} ${response.statusText}${detail ? `: ${detail}` : ""}`);
  }

  const audio = Buffer.from(await response.arrayBuffer());
  if (!isWave(audio)) throw new Error("Fish Audio response is not a RIFF/WAVE file");

  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  const temporaryPath = path.join(
    path.dirname(outputPath),
    `.${path.basename(outputPath)}.${process.pid}.${Date.now()}.tmp`,
  );
  fs.writeFileSync(temporaryPath, audio, { flag: "wx" });
  let backupPath;
  if (fs.existsSync(outputPath)) {
    backupPath = `${outputPath}.bak-${timestamp()}`;
    fs.renameSync(outputPath, backupPath);
  }
  fs.renameSync(temporaryPath, outputPath);
  console.log(JSON.stringify({
    ...requestSummary,
    bytesWritten: audio.length,
    ...(backupPath ? { backup: backupPath } : {}),
  }, null, 2));
} catch (error) {
  console.error(`fish-tts: ${error.message}`);
  process.exitCode = 1;
}
