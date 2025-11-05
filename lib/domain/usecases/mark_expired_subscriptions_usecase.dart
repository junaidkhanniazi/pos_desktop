import 'package:pos_desktop/domain/repositories/subscription_repository.dart';

class MarkExpiredSubscriptionsUseCase {
  final SubscriptionRepository repository;

  MarkExpiredSubscriptionsUseCase(this.repository);

  Future<void> call() async {
    await repository.markExpiredSubscriptions();
  }
}
