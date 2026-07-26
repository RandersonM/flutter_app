# OpFan — Documentação

Índice central da documentação do projeto. Guias de setup específicos vivem aqui em `docs/`; specs de features (spec-driven development) vivem em [`.specs/`](../.specs/); guias para assistentes de IA ficam na raiz do projeto (arquivos que essas ferramentas carregam automaticamente).

## Nesta pasta (`docs/`)

| Documento | Conteúdo |
|---|---|
| [`flutter-gemma-on-device.md`](./flutter-gemma-on-device.md) | LLM on-device (chat Vegapunk, RAG, function calling) — configuração, arquitetura, pontos fortes/fracos |
| [`gemini-cloud-ai-setup.md`](./gemini-cloud-ai-setup.md) | Gemini na nuvem (`google_generative_ai`) — geração de texto/imagem, distinto do `flutter_gemma` |
| [`firebase-setup.md`](./firebase-setup.md) | Configuração do Firebase Auth (Google Sign-In) |
| [`firestore-setup.md`](./firestore-setup.md) | Configuração do Firestore Database |
| [`firestore-troubleshooting.md`](./firestore-troubleshooting.md) | Erros comuns de permissão/índice no Firestore |
| [`youtube-api-setup.md`](./youtube-api-setup.md) | Configuração da YouTube Data API v3 |

## Na raiz do projeto

Estes arquivos ficam na raiz de propósito — ferramentas de IA (Claude Code, Gemini CLI) os carregam automaticamente de lá; mover para `docs/` quebraria essa integração.

| Documento | Conteúdo |
|---|---|
| [`../CLAUDE.md`](../CLAUDE.md) | Guia do projeto para o Claude Code — stack, arquitetura, convenções |
| [`../GEMINI.md`](../GEMINI.md) | Guia equivalente para o Gemini CLI |
| [`../README.md`](../README.md) | Ponto de entrada do repositório |

## Specs de features (`.specs/`)

Sistema de spec-driven development (spec → design → tasks) por feature. Não centralizado em `docs/` porque é uma estrutura própria de workflow, não documentação de referência solta.

- [`.specs/codebase/`](../.specs/codebase/) — `ARCHITECTURE.md`, `STACK.md`, `CONCERNS.md`
- [`.specs/features/`](../.specs/features/) — uma pasta por feature (`vegapunk-chat`, `vegapunk-rag`, `gemma-performance-audit`, `nami-finances-rag`, etc.)

### ⚠️ Lacuna de documentação conhecida

`.specs/codebase/ARCHITECTURE.md` e `STACK.md` descrevem uma versão **anterior** do projeto (estrutura `lib/screens/` + `lib/widgets/`, sem menção ao `flutter_gemma`). A estrutura atual é `lib/features/` (ver `CLAUDE.md` na raiz, que está atualizado). Ao decidir arquitetura, priorize: **código-fonte > `CLAUDE.md`/`GEMINI.md` > `.specs/features/*/design.md` > `.specs/codebase/*`** (do mais para o menos atualizado). Isso é comentado em detalhe em [`flutter-gemma-on-device.md` §7](./flutter-gemma-on-device.md#7-divergências-entre-o-spec-original-e-o-código-atual).

## IA no projeto — visão rápida

O OpFan usa **duas tecnologias de IA distintas e independentes**:

1. **Gemini na nuvem** (`google_generative_ai`) — texto e imagem via API do Google, usado em features pontuais (ex.: melhoria de prompts de imagem). Rate-limited, requer rede.
2. **`flutter_gemma`** — LLM rodando no dispositivo, sem rede após o download do modelo. Alimenta o chat **Ask Vegapunk** e o assistente de **Nami Finances**, com RAG e function calling.

Não confunda os dois ao ler "Gemini"/"Gemma" no código — são pacotes, modelos e trade-offs completamente diferentes.
