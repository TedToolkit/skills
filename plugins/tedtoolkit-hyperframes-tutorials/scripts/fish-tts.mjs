#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { spawnSync } from "node:child_process";

const DEFAULT_ENDPOINT = "https://api.fish.audio/v1/tts";
const API_KEY_ENV = "FISH_API_KEY";
const VOICE_ID_ENV = "FISH_VOICE_ID";
const NARRATION_SAMPLE_RATE = 44100;
const SUPPORTED_MODELS = new Set([
  "s1",
  "s2-pro",
  "s2.1-pro",
  "s2.1-pro-free",
  "drama-3-preview",
]);

function usage() {
  console.error(
    "usage: fish-tts.mjs <narration.txt> <output.wav> [--model <name>] [--replace] [--retry-uncertain] [--dry-run]",
  );
  process.exit(2);
}

function parseArgs(argv) {
  if (argv.length < 2) usage();
  const positional = argv.slice(0, 2);
  const options = {
    model: "s2.1-pro",
    replace: false,
    retryUncertain: false,
    dryRun: false,
  };
  for (let index = 2; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--replace") options.replace = true;
    else if (argument === "--retry-uncertain") options.retryUncertain = true;
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

function sha256(value) {
  return `sha256:${crypto.createHash("sha256").update(value).digest("hex")}`;
}

function readRequestRecord(recordPath) {
  if (!fs.existsSync(recordPath)) return { formatVersion: 1, attempts: [] };
  const record = JSON.parse(fs.readFileSync(recordPath, "utf8"));
  if (record.formatVersion !== 1 || !Array.isArray(record.attempts) ||
      record.attempts.some((attempt) => typeof attempt.requestSha256 !== "string" ||
        !["pending", "http-error", "complete"].includes(attempt.status))) {
    throw new Error(`invalid Fish request record; inspect before retrying: ${recordPath}`);
  }
  return record;
}

function writeRequestRecord(recordPath, record) {
  const temporaryPath = `${recordPath}.${process.pid}.${Date.now()}.tmp`;
  fs.writeFileSync(temporaryPath, `${JSON.stringify(record, null, 2)}\n`, { flag: "wx" });
  fs.renameSync(temporaryPath, recordPath);
}

function isWave(buffer) {
  return buffer.length >= 12 &&
    buffer.subarray(0, 4).toString("ascii") === "RIFF" &&
    buffer.subarray(8, 12).toString("ascii") === "WAVE";
}

function normalizeWave(buffer) {
  if (!isWave(buffer)) throw new Error("Fish Audio response is not a RIFF/WAVE file");
  if (buffer.length < 44 || buffer.toString("ascii", 12, 16) !== "fmt " ||
      buffer.readUInt32LE(16) !== 16 || buffer.readUInt16LE(20) !== 1 ||
      buffer.toString("ascii", 36, 40) !== "data") {
    throw new Error("Fish Audio response has an unsupported WAV layout");
  }
  if (buffer.readUInt32LE(24) !== NARRATION_SAMPLE_RATE) {
    throw new Error(`Fish Audio response has unexpected sample rate: ${buffer.readUInt32LE(24)}`);
  }
  const blockAlign = buffer.readUInt16LE(32);
  if (!blockAlign || (buffer.length - 44) % blockAlign !== 0) {
    throw new Error("Fish Audio response has incomplete PCM frames");
  }
  // Fish can return streaming WAV headers with placeholder RIFF and data lengths.
  buffer.writeUInt32LE(buffer.length - 8, 4);
  buffer.writeUInt32LE(buffer.length - 44, 40);
  return buffer;
}

function enableEnvironmentProxy() {
  if (!process.env.HTTPS_PROXY && !process.env.https_proxy) return;
  if (process.env.NODE_USE_ENV_PROXY !== undefined) return;
  if (process.execArgv.includes("--use-env-proxy") ||
      process.execArgv.includes("--no-use-env-proxy")) return;
  if (!process.allowedNodeEnvironmentFlags.has("--use-env-proxy")) return;

  // Node reads proxy settings at startup, so restart before the paid request.
  const child = spawnSync(process.execPath, [
    "--use-env-proxy", ...process.execArgv, process.argv[1], ...process.argv.slice(2),
  ], { stdio: "inherit" });
  if (child.error) throw child.error;
  process.exit(child.status ?? 1);
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
  const recordPath = `${outputPath}.fish-request.json`;

  const requestSummary = {
    endpoint: DEFAULT_ENDPOINT,
    model: options.model,
    input: inputPath,
    output: outputPath,
    textUtf8Bytes: Buffer.byteLength(narrationText, "utf8"),
    apiKeyEnv: API_KEY_ENV,
    voiceIdEnv: VOICE_ID_ENV,
    format: "wav",
    sampleRate: NARRATION_SAMPLE_RATE,
    sendsReferenceAudio: false,
    outputExists: fs.existsSync(outputPath),
    requestRecord: recordPath,
    requestLockExists: fs.existsSync(`${recordPath}.lock`),
  };
  if (options.dryRun) {
    const record = readRequestRecord(recordPath);
    requestSummary.lastAttemptStatus = record.attempts.at(-1)?.status ?? "none";
    console.log(JSON.stringify(requestSummary, null, 2));
    process.exit(0);
  }

  const apiKey = process.env[API_KEY_ENV];
  const voiceId = process.env[VOICE_ID_ENV];
  if (!apiKey) throw new Error(`missing API key in ${API_KEY_ENV}`);
  if (!voiceId) throw new Error(`missing saved Fish voice ID in ${VOICE_ID_ENV}`);

  enableEnvironmentProxy();
  const payload = {
    text: narrationText,
    reference_id: voiceId,
    format: "wav",
    sample_rate: NARRATION_SAMPLE_RATE,
    normalize: true,
    latency: "normal",
    prosody: { speed: 1, volume: 0, normalize_loudness: true },
  };
  const requestSha256 = sha256(JSON.stringify({
    endpoint: DEFAULT_ENDPOINT,
    model: options.model,
    payload,
  }));

  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  const lockPath = `${recordPath}.lock`;
  let lockFd;
  try {
    try {
      lockFd = fs.openSync(lockPath, "wx", 0o600);
    } catch (error) {
      if (error.code === "EEXIST") {
        throw new Error(`another Fish request may be running; inspect the lock before retrying: ${lockPath}`);
      }
      throw error;
    }
    const record = readRequestRecord(recordPath);
    const previous = record.attempts.at(-1);
    const outputExists = fs.existsSync(outputPath);
    if (["pending", "http-error"].includes(previous?.status) && !options.retryUncertain) {
      throw new Error(`previous Fish request has no confirmed WAV; inspect provider usage and pass --retry-uncertain only after deciding to retry: ${recordPath}`);
    }
    if (outputExists && !options.replace) {
      if (previous?.status === "complete" && previous.requestSha256 === requestSha256 &&
          previous.outputSha256 === sha256(fs.readFileSync(outputPath))) {
        console.log(JSON.stringify({ ...requestSummary, reused: true, requestSha256 }, null, 2));
      } else {
        throw new Error(`output already exists; inspect it or pass --replace: ${outputPath}`);
      }
    } else {
      if (!outputExists && previous?.status === "complete" &&
          previous.requestSha256 === requestSha256 && !options.retryUncertain) {
        throw new Error(`the same Fish request completed before, but its WAV is missing; inspect before retrying: ${recordPath}`);
      }
      const attempt = {
        requestSha256,
        textSha256: sha256(narrationText),
        model: options.model,
        textUtf8Bytes: requestSummary.textUtf8Bytes,
        startedAt: new Date().toISOString(),
        status: "pending",
      };
      record.attempts.push(attempt);
      writeRequestRecord(recordPath, record);

      const response = await fetch(DEFAULT_ENDPOINT, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${apiKey}`,
          "Content-Type": "application/json",
          model: options.model,
        },
        body: JSON.stringify(payload),
      });
      if (!response.ok) {
        const detail = (await response.text())
          .replaceAll(apiKey, "[redacted-api-key]")
          .replaceAll(voiceId, "[redacted-voice-id]")
          .slice(0, 1000);
        attempt.status = "http-error";
        attempt.httpStatus = response.status;
        attempt.finishedAt = new Date().toISOString();
        writeRequestRecord(recordPath, record);
        throw new Error(`Fish Audio returned ${response.status} ${response.statusText}${detail ? `: ${detail}` : ""}`);
      }

      const audio = normalizeWave(Buffer.from(await response.arrayBuffer()));
      const temporaryPath = path.join(
        path.dirname(outputPath),
        `.${path.basename(outputPath)}.${process.pid}.${Date.now()}.tmp`,
      );
      fs.writeFileSync(temporaryPath, audio, { flag: "wx" });
      let backupPath;
      if (outputExists) {
        backupPath = `${outputPath}.bak-${timestamp()}`;
        fs.renameSync(outputPath, backupPath);
      }
      fs.renameSync(temporaryPath, outputPath);
      attempt.status = "complete";
      attempt.finishedAt = new Date().toISOString();
      attempt.outputSha256 = sha256(audio);
      writeRequestRecord(recordPath, record);
      console.log(JSON.stringify({
        ...requestSummary,
        requestSha256,
        bytesWritten: audio.length,
        ...(backupPath ? { backup: backupPath } : {}),
      }, null, 2));
    }
  } finally {
    if (lockFd !== undefined) {
      fs.closeSync(lockFd);
      fs.unlinkSync(lockPath);
    }
  }
} catch (error) {
  console.error(`fish-tts: ${error.message}`);
  process.exitCode = 1;
}
