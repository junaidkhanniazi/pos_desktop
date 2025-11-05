import 'package:pos_desktop/domain/entities/subscription_entity.dart';
import 'package:pos_desktop/domain/repositories/subscription_repository.dart';

class GetSubscriptionsByOwnerUseCase {
  final SubscriptionRepository repository;

  GetSubscriptionsByOwnerUseCase(this.repository);

  Future<List<SubscriptionEntity>> call(String ownerId) async {
    return await repository.getSubscriptionsByOwner(ownerId);
  }
}
