import 'package:pos_desktop/domain/repositories/subscription_repository.dart';

class UpdateSubscriptionStatusUseCase {
  final SubscriptionRepository repository;

  UpdateSubscriptionStatusUseCase(this.repository);

  Future<void> call(String subscriptionId, String status) async {
    await repository.updateStatus(subscriptionId, status);
  }
}
