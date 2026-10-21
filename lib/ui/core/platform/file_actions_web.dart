import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

String _blobUrl(List<int> bytes, String mimeType) {
  final blob = web.Blob(
    [Uint8List.fromList(bytes).toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  return web.URL.createObjectURL(blob);
}

void saveFile(List<int> bytes, String fileName, String mimeType) {
  final url = _blobUrl(bytes, mimeType);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

void openBytes(List<int> bytes, String mimeType) {
  web.window.open(_blobUrl(bytes, mimeType), '_blank');
}

void openUrl(Uri url) {
  web.window.open(url.toString(), '_blank');
}
