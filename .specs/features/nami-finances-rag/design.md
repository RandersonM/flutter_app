# System Design: Nami Finances RAG (Phase 2)

## 1. Architecture Components

### 1.1 Vector Store & Embeddings (`NamiRagService`)
- Create a dedicated `NamiRagService` (implementing `IRAGService` or a specialized interface).
- **Initialization**: Will call `FlutterGemma.installEmbedder()` and `FlutterGemmaPlugin.instance.initializeVectorStore('nami_finances_store')`.
- **Sync Logic**: 
  - Every time `NamiFinancesBloc` saves or updates a month's data to Hive, it will trigger an event to `NamiRagService`.
  - The service converts `NamiFinancesModel` into a text chunk (e.g., "In January 2026, total income was...").
  - The service calculates embeddings and adds it using `addDocument`.
  - **Metadata**: `{"module": "nami_finances", "year": "YYYY", "month": "MM"}`.

### 1.2 Chat UI (`NamiFinancesChatScreen` or BottomSheet)
- A new interactive chat interface accessible via a Floating Action Button (FAB) or AppBar icon on the `NamiFinancesScreen`.
- It will have a simple message list and an input field.
- **State Management**: `NamiChatBloc` (separate from VegapunkChatBloc) to manage local chat state and streaming tokens.

### 1.3 LLM Orchestration
- When the user asks a question in Nami Chat:
  1. `NamiRagService` runs `searchSimilar` on the vector store.
  2. The retrieved text documents (the semantic context) are injected into the system prompt.
  3. `GemmaService` is called with the context injected into `styleInstruction` or a dedicated `ragContext` parameter.

## 2. Separation from Vegapunk Chat
- Vegapunk Chat (`VegapunkChatBloc` and `VegapunkChatRepository`) will **not** be injected with `NamiRagService` in this phase.
- Vegapunk Chat will continue to rely solely on Function Tools (e.g., `SearchInternetHandler`, `SearchCharactersHandler`).

## 3. Data Models
- **RAG Document**:
  - `id`: `${NamiFinancesModel.id}`
  - `content`: Generated textual representation of the finances.
  - `metadata`: JSON string containing year and month for fast filtering.
