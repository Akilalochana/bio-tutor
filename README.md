# bio-tutor 🧬🇱🇰
### 100% Offline, On-Device Edge-AI Biology Tutor for Sri Lankan G.C.E. Advanced Level Students

[![Framework](https://img.shields.io/badge/Framework-Flutter-02569B?style=flat-square&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Model](https://img.shields.io/badge/Model-Gemma--4--E2B--it--litert--lm-orange?style=flat-square)](https://ai.google.dev/gemma)
[![Target](https://img.shields.io/badge/Target-G.C.E.%20A/L%20Biology-green?style=flat-square)]()
[![Internet](https://img.shields.io/badge/Internet-100%25%20Offline%20/%20No%20Data%20Required-red?style=flat-square)]()

---

## 📌 Overview

**bio-tutor** is a decentralized, offline educational mobile application built specifically for Sri Lankan Advanced Level (A/L) Biology students. Powered entirely on-device by Google's **Gemma 4 (E2B-it-litert-lm)** model, the app serves as an interactive, highly personalized AI tutor that operates completely without internet connectivity.

When a student attempts a practice MCQ and selects an incorrect option, **bio-tutor** dynamically targets the specific learning weak-point. It extracts the relevant curriculum context from a locally embedded, highly structured knowledge base generated from the official National Institute of Education (NIE) Resource Books. Gemma 4 then processes this context on-device to deliver accurate, step-by-step reasoning in native **Sinhala**, neutralizing the risk of LLM hallucinations.

---

## 🚨 The Problem & Social Impact

According to official statistics from the **2025 G.C.E. Advanced Level Examination**:

- **The Stream Disparity:** The Biological Science stream records one of the lowest university qualification rates at just **59.56%** among school candidates — meaning over 40% of students fail to qualify.
- **The Regional Divide:** Resource distribution is heavily unequal. While the urbanized Western Province achieves a **69.42%** university eligibility rate, rural areas fall drastically behind:
  - 🟡 Uva Province: **63.53%**
  - 🟡 Central Province: **63.04%**
  - 🔴 North Central Province: **60.91%**
- **The Access Barrier:** Elite educational materials and tutoring are locked behind expensive private tuition. Existing cloud-based generative AI applications are unusable for rural students due to **spotty connectivity** and prohibitive data costs.

> **bio-tutor bridges this digital divide by delivering frontier AI capabilities directly to mid-range mobile hardware — requiring zero internet data.**

---

## ✨ Key Features

| Feature | Description |
|---|---|
| 📚 **Syllabus-Aligned Quiz UI** | Unit-by-unit MCQ practice covering the complete A/L Biology matrix (e.g., *Introduction to Biology*, *Chemical Basis of Life*) |
| 🔍 **Local RAG** | Pre-processed syllabus chunks stored on-device provide deterministic grounding for LLM inference — no vector database required |
| 🇱🇰 **Sinhala Explanations** | Prompt-engineered pipeline delivers natural, accurate biological reasoning in Sinhala |
| 🎮 **Gamified Performance Tracking** | Daily streaks, MCQ counts, and accuracy percentages to keep students motivated |
| ✈️ **Air-Gapped Privacy** | Fully functional in Airplane Mode — zero API costs, zero data leakage, zero latency |

---

## 🛠️ Technical Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Frontend                     │
│         (Interactive Mobile Quiz & Diagnostics)         │
└────────────────────────────┬────────────────────────────┘
                             │
                  [On Detection of Incorrect Answer]
                             ▼
┌─────────────────────────────────────────────────────────┐
│                 Local Knowledge Base                    │
│     (Pre-processed Syllabus Data & Cached Chunks)       │
└────────────────────────────┬────────────────────────────┘
                             │
                  [Extracts Grounding Context Layer]
                             ▼
┌─────────────────────────────────────────────────────────┐
│               On-Device Inference Engine                │
│             (LiteRT / TensorFlow TFLite)                │
└────────────────────────────┬────────────────────────────┘
                             │
                  [Passes Context + Base Prompt]
                             ▼
┌─────────────────────────────────────────────────────────┐
│                 Gemma 4 Edge Execution                  │
│               (gemma-4-E2B-it-litert-lm)                │
└────────────────────────────┬────────────────────────────┘
                             │
                  [Compiles Sinhala Explanation]
                             ▼
┌─────────────────────────────────────────────────────────┐
│                Dynamic Rich Text Render                 │
│         (UI output with clear learning paths)           │
└─────────────────────────────────────────────────────────┘
```

### Strategic Technical Stack Decisions

1. **Gemma-4-E2B-it-litert-lm** — Chosen for its exceptional compression ratio, low-latency execution profile on mobile processors, and advanced instruction-following capabilities within quantized models.

2. **Decoupled Data Architecture** — The pipeline uses pre-parsed structured content created via our processing notebooks (`final-chunk.ipynb`), ensuring the local storage schema is lightweight and optimized for instantaneous key-value retrieval on-device — without running heavy server-grade vector databases.

---

## 📂 Repository Structure

```
bio-tutor/
├── backend/                     # Admin configuration and centralized service logic
├── mobile/                      # Complete Flutter Mobile Application codebase
├── postman/collections/         # Integrated API testing definitions for bio_tutor
├── al-bio.ipynb                 # Initial data parsing, exploratory research & evaluation
└── final-chunk.ipynb            # Resource book parsing & chunking pipelines
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (Latest Stable Release)
- Android Studio / Xcode
- A physical Android device with **4GB+ RAM** recommended for local model performance

### Installation

**1. Clone the repository:**
```bash
git clone https://github.com/Akilalochana/bio-tutor.git
cd bio-tutor
```

**2. Navigate to the app and install dependencies:**
```bash
cd mobile
flutter pub get
```

**3. Add the local model weights:**

- Acquire the runtime-optimized `gemma-4-E2B-it-litert-lm` model file.
- Place it inside the app workspace at:
  ```
  assets/models/
  ```

**4. Build and run:**
```bash
flutter run --release
```

> ⚠️ Always use `--release` to unlock full hardware acceleration for the LiteRT execution pipeline.

---

## 🏆 Hackathon Submission

This project was compiled for the **[Gemma 4 Good Hackathon](https://www.kaggle.com/)** on Kaggle.

- **Track:** Future of Education / Digital Equity & Inclusivity
- 🎬 **Demo Video:** [Watch on YouTube](https://www.youtube.com/watch?v=gj4VTAFyiss)
- 📦 **Live Demo APK:** [Download Android APK](https://github.com/Akilalochana/bio-tutor/releases/download/v1.0.0/app-release.apk)
- 📝 **Kaggle Writeup:** [Read Technical Writeup](https://www.kaggle.com/competitions/gemma-4-good-hackathon/writeups/new-writeup-1776795486476)

---

## 📄 License

This project is open-source. See the [LICENSE](https://creativecommons.org/licenses/by/4.0/) file for details.

---

