# Configuração da API do YouTube

## Como configurar a API key do YouTube

### 1. Obter a API Key

1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Crie um novo projeto ou selecione um existente
3. Vá para **APIs & Services** > **Library**
4. Procure por **YouTube Data API v3** e ative-a
5. Vá para **APIs & Services** > **Credentials**
6. Clique em **Create Credentials** > **API key**
7. Copie a API key gerada

### 2. Configurar no App

1. Abra o arquivo `lib/core/services/youtube_service.dart`
2. Substitua `YOUR_YOUTUBE_API_KEY` pela sua API key real:

```dart
static const String _apiKey = 'SUA_API_KEY_AQUI';
```

### 3. Funcionalidades

- **Busca automática**: Quando um personagem é carregado, o app busca automaticamente por vídeos AMV
- **Fallback**: Se não há API key configurada, usa dados simulados para desenvolvimento
- **Player integrado**: Clique no banner para assistir ao vídeo em fullscreen
- **Thumbnail**: Mostra a thumbnail do vídeo como banner

### 4. Exemplo de uso

```dart
final youtubeService = YouTubeService();
final video = await youtubeService.searchCharacterAMV('Monkey D. Luffy');
```

### 5. Dados simulados (Desenvolvimento)

Se você não configurar a API key, o app funcionará normalmente usando dados simulados com um vídeo de placeholder.

## ⚠️ Importante

- Mantenha sua API key segura
- Não commite a API key para o repositório
- Configure quotas apropriadas no Google Cloud Console
- A API do YouTube tem limites de uso gratuito

## Estrutura dos arquivos

- `lib/core/services/youtube_service.dart` - Serviço principal
- `lib/core/home/models/youtube_video_model.dart` - Modelo de dados
- `lib/screens/home/widgets/youtube_player_screen.dart` - Tela do player
- `lib/screens/home/widgets/simple_video_banner.dart` - Banner com suporte a YouTube 