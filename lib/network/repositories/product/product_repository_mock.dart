import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/category_response.dart';
import 'package:silvercart/models/product_request.dart';
import 'package:silvercart/models/product_response.dart';
import 'package:silvercart/network/repositories/product/product_repository.dart';

@LazySingleton(as: ProductRepository, env: [Environment.dev])
class ProductRepositoryMock implements ProductRepository {
  @override
  Future<BaseResponse<ProductResponse>> getProducts() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Mock product data
    final mockProducts = [
      Product(
        id: '1',
        productName: 'Gạo ST25 cao cấp 5kg',
        description: 'Gạo thơm ngon, giàu dinh dưỡng cho người cao tuổi',
        videoPath: '',
        productType: 'FOOD',
        creationDate: DateTime.now(),
        productCategories: [
          ProductCategory(id: '1', categoryName: 'Thực phẩm'),
        ],
        variants: [
          Variant(
            id: '1',
            variantName: '5kg',
            isActive: true,
            productItems: [
              ProductItem(
                id: '1',
                sku: 'GAO-ST25-5KG',
                originalPrice: 150000,
                discountedPrice: 125000,
                weight: 5000,
                stock: 50,
                isActive: true,
                productImages: [
                  ProductImage(
                    id: '1',
                    imagePath: 'https://example.com/gao-st25.jpg',
                    imageName: 'gao-st25.jpg',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      Product(
        id: '2',
        productName: 'Thuốc hạ huyết áp',
        description: 'Thuốc điều trị huyết áp cao, an toàn cho người già',
        videoPath: '',
        productType: 'MEDICINE',
        creationDate: DateTime.now(),
        productCategories: [
          ProductCategory(id: '2', categoryName: 'Thuốc & Sức khỏe'),
        ],
        variants: [
          Variant(
            id: '2',
            variantName: 'Hộp 30 viên',
            isActive: true,
            productItems: [
              ProductItem(
                id: '2',
                sku: 'THUOC-HUYET-AP-30',
                originalPrice: 85000,
                discountedPrice: 85000,
                weight: 50,
                stock: 100,
                isActive: true,
                productImages: [
                  ProductImage(
                    id: '2',
                    imagePath: 'https://example.com/thuoc-huyet-ap.jpg',
                    imageName: 'thuoc-huyet-ap.jpg',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      Product(
        id: '3',
        productName: 'Dầu gội đầu dành cho người già',
        description: 'Dầu gội dịu nhẹ, không gây kích ứng da đầu',
        videoPath: '',
        productType: 'PERSONAL_CARE',
        creationDate: DateTime.now(),
        productCategories: [
          ProductCategory(id: '3', categoryName: 'Chăm sóc cá nhân'),
        ],
        variants: [
          Variant(
            id: '3',
            variantName: 'Chai 500ml',
            isActive: true,
            productItems: [
              ProductItem(
                id: '3',
                sku: 'DAU-GOI-500ML',
                originalPrice: 55000,
                discountedPrice: 45000,
                weight: 500,
                stock: 75,
                isActive: true,
                productImages: [
                  ProductImage(
                    id: '3',
                    imagePath: 'https://example.com/dau-goi.jpg',
                    imageName: 'dau-goi.jpg',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      Product(
        id: '4',
        productName: 'Nồi cơm điện cao cấp',
        description: 'Nồi cơm điện thông minh, dễ sử dụng cho người già',
        videoPath: '',
        productType: 'HOUSEHOLD',
        creationDate: DateTime.now(),
        productCategories: [
          ProductCategory(id: '4', categoryName: 'Gia dụng'),
        ],
        variants: [
          Variant(
            id: '4',
            variantName: '1.8L',
            isActive: true,
            productItems: [
              ProductItem(
                id: '4',
                sku: 'NOI-COM-1.8L',
                originalPrice: 1250000,
                discountedPrice: 1250000,
                weight: 3000,
                stock: 20,
                isActive: true,
                productImages: [
                  ProductImage(
                    id: '4',
                    imagePath: 'https://example.com/noi-com.jpg',
                    imageName: 'noi-com.jpg',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      Product(
        id: '5',
        productName: 'Áo len dành cho người cao tuổi',
        description: 'Áo len ấm áp, thoải mái cho mùa đông',
        videoPath: '',
        productType: 'CLOTHING',
        creationDate: DateTime.now(),
        productCategories: [
          ProductCategory(id: '5', categoryName: 'Quần áo'),
        ],
        variants: [
          Variant(
            id: '5',
            variantName: 'Size L',
            isActive: true,
            productItems: [
              ProductItem(
                id: '5',
                sku: 'AO-LEN-L',
                originalPrice: 320000,
                discountedPrice: 320000,
                weight: 300,
                stock: 30,
                isActive: true,
                productImages: [
                  ProductImage(
                    id: '5',
                    imagePath: 'https://example.com/ao-len.jpg',
                    imageName: 'ao-len.jpg',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      Product(
        id: '6',
        productName: 'Máy đo huyết áp tự động',
        description: 'Máy đo huyết áp chính xác, dễ sử dụng',
        videoPath: '',
        productType: 'ELECTRONIC',
        creationDate: DateTime.now(),
        productCategories: [
          ProductCategory(id: '6', categoryName: 'Điện tử'),
        ],
        variants: [
          Variant(
            id: '6',
            variantName: 'Tự động',
            isActive: true,
            productItems: [
              ProductItem(
                id: '6',
                sku: 'MAY-DO-HUYET-AP',
                originalPrice: 1000000,
                discountedPrice: 850000,
                weight: 500,
                stock: 15,
                isActive: true,
                productImages: [
                  ProductImage(
                    id: '6',
                    imagePath: 'https://example.com/may-do-huyet-ap.jpg',
                    imageName: 'may-do-huyet-ap.jpg',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];

    return BaseResponse.success(
      data: ProductResponse(
        pageNumber: 1,
        pageSize: 10,
        totalNumberOfPages: 1,
        totalNumberOfRecords: mockProducts.length,
        results: mockProducts,
      ),
    );
  }

  @override
  Future<BaseResponse<Product>> getProduct(int id) async{
    return BaseResponse.success(
      data: Product(
        id: '1',
        productName: 'Gạo ST25 cao cấp 5kg',
        description: 'Gạo thơm ngon, giàu dinh dưỡng cho người cao tuổi',
        videoPath: '',
        productType: 'FOOD',
        creationDate: DateTime.now(),
        productCategories: [
          ProductCategory(id: '1', categoryName: 'Thực phẩm'),
        ],
        variants: [
          Variant(
            id: '1',
            variantName: '5kg',
            isActive: true,
            productItems: [
              ProductItem(
                id: '1',
                sku: 'GAO-ST25-5KG',
                originalPrice: 150000,
                discountedPrice: 125000,
                weight: 5000,
                stock: 50,
                isActive: true,
                productImages: [
                  ProductImage(
                    id: '1',
                    imagePath: 'https://example.com/gao-st25.jpg',
                    imageName: 'gao-st25.jpg',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Future<BaseResponse<CategoryResponse>> getProductCategories(ProductRequest request) async {
    return BaseResponse.success(
      data: CategoryResponse(
        pageNumber: 1,
        pageSize: 10,
        totalNumberOfPages: 1,
        totalNumberOfRecords: 10,
        results: [
          CategoryModel(
            id: '1',
            name: 'Thực phẩm',
            description: 'Thực phẩm',
            parentCategoryId: '1',
            parentCategoryName: 'Thực phẩm',
            creationDate: DateTime.now(),
            productCount: 10,
            status: 'ACTIVE',
          ),
        ],
      ),
    );
  }

  @override
  Future<BaseResponse<CategoryModel>> getProductCategory(int id) async {
    return BaseResponse.success(
      data:  CategoryModel(
            id: '1',
            name: 'Thực phẩm',
            description: 'Thực phẩm',
            parentCategoryId: '1',
            parentCategoryName: 'Thực phẩm',
            creationDate: DateTime.now(),
            productCount: 10,
            status: 'ACTIVE',
          ),
    );
  }
}