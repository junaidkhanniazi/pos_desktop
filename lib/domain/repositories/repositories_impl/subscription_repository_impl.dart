import 'package:pos_desktop/data/local/dao/subscription_dao.dart';
import 'package:pos_desktop/data/models/subscription_model.dart';
import 'package:pos_desktop/domain/entities/subscription_entity.dart';
import 'package:pos_desktop/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionDao _dao;

  SubscriptionRepositoryImpl(this._dao);

  @override
  Future<int> addSubscription(SubscriptionEntity subscription) async {
    final model = SubscriptionModel.fromEntity(subscription);
    return await _dao.insertSubscription(model);
  }

  @override
  Future<List<SubscriptionEntity>> getAllSubscriptions() async {
    final list = await _dao.getAllSubscriptions();
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<SubscriptionEntity>> getSubscriptionsByOwner(
    String ownerId,
  ) async {
    final list = await _dao.getSubscriptionsByOwner(int.parse(ownerId));
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<SubscriptionEntity?> getActiveSubscription(String ownerId) async {
    final model = await _dao.getActiveSubscription(int.parse(ownerId));
    return model?.toEntity();
  }

  @override
  Future<void> updateStatus(String subscriptionId, String status) async {
    await _dao.updateSubscriptionStatus(int.parse(subscriptionId), status);
  }

  @override
  Future<void> markExpiredSubscriptions() async {
    await _dao.markExpiredSubscriptions();
  }

  @override
  Future<void> deleteSubscription(String subscriptionId) async {
    await _dao.deleteSubscription(int.parse(subscriptionId));
  }
}
