# Gemini AI na Nuvem (Google) — Configuração

> **Este documento cobre o Gemini na nuvem** — texto do Sanji e imagens de personagens e
> tripulações. Para o LLM que roda **no dispositivo** (`flutter_gemma`, chats do Vegapunk e
> da Nami), veja [`flutter-gemma-on-device.md`](./flutter-gemma-on-device.md).

## Arquitetura: o app não tem a chave

Desde o SEC-1, o app nunca recebe a chave do Gemini, do Tavily nem do Imgur. Ele chama três
Cloud Functions callable (`functions/src/ai_proxy.ts`), que guardam as chaves como
**secrets** do Firebase:

| Function | Faz | Secrets |
|---|---|---|
| `geminiGenerateText` | `gemini-2.5-flash-lite` (texto do Sanji) | `GEMINI_API_KEY` |
| `geminiGenerateImage` | `gemini-2.5-flash-image` + upload no Imgur, devolve a URL | `GEMINI_API_KEY`, `IMGUR_CLIENT_ID` |
| `webSearch` | busca Tavily do Vegapunk (`searchInternet`) | `TAVILY_API_KEY` |

Toda chamada:

- exige **usuário logado** (`unauthenticated` caso contrário);
- consome uma **cota diária por usuário** em `ai_usage/{uid}` (texto 50, imagem 10, busca 30);
  passou do limite → `resource-exhausted`;
- valida tamanho do prompt (12 000 caracteres) e da busca (400);
- pode exigir **App Check** (`REQUIRE_APP_CHECK=true`).

No app, `GeminiService` e `WebSearchService` (`lib/core/services/`) só fazem a chamada:
qualquer falha vira `null` / lista vazia, e `resource-exhausted` pausa novas chamadas por 2
minutos.

## Configurar

1. Gere as chaves:
   - Gemini: [Google AI Studio](https://aistudio.google.com/app/apikey)
   - Tavily: [tavily.com](https://tavily.com)
   - Imgur: [api.imgur.com/oauth2/addclient](https://api.imgur.com/oauth2/addclient) (anonymous usage)
2. Grave como secrets e faça o deploy:

```bash
firebase functions:secrets:set GEMINI_API_KEY
firebase functions:secrets:set TAVILY_API_KEY
firebase functions:secrets:set IMGUR_CLIENT_ID
cd functions && npm run deploy
```

3. (Recomendado) **App Check**: registre os apps no console do Firebase (Play Integrity no
   Android, DeviceCheck no iOS) e os *debug tokens* que o app imprime em builds de debug.
   Depois crie `functions/.env.opfan-db177` com `REQUIRE_APP_CHECK=true` e faça o deploy de
   novo. Antes disso, o parâmetro fica `false` — ligar sem registrar os apps bloqueia todas
   as chamadas.

O projeto precisa estar no plano **Blaze** (já está: as Functions agendadas exigem). Nesse
volume as chamadas cabem na cota grátis de Functions; o consumo do Gemini e do Tavily é
cobrado pela própria chave, com ou sem proxy.

## Comportamento de falha

- **Sem login, sem cota ou sem rede**: o Sanji mostra o erro de dica/refeição; a geração de
  imagem não devolve imagem; a busca do Vegapunk responde que não encontrou resultados.
- **Cache**: URLs de imagem geradas ficam em memória por prompt durante a sessão.

## Solução de problemas

- `unauthenticated`: o usuário não está logado (Sanji e imagens ficam em rotas privadas).
- `failed-precondition`: `REQUIRE_APP_CHECK` ligado e o app sem token válido — registre o app
  ou o debug token no console.
- `resource-exhausted`: cota diária do usuário (ou do Gemini/Tavily) estourada.
- `unavailable`: a chamada ao Gemini, Tavily ou Imgur falhou; veja `firebase functions:log`.
