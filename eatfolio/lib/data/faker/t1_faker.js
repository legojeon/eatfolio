// t1_faker.js
// Run: node path/to/t1_faker.js

import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";
import dotenv from "dotenv";
import admin from "firebase-admin";
import axios from "axios";
import FormData from "form-data";
import { faker } from "@faker-js/faker/locale/ko";
import { spawnSync } from "child_process";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/* Load root .env */
const candidates = [path.resolve(__dirname, "../../.."), process.cwd()];
let loaded = false;
for (const root of candidates) {
  const envPath = path.join(root, ".env");
  if (fs.existsSync(envPath)) {
    dotenv.config({ path: envPath });
    console.log(`[dotenv] loaded: ${envPath}`);
    loaded = true;
    break;
  }
}
if (!loaded) {
  console.warn("[dotenv] .env not found in common roots – ensure Firebase Admin & Pexels keys exist.");
}

/* ---------- Config ---------- */
const DAYS = 30;
const MAX_PEXELS_PER_PAGE = 80;
const TIMEOUT_MS = 20000;

// Wait for backend analysis instead of fixed delay
const ANALYSIS_TIMEOUT_MS = Number(process.env.FAKER_ANALYSIS_TIMEOUT_MS || 5 * 60 * 1000); // 5m
const ANALYSIS_INITIAL_POLL_MS = Number(process.env.FAKER_ANALYSIS_INITIAL_POLL_MS || 2000);
const ANALYSIS_MAX_POLL_MS = Number(process.env.FAKER_ANALYSIS_MAX_POLL_MS || 10000);

const TARGET_PATH = "/storage/emulated/0/Android/data/com.example.eatfolio/files/";
const LOCAL_CACHE = path.join(__dirname, "monthly_fake_images");
const BACKEND_URL = (process.env.BACKEND_URL || "https://eat.coco.io.kr").replace(/\/+$/, "");
const CALL_BACKEND = true; // set false to skip /request_analysis

// Who to attribute docs to
const USER_ID = process.env.FAKER_USER_ID || "LPK07O0YrBhpvU1lZ0MUWBxq5g62";

// Pexels API
const PEXELS_API_KEY = process.env.PEXELS_API_KEY || process.env.PIXELS_API_KEY || "";
if (!PEXELS_API_KEY) {
  console.error("❌ Missing Pexels API key. Set PEXELS_API_KEY (or PIXELS_API_KEY) in .env");
  process.exit(1);
}

// Meals + time ranges (KST)
const MEAL_ORDER = ["breakfast", "lunch", "dinner"];
const MEAL_QUERIES = { breakfast: "rice dish", lunch: "chinese food", dinner: "asian dish" };
// (start_h, start_m, end_h, end_m)
const MEAL_TIME_RANGES = {
  breakfast: [7, 0, 9, 0],
  lunch: [11, 30, 13, 30],
  dinner: [18, 0, 21, 0],
};

/* ---------- Firebase Admin init ---------- */
const serviceAccount = {
  type: "service_account",
  project_id: process.env.FIREBASE_PROJECT_ID,
  private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
  private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
  client_email: process.env.FIREBASE_CLIENT_EMAIL,
  client_id: process.env.FIREBASE_CLIENT_ID,
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL,
};
for (const k of ["project_id", "private_key", "client_email"]) {
  if (!serviceAccount[k]) {
    console.error("❌ Missing Firebase Admin env; check your .env");
    process.exit(1);
  }
}
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

/* ---------- Helpers ---------- */
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

function adbOk() {
  const res = spawnSync("adb", ["devices"], { encoding: "utf-8" });
  if (res.error) return false;
  const lines = (res.stdout || "").split("\n").slice(1).filter((l) => l.trim());
  return lines.some((ln) => ln.includes("\tdevice") || ln.includes("emulator"));
}

function adbShell(args, { ignoreError = true } = {}) {
  const res = spawnSync("adb", ["shell", ...args], { encoding: "utf-8" });
  if (res.status !== 0 && !ignoreError) {
    throw new Error(`adb shell ${args.join(" ")} failed: ${res.stderr || res.error}`);
  }
  return res;
}

function adbPush(local, remote) {
  const res = spawnSync("adb", ["push", local, remote], { encoding: "utf-8" });
  if (res.status !== 0) {
    throw new Error(`adb push failed: ${res.stderr || res.error}`);
  }
}

function ensureTargetDir(p) {
  adbShell(["mkdir", "-p", p], { ignoreError: true });
}

function randomTimeInRange([sh, sm, eh, em]) {
  const start = sh * 60 + sm;
  const end = eh * 60 + em;
  const pick = Math.floor(Math.random() * (end - start + 1)) + start;
  const hh = Math.floor(pick / 60);
  const mm = pick % 60;
  const ss = Math.floor(Math.random() * 60);
  return { hh, mm, ss };
}

// Return a Date representing KST local wall clock y/m/d hh:mm:ss (stored as absolute UTC instant)
function dateInKST(y, m, d, hh, mm, ss) {
  // KST local time -> UTC instant = subtract 9h
  return new Date(Date.UTC(y, m - 1, d, hh - 9, mm, ss));
}

function yyyymmdd(date) {
  const y = date.getUTCFullYear();
  const m = String(date.getUTCMonth() + 1).padStart(2, "0");
  const d = String(date.getUTCDate()).padStart(2, "0");
  return `${y}${m}${d}`;
}

function makeRecordId() {
  return `${Date.now()}_${faker.string.alphanumeric(6)}`;
}

function guessContentTypeFromExt(file) {
  const ext = path.extname(file).toLowerCase();
  if (ext === ".png") return "image/png";
  if (ext === ".webp") return "image/webp";
  return "image/jpeg";
}

async function searchPexels(query, per_page = 80, page = 1) {
  const url = "https://api.pexels.com/v1/search";
  const res = await axios.get(url, {
    headers: { Authorization: PEXELS_API_KEY },
    params: { query, per_page, page },
    timeout: TIMEOUT_MS,
  });
  const photos = Array.isArray(res.data?.photos) ? res.data.photos : [];
  const urls = [];
  for (const p of photos) {
    const src = p?.src || {};
    urls.push(src.large2x || src.original || src.large || src.medium || src.small);
  }
  return urls.filter(Boolean);
}

async function collectUrlsFor(query, need) {
  let page = 1;
  let out = [];
  while (out.length < need) {
    const batch = await searchPexels(query, Math.min(MAX_PEXELS_PER_PAGE, need), page);
    if (!batch.length) break;
    out = out.concat(batch);
    page += 1;
    await sleep(400);
  }
  if (out.length < need && out.length > 0) {
    const times = Math.ceil(need / out.length);
    out = Array(times).fill(out).flat().slice(0, need);
  }
  return out.slice(0, need);
}

async function collectMealPools(plan) {
  const counts = plan.reduce((acc, { meal }) => ((acc[meal] = (acc[meal] || 0) + 1), acc), {});
  const pools = {};
  for (const meal of Object.keys(counts)) {
    const q = MEAL_QUERIES[meal] || "food";
    const cnt = counts[meal];
    const urls = await collectUrlsFor(q, cnt);
    pools[meal] = urls.length ? urls : await collectUrlsFor("food", cnt);
  }
  return pools;
}

async function download(url, toPath) {
  await fs.promises.mkdir(path.dirname(toPath), { recursive: true });
  const res = await axios.get(url, { responseType: "arraybuffer", timeout: TIMEOUT_MS });
  await fs.promises.writeFile(toPath, Buffer.from(res.data));
  const ct =
    res.headers["content-type"] ||
    (url.endsWith(".png") ? "image/png" : url.endsWith(".webp") ? "image/webp" : "image/jpeg");
  return ct;
}

function planMonthKST() {
  // now in KST
  const now = new Date(Date.now() + 9 * 3600 * 1000);
  const start = new Date(now);
  start.setUTCDate(start.getUTCDate() - (DAYS - 1));
  const days = [];
  for (let i = 0; i < DAYS; i++) {
    const d = new Date(start);
    d.setUTCDate(start.getUTCDate() + i);
    days.push(new Date(d));
  }
  const plan = [];
  for (const d of days) {
    const mealsToday = faker.number.int({ min: 2, max: 3 });
    const chosen = faker.helpers
      .arrayElements(MEAL_ORDER, mealsToday)
      .sort((a, b) => MEAL_ORDER.indexOf(a) - MEAL_ORDER.indexOf(b));
    for (const meal of chosen) plan.push({ date: new Date(d), meal });
  }
  plan.sort((a, b) => a.date - b.date || MEAL_ORDER.indexOf(a.meal) - MEAL_ORDER.indexOf(b.meal));
  return plan;
}

/* ---------- Firestore + Backend ---------- */
async function seedPhotosDoc({ recordId, userId, devicePath, meal, createdAtKstDate }) {
  const doc = {
    record_id: recordId,
    user_id: userId,
    rating: faker.number.int({ min: 1, max: 5 }),
    memo: faker.lorem.sentence(),
    image_path: devicePath,                         // on-device path
    created_at: createdAtKstDate.toISOString(),     // ISO string (replaces created_at_iso)
    analyze: false,                                 // backend flips to true or sets status
    meal_time: meal,                                // "breakfast" | "lunch" | "dinner"
    calories: null,
    weight_g: null,
    nutrition_info: null,
    food_category: faker.helpers.arrayElement(["한식", "양식", "일식", "중식"]),
    food_name: faker.commerce.productName(),
  };
  await db.collection("Photos").doc(recordId).set(doc);
}

async function callBackend(filePath, recordId, userId, contentType = "image/jpeg") {
  const url = `${BACKEND_URL}/request_analysis`;
  const form = new FormData();
  form.append("record_id", recordId);
  form.append("user_id", userId);
  form.append("file", fs.createReadStream(filePath), {
    filename: path.basename(filePath),
    contentType,
  });

  try {
    const res = await axios.post(url, form, {
      headers: form.getHeaders(),
      maxBodyLength: Infinity,
      maxContentLength: Infinity,
      timeout: 120000,
      validateStatus: () => true,
    });
    if (res.status !== 200) {
      console.warn(`⚠️ Backend returned ${res.status}: ${
        typeof res.data === "string" ? res.data : JSON.stringify(res.data)
      }`);
    } else {
      console.log("✅ Backend accepted:", res.data?.predicted_food_name || "(no name)");
    }
  } catch (e) {
    console.warn("⚠️ Backend call failed:", e.message);
  }
}

async function waitForAnalysis(recordId, {
  timeoutMs = ANALYSIS_TIMEOUT_MS,
  pollMs = ANALYSIS_INITIAL_POLL_MS,
  maxPollMs = ANALYSIS_MAX_POLL_MS
} = {}) {
  const docRef = db.collection("Photos").doc(recordId);
  const deadline = Date.now() + timeoutMs;

  while (Date.now() < deadline) {
    const snap = await docRef.get();
    if (snap.exists) {
      const d = snap.data() || {};
      // consider it "done" if analyze=true OR a known status/fields exist
      if (d.analyze === true || d.analysis_status === "done" ||
          d.predicted_food_name || d.nutrition_info || d.calories != null) {
        return d;
      }
      if (d.analysis_status === "error") {
        throw new Error(`analysis_status=error for ${recordId}`);
      }
    }
    await sleep(pollMs);
    pollMs = Math.min(Math.floor(pollMs * 1.5), maxPollMs);
  }
  throw new Error(`Timed out waiting for analysis on ${recordId}`);
}

/* ---------- Main ---------- */
async function main() {
  if (!adbOk()) {
    console.error("❌ No ADB device/emulator found. Start your emulator (or connect device) and enable USB debugging.");
    process.exit(1);
  }

  await fs.promises.mkdir(LOCAL_CACHE, { recursive: true });
  ensureTargetDir(TARGET_PATH);

  const plan = planMonthKST(); // [{ date (KST-view), meal }, ...]
  const pools = await collectMealPools(plan);
  const mealIdx = { breakfast: 0, lunch: 0, dinner: 0 };

  console.log(`🗓️ Will generate ${plan.length} images across ${DAYS} days (2–3/day).`);
  console.log(`📤 Pushing to: ${TARGET_PATH}\n`);

  for (const { date: kstDay, meal } of plan) {
    const [sh, sm, eh, em] = MEAL_TIME_RANGES[meal] || [12, 0, 13, 0];
    const { hh, mm, ss } = randomTimeInRange([sh, sm, eh, em]);

    const y = kstDay.getUTCFullYear();
    const m = kstDay.getUTCMonth() + 1;
    const d = kstDay.getUTCDate();

    const createdAtKst = dateInKST(y, m, d, hh, mm, ss);
    const dayStr = yyyymmdd(kstDay);
    const filename = `meal_${dayStr}_${meal}.jpg`;

    const pool = pools[meal];
    if (!pool || !pool.length) {
      console.error(`❌ No images for ${meal}; aborting.`);
      break;
    }
    const url = pool[mealIdx[meal] % pool.length];
    mealIdx[meal]++;

    const localPath = path.join(LOCAL_CACHE, filename);
    const devicePath = `${TARGET_PATH}${filename}`;

    try {
      let contentType;
      if (fs.existsSync(localPath)) {
        contentType = guessContentTypeFromExt(localPath);
      } else {
        contentType = await download(url, localPath);
      }

      // push to device
      adbPush(localPath, devicePath);

      // chmod best-effort
      adbShell(["chmod", "644", devicePath], { ignoreError: true });

      // set modified time on device via toybox: YYYYMMDDhhmm.SS
      const ts = `${dayStr}${String(hh).padStart(2, "0")}${String(mm).padStart(2, "0")}.${String(ss).padStart(2, "0")}`;
      adbShell(["toybox", "touch", "-t", ts, devicePath], { ignoreError: true });

      // Firestore seed (created_at is ISO string)
      const recordId = makeRecordId();
      await seedPhotosDoc({
        recordId,
        userId: USER_ID,
        devicePath,
        meal,
        createdAtKstDate: createdAtKst,
      });

      console.log(
        `📄 Seeded Photos/${recordId} | ${filename} (${meal} @ ${String(hh).padStart(2,"0")}:${String(mm).padStart(2,"0")}:${String(ss).padStart(2,"0")} KST)`
      );

      // Kick off backend and WAIT until it's done
      if (CALL_BACKEND) {
        await callBackend(localPath, recordId, USER_ID, contentType || "image/jpeg");
        try {
          const analyzed = await waitForAnalysis(recordId);
          console.log(`✅ Analysis complete for ${recordId}: ${
            analyzed?.predicted_food_name || analyzed?.food_name || "(no name)"
          }`);
        } catch (e) {
          console.warn(`⚠️ Analysis wait failed for ${recordId}: ${e.message}`);
        }
      }
    } catch (e) {
      console.warn(`⚠️ Failed ${filename}: ${e.message}`);
    }
  }

  console.log("\n🎉 Done!");
  try {
    await admin.app().delete();
  } catch {}
}

main().catch(async (e) => {
  console.error("❌ Error:", e);
  try { await admin.app().delete(); } catch {}
  process.exit(1);
});
