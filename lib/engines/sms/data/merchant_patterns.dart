/// Represents a known merchant and the regex pattern to detect its SMS.
class MerchantPattern {
  const MerchantPattern({
    required this.id,
    required this.name,
    required this.regex,
    required this.categoryId,
    required this.iconName,
  });

  final String id;
  final String name;
  final RegExp regex;
  final String categoryId; // should match a default category id in the DB
  final String iconName;
}

/// 17 Common Indian Merchant SMS Patterns
final List<MerchantPattern> kIndianMerchantPatterns = [
  MerchantPattern(
    id: 'mer_swiggy',
    name: 'Swiggy',
    regex: RegExp(r'swiggy', caseSensitive: false),
    categoryId: 'cat_food',
    iconName: 'fastfood',
  ),
  MerchantPattern(
    id: 'mer_zomato',
    name: 'Zomato',
    regex: RegExp(r'zomato', caseSensitive: false),
    categoryId: 'cat_food',
    iconName: 'restaurant',
  ),
  MerchantPattern(
    id: 'mer_uber',
    name: 'Uber',
    regex: RegExp(r'uber', caseSensitive: false),
    categoryId: 'cat_transport',
    iconName: 'directions_car',
  ),
  MerchantPattern(
    id: 'mer_ola',
    name: 'Ola',
    regex: RegExp(r'ola', caseSensitive: false),
    categoryId: 'cat_transport',
    iconName: 'local_taxi',
  ),
  MerchantPattern(
    id: 'mer_amazon',
    name: 'Amazon',
    regex: RegExp(r'amazon', caseSensitive: false),
    categoryId: 'cat_shopping',
    iconName: 'shopping_cart',
  ),
  MerchantPattern(
    id: 'mer_flipkart',
    name: 'Flipkart',
    regex: RegExp(r'flipkart', caseSensitive: false),
    categoryId: 'cat_shopping',
    iconName: 'shopping_bag',
  ),
  MerchantPattern(
    id: 'mer_myntra',
    name: 'Myntra',
    regex: RegExp(r'myntra', caseSensitive: false),
    categoryId: 'cat_shopping',
    iconName: 'checkroom',
  ),
  MerchantPattern(
    id: 'mer_blinkit',
    name: 'Blinkit',
    regex: RegExp(r'blinkit|grofers', caseSensitive: false),
    categoryId: 'cat_groceries',
    iconName: 'local_grocery_store',
  ),
  MerchantPattern(
    id: 'mer_zepto',
    name: 'Zepto',
    regex: RegExp(r'zepto', caseSensitive: false),
    categoryId: 'cat_groceries',
    iconName: 'shopping_basket',
  ),
  MerchantPattern(
    id: 'mer_instamart',
    name: 'Instamart',
    regex: RegExp(r'instamart', caseSensitive: false),
    categoryId: 'cat_groceries',
    iconName: 'storefront',
  ),
  MerchantPattern(
    id: 'mer_bigbasket',
    name: 'BigBasket',
    regex: RegExp(r'bigbasket', caseSensitive: false),
    categoryId: 'cat_groceries',
    iconName: 'shopping_cart',
  ),
  MerchantPattern(
    id: 'mer_netflix',
    name: 'Netflix',
    regex: RegExp(r'netflix', caseSensitive: false),
    categoryId: 'cat_entertainment',
    iconName: 'movie',
  ),
  MerchantPattern(
    id: 'mer_spotify',
    name: 'Spotify',
    regex: RegExp(r'spotify', caseSensitive: false),
    categoryId: 'cat_entertainment',
    iconName: 'music_note',
  ),
  MerchantPattern(
    id: 'mer_bookmyshow',
    name: 'BookMyShow',
    regex: RegExp(r'bookmyshow|bms', caseSensitive: false),
    categoryId: 'cat_entertainment',
    iconName: 'confirmation_number',
  ),
  MerchantPattern(
    id: 'mer_jio',
    name: 'Jio',
    regex: RegExp(r'jio', caseSensitive: false),
    categoryId: 'cat_utilities',
    iconName: 'phone_android',
  ),
  MerchantPattern(
    id: 'mer_airtel',
    name: 'Airtel',
    regex: RegExp(r'airtel', caseSensitive: false),
    categoryId: 'cat_utilities',
    iconName: 'wifi',
  ),
  MerchantPattern(
    id: 'mer_bescom',
    name: 'BESCOM / Electricity',
    regex: RegExp(r'bescom|electricity', caseSensitive: false),
    categoryId: 'cat_utilities',
    iconName: 'bolt',
  ),
];
