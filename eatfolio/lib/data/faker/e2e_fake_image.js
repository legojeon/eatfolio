// e2e_fake_image.js
// Run: node eatfolio/lib/data/faker/e2e_fake_image.js

import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";
import dotenv from "dotenv";
import admin from "firebase-admin";
import axios from "axios";
import FormData from "form-data";
import { faker } from "@faker-js/faker/locale/ko";

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

/* Config */
const BACKEND_URL = "https://eat.coco.io.kr"; // no trailing slash
const USER_ID = "LPK07O0YrBhpvU1lZ0MUWBxq5g62";
const OUT_DIR = path.join(__dirname, "new_fake_images");
const PEXELS_API_KEY =
  process.env.PEXELS_API_KEY || process.env.PIXELS_API_KEY || "";
if (!PEXELS_API_KEY) {
  console.error("❌ Missing Pexels API key. Set PEXELS_API_KEY (or PIXELS_API_KEY) in .env");
  process.exit(1);
}

/* Firebase Admin init */
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

/* Helpers */
function nowMealTime() {
  const h = new Date().getHours();
  if (h >= 6 && h < 11) return "breakfast";
  if (h >= 11 && h < 16) return "lunch";
  if (h >= 16 && h < 21) return "dinner";
  return "midnight snack";
}
function makeRecordId() {
  return `${Date.now()}_${faker.string.alphanumeric(6)}`;
}

/** Fetch a real food photo from Pexels and save to disk. */
async function fetchAndSavePexelsFoodImage(outDir, query = "rice dish") {
  await fs.promises.mkdir(outDir, { recursive: true });

  // 1) search Pexels
  const page = faker.number.int({ min: 1, max: 50 });
  const per_page = 30;
  const searchUrl = "https://api.pexels.com/v1/search";
  const search = await axios.get(searchUrl, {
    headers: { Authorization: PEXELS_API_KEY },
    params: { query, per_page, page },
    timeout: 20000,
  });

  const photos = Array.isArray(search.data?.photos) ? search.data.photos : [];
  if (!photos.length) throw new Error("No photos found from Pexels.");

  // Pick a random photo and a reasonable size
  const pick = photos[faker.number.int({ min: 0, max: photos.length - 1 })];
  const src = pick?.src?.medium || pick?.src?.original || pick?.src?.large || pick?.src?.small;
  if (!src) throw new Error("Selected Pexels photo has no usable src.");

  // 2) download
  const imgRes = await axios.get(src, { responseType: "arraybuffer", timeout: 30000 });
  const contentType =
    imgRes.headers["content-type"] ||
    (src.endsWith(".png") ? "image/png" : "image/jpeg");

  // 3) save
  const ext = contentType.includes("png") ? ".png" : contentType.includes("webp") ? ".webp" : ".jpg";
  const filePath = path.join(outDir, `food_${Date.now()}${ext}`);
  await fs.promises.writeFile(filePath, Buffer.from(imgRes.data));

  return { filePath, contentType };
}

async function seedPhotosDoc(recordId, userId, localImagePath) {
  const mealTime = nowMealTime();
  const doc = {
    record_id: recordId,
    user_id: userId,
    rating: faker.number.int({ min: 1, max: 5 }),
    memo: faker.lorem.sentence(),
    image_path: localImagePath, // UI preview only
    created_at: new Date().toISOString(),
    analyze: false, // backend will flip to true (or set stub)
    meal_time: mealTime,
    calories: null,
    weight_g: null,
    nutrition_info: null,
    food_category: faker.helpers.arrayElement(["한식", "양식", "일식", "중식"]),
    food_name: faker.commerce.productName(),
  };
  await db.collection("Photos").doc(recordId).set(doc);
}

/** POST to backend and return response (logs non-200, no throw). */
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
      maxContentLength: Infinity,
      maxBodyLength: Infinity,
      timeout: 120000,
      validateStatus: () => true, // don't throw on non-2xx
    });

    if (res.status !== 200) {
      console.warn(`⚠️ Backend returned ${res.status}: ${
        typeof res.data === "string" ? res.data : JSON.stringify(res.data)
      }`);
    } else {
      console.log("✅ Backend responded:", res.data?.predicted_food_name || "(no name)");
    }
  } catch (e) {
    console.warn("⚠️ Backend call failed:", e.message);
  }
}

/* Main — no waiting */
async function main() {
  console.log("🔎 Fetching a real food photo from Pexels…");
  const { filePath, contentType } = await fetchAndSavePexelsFoodImage(OUT_DIR, "asian food");
  const recordId = makeRecordId();

  console.log("🖼️  Image:", filePath);
  console.log("🆔 record_id:", recordId);
  console.log("👤 user_id:", USER_ID);

  console.log("🗃️  Seeding Firestore doc (analyze:false)...");
  await seedPhotosDoc(recordId, USER_ID, filePath);

  console.log("📤 Calling backend /request_analysis…");
  await callBackend(filePath, recordId, USER_ID, contentType);

  console.log("🏁 Done. (No Firestore polling.)");
}

main()
  .catch(async (e) => {
    console.error("❌ Error:", e.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    try { await admin.app().delete(); } catch {}
  });
