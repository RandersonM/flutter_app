# Nami Finances RAG (Phase 2)

## 1. Overview
The goal of this phase is to introduce an on-device Retrieval-Augmented Generation (RAG) system exclusively for the **Nami Finances** module. This allows the user to query their own local financial data semantically using `flutter_gemma` (Qdrant Edge vector store) without sending personal financial data to the cloud.

## 2. Scope
### In-Scope
- Initialize the `flutter_gemma` vector store with an on-device embedding model (e.g., EmbeddingGemma).
- Implement a data pipeline to convert monthly `NamiFinancesModel` Hive objects into text documents and sync them to the vector store.
- Create a dedicated chat/query UI inside the Nami Finances section.
- Use local Gemma LLM to answer questions based on the retrieved RAG context.

### Out-of-Scope
- Vegapunk Chat integration: Vegapunk Chat will **not** use RAG in this phase. It will continue to use only Function Tools.
- Cloud synchronization of the vector store (all embeddings stay on-device).

## 3. Requirements
- **Data Privacy**: All embeddings and vector searches must happen on-device.
- **Accuracy**: The LLM must base its answers strictly on the retrieved financial documents (grounding).
- **Metadata Filtering**: The vector store documents must include metadata (e.g., year, month) to allow precise filtering if the user asks about a specific period.
- **Separation of Concerns**: The RAG logic for Nami Finances must be decoupled from the global Vegapunk Chat to ensure modularity.
