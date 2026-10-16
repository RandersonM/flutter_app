# OpFan — Documentação

Índice central da documentação do projeto. Guias de setup específicos vivem aqui em `docs/`; specs de features (spec-driven development) vivem em [`.specs/`](../.specs/); guias para assistentes de IA ficam na raiz do projeto (arquivos que essas ferramentas carregam automaticamente).

## Nesta pasta (`docs/`)

| Documento | Conteúdo |
|---|---|
| [`flutter-gemma-on-device.md`](./flutter-gemma-on-device.md) | LLM on-device (chat Vegapunk, assistente da Nami, RAG, function calling) — configuração, arquitetura, pontos fortes/fracos |
| [`flutter-gemma-code-tour.md`](./flutter-gemma-code-tour.md) | Roteiro de apresentação do código do `flutter_gemma` — o que abrir, em que ordem, com números de linha |
| [`gemini-cloud-ai-setup.md`](./gemini-cloud-ai-setup.md) | Gemini na nuvem (`google_generative_ai` + REST) — texto do Sanji e imagens de personagens/tripulações, distinto do `flutter_gemma` |
| [`firebase-setup.md`](./firebase-setup.md) | Configuração do Firebase Auth (Google Sign-In) |
| [`firestore-setup.md`](./firestore-setup.md) | Configuração do Firestore Database |
| [`firestore-troubleshooting.md`](./firestore-troubleshooting.md) | Erros comuns de permissão/índice no Firestore |
| [`youtube-api-setup.md`](./youtube-api-setup.md) | Configuração da YouTube Data API v3 |

## Na raiz do projeto

Estes arquivos ficam na raiz de propósito — ferramentas de IA (Claude Code, Gemini CLI) os carregam automaticamente de lá; mover para `docs/` quebraria essa integração.

| Documento | Conteúdo |
|---|---|
| [`../CLAUDE.md`](../CLAUDE.md) | Guia do projeto para o Claude Code — stack, arquitetura, convenções; as regras detalhadas por tema ficam em [`../.claude/rules/`](../.claude/rules/) |
| [`../GEMINI.md`](../GEMINI.md) | Guia equivalente para o Gemini CLI |
| [`../README.md`](../README.md) | Ponto de entrada do repositório |

## Specs de features (`.specs/`)

Sistema de spec-driven development (spec → design → tasks) por feature. Não centralizado em `docs/` porque é uma estrutura própria de workflow, não documentação de referência solta.

- [`.specs/codebase/`](../.specs/codebase/) — `ARCHITECTURE.md`, `STACK.md`, `CONCERNS.md`, `TECH_DEBT.md` (backlog priorizado)
- [`.specs/features/`](../.specs/features/) — uma pasta por feature (`vegapunk-chat`, `vegapunk-rag`, `gemma-performance-audit`, `nami-finances-rag`, etc.)

### Qual fonte vale mais

Os specs de feature registram a intenção da época em que foram escritos; alguns ficaram para trás (o `vegapunk-chat` previa Qwen3 `.task` e mediapipe — o topo do `design.md` dele resume o pipeline atual). Ao decidir arquitetura, priorize: **código-fonte > `CLAUDE.md` + `.claude/rules/` > `.specs/codebase/*` > `.specs/features/*`**. Quando um doc divergir do código, corrija o doc na mesma mudança.

## IA no projeto — visão rápida

O OpFan usa **duas tecnologias de IA distintas e independentes**:

1. **`flutter_gemma`** — LLM **Gemma 4 E2B** rodando no dispositivo (engine LiteRT-LM, embeddings Gecko + vector store SQLite para RAG), sem rede após o download do modelo. Alimenta o chat **Ask Vegapunk** e o assistente de **Nami Finances**, com RAG e function calling.
2. **Gemini na nuvem** (`google_generative_ai` para texto, REST para imagem) — usado só no texto do **Sanji** e nas imagens de **personagens customizados e tripulações**. Rate-limited, requer rede. Não é usado em chat.

Não confunda os dois ao ler "Gemini"/"Gemma" no código — são pacotes, modelos e trade-offs completamente diferentes.
