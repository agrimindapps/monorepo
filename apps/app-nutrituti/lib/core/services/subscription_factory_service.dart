/// Simple subscription ID factory
class SubscriptionFactoryService {
  static String create({
    required String platform,
    required String productId,
  }) {
    return 'br.com.agrimind.nutrituti.$productId';
  }
}
