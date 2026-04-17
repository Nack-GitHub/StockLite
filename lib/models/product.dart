class Product {
  final String id;
  final String name;
  final String sku;
  final String imageUrl;
  final int stock;
  final String status;

  final String category;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.imageUrl,
    required this.stock,
    required this.status,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'imageUrl': imageUrl,
      'stock': stock,
      'status': status,
      'category': category,
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      sku: map['sku'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      stock: map['stock'] ?? 0,
      status: map['status'] ?? 'In Stock',
      category: map['category'] ?? 'General',
    );
  }
}

final List<Product> mockProducts = [
  Product(
    id: '1',
    name: 'Apex Wireless Pro',
    sku: 'HEAD-APX-001',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCBAUdylwU8gVdAdwMGh382JO-CrgEJb1lc3W8W2b3CJY0rjM0p2iuN8QTrHHXPKVUOfrZ20KYazqwLjP8xGIHr27ilse8BVx5WtuAFmtW0TiFxJ4vvX48rxkZ_cU9-W_iXnRb6ZjgqyW0nNrbT4tWFwNRgNgRwnjjqgS3LNiJ8XanFUBGMeJqV-dKdxjEraGPEgx_K8upK7kEgfvpFyglKntbUrHF-dTdMKbDA2of5Dvty63PQilVQlzN49mslchpJEJgJtXy0FTM',
    stock: 15,
    status: 'In Stock',
    category: 'Electronics',
  ),
  Product(
    id: '2',
    name: 'ErgoFlow Series X',
    sku: 'CHAIR-ERG-202',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD5htjzMm7SggJuNWoNfvISxSudMPYBzlgHEI61Pq9FqTGJXH296t-KZrkAiMBZg6idlyead-TopyL-fmHZnYhsBIlmavWcRHvDRrj_M3xJgbd1CtauL248fs0Wd8KcVBXd_KQ0Z_55qGMWHSF54DxuMekSNL3yupSI6PP8NGEd5Ha8alF8WDx8l_Y1Dza0E05pU0wgLhN7EYHvag5LO7rjcIBN0u5LbzYLVmgBC8S3TOE8qx-U3581PQ0CpSPkdKKryV2LW9_3EgQ',
    stock: 4,
    status: 'Low Stock',
    category: 'Furniture',
  ),
  Product(
    id: '3',
    name: 'Artisan Ceramic Set',
    sku: 'HOME-ART-993',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBRmFNsy9ScTXI0VqDpy73F0zUIEcwJXrFiIntj7kTl4-_0ZMeTcyZtsHkelDoLKzRbrViKm3lJIfNSuzOIAF7ImJgPU4vWmt5rNJx2Xk_BAWUWKlhPQ3PzfqrTU9D_4WJYzN4pAaZ7krmyls9gnOWpiqLO-V8B1hktpPGN7S7EmjG8vq9HGaI6T-URuYtscUSl2v5Z3dTTwZPfcGaWDR8Rd6PTnFDVRMs2L2jrectETIgFEe-CwvlFMlp0W6MUgkW9cpePSmq28fA',
    stock: 82,
    status: 'In Stock',
    category: 'Home Goods',
  ),
  Product(
    id: '4',
    name: 'Guardian Cam 4K',
    sku: 'SEC-GUA-400',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCG4BnigvL9LuRLsIWcelOdnH6wlkAvRB62OVHFbkHalYYP2GBlwjK3IaBSQtlJd-58wmXHCs3c7D8OvBRk1hpOCma5-wJZzsdDuPb4bE0QEO-8-QAAy7xraX7WZGc1tRIPNDMhV7ubFIB1mRupXwqPtzYK9keRKM0y73XRSNQ0vAYuEnn_B6ST4POaHOBfxAasoVCKpQ82noCLR_BDSxOZgoS8ZP-E9NHPUUgicfwy9MEfcDhw2JIUoiz-3TbTRYirGs26lX1sZQY',
    stock: 0,
    status: 'Out of Stock',
    category: 'Security',
  ),
];
