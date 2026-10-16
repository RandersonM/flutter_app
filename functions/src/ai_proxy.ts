// ============================================================================
// AI PROXY: the app never holds the Gemini, Tavily or Imgur keys. Each call
// needs a signed-in user, counts against a per-user daily quota, and can be
// required to carry an App Check token (REQUIRE_APP_CHECK).
// ============================================================================
import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {defineBoolean, defineSecret} from "firebase-functions/params";
import * as admin from "firebase-admin";

const geminiApiKey = defineSecret("GEMINI_API_KEY");
const tavilyApiKey = defineSecret("TAVILY_API_KEY");
const imgurClientId = defineSecret("IMGUR_CLIENT_ID");

// Off until App Check is registered in the console for both apps; flipping it
// on before that would reject every call.
const requireAppCheck = defineBoolean("REQUIRE_APP_CHECK", {default: false});

const GEMINI_BASE_URL = "https://generativelanguage.googleapis.com/v1beta";
const TEXT_MODEL = "gemini-2.5-flash-lite";
const IMAGE_MODEL = "gemini-2.5-flash-image";

type QuotaKind = "text" | "image" | "search";

const DAILY_LIMITS: Record<QuotaKind, number> = {
  text: 50,
  image: 10,
  search: 30,
};

const MAX_PROMPT_CHARS = 12000;
const MAX_SYSTEM_CHARS = 4000;
const MAX_QUERY_CHARS = 400;

function requireCaller(request: CallableRequest): string {
  if (requireAppCheck.value() && !request.app) {
    throw new HttpsError("failed-precondition", "App Check token required");
  }
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required");
  return uid;
}

function requireString(value: unknown, field: string, maxChars: number): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${field} is required`);
  }
  if (value.length > maxChars) {
    throw new HttpsError("invalid-argument", `${field} is too long`);
  }
  return value;
}

function optionalNumber(
  value: unknown,
  min: number,
  max: number,
): number | undefined {
  if (typeof value !== "number" || Number.isNaN(value)) return undefined;
  return Math.min(Math.max(value, min), max);
}

/** Usage lives in `ai_usage/{uid}`; clients have no rule for it. */
async function consumeQuota(uid: string, kind: QuotaKind): Promise<void> {
  const ref = admin.firestore().collection("ai_usage").doc(uid);
  const today = new Date().toISOString().slice(0, 10);
  await admin.firestore().runTransaction(async (tx) => {
    const data = (await tx.get(ref)).data();
    const counts: Record<string, number> =
      data?.day === today ? {...(data.counts ?? {})} : {};
    const used = counts[kind] ?? 0;
    if (used >= DAILY_LIMITS[kind]) {
      throw new HttpsError("resource-exhausted", `Daily ${kind} limit reached`);
    }
    counts[kind] = used + 1;
    tx.set(ref, {day: today, counts});
  });
}

async function postJson(
  url: string,
  body: unknown,
  headers: Record<string, string>,
): Promise<Record<string, unknown>> {
  const response = await fetch(url, {
    method: "POST",
    headers: {"Content-Type": "application/json", ...headers},
    body: JSON.stringify(body),
  });
  if (response.status === 429) {
    throw new HttpsError("resource-exhausted", "Upstream quota exceeded");
  }
  if (!response.ok) {
    console.error(`AI proxy: upstream ${url.split("?")[0]} -> ${response.status}`);
    throw new HttpsError("unavailable", "Upstream request failed");
  }
  return (await response.json()) as Record<string, unknown>;
}

interface GeminiPart {
  text?: string;
  inlineData?: {mimeType?: string; data?: string};
}

function firstParts(result: Record<string, unknown>): GeminiPart[] {
  const candidates = result.candidates as
    | Array<{content?: {parts?: GeminiPart[]}}>
    | undefined;
  return candidates?.[0]?.content?.parts ?? [];
}

export const geminiGenerateText = onCall(
  {secrets: [geminiApiKey]},
  async (request) => {
    const uid = requireCaller(request);
    const data = (request.data ?? {}) as Record<string, unknown>;
    const prompt = requireString(data.prompt, "prompt", MAX_PROMPT_CHARS);
    const systemInstruction =
      typeof data.systemInstruction === "string" &&
      data.systemInstruction.trim().length > 0 ?
        requireString(
          data.systemInstruction,
          "systemInstruction",
          MAX_SYSTEM_CHARS,
        ) :
        undefined;
    await consumeQuota(uid, "text");

    const result = await postJson(
      `${GEMINI_BASE_URL}/models/${TEXT_MODEL}:generateContent`,
      {
        contents: [{role: "user", parts: [{text: prompt}]}],
        ...(systemInstruction ?
          {systemInstruction: {parts: [{text: systemInstruction}]}} :
          {}),
        generationConfig: {
          temperature: optionalNumber(data.temperature, 0, 2) ?? 0.4,
          topK: optionalNumber(data.topK, 1, 100) ?? 40,
          topP: optionalNumber(data.topP, 0, 1) ?? 0.95,
          maxOutputTokens: optionalNumber(data.maxOutputTokens, 1, 8192) ?? 8192,
        },
      },
      {"x-goog-api-key": geminiApiKey.value()},
    );

    const text = firstParts(result)
      .map((part) => part.text ?? "")
      .join("");
    return {text: text.length > 0 ? text : null};
  },
);

export const geminiGenerateImage = onCall(
  {secrets: [geminiApiKey, imgurClientId], timeoutSeconds: 180},
  async (request) => {
    const uid = requireCaller(request);
    const data = (request.data ?? {}) as Record<string, unknown>;
    const prompt = requireString(data.prompt, "prompt", MAX_PROMPT_CHARS);
    await consumeQuota(uid, "image");

    const result = await postJson(
      `${GEMINI_BASE_URL}/models/${IMAGE_MODEL}:generateContent`,
      {
        contents: [{parts: [{text: prompt}]}],
        generationConfig: {responseModalities: ["IMAGE"]},
      },
      {"x-goog-api-key": geminiApiKey.value()},
    );

    const image = firstParts(result).find(
      (part) => part.inlineData?.data && part.inlineData.mimeType === "image/png",
    );
    if (!image?.inlineData?.data) return {url: null};

    const form = new FormData();
    form.append("image", image.inlineData.data);
    form.append("type", "base64");
    const upload = await fetch("https://api.imgur.com/3/image", {
      method: "POST",
      headers: {Authorization: `Client-ID ${imgurClientId.value()}`},
      body: form,
    });
    if (!upload.ok) {
      console.error(`AI proxy: Imgur upload -> ${upload.status}`);
      throw new HttpsError("unavailable", "Image upload failed");
    }
    const uploaded = (await upload.json()) as {data?: {link?: string}};
    return {url: uploaded.data?.link ?? null};
  },
);

const SEARCH_TOPICS = ["general", "news", "finance"];
const SEARCH_DEPTHS = ["basic", "advanced"];

export const webSearch = onCall(
  {secrets: [tavilyApiKey]},
  async (request) => {
    const uid = requireCaller(request);
    const data = (request.data ?? {}) as Record<string, unknown>;
    const query = requireString(data.query, "query", MAX_QUERY_CHARS);
    const topic = SEARCH_TOPICS.includes(data.topic as string) ?
      (data.topic as string) :
      "general";
    const depth = SEARCH_DEPTHS.includes(data.searchDepth as string) ?
      (data.searchDepth as string) :
      "advanced";
    const includeAnswer = SEARCH_DEPTHS.includes(data.includeAnswer as string) ?
      (data.includeAnswer as string) :
      "advanced";
    await consumeQuota(uid, "search");

    const result = await postJson(
      "https://api.tavily.com/search",
      {
        query,
        search_depth: depth,
        max_results: optionalNumber(data.maxResults, 1, 10) ?? 5,
        topic,
        include_answer: includeAnswer,
        include_raw_content: false,
      },
      {Authorization: `Bearer ${tavilyApiKey.value()}`},
    );

    const results = (result.results as Array<Record<string, unknown>>) ?? [];
    return {
      answer: typeof result.answer === "string" ? result.answer : null,
      results: results.map((item) => ({
        title: item.title ?? "",
        url: item.url ?? "",
        content: item.content ?? "",
        score: typeof item.score === "number" ? item.score : 0,
      })),
    };
  },
);
