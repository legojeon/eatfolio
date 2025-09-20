// index.js
require("dotenv").config(); // <-- load functions/.env locally & in emulator

const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

// Region
setGlobalOptions({ region: "asia-northeast3" });

// ---- Read from .env only ----
const ANALYSIS_API_URL = process.env.ANALYSIS_API_URL || "";

// Firebase Admin
initializeApp();
const db = getFirestore();

const SODIUM_PER_RAMEN_MG = 1800;
const PROTEIN_PER_EGG_G = 6;

/** Timestamp/ISO safe conversion */
function tsToDate(v) {
  return v?.toDate ? v.toDate() : new Date(v);
}

/** avg_nutrients: ["calories: 721 kcal", "58g protein", ...] -> {calories:"721kcal", protein:"58g", ...} */
function formatAvgNutrients(arr) {
  if (!Array.isArray(arr)) return arr;
  const out = {};
  for (const raw of arr) {
    if (typeof raw !== "string") continue;
    let s = raw.trim();

    if (/kcal/i.test(s)) {
      s = s.replace(/calories?:?/i, "").trim();
      s = s.replace(/\s*kcal/i, "kcal");
      out.calories = s;
      continue;
    }
    if (/protein/i.test(s)) {
      const m = s.match(/(\d+(?:\.\d+)?)\s*g/i);
      out.protein = m ? `${m[1]}g` : s;
      continue;
    }
    if (/fat/i.test(s)) {
      const m = s.match(/(\d+(?:\.\d+)?)\s*g/i);
      out.fat = m ? `${m[1]}g` : s;
      continue;
    }
    if (/carb|carbohydrate/i.test(s)) {
      const m = s.match(/(\d+(?:\.\d+)?)\s*g/i);
      out.carbohydrate = m ? `${m[1]}g` : s;
      continue;
    }
  }
  return out;
}

/** Ensure user_stats doc has the fields we expect (avoid crashes on first updates) */
function ensureStatsShape(stats, userId) {
  stats = stats || {};
  stats.user_id = stats.user_id || userId;

  stats.meal_time_stats = stats.meal_time_stats || {
    breakfast: { count: 0 },
    lunch: { count: 0 },
    dinner: { count: 0 },
  };
  for (const k of ["breakfast", "lunch", "dinner"]) {
    const cur = stats.meal_time_stats[k] || {};
    stats.meal_time_stats[k] = { count: Number(cur.count) || 0 };
  }

  stats.avg_meal_time = stats.avg_meal_time || { breakfast: "N/A", lunch: "N/A", dinner: "N/A" };
  stats.total_calories = Number(stats.total_calories) || 0;
  stats.avg_calories = Number(stats.avg_calories) || 0;
  stats.meal_count = Number(stats.meal_count) || 0;
  stats.total_weight_g = Number(stats.total_weight_g) || 0;

  stats.macros_total_g = stats.macros_total_g || { carbohydrate: 0, protein: 0, fat: 0 };
  stats.macros_total_g.carbohydrate = Number(stats.macros_total_g.carbohydrate) || 0;
  stats.macros_total_g.protein = Number(stats.macros_total_g.protein) || 0;
  stats.macros_total_g.fat = Number(stats.macros_total_g.fat) || 0;

  stats.macro_ratio_string = stats.macro_ratio_string || "0:0:0";
  stats.sodium_total_mg = Number(stats.sodium_total_mg) || 0;
  stats.sodium_ramen_equiv = Number(stats.sodium_ramen_equiv) || 0;
  stats.protein_total_g = Number(stats.protein_total_g) || 0;
  stats.protein_egg_equiv = Number(stats.protein_egg_equiv) || 0;

  return stats;
}

// --- Helpers ---
function normalizeMealKey(mealType) {
  const s = String(mealType || "").trim().toLowerCase();
  if (!s) return null;
  const map = {
    breakfast: "breakfast", morning: "breakfast", brunch: "breakfast", "아침": "breakfast", "조식": "breakfast",
    lunch: "lunch", "점심": "lunch", "중식": "lunch",
    dinner: "dinner", supper: "dinner", "저녁": "dinner", "석식": "dinner",
  };
  if (map[s]) return map[s];
  if (s.startsWith("break")) return "breakfast";
  if (s.startsWith("morn")) return "breakfast";
  if (s.startsWith("lunch")) return "lunch";
  if (s.startsWith("din") || s.startsWith("sup")) return "dinner";
  return null;
}

function minutesInTz(date, timeZone = "Asia/Seoul") {
  try {
    const parts = new Intl.DateTimeFormat("en-GB", {
      timeZone, hour12: false, hour: "2-digit", minute: "2-digit",
    }).formatToParts(date);

    const h = parseInt(parts.find(p => p.type === "hour")?.value || NaN, 10);
    const m = parseInt(parts.find(p => p.type === "minute")?.value || NaN, 10);

    if (Number.isFinite(h) && Number.isFinite(m)) return h * 60 + m;
  } catch (_) {}
  const minsUTC = date.getUTCHours() * 60 + date.getUTCMinutes();
  const minsKST = minsUTC + 9 * 60;
  return ((minsKST % 1440) + 1440) % 1440;
}

function gcd(a, b) { a = Math.abs(a); b = Math.abs(b); while (b) [a, b] = [b, a % b]; return a || 1; }
function gcd3(a, b, c) { return gcd(gcd(a, b), c); }

/** Generate weekly report via FastAPI and save to user_reports/{userId} */
async function generateAndSaveUserReport(userId) {
  const base = (ANALYSIS_API_URL || "").replace(/\/+$/, "");
  console.log("[UserReports] ANALYSIS_API_URL =", base || "(empty)");
  if (!base) {
    console.warn("[UserReports] ANALYSIS_API_URL not set; skipping report generation.");
    return;
  }

  const url = `${base}/nutritional-analysis`;
  console.log("[UserReports] POST", url, "for user", userId);

  try {
    const resp = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=utf-8" },
      body: JSON.stringify({ user_id: userId }),
    });

    console.log("[UserReports] response status =", resp.status);
    console.log("[UserReports] response headers =", Object.fromEntries(resp.headers.entries()));

    // Gracefully handle "no data" weeks
    if (resp.status === 404) {
      console.warn("[UserReports] No weekly data. Writing placeholder.");
      await db.collection("user_reports").doc(userId).set({
        user_id: userId,
        created_at: FieldValue.serverTimestamp(),
        report: {
          avg_nutrients: {},
          pos_analysis: "아직 데이터가 부족해요. 이번 주도 기록을 이어가 볼까요?",
          neg_analysis: "데이터가 부족해 세부 분석이 어려워요.",
          feedback: "하루 한 번만 기록해도 분석 품질이 좋아져요!",
          rec_meal: [],
          score: 0,
        },
      });
      return;
    }

    if (!resp.ok) {
      const txt = await resp.text().catch(() => "");
      console.error("[UserReports] HTTP error response:", resp.status, txt);
      throw new Error(`Analysis API HTTP ${resp.status} ${txt}`);
    }

    const analysisJson = await resp.json();
    console.log("[UserReports] Raw analysis response:", JSON.stringify(analysisJson, null, 2));
    
    // avg_nutrients 처리 개선
    if (analysisJson && analysisJson.avg_nutrients) {
      if (Array.isArray(analysisJson.avg_nutrients)) {
        analysisJson.avg_nutrients = formatAvgNutrients(analysisJson.avg_nutrients);
      } else if (typeof analysisJson.avg_nutrients === 'object') {
        console.log("[UserReports] avg_nutrients already an object:", analysisJson.avg_nutrients);
      } else {
        console.warn("[UserReports] Unexpected avg_nutrients type:", typeof analysisJson.avg_nutrients);
        analysisJson.avg_nutrients = {};
      }
    } else {
      analysisJson.avg_nutrients = {};
    }

    // 필수 필드 확인 및 기본값 설정
    const requiredFields = ['pos_analysis', 'neg_analysis', 'feedback', 'rec_meal', 'score'];
    for (const field of requiredFields) {
      if (!(field in analysisJson)) {
        console.warn(`[UserReports] Missing required field: ${field}, setting default`);
        switch (field) {
          case 'pos_analysis':
            analysisJson[field] = "일부 식사에서 균형 잡힌 선택이 관찰됩니다.";
            break;
          case 'neg_analysis':
            analysisJson[field] = "일부 영양소가 권장 범위를 벗어나 조정이 필요합니다.";
            break;
          case 'feedback':
            analysisJson[field] = "꾸준한 기록을 이어가세요!";
            break;
          case 'rec_meal':
            analysisJson[field] = [];
            break;
          case 'score':
            analysisJson[field] = 0;
            break;
        }
      }
    }

    console.log("[UserReports] Final processed analysis data:", JSON.stringify(analysisJson, null, 2));

    await db.collection("user_reports").doc(userId).set({
      user_id: userId,
      created_at: FieldValue.serverTimestamp(),
      report: analysisJson,
    });

    console.log(`[UserReports] saved/updated report for user ${userId}`);
  } catch (err) {
    console.error("[UserReports] failed to generate/save report:", err);
    console.error("[UserReports] Error stack:", err.stack);
    
    // 에러 발생 시에도 기본 리포트 생성 시도
    try {
      console.log("[UserReports] Attempting to create fallback report due to error");
      await db.collection("user_reports").doc(userId).set({
        user_id: userId,
        created_at: FieldValue.serverTimestamp(),
        report: {
          avg_nutrients: {},
          pos_analysis: "분석 중 오류가 발생했습니다.",
          neg_analysis: "일시적인 문제로 분석을 완료할 수 없습니다.",
          feedback: "잠시 후 다시 시도해주세요.",
          rec_meal: [],
          score: 0,
        },
      });
      console.log("[UserReports] Fallback report created successfully");
    } catch (fallbackErr) {
      console.error("[UserReports] Failed to create fallback report:", fallbackErr);
    }
  }
}

// --- NEW: recompute circular average meal times (KST) from Photos ---
async function recomputeAvgMealTimeKST(userId) {
  const qSnap = await db
    .collection("Photos")
    .where("user_id", "==", userId)
    .where("analyze", "==", true)
    .get();

  const acc = {
    breakfast: { sx: 0, sy: 0, n: 0 },
    lunch:     { sx: 0, sy: 0, n: 0 },
    dinner:    { sx: 0, sy: 0, n: 0 },
  };

  for (const doc of qSnap.docs) {
    const d = doc.data();
    const key = normalizeMealKey(d.meal_time);
    if (!key || !d.created_at) continue;

    const date = tsToDate(d.created_at);
    const mins = minutesInTz(date, "Asia/Seoul");
    if (!Number.isFinite(mins)) continue;

    const theta = (2 * Math.PI * mins) / 1440; // minutes -> angle
    acc[key].sx += Math.cos(theta);
    acc[key].sy += Math.sin(theta);
    acc[key].n  += 1;
  }

  const out = { breakfast: "N/A", lunch: "N/A", dinner: "N/A" };

  for (const k of ["breakfast", "lunch", "dinner"]) {
    const { sx, sy, n } = acc[k];
    if (n > 0) {
      let ang = Math.atan2(sy, sx); // [-π, π]
      if (ang < 0) ang += 2 * Math.PI; // [0, 2π)

      let mins = (ang / (2 * Math.PI)) * 1440;
      let h = Math.floor(mins / 60);
      let m = Math.round(mins % 60);
      if (m === 60) { h = (h + 1) % 24; m = 0; }

      out[k] = `${String(h).padStart(2, "0")}:${String(m).padStart(2, "0")}`;
    }
  }

  await db.collection("user_stats").doc(userId).update({
    avg_meal_time: out,
    updated_at: FieldValue.serverTimestamp(),
  });
}

/**
 * RUNS ONLY WHEN: Photos/{photoId}.analyze changes false/undefined -> true
 */
exports.updateUserStatsOnAnalyzedPhoto = onDocumentUpdated("Photos/{photoId}", async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();
  if (!before || !after) return null;

  const wasAnalyzed = !!before.analyze;
  const isAnalyzed = !!after.analyze;
  if (wasAnalyzed || !isAnalyzed) return null;

  const photoData = after;
  const userId = photoData.user_id;
  if (!userId) return null;

  const userStatsRef = db.collection("user_stats").doc(userId);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(userStatsRef);
    let stats = snap.exists ? snap.data() : {};
    stats = ensureStatsShape(stats, userId);

    const addCalories = Number(photoData.calories) || 0;
    const addWeight = Number(photoData.weight_g) || 0;

    stats.meal_count += 1;
    stats.total_calories += addCalories;
    stats.total_weight_g += addWeight;

    if (photoData.nutrition_info) {
      const ni = photoData.nutrition_info;
      stats.macros_total_g.carbohydrate += Number(ni.carbohydrate) || 0;
      stats.macros_total_g.protein += Number(ni.protein) || 0;
      stats.macros_total_g.fat += Number(ni.fat) || 0;
      stats.sodium_total_mg += Number(ni.sodium) || 0;
    }
    stats.protein_total_g = stats.macros_total_g.protein;

    stats.avg_calories = stats.meal_count > 0 ? Math.round(stats.total_calories / stats.meal_count) : 0;
    stats.sodium_ramen_equiv = Math.round(stats.sodium_total_mg / SODIUM_PER_RAMEN_MG);
    stats.protein_egg_equiv  = Math.round(stats.protein_total_g / PROTEIN_PER_EGG_G);

    // macro ratio via GCD (safe)
    {
      const { carbohydrate: cRaw, protein: pRaw, fat: fRaw } = stats.macros_total_g;
      const intCarb    = Math.round(Math.max(0, Number(cRaw) || 0));
      const intProtein = Math.round(Math.max(0, Number(pRaw) || 0));
      const intFat     = Math.round(Math.max(0, Number(fRaw) || 0));
      if (intCarb + intProtein + intFat > 0) {
        const g = gcd3(intCarb, intProtein, intFat) || 1;
        stats.macro_ratio_string = `${Math.floor(intCarb/g)}:${Math.floor(intProtein/g)}:${Math.floor(intFat/g)}`;
      } else {
        stats.macro_ratio_string = "0:0:0";
      }
    }

    // keep existing counters for meal_time_stats as-is (no schema change)
    const key = normalizeMealKey(photoData.meal_time);
    if (key) {
      stats.meal_time_stats[key] = stats.meal_time_stats[key] || { count: 0 };
      stats.meal_time_stats[key].count += 1;
    }

    stats.updated_at = FieldValue.serverTimestamp();
    tx.set(userStatsRef, stats);
  });

  // NEW: compute circular averages and write ONLY avg_meal_time values
  await recomputeAvgMealTimeKST(userId);

  console.log(`[UserStats] updated (circular avg meal time) for user ${userId} (photo ${event.params.photoId})`);

  await generateAndSaveUserReport(userId);
  return null;
});
