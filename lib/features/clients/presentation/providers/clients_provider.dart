import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talabati/features/clients/data/models/client.dart';
import 'package:talabati/features/clients/data/repositories/clients_repository.dart';

final clientsRepositoryProvider = Provider((ref) => ClientsRepository());

final clientsProvider = NotifierProvider<ClientsNotifier, List<Client>>(ClientsNotifier.new);

class SearchClientQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  
  @override
  set state(String value) => super.state = value;
}

final searchClientQueryProvider = NotifierProvider<SearchClientQueryNotifier, String>(SearchClientQueryNotifier.new);

final filteredClientsProvider = Provider<List<Client>>((ref) {
  final clients = ref.watch(clientsProvider);
  final query = ref.watch(searchClientQueryProvider).toLowerCase();

  if (query.isEmpty) {
    return clients;
  }

  return clients.where((client) {
    return client.name.toLowerCase().contains(query) ||
        client.phone.contains(query);
  }).toList();
});

class ClientsNotifier extends Notifier<List<Client>> {
  ClientsRepository get _repository => ref.read(clientsRepositoryProvider);

  @override
  List<Client> build() {
    loadClients();
    return [];
  }

  Future<void> loadClients() async {
    final clients = await _repository.getClients();
    state = clients;
  }

  Future<void> addClient(Client client) async {
    await _repository.addClient(client);
    await loadClients();
  }

  Future<void> updateClient(Client client) async {
    await _repository.updateClient(client);
    await loadClients();
  }

  Future<void> deleteClient(String id) async {
    await _repository.deleteClient(id);
    await loadClients();
  }

  Future<Client?> checkPhoneDuplicate(String phone) async {
    return await _repository.getClientByPhone(phone);
  }
}
