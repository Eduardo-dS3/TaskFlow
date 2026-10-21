import 'file_actions_stub.dart'
    if (dart.library.js_interop) 'file_actions_web.dart'
    as impl;

/// Ações com arquivos que dependem do navegador.

/// Baixa [bytes] como um arquivo chamado [fileName].
void saveFile(List<int> bytes, String fileName, String mimeType) =>
    impl.saveFile(bytes, fileName, mimeType);

/// Abre [bytes] em uma nova aba (ex.: prévia de PDF).
void openBytes(List<int> bytes, String mimeType) =>
    impl.openBytes(bytes, mimeType);

/// Abre um endereço em uma nova aba.
void openUrl(Uri url) => impl.openUrl(url);
