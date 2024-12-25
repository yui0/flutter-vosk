import 'dart:async';
import 'dart:js_interop';
import 'dart:convert';

import 'package:fllama/fllama.dart';

@JS('fllamaInferenceJs')
external JSPromise<JSNumber> fllamaInferenceJs(
    JSAny request, JSFunction callback);

typedef FllamaInferenceCallback = void Function(String response, bool done);

// Keep in sync with fllama_inference_request.dart to pass correctly from Dart to JS
extension type _JSFllamaInferenceRequest._(JSObject _)  implements JSObject {
  external factory _JSFllamaInferenceRequest({
    required int contextSize,
    required String input,
    required int maxTokens,
    required String modelPath,
    String? modelMmprojPath,
    required int numGpuLayers,
    required int numThreads,
    required double temperature,
    required double penaltyFrequency,
    required double penaltyRepeat,
    required double topP,
    String? grammar,
    String? eosToken,
    // INTENTIONALLY MISSING: logger
  });
}


/// Runs standard LLM inference. The future returns immediately after being
/// called. [callback] is called on each new output token with the response and
/// a boolean indicating whether the response is the final response.
///
/// This is *not* what most people want to use. LLMs post-ChatGPT use a chat
/// template and an EOS token. Use [fllamaChat] instead if you expect this
/// sort of interface, i.e. an OpenAI-like API.
Future<int> fllamaInference(FllamaInferenceRequest dartRequest,
    FllamaInferenceCallback callback) async {
  final jsRequest = _JSFllamaInferenceRequest(
    contextSize: dartRequest.contextSize,
    input: dartRequest.input,
    maxTokens: dartRequest.maxTokens,
    modelPath: dartRequest.modelPath,
    modelMmprojPath: dartRequest.modelMmprojPath,
    numGpuLayers: dartRequest.numGpuLayers,
    numThreads: dartRequest.numThreads,
    temperature: dartRequest.temperature,
    penaltyFrequency: dartRequest.penaltyFrequency,
    penaltyRepeat: dartRequest.penaltyRepeat,
    topP: dartRequest.topP,
    grammar: dartRequest.grammar,
    eosToken: dartRequest.eosToken,
  );

  final completer = Completer<int>();
  callbackFn(String response, bool done) {
    callback(response, done);
  }
  fllamaInferenceJs(jsRequest, callbackFn.toJS).toDart.then((value) {
    completer.complete(value.toDartInt);
  });
  return completer.future;
}

// JSAny used to be void. JSVoid does not work.
@JS('fllamaMlcWebModelDeleteJs')
external JSPromise<JSAny> fllamaMlcWebModelDeleteJs(String modelId);

@JS('fllamaMlcIsWebModelDownloadedJs')
external JSPromise<JSBoolean> fllamaMlcIsWebModelDownloadedJs(String modelId);

@JS('fllamaChatMlcWebJs')
external JSPromise<JSNumber> fllamaChatMlcWebJs(
    // ignore: library_private_types_in_public_api
    _JSFllamaMlcInferenceRequest request, JSFunction loadCallback, JSFunction callback);

extension type _JSFllamaMlcInferenceRequest._(JSObject _)  implements JSObject {
   external _JSFllamaMlcInferenceRequest({
    required String messagesAsJsonString,
    required String toolsAsJsonString,
    required int maxTokens,
    // Must match a model_id in [prebuiltAppConfig] in https://github.com/mlc-ai/web-llm/blob/main/src/config.ts
    required String modelId,
    required double temperature,
    required double penaltyFrequency,
    required double penaltyRepeat,
    required double topP,
  });
}

typedef FllamaMlcLoadCallback = void Function(
    double downloadProgress, double loadProgress);

Future<bool> fllamaMlcIsWebModelDownloaded(String modelId) async {
  return fllamaMlcIsWebModelDownloadedJs(modelId).toDart.then((value) {
    return value.toDart;
  });
}

/// Use MLC's web JS SDK to do chat inference.
/// If not on web, this will fallback to using [fllamaChat].
///
/// llama.cpp converted to WASM is very slow compared to native inference on the
/// same platform, because it does not use the GPU.
///
/// MLC uses WebGPU to achieve ~native inference speeds.
Future<int> fllamaChatMlcWeb(
    OpenAiRequest request,
    FllamaMlcLoadCallback loadCallback,
    FllamaInferenceCallback callback) async {
  final messagesAsMaps = request.messages
      .map((e) => {
            'role': e.role.openAiName,
            'content': e.text,
          })
      .toList();
  final toolsAsMaps = request.tools
      .map((e) => {
            'type': 'function',
            'function': {
              'name': e.name,
              'description': e.description,
              'parameters': e.jsonSchema,
            }
          })
      .toList();
  final jsRequest = _JSFllamaMlcInferenceRequest(
    toolsAsJsonString: jsonEncode(toolsAsMaps),
    messagesAsJsonString: jsonEncode(messagesAsMaps),
    maxTokens: request.maxTokens,
    modelId: request.modelPath,
    temperature: request.temperature,
    penaltyFrequency: request.frequencyPenalty,
    penaltyRepeat: request.presencePenalty,
    topP: request.topP,
  );
  final completer = Completer<int>();
  firstCallback(double downloadProgress, double loadProgress) {
    loadCallback(downloadProgress, loadProgress);
  } 
  secondCallback(String response, bool done) {
    callback(response, done);
  }
  fllamaChatMlcWebJs(jsRequest, firstCallback.toJS, secondCallback.toJS).toDart.then((value) {
    completer.complete(value.toDartInt);
  });
  return completer.future;
}

Future<void> fllamaMlcWebModelDelete(String modelId) async {
  await fllamaMlcWebModelDeleteJs(modelId).toDart;
}

// Tokenize
@JS('fllamaTokenizeJs')
external JSPromise<JSNumber> fllamaTokenizeJs(String modelPath, String input);

/// Returns the number of tokens in [request.input].
///
/// Useful for identifying what messages will be in context when the LLM is run.
Future<int> fllamaTokenize(FllamaTokenizeRequest request) async {
  try {
    final completer = Completer<int>();
    // print('[fllama_html] calling fllamaTokenizeJs at ${DateTime.now()}');

    fllamaTokenizeJs(request.modelPath, request.input).toDart.then((value) {
      // print(
      // '[fllama_html] fllamaTokenizeAsync finished with $value at ${DateTime.now()}');
      completer.complete(value.toDartInt);
    });
    // print('[fllama_html] called fllamaTokenizeJs at ${DateTime.now()}');
    return completer.future;
  } catch (e) {
    // ignore: avoid_print
    print('[fllama_html] fllamaTokenizeAsync caught error: $e');
    rethrow;
  }
}

// Chat template
@JS('fllamaChatTemplateGetJs')
external JSPromise<JSString> fllamaChatTemplateGetJs(String modelPath);

/// Returns the chat template embedded in the .gguf file.
/// If none is found, returns an empty string.
///
/// See [fllamaSanitizeChatTemplate] for using sensible fallbacks for gguf
/// files that don't have a chat template or have incorrect chat templates.
Future<String> fllamaChatTemplateGet(String modelPath) async {
  try {
    final completer = Completer<String>();
    // print('[fllama_html] calling fllamaChatTemplateGetJs at ${DateTime.now()}');
    fllamaChatTemplateGetJs(modelPath).toDart.then((value) {
      // print(
      // '[fllama_html] fllamaChatTemplateGetJs finished with $value at ${DateTime.now()}');
      completer.complete(value.toDart);
    });
    // print('[fllama_html] called fllamaChatTemplateGetJs at ${DateTime.now()}');
    return completer.future;
  } catch (e) {
    // ignore: avoid_print
    print('[fllama_html] fllamaChatTemplateGetJs caught error: $e');
    rethrow;
  }
}

@JS('fllamaBosTokenGetJs')
external JSPromise<JSString?> fllamaBosTokenGetJs(String modelPath);

/// Returns the EOS token embedded in the .gguf file.
/// If none is found, returns an empty string.
///
/// See [fllamaApplyChatTemplate] for using sensible fallbacks for gguf
/// files that don't have an EOS token or have incorrect EOS tokens.
Future<String> fllamaBosTokenGet(String modelPath) {
  try {
    final completer = Completer<String>();
    // print('[fllama_html] calling fllamaEosTokenGet at ${DateTime.now()}');
    fllamaBosTokenGetJs(modelPath).toDart.then((value) {
      // print(
      // '[fllama_html] fllamaEosTokenGet finished with $value at ${DateTime.now()}');
      completer.complete(value?.toDart ?? '');
    });
    // print('[fllama_html] called fllamaEosTokenGet at ${DateTime.now()}');
    return completer.future;
  } catch (e) {
    // ignore: avoid_print
    print('[fllama_html] fllamaBosTokenGet caught error: $e');
    rethrow;
  }
}

@JS('fllamaEosTokenGetJs')
external JSPromise<JSString> fllamaEosTokenGetJs(String modelPath);

/// Returns the EOS token embedded in the .gguf file.
/// If none is found, returns an empty string.
///
/// See [fllamaApplyChatTemplate] for using sensible fallbacks for gguf
/// files that don't have an EOS token or have incorrect EOS tokens.
Future<String> fllamaEosTokenGet(String modelPath) {
  try {
    final completer = Completer<String>();
    // print('[fllama_html] calling fllamaEosTokenGet at ${DateTime.now()}');
    fllamaEosTokenGetJs(modelPath).toDart.then((value) {
      // print(
      // '[fllama_html] fllamaEosTokenGet finished with $value at ${DateTime.now()}');
      completer.complete(value.toDart);
    });
    // print('[fllama_html] called fllamaEosTokenGet at ${DateTime.now()}');
    return completer.future;
  } catch (e) {
    // ignore: avoid_print
    print('[fllama_html] fllamaEosTokenGet caught error: $e');
    rethrow;
  }
}

@JS('fllamaCancelInferenceJs')
external void fllamaCancelInferenceJs(int requestId);

/// Cancels the inference with the given [requestId].
///
/// It is recommended you do _not_ update your state based on this.
/// Use the callbacks, like you would generally.
///
/// This is supported via:
/// - Inferences that have not yet started will call their callback with `done` set
///  to `true` and an empty string.
/// - Inferences that have started will call their callback with `done` set to
/// `true` and the final output of the inference.
void fllamaCancelInference(int requestId) {
  fllamaCancelInferenceJs(requestId);
}
