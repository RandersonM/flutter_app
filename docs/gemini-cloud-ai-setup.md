# Gemini AI na Nuvem (Google) — Configuração

> **Este documento cobre o Gemini na nuvem** — texto do Sanji e imagens de personagens e
> tripulações. Para o LLM que roda **no dispositivo** (`flutter_gemma`, chats do Vegapunk e
> da Nami), veja [`flutter-gemma-on-device.md`](./flutter-gemma-on-device.md).

## Arquitetura: sem chave do Gemini no app, sem custo

O projeto Firebase está no plano gratuito **Spark** (sem conta de faturamento). Por isso o
Gemini passa pelo **Firebase AI Logic** (pacote `firebase_ai`, backend *Gemini Developer
API*), que funciona no Spark:

- a chave do Gemini fica **dentro do projeto Firebase** — o app não tem nenhuma;
- cada chamada leva um token do **App Check** (também gratuito);
- o limite é o *free tier* do Gemini; sem cartão cadastrado, não existe cobrança.

| Uso | Modelo | Código |
|---|---|---|
| Texto do Sanji | `gemini-3.5-flash-lite` | `GeminiService.generateText` |
| Imagem de personagem / tripulação | `gemini-2.5-flash-image` | `GeminiService.generateImage` |

`GeminiService` (`lib/core/services/gemini/`) usa `IGeminiClient`, implementado por
`FirebaseAiGeminiClient` — a única classe que conhece o `firebase_ai`. A imagem gerada vem
em bytes e é hospedada por `IImageHostService` (`ImgurImageHostService`, com
`IMGUR_CLIENT_ID` do `.env`; sem ele, a imagem fica como data URI).

Toda falha vira `null` (o Sanji mostra o erro de dica/refeição; a imagem não aparece). Cota
gratuita esgotada (`QuotaExceededException`) pausa novas chamadas por 2 minutos.

## Configurar (uma vez)

1. No [console do Firebase](https://console.firebase.google.com/project/opfan-db177), abra
   **AI Logic** → **Get started** → escolha **Gemini Developer API**. O console cria e
   guarda a chave do Gemini no projeto.
2. **App Check** → registre os dois apps:
   - Android: **Play Integrity**;
   - iOS: **DeviceCheck**;
   - em builds de debug o app imprime um *debug token* no log — adicione-o em
     App Check → Apps → ⋮ → *Manage debug tokens*.
3. Ainda em App Check → **APIs** → *Firebase AI Logic* → **Enforce**, depois que os apps e
   os debug tokens estiverem registrados (antes disso, todas as chamadas seriam recusadas).

Nada disso exige cartão.

## Free tier: o que conferir

O *free tier* da Gemini Developer API tem limites por minuto e por dia por modelo.

- `gemini-2.5-flash-lite` não está mais disponível para projetos novos (404); o app usa
  `gemini-3.5-flash-lite`.
- **Geração de imagem não tem cota no free tier**: `gemini-2.5-flash-image` responde 429
  (*"You exceeded your current quota"*) mesmo na primeira chamada. Sem faturamento, as
  imagens de personagem/tripulação não são geradas — o app trata como "sem imagem" e o
  resto continua funcionando. (Verificado em 2026-10-16 pelo AI Logic do projeto.)

## Solução de problemas

- *"Firebase AI Logic API has not been used / is disabled"*: faça o passo 1.
- Chamadas recusadas depois de ativar o *Enforce*: o app (ou o debug token do
  simulador/emulador) não está registrado no App Check.
- `QuotaExceededException` nos logs: cota gratuita do Gemini esgotada; espere o reset.
