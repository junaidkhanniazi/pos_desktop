import 'package:pos_desktop/domain/entities/subscription_entity.dart';
import 'package:pos_desktop/domain/repositories/subscription_repository.dart';

class GetActiveSubscriptionUseCase {
  final SubscriptionRepository repository;

  GetActiveSubscriptionUseCase(this.repository);

  Future<SubscriptionEntity?> call(String ownerId) async {
    return await repository.getActiveSubscription(ownerId);
  }
}
