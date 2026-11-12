import '../../core/api/api_exception.dart';
import 'address.dart';
import 'geo.dart';
import 'user.dart';
import 'user_repository.dart';

class FakeUserRepository implements UserRepository {
  FakeUserRepository({this.fail = false, this.delay = Duration.zero});

  final bool fail;
  final Duration delay;

  final List<User> _users = [
    const User(
      id: 1,
      name: 'Aida Nurlanova',
      username: 'aida',
      email: 'aida@kbtu.kz',
      phone: '+7 701 111 22 33',
      website: 'aida.kz',
      address: Address(
        street: 'Tole bi 59',
        suite: 'Room 312',
        city: 'Almaty',
        zipcode: '050000',
        geo: Geo(lat: 43.2551, lng: 76.9431),
      ),
      company: (name: 'KBTU', catchPhrase: 'Learn by building'),
    ),
    const User(
      id: 2,
      name: 'Dias Seitkali',
      username: 'dias',
      email: 'dias@kbtu.kz',
      phone: '+7 702 444 55 66',
      website: null,
      address: Address(
        street: 'Mangilik El 55',
        suite: 'Block C',
        city: 'Astana',
        zipcode: '010000',
        geo: Geo(lat: 51.0890, lng: 71.4160),
      ),
      company: (name: 'Astana Hub', catchPhrase: 'Ship it on Friday'),
    ),
  ];

  Future<void> _wait() async {
    await Future<void>.delayed(delay);
    if (fail) throw const NoConnectionException();
  }

  @override
  Future<UsersResult> getAll() async {
    await _wait();
    return (items: List<User>.unmodifiable(_users), fromCache: false);
  }

  @override
  Future<User> getById(int id) async {
    await _wait();
    for (final u in _users) {
      if (u.id == id) return u;
    }
    throw const NotFoundException();
  }

  @override
  Future<User> create(User draft) async {
    await _wait();
    final user = User(
      id: _users.length + 1,
      name: draft.name,
      username: draft.username,
      email: draft.email,
      phone: draft.phone,
      website: draft.website,
      address: draft.address,
      company: draft.company,
    );
    _users.add(user);
    return user;
  }
}
