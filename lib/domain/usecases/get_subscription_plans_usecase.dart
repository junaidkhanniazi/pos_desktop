// domain/usecases/get_subscription_plans_usecase.dart
import 'package:pos_desktop/domain/repositories/subscription_plan_repository.dart';
import 'package:pos_desktop/domain/entities/subscription_plan_entity.dart';

class GetSubscriptionPlansUseCase {
  final SubscriptionPlanRepository _repository;

  GetSubscriptionPlansUseCase(this._repository);

  Future<List<SubscriptionPlanEntity>> execute() async {
    return await _repository.getActivePlans();
  }
}
