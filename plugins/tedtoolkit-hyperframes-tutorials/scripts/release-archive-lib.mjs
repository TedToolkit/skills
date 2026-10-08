import crypto from "node:crypto";
import fs from "node:fs";
import { open } from "node:fs/promises";
import zlib from "node:zlib";

function toSafeNumber(value, label) {
  if (value > BigInt(Number.MAX_SAFE_INTEGER)) throw new Error(`ZIP ${label} exceeds supported size`);
  return Number(value);
}

async function readAt(handle, length, position) {
  const buffer = Buffer.alloc(length);
  let offset = 0;
  while (offset < length) {
    const { bytesRead } = await handle.read(buffer, offset, length - offset, position + offset);
    if (!bytesRead) throw new Error("ZIP ends before its declared records");
    offset += bytesRead;
  }
  return buffer;
}

function zip64Values(extra, needSize, needCompressed, needOffset) {
  let cursor = 0;
  while (cursor + 4 <= extra.length) {
    const kind = extra.readUInt16LE(cursor);
    const length = extra.readUInt16LE(cursor + 2);
    cursor += 4;
    if (cursor + length > extra.length) throw new Error("ZIP extra field is truncated");
    if (kind === 0x0001) {
      let field = cursor;
      const take = (label) => {
        if (field + 8 > cursor + length) throw new Error(`ZIP64 ${label} is missing`);
        const result = toSafeNumber(extra.readBigUInt64LE(field), label);
        field += 8;
        return result;
      };
      return {
        size: needSize ? take("uncompressed size") : undefined,
        compressed: needCompressed ? take("compressed size") : undefined,
        offset: needOffset ? take("local header offset") : undefined,
      };
    }
    cursor += length;
  }
  if (needSize || needCompressed || needOffset) throw new Error("ZIP64 entry lacks its size metadata");
  return {};
}

function safeEntryName(name) {
  if (!name || name.includes("\\") || name.includes("\0") || name.startsWith("/") ||
      /^[A-Za-z]:/.test(name) || name.split("/").some((part) => part === ".." || part === ".")) {
    throw new Error(`ZIP contains an unsafe path: ${name}`);
  }
  return name;
}

async function zipDirectory(handle, archiveSize) {
  const tailLength = Math.min(archiveSize, 22 + 65535);
  const tailStart = archiveSize - tailLength;
  const tail = await readAt(handle, tailLength, tailStart);
  let eocd = -1;
  for (let index = tail.length - 22; index >= 0; index -= 1) {
    if (tail.readUInt32LE(index) === 0x06054b50 &&
        index + 22 + tail.readUInt16LE(index + 20) === tail.length) {
      eocd = index;
      break;
    }
  }
  if (eocd < 0) throw new Error("ZIP end-of-central-directory record is missing");
  if (tail.readUInt16LE(eocd + 4) !== 0 || tail.readUInt16LE(eocd + 6) !== 0) {
    throw new Error("multi-disk ZIP archives are unsupported");
  }
  let count = tail.readUInt16LE(eocd + 10);
  let size = tail.readUInt32LE(eocd + 12);
  let offset = tail.readUInt32LE(eocd + 16);
  if (count === 0xffff || size === 0xffffffff || offset === 0xffffffff) {
    const locatorPosition = tailStart + eocd - 20;
    if (locatorPosition < 0) throw new Error("ZIP64 locator is missing");
    const locator = await readAt(handle, 20, locatorPosition);
    if (locator.readUInt32LE(0) !== 0x07064b50 || locator.readUInt32LE(4) !== 0 ||
        locator.readUInt32LE(16) !== 1) throw new Error("ZIP64 locator is invalid");
    const zip64Position = toSafeNumber(locator.readBigUInt64LE(8), "directory offset");
    const record = await readAt(handle, 56, zip64Position);
    if (record.readUInt32LE(0) !== 0x06064b50 || record.readUInt32LE(16) !== 0 ||
        record.readUInt32LE(20) !== 0) throw new Error("ZIP64 directory record is invalid");
    count = toSafeNumber(record.readBigUInt64LE(32), "entry count");
    size = toSafeNumber(record.readBigUInt64LE(40), "central directory size");
    offset = toSafeNumber(record.readBigUInt64LE(48), "central directory offset");
  }
  if (offset + size > archiveSize || count > 1_000_000) throw new Error("ZIP directory bounds are invalid");
  return { count, offset, end: offset + size };
}

async function fileHash(handle, archivePath, entry, archiveSize) {
  const local = await readAt(handle, 30, entry.offset);
  if (local.readUInt32LE(0) !== 0x04034b50 || local.readUInt16LE(8) !== entry.method) {
    throw new Error(`ZIP local header differs from directory: ${entry.name}`);
  }
  const nameLength = local.readUInt16LE(26);
  const extraLength = local.readUInt16LE(28);
  const localName = await readAt(handle, nameLength, entry.offset + 30);
  if (localName.toString("utf8") !== entry.name) {
    throw new Error(`ZIP local filename differs from directory: ${entry.name}`);
  }
  const start = entry.offset + 30 + nameLength + extraLength;
  if (start + entry.compressed > archiveSize) throw new Error(`ZIP file data is truncated: ${entry.name}`);
  if (entry.method !== 0 && entry.method !== 8) {
    throw new Error(`ZIP compression method is unsupported for ${entry.name}: ${entry.method}`);
  }
  if (entry.compressed === 0) {
    if (entry.size !== 0 || entry.method !== 0) throw new Error(`ZIP file data is missing: ${entry.name}`);
    return `sha256:${crypto.createHash("sha256").digest("hex")}`;
  }
  const input = fs.createReadStream(archivePath, { start, end: start + entry.compressed - 1 });
  const output = entry.method === 8 ? input.pipe(zlib.createInflateRaw()) : input;
  const hash = crypto.createHash("sha256");
  let bytes = 0;
  for await (const chunk of output) {
    bytes += chunk.length;
    if (bytes > entry.size) throw new Error(`ZIP decompressed size exceeds its directory record: ${entry.name}`);
    hash.update(chunk);
  }
  if (bytes !== entry.size) throw new Error(`ZIP decompressed size differs from its directory record: ${entry.name}`);
  return `sha256:${hash.digest("hex")}`;
}

export async function fingerprintZip(archivePath) {
  const handle = await open(archivePath, "r");
  try {
    const archiveSize = (await handle.stat()).size;
    const directory = await zipDirectory(handle, archiveSize);
    const files = new Map();
    let cursor = directory.offset;
    for (let index = 0; index < directory.count; index += 1) {
      const header = await readAt(handle, 46, cursor);
      if (header.readUInt32LE(0) !== 0x02014b50) throw new Error("ZIP central directory entry is invalid");
      const flags = header.readUInt16LE(8);
      const method = header.readUInt16LE(10);
      if (flags & 1) throw new Error("encrypted ZIP entries are unsupported");
      const nameLength = header.readUInt16LE(28);
      const extraLength = header.readUInt16LE(30);
      const commentLength = header.readUInt16LE(32);
      const rest = await readAt(handle, nameLength + extraLength + commentLength, cursor + 46);
      const nameBytes = rest.subarray(0, nameLength);
      if (!(flags & 0x0800) && nameBytes.some((byte) => byte > 0x7f)) {
        throw new Error("ZIP filename lacks a UTF-8 encoding flag");
      }
      const name = safeEntryName(nameBytes.toString("utf8"));
      const extra = rest.subarray(nameLength, nameLength + extraLength);
      const rawSize = header.readUInt32LE(24);
      const rawCompressed = header.readUInt32LE(20);
      const rawOffset = header.readUInt32LE(42);
      const zip64 = zip64Values(extra, rawSize === 0xffffffff,
        rawCompressed === 0xffffffff, rawOffset === 0xffffffff);
      const entry = {
        name,
        method,
        size: zip64.size ?? rawSize,
        compressed: zip64.compressed ?? rawCompressed,
        offset: zip64.offset ?? rawOffset,
      };
      const unixMode = header.readUInt16LE(4) >> 8 === 3 ? header.readUInt32LE(38) >>> 16 : 0;
      if ((unixMode & 0xf000) === 0xa000) throw new Error(`ZIP contains a symbolic link: ${name}`);
      if (!name.endsWith("/")) {
        if (files.has(name)) throw new Error(`ZIP repeats a file path: ${name}`);
        files.set(name, await fileHash(handle, archivePath, entry, archiveSize));
      }
      cursor += 46 + rest.length;
    }
    if (cursor !== directory.end) throw new Error("ZIP central directory size does not match its entries");
    return files;
  } finally {
    await handle.close();
  }
}

export async function compareZipToDirectory(archivePath, expectedFiles) {
  const archived = await fingerprintZip(archivePath);
  const expected = new Map(Object.entries(expectedFiles));
  const names = [...archived.keys()];
  if (!archived.has("index.html") && names.length > 0) {
    const first = names[0].split("/")[0];
    if (names.every((name) => name.startsWith(`${first}/`))) {
      const unwrapped = new Map();
      for (const [name, hash] of archived) unwrapped.set(name.slice(first.length + 1), hash);
      archived.clear();
      for (const [name, hash] of unwrapped) archived.set(name, hash);
    }
  }
  const missing = [...expected.keys()].filter((name) => !archived.has(name));
  const extra = [...archived.keys()].filter((name) => !expected.has(name));
  const changed = [...expected.keys()].filter((name) => archived.has(name) && archived.get(name) !== expected.get(name));
  if (missing.length || extra.length || changed.length) {
    throw new Error(`ZIP differs from release directory: missing ${missing.join(", ") || "none"}; extra ${extra.join(", ") || "none"}; changed ${changed.join(", ") || "none"}`);
  }
}
