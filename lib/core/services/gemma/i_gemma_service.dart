import 'package:flutter_gemma/core/model_response.dart';
import 'package:flutter_gemma/core/tool.dart';

import 'gemma_service_status.dart';

abstract class IGemmaService {
  Stream<GemmaServiceStatus> get statusStream;
  GemmaServiceStatus get currentStatus;

  /// Check if model is on-device and load it; call once at startup.
  Future<void> initialize({bool isThinkingMode = false});

  /// Download the model file, broadcasting progress via [statusStream].
  Future<void> downloadModel();

  /// Load an already-installed model into memory and create a chat session.
  Future<void> loadModel({bool isThinkingMode = false});

  /// Send a user message and return a streaming response.
  ///
  /// The stream yields [ModelResponse] objects which can be:
  /// - [TextResponse] — a text token for streaming display
  /// - [FunctionCallResponse] — a native tool call detected by the SDK
  /// - [ThinkingResponse] — thinking/reasoning content
  ///
  /// [ragContext] is an optional list of relevant facts injected before the query.
  Stream<ModelResponse> sendMessage(
    String text, {
    String? styleInstruction,
    List<String>? ragContext,
  });

  /// Set the native tools for the Gemma 4 SDK function calling.
  ///
  /// Must be called before [loadModel] or [initialize] to take effect.
  void setTools(List<Tool> tools);

  /// Stop an in-progress generation.
  Future<void> stopGeneration();

  /// Reset the chat history while keeping the model loaded.
  Future<void> resetChat({bool isThinkingMode = false});

  /// Send a message on an independent, named chat session — its own system
  /// instruction and its own conversation history, created lazily on first
  /// use. Does not touch the legacy singleton chat used by [sendMessage].
  ///
  /// Use this for any feature whose persona/history must not bleed into (or
  /// be polluted by) the main chat — e.g. Nami finances vs. Vegapunk.
  /// [ragContext] is prefixed to the message as directly-usable data, not
  /// the "reference — use only if relevant" framing [sendMessage] applies.
  ///
  /// The session survives until [closeSession] is called or the model is
  /// reloaded (which invalidates every open session).
  ///
  /// Pass [tools] to enable native function calling on this session (the
  /// session is created with them on first use). When the returned stream
  /// yields a [FunctionCallResponse], execute the tool and feed the result
  /// back via [sendSessionToolResult] for the model's final answer.
  ///
  /// [maxOutputTokens] caps the length of the generated answer for this
  /// session (set on first use, when the session is created). Raise it for
  /// assistants that produce long, detailed replies.
  Stream<ModelResponse> sendSessionMessage(
    String sessionId, {
    required String systemInstruction,
    required String text,
    List<String>? ragContext,
    List<Tool>? tools,
    int maxOutputTokens = 512,
  });

  /// Feed a tool result back into a session (second pass) after a
  /// [FunctionCallResponse] from [sendSessionMessage]. Mirrors [sendMessage]'s
  /// tool-response flow but for an independent named session.
  Stream<ModelResponse> sendSessionToolResult(
    String sessionId, {
    required String toolName,
    required Map<String, dynamic> result,
  });

  /// Closes and forgets a session opened via [sendSessionMessage]. Callers
  /// should do this when the owning feature's UI is disposed, so an idle
  /// session doesn't keep holding its KV cache in memory indefinitely.
  Future<void> closeSession(String sessionId);

  void dispose();
}
