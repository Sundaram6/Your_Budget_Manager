import '../../category/category_engine.dart';

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
  final String categoryId; // matches a default category id in the DB
  final String iconName;
}

/// Comprehensive Indian Bank, UPI, and Merchant SMS Patterns
/// Note: Specific merchants (Food, Shopping, Travel, Groceries) are listed BEFORE
/// payment providers/banks so that merchant detection is prioritized.
final List<MerchantPattern> kIndianMerchantPatterns = [
  // Food & Dining
  MerchantPattern(
    id: 'mer_swiggy',
    name: 'Swiggy',
    regex: RegExp(r'swiggy', caseSensitive: false),
    categoryId: CategoryEngine.catFood,
    iconName: 'fastfood',
  ),
  MerchantPattern(
    id: 'mer_zomato',
    name: 'Zomato',
    regex: RegExp(r'zomato', caseSensitive: false),
    categoryId: CategoryEngine.catFood,
    iconName: 'restaurant',
  ),

  // Groceries & Quick Commerce
  MerchantPattern(
    id: 'mer_blinkit',
    name: 'Blinkit',
    regex: RegExp(r'blinkit|grofers', caseSensitive: false),
    categoryId: CategoryEngine.catGroceries,
    iconName: 'local_grocery_store',
  ),
  MerchantPattern(
    id: 'mer_zepto',
    name: 'Zepto',
    regex: RegExp(r'zepto', caseSensitive: false),
    categoryId: CategoryEngine.catGroceries,
    iconName: 'shopping_basket',
  ),
  MerchantPattern(
    id: 'mer_instamart',
    name: 'Instamart',
    regex: RegExp(r'instamart', caseSensitive: false),
    categoryId: CategoryEngine.catGroceries,
    iconName: 'storefront',
  ),
  MerchantPattern(
    id: 'mer_bigbasket',
    name: 'BigBasket',
    regex: RegExp(r'bigbasket', caseSensitive: false),
    categoryId: CategoryEngine.catGroceries,
    iconName: 'shopping_cart',
  ),

  // Transport & Travel
  MerchantPattern(
    id: 'mer_uber',
    name: 'Uber',
    regex: RegExp(r'uber', caseSensitive: false),
    categoryId: CategoryEngine.catTransport,
    iconName: 'directions_car',
  ),
  MerchantPattern(
    id: 'mer_ola',
    name: 'Ola',
    regex: RegExp(r'ola', caseSensitive: false),
    categoryId: CategoryEngine.catTransport,
    iconName: 'local_taxi',
  ),

  // Shopping & Ecommerce
  MerchantPattern(
    id: 'mer_amazon',
    name: 'Amazon',
    regex: RegExp(r'amazon', caseSensitive: false),
    categoryId: CategoryEngine.catShopping,
    iconName: 'shopping_cart',
  ),
  MerchantPattern(
    id: 'mer_flipkart',
    name: 'Flipkart',
    regex: RegExp(r'flipkart', caseSensitive: false),
    categoryId: CategoryEngine.catShopping,
    iconName: 'shopping_bag',
  ),
  MerchantPattern(
    id: 'mer_myntra',
    name: 'Myntra',
    regex: RegExp(r'myntra', caseSensitive: false),
    categoryId: CategoryEngine.catShopping,
    iconName: 'checkroom',
  ),

  // Entertainment & Subscriptions
  MerchantPattern(
    id: 'mer_netflix',
    name: 'Netflix',
    regex: RegExp(r'netflix', caseSensitive: false),
    categoryId: CategoryEngine.catEntertainment,
    iconName: 'movie',
  ),
  MerchantPattern(
    id: 'mer_spotify',
    name: 'Spotify',
    regex: RegExp(r'spotify', caseSensitive: false),
    categoryId: CategoryEngine.catEntertainment,
    iconName: 'music_note',
  ),
  MerchantPattern(
    id: 'mer_bookmyshow',
    name: 'BookMyShow',
    regex: RegExp(r'bookmyshow|bms', caseSensitive: false),
    categoryId: CategoryEngine.catEntertainment,
    iconName: 'confirmation_number',
  ),

  // Utilities & Telecom
  MerchantPattern(
    id: 'mer_jio',
    name: 'Jio',
    regex: RegExp(r'jio', caseSensitive: false),
    categoryId: CategoryEngine.catUtilities,
    iconName: 'phone_android',
  ),
  MerchantPattern(
    id: 'mer_airtel',
    name: 'Airtel',
    regex: RegExp(r'airtel', caseSensitive: false),
    categoryId: CategoryEngine.catUtilities,
    iconName: 'wifi',
  ),
  MerchantPattern(
    id: 'mer_bescom',
    name: 'BESCOM / Electricity',
    regex: RegExp(r'bescom|electricity', caseSensitive: false),
    categoryId: CategoryEngine.catUtilities,
    iconName: 'bolt',
  ),

  // Payment Wallets & Apps
  MerchantPattern(
    id: 'mer_paytm',
    name: 'Paytm',
    regex: RegExp(r'paytm', caseSensitive: false),
    categoryId: CategoryEngine.catUtilities,
    iconName: 'account_balance_wallet',
  ),
  MerchantPattern(
    id: 'mer_phonepe',
    name: 'PhonePe',
    regex: RegExp(r'phonepe', caseSensitive: false),
    categoryId: CategoryEngine.catUtilities,
    iconName: 'account_balance_wallet',
  ),
  MerchantPattern(
    id: 'mer_gpay',
    name: 'Google Pay',
    regex: RegExp(r'gpay|google pay', caseSensitive: false),
    categoryId: CategoryEngine.catUtilities,
    iconName: 'account_balance_wallet',
  ),

  // Banks & Financial Institutions
  MerchantPattern(
    id: 'mer_hdfc',
    name: 'HDFC Bank',
    regex: RegExp(r'hdfc|hdfcbank', caseSensitive: false),
    categoryId: CategoryEngine.catUtilities,
    iconName: 'account_balance',
  ),
  MerchantPattern(
    id: 'mer_icici',
    name: 'ICICI Bank',
    regex: RegExp(r'icici|icicibank', caseSensitive: false),
    categoryId: CategoryEngine.catUtilities,
    iconName: 'account_balance',
  ),
  MerchantPattern(
    id: 'mer_sbi',
    name: 'SBI Bank',
    regex: RegExp(r'sbi|state bank|sbicard', caseSensitive: false),
    categoryId: CategoryEngine.catUtilities,
    iconName: 'account_balance',
  ),
  MerchantPattern(
    id: 'mer_axis',
    name: 'Axis Bank',
    regex: RegExp(r'axis|axisbank', caseSensitive: false),
    categoryId: CategoryEngine.catUtilities,
    iconName: 'account_balance',
  ),
];
