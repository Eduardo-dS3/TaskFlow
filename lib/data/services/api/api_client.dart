import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import '../../../utils/result.dart';
import 'api_exception.dart';

/// Acesso ao servidor do TaskFlow (PocketBase).
///
/// Envolve o SDK, devolvendo [Result] e erros como [ApiException]. Só os
/// repositórios conhecem este serviço.
class ApiClient {
  ApiClient(this._pb);

  /// Coleção das contas da equipe.
  static const usersCollection = 'users';

  final PocketBase _pb;

  // ---------------------------------------------------------------------------
  // Sessão
  // ---------------------------------------------------------------------------

  bool get isAuthenticated => _pb.authStore.isValid;

  /// Registro do usuário logado, como recebido no login.
  RecordModel? get authRecord => _pb.authStore.record;

  String get authId => _pb.authStore.record?.id ?? '';

  Stream<AuthStoreEvent> get authChanges => _pb.authStore.onChange;

  Future<Result<RecordModel>> authWithPassword(String email, String password) =>
      _guard(() async {
        final auth = await _pb
            .collection(usersCollection)
            .authWithPassword(email, password);
        return auth.record;
      });

  /// Renova o token salvo e recarrega os dados do usuário logado.
  Future<Result<RecordModel>> authRefresh() => _guard(() async {
    final auth = await _pb.collection(usersCollection).authRefresh();
    return auth.record;
  });

  void clearSession() => _pb.authStore.clear();

  // ---------------------------------------------------------------------------
  // Registros
  // ---------------------------------------------------------------------------

  /// Monta um filtro com parâmetros escapados (evita injeção no filtro).
  String filter(String expression, Map<String, dynamic> params) =>
      _pb.filter(expression, params);

  Future<Result<List<RecordModel>>> list(
    String collection, {
    String? filter,
    String? sort,
    String? expand,
  }) => _guard(
    () => _pb
        .collection(collection)
        .getFullList(batch: 500, filter: filter, sort: sort, expand: expand),
  );

  Future<Result<RecordModel>> getOne(
    String collection,
    String id, {
    String? expand,
  }) => _guard(() => _pb.collection(collection).getOne(id, expand: expand));

  Future<Result<RecordModel>> create(
    String collection,
    Map<String, dynamic> body, {
    List<http.MultipartFile> files = const [],
    String? expand,
  }) => _guard(
    () => _pb
        .collection(collection)
        .create(body: body, files: files, expand: expand),
  );

  Future<Result<RecordModel>> update(
    String collection,
    String id,
    Map<String, dynamic> body, {
    String? expand,
  }) => _guard(
    () => _pb.collection(collection).update(id, body: body, expand: expand),
  );

  Future<Result<void>> delete(String collection, String id) =>
      _guard(() => _pb.collection(collection).delete(id));

  /// Chamada a uma rota própria do TaskFlow (pb_hooks).
  Future<Result<Map<String, dynamic>>> send(
    String path, {
    String method = 'GET',
    Map<String, dynamic> body = const {},
  }) => _guard(
    () => _pb.send<Map<String, dynamic>>(path, method: method, body: body),
  );

  /// Endereço de um arquivo protegido, com token temporário de acesso.
  Future<Result<Uri>> protectedFileUrl(
    String collection,
    String recordId,
    String fileName,
  ) => _guard(() async {
    final token = await _pb.files.getToken();
    final record = RecordModel({'id': recordId, 'collectionName': collection});
    return _pb.files.getURL(record, fileName, token: token);
  });

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.ok(await action());
    } on ClientException catch (error) {
      return Result.error(ApiException.from(error));
    }
  }
}
