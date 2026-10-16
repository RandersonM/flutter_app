# Spec: Vegapunk RAG — Redução de Alucinações + Respostas Concisas

**Feature ID:** VGP-RAG  
**Status:** Draft  
**Branch:** feat/create-cooking-tips-screen  
**Predecessor:** `.specs/features/vegapunk-chat/spec.md` (Phase 1 — já implementado)

---

## Contexto

O Vegapunk Chat (Phase 1) já está em produção com `GemmaService` + Qwen3 0.6B on-device. Dois problemas persistem:

1. **Respostas excessivamente longas** — O `_promptEn/Pt` diz "no longer than a few paragraphs" mas o modelo ignora isso. Uma pergunta simples como "você conhece o Sanji?" vira 10 parágrafos.
2. **Alucinações** — Sem base de conhecimento fundamentada, o modelo inventa detalhes sobre personagens, frutas do diabo e eventos do manga/anime de One Piece.

Este spec cobre o que o spec original listou como **"Out of Scope — Future Phases"**:
> Phase 3: RAG com dados de One Piece via `flutter_gemma_embeddings` + `flutter_gemma_rag_qdrant`

---

## Diagnóstico da Verbosidade

| Causa | Detalhe |
|-------|---------|
| System prompt vago | "no longer than a few paragraphs" é ignorado pelo Qwen3 0.6B |
| maxTokens alto | Normal: 1024 tokens. Para respostas concisas, 300–400 são suficientes |
| Sem instrução de formato | O modelo decide o formato livremente → escreve ensaios |
| Style instructions dos satélites | Podem sobrescrever a instrução de brevidade |

---

## Requisitos

### Fase 0 — Quick Fix: Brevidade (GemmaService)

| ID | Requisito |
|----|-----------|
| VGP-RAG-01 | O `_promptEn` e `_promptPt` SHALL ter instrução de brevidade explícita e quantificada: máximo 80 palavras para perguntas simples, sem preamble, sem repetição da pergunta |
| VGP-RAG-02 | maxTokens em modo normal SHALL ser reduzido de 1024 para 400 |
| VGP-RAG-03 | A system instruction SHALL instruir o modelo a responder com 1–3 frases para perguntas sim/não ou de identificação de personagem |
| VGP-RAG-04 | A instrução de brevidade SHALL ser reforçada ao início de cada `sendMessage` via prefixo no prompt (fallback adicional) |

### Fase 1 — Pacotes RAG

| ID | Requisito |
|----|-----------|
| VGP-RAG-05 | O sistema SHALL adicionar `flutter_gemma_embeddings` ao `pubspec.yaml` (geração de embeddings on-device) |
| VGP-RAG-06 | O sistema SHALL adicionar `flutter_gemma_rag_sqlite` ao `pubspec.yaml` (vector store cross-platform, incluindo iOS) |
| VGP-RAG-07 | O `FlutterGemma.initialize()` em `main.dart` SHALL ser atualizado para incluir o backend de embeddings e o vector store sqlite |

### Fase 2 — RAGService

| ID | Requisito |
|----|-----------|
| VGP-RAG-08 | O sistema SHALL implementar `IRAGService` com métodos: `initialize()`, `addDocument()`, `addDocumentBatch()`, `search()`, `clearSession()` |
| VGP-RAG-09 | `RAGService` SHALL usar `FlutterGemmaPlugin.instance.addDocument()` e `searchSimilar()` conforme API do flutter_gemma |
| VGP-RAG-10 | Documentos SHALL ter: `id` (String), `content` (String), `metadata` (JSON com `category`, `lang`, `topic`, `isSession`) |
| VGP-RAG-11 | `search(query, {topK: 3})` SHALL retornar os documentos mais relevantes como `List<SearchResult>` |
| VGP-RAG-12 | `clearSession()` SHALL remover apenas documentos onde `isSession: true` no metadata, preservando a knowledge base |

### Fase 3 — OnePieceKnowledgeBase

| ID | Requisito |
|----|-----------|
| VGP-RAG-13 | O sistema SHALL ter `OnePieceKnowledgeBase` com documentos seed sobre: Vegapunk e seus 6 satélites, personagens principais (Luffy, Zoro, Nami, Sanji, etc.), Frutas do Diabo relevantes, arcos principais |
| VGP-RAG-14 | Documentos seed SHALL ser bilíngues (EN e PT como documentos separados) ou marcados como `lang: both` |
| VGP-RAG-15 | A knowledge base SHALL ser carregada na inicialização do `VegapunkChatCubit`, uma única vez por sessão |

### Fase 4 — Integração com GemmaService

| ID | Requisito |
|----|-----------|
| VGP-RAG-16 | `GemmaService.sendMessage()` SHALL aceitar `List<String>? ragContext` opcional |
| VGP-RAG-17 | Quando `ragContext` não é vazio, o prompt SHALL incluir uma seção `[CONTEXT]` antes da query do usuário |
| VGP-RAG-18 | `VegapunkChatRepository` SHALL orquestrar: (1) busca RAG → (2) injeção no prompt → (3) geração |
| VGP-RAG-19 | O sistema SHALL adicionar um documento de sessão resumindo o exchange após cada resposta completa (memória conversacional) |
| VGP-RAG-20 | O sistema SHALL funcionar em modo degradado sem RAG inicializado (sem contexto injetado, fallback ao comportamento atual) |

---

## Acceptance Criteria

- [ ] Pergunta "você conhece o Sanji?" gera resposta de no máximo 80 palavras
- [ ] Pergunta sim/não sobre personagem gera resposta de 1–3 frases
- [ ] Perguntas sobre Vegapunk e satélites retornam fatos corretos (extraídos da knowledge base)
- [ ] Perguntas sobre Frutas do Diabo retornam nomes e poderes corretos
- [ ] Contexto RAG é visível nos logs de debug antes de cada geração
- [ ] Documentos de sessão acumulam e influenciam respostas subsequentes
- [ ] `clearSession()` reseta memória conversacional mas mantém knowledge base
- [ ] Feature funciona no iOS (sqlite-vec)

---

## Constraints

- Manter `IGemmaService` retrocompatível — `ragContext` é parâmetro opcional
- Não quebrar o satellite style instruction system existente
- Não introduzir nova UI — apenas melhorias internas de qualidade de resposta
- sqlite-vec (não qdrant-edge) pelo suporte a iOS
- Verificar nomes exatos de pacotes em pub.dev antes de T1.1 (pode diferir de `flutter_gemma_embeddings`)
- Manter DI via GetIt, sem Riverpod/Provider
