import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final json = await _api.get(_api.uri('/users'));
    return _parse(
      'users',
      () => (json as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<User> getById(int id) async {
    final json = await _api.get(_api.uri('/users/$id'));
    return _parse(
      'users/$id',
      () => User.fromJson(json as Map<String, dynamic>),
    );
  }

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
