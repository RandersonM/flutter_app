# Implementation Tasks: Nami Finances RAG (Phase 2)

- [ ] **T1 - Dependency Setup**: Ensure `flutter_gemma` version is configured correctly in `pubspec.yaml` to support embedding models.
- [ ] **T2 - NamiRagService Creation**: Create `NamiRagService` in `lib/features/nami_finances/data/services/` that handles initializing the vector store, downloading the embedding model (if not cached), and adding documents.
- [ ] **T3 - DI Registration**: Register `NamiRagService` as a Singleton in GetIt (`lib/app/di/features_module.dart`).
- [ ] **T4 - Data Synchronization**: Modify `NamiFinancesBloc` so that whenever `SaveFinances` or `UpdateFinances` is called, it triggers `NamiRagService.syncMonth(NamiFinancesModel)` to convert the data to text and save it to the vector store.
- [ ] **T5 - Nami Chat State**: Create `NamiChatBloc` to handle chat state (loading, streaming tokens, error) strictly for Nami Finances.
- [ ] **T6 - Nami Chat UI**: Implement a simple chat interface (e.g. `NamiFinancesChatSheet` or `NamiFinancesChatScreen`) accessible from the main Nami Finances dashboard.
- [ ] **T7 - RAG Retrieval Logic**: In `NamiChatBloc`, intercept the user query, call `NamiRagService.searchSimilar(query)`, and inject the resulting document strings into the `GemmaService` prompt.
- [ ] **T8 - Testing & Validation**: Test the chat flow locally to verify that the LLM references the local finances accurately without affecting Vegapunk Chat.
