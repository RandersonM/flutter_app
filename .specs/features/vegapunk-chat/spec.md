# Ask Vegapunk — Feature Specification

**Feature ID:** VEGAPUNK  
**Status:** Specification  
**Created:** 2026-06-24  
**Author:** Randerson M A dos Santos

---

## Overview

Integrate **flutter_gemma** (on-device LLM inference) into OpFan to power a conversational chat interface themed as **Dr. Vegapunk** — the greatest scientist in the One Piece world. The model runs entirely on-device: no data leaves the device after the initial model download.

This is the **Phase 1** of on-device AI integration. The `GemmaService` infrastructure will be reused by other features in later phases.

---

## Goals

- Ship an on-device chat experience (no cloud API, no rate limiting, fully private)
- Establish the `GemmaService` abstraction that other features can consume
- Replace the Planner tab in the BottomAppBar with the new Ask Vegapunk tab
- Move Planner to the `UserDrawerContent` (hamburger menu on HomeAppBar)

---

## Non-Goals (Phase 1)

- Conversation persistence to Firestore (in-memory session only)
- Multi-modal input (images, audio) — text only
- RAG / embeddings integration
- LoRA fine-tuning on One Piece data
- Multiple model options in UI
- Offline model fallback per-device capability detection

---

## Requirements

### Model & Engine

| ID | Requirement |
|----|-------------|
| VGP-01 | The app SHALL use `flutter_gemma ^1.1.1` as the on-device inference runtime |
| VGP-02 | The app SHALL use the `flutter_gemma_mediapipe` backend for `.task` model files |
| VGP-03 | The default model SHALL be **Qwen3 0.6B** (`.task` format, ~586 MB) from HuggingFace |
| VGP-04 | A lighter fallback model SHALL be documented: **SmolLM 135MB** (mobile-only) |
| VGP-05 | The model SHALL be downloaded once and cached in the app's documents directory |
| VGP-06 | Model download requires the existing `HUGGING_FACE_API_KEY` env var |
| VGP-07 | Two new env vars SHALL be added: `GEMMA_MODEL_URL` and `GEMMA_MODEL_NAME` |

### Model Download UX

| ID | Requirement |
|----|-------------|
| VGP-08 | On first access to the chat screen, the app SHALL show a download prompt explaining model size (~586 MB) and one-time nature |
| VGP-09 | The download SHALL show a progress indicator (%) |
| VGP-10 | The user SHALL be able to cancel the download |
| VGP-11 | If download fails, the user SHALL see a retry option |
| VGP-12 | After successful download, the model SHALL load automatically without user action |

### Chat Feature

| ID | Requirement |
|----|-------------|
| VGP-13 | The chat interface SHALL stream tokens in real-time as the model generates them |
| VGP-14 | The model SHALL respond using the **Vegapunk persona** (system prompt) |
| VGP-15 | The system prompt SHALL be set once per session and NOT visible to the user |
| VGP-16 | The chat session SHALL be in-memory only (cleared on screen dispose) |
| VGP-17 | The user SHALL be able to send text messages |
| VGP-18 | While the model is generating, input SHALL be disabled and a stop/cancel affordance SHALL be shown |
| VGP-19 | The chat SHALL support both English and Portuguese (model responds in the language the user writes in) |
| VGP-20 | Messages SHALL be displayed in a scrollable list, newest at bottom |
| VGP-21 | The chat SHALL auto-scroll to the latest message |

### Navigation Changes

| ID | Requirement |
|----|-------------|
| VGP-22 | The 5th slot in `BottomNavigation` SHALL change from `knowledge` (Planner) to `vegapunkChat` |
| VGP-23 | The Planner (Robin Knowledge) SHALL be added to `UserDrawerContent` as a new menu item |
| VGP-24 | The new bottom nav item SHALL use icon `PhosphorIconsRegular.robot` and label "Vegapunk" |
| VGP-25 | The Ask Vegapunk screen SHALL navigate as a named route `/vegapunk-chat` |
| VGP-26 | The route SHALL be public (no auth guard required — model is local) |

### Platform Constraints

| ID | Requirement |
|----|-------------|
| VGP-27 | iOS minimum version SHALL be 16.0 |
| VGP-28 | iOS `Info.plist` SHALL have `UIFileSharingEnabled = true` |
| VGP-29 | iOS `Runner.entitlements` SHALL have increased memory entitlements |
| VGP-30 | iOS `Podfile` SHALL use static linking: `use_frameworks! :linkage => :static` |
| VGP-31 | Android architecture support: arm64-v8a (full), x86_64 (text only) |

---

## Environment Variables

### Already Exists

| Variable | Purpose |
|----------|---------|
| `HUGGING_FACE_API_KEY` | HuggingFace authentication token for gated model download |
| `HUGGING_FACE_BASE_URL` | HuggingFace base URL (reference only; direct URL used for download) |

### New Variables Required

| Variable | Example Value | Purpose |
|----------|--------------|---------|
| `GEMMA_MODEL_URL` | `https://huggingface.co/Qwen/Qwen3-0.6B-mobile/resolve/main/Qwen3-0.6B-mobile.task` | Direct download URL for model file |
| `GEMMA_MODEL_NAME` | `qwen3_0.6b.task` | Local filename stored in app documents |

---

## Vegapunk Persona — System Prompt

```
You are Dr. Vegapunk, the greatest scientific mind in history. 
You speak with brilliant enthusiasm, mix deep scientific insight with 
One Piece lore, and occasionally reference your six satellites (Shaka, Lilith, Edison, Pythagoras, Atlas, York).
You address the user as a fellow researcher or apprentice.
Keep answers concise but intellectually rich.
You respond in the same language the user writes in.
```

---

## Acceptance Criteria

- [ ] Model downloads once with visible progress on first chat access
- [ ] Chat streams tokens in real-time with Vegapunk persona
- [ ] Bottom nav shows Vegapunk tab (robot icon) instead of Planner
- [ ] Planner accessible from UserDrawerContent hamburger menu
- [ ] Works on iOS 16+ and Android arm64-v8a
- [ ] No network call during chat (only during model download)
- [ ] `GemmaService` can be imported by other features without re-initializing

---

## Out of Scope — Future Phases

- Phase 2: Apply Vegapunk chat as a contextual assistant inside existing features (e.g. explain Devil Fruit, analyze crew stats)
- Phase 3: RAG with One Piece data embedded via `flutter_gemma_embeddings` + `flutter_gemma_rag_qdrant`
- Phase 4: Per-feature LLM personas (Sanji for cooking tips, Robin for knowledge, Zoro for workout advice)
