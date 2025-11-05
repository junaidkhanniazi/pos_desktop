import 'package:pos_desktop/domain/entities/subscription_entity.dart';
import 'package:pos_desktop/domain/repositories/subscription_repository.dart';

class AddSubscriptionUseCase {
  final SubscriptionRepository repository;

  AddSubscriptionUseCase(this.repository);

  Future<int> call(SubscriptionEntity subscription) async {
    return await repository.addSubscription(subscription);
  }
}
