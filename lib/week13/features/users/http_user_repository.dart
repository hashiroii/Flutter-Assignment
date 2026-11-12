import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';
import 'users_cache.dart';

class HttpUserRepository implements UserRepository {
  HttpUserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  @override
  Future<UsersResult> getAll() async {
    try {
      final fresh = await _fetch();
      await _cache.save(fresh);
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<List<User>> _fetch() async {
    final json = await _api.get(_api.uri('/users'));
    return _parse(
      'users',
      () => (json as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<User> getById(int id) async {
    final json = await _api.get(_api.uri('/users/$id'));
    return _parse(
      'users/$id',
      () => User.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<User> create(User draft) async {
    final json = await _api.post(_api.uri('/users'), draft.toJson());
    return _parse('users', () => User.fromJson(json as Map<String, dynamic>));
  }

  T _parse<T>(String where, T Function() read) {
    try {
      return read();
    } on TypeError catch (e) {
      throw BadResponseException('$where: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$where: $e');
    }
  }
}
