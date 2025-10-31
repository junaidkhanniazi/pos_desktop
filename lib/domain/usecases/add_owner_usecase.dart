import 'package:pos_desktop/domain/entities/owner_entity.dart';
import 'package:pos_desktop/domain/repositories/owner_repository.dart';

class AddOwnerUseCase {
  final OwnerRepository _repository;

  AddOwnerUseCase(this._repository);

  Future<void> call(OwnerEntity owner) async {
    await _repository.addOwner(owner);
  }
}

// ✅ NEW USECASE FOR SUBSCRIPTION
class UpdateOwnerSubscriptionUseCase {
  final OwnerRepository _repository;

  UpdateOwnerSubscriptionUseCase(this._repository);

  Future<void> call({
    required String ownerId,
    required String subscriptionPlan,
    required String receiptImage,
    required double subscriptionAmount,
  }) async {
    await _repository.updateOwnerSubscription(
      ownerId: ownerId,
      subscriptionPlan: subscriptionPlan,
      receiptImage: receiptImage,
      subscriptionAmount: subscriptionAmount,
    );
  }
}

// ✅ NEW USECASE FOR GETTING SUBSCRIPTION PLANS
class GetSubscriptionPlansUseCase {
  final OwnerRepository _repository;

  GetSubscriptionPlansUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await _repository.getSubscriptionPlans();
  }
}

// ✅ NEW USECASE FOR GETTING OWNERS WITH RECEIPT
class GetOwnersWithReceiptUseCase {
  final OwnerRepository _repository;

  GetOwnersWithReceiptUseCase(this._repository);

  Future<List<OwnerEntity>> call() async {
    return await _repository.getOwnersWithReceipt();
  }
}
