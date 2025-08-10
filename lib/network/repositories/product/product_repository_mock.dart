import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/category_response.dart';
import 'package:silvercart/models/product_request.dart';
import 'package:silvercart/models/product_response.dart';
import 'package:silvercart/models/product_search_request.dart';
import 'package:silvercart/models/product_search_response.dart';
import 'package:silvercart/models/product_detail_response.dart';
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

  @override
  Future<BaseResponse<ProductSearchResponse>> searchProducts(ProductSearchRequest request) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock product search response based on the provided structure
    final mockResponse = ProductSearchResponse(
      message: "Product list retrieved successfully.",
      data: ProductSearchData(
        totalItems: 1,
        page: 1,
        pageSize: 10,
        items: [
          SearchProductItem(
            id: "9595F0E3-A617-4041-4434-08DDD50D48E5",
            name: "Gậy chống cao cấp Drive Medical",
            brand: "Drive Medical",
            price: 350000,
            description: "Gậy chống bốn chân chắc chắn, có điều chỉnh độ cao, giúp người già di chuyển an toàn hơn.",
            imageUrl: "https://example.com/images/gay-chong-den.jpg",
            categories: [
              SearchProductCategory(
                id: "E76759AA-CFD4-4A52-7C96-08DDD50B5C9B",
                code: "mobility_aids",
                description: "Các dụng cụ hỗ trợ di chuyển như gậy, xe lăn, khung tập đi",
                label: "Hỗ trợ di chuyển",
                type: 0,
                listOfValueId: "",
              ),
              SearchProductCategory(
                id: "E5669704-476C-47CC-7C9B-08DDD50B5C9B",
                code: "walking_cane",
                description: "Gậy giúp người già giữ thăng bằng khi đi bộ",
                label: "Gậy chống",
                type: 0,
                listOfValueId: "",
              ),
            ],
          ),
        ],
      ),
    );

    return BaseResponse.success(data: mockResponse);
  }

  @override
  Future<BaseResponse<ProductDetailResponse>> getProductDetail(String id) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock product detail response based on the provided structure
    final mockResponse = ProductDetailResponse(
      message: "Get product successfully",
      data: ProductDetailData(
        id: "9595f0e3-a617-4041-4434-08ddd50d48e5",
        name: "Gậy chống cao cấp Drive Medical",
        brand: "Drive Medical",
        description: "Gậy chống bốn chân chắc chắn, có điều chỉnh độ cao, giúp người già di chuyển an toàn hơn.",
        videoPath: "https://example.com/videos/gay-chong.mp4",
        weight: "5",
        height: "90",
        length: "15",
        width: "10",
        manufactureDate: DateTime.parse("2025-06-01T00:00:00+00:00"),
        expirationDate: DateTime.parse("2030-06-01T00:00:00+00:00"),
        categories: [
          ProductDetailCategory(
            id: "e76759aa-cfd4-4a52-7c96-08ddd50b5c9b",
            code: "mobility_aids",
            description: "Các dụng cụ hỗ trợ di chuyển như gậy, xe lăn, khung tập đi",
            label: "Hỗ trợ di chuyển",
            type: 0,
            listOfValueId: "e83fdb81-1ca6-49da-bd91-f42ce99fd8ee",
          ),
          ProductDetailCategory(
            id: "e5669704-476c-47cc-7c9b-08ddd50b5c9b",
            code: "walking_cane",
            description: "Gậy giúp người già giữ thăng bằng khi đi bộ",
            label: "Gậy chống",
            type: 0,
            listOfValueId: "bcf673f9-38e1-4fc1-80b3-08ddd50b9acd",
          ),
        ],
        productVariants: [
          ProductVariant(
            id: "a1100519-4f22-4f0a-2b37-08ddd50d48f1",
            price: 350000,
            discount: 5,
            stock: 20,
            isActive: true,
            productImages: [
              ProductVariantImage(
                id: "e002e9bd-240f-4e1a-f5c5-08ddd50d48f8",
                url: "https://example.com/images/gay-chong-den.jpg",
              ),
            ],
            productVariantValues: [
              ProductVariantValue(
                id: "b413d7c1-484e-48b2-7969-08ddd50d48fe",
                valueId: "2bd17f8d-3395-430b-7cad-08ddd50b5c9b",
                valueCode: "red",
                valueLabel: "Đỏ",
              ),
              ProductVariantValue(
                id: "9d4afe96-538b-4eae-796a-08ddd50d48fe",
                valueId: "c1310e35-e694-4734-7cb3-08ddd50b5c9b",
                valueCode: "M",
                valueLabel: "Medium",
              ),
            ],
          ),
          ProductVariant(
            id: "665c726b-e9f7-4e5b-2b38-08ddd50d48f1",
            price: 360000,
            discount: 4,
            stock: 15,
            isActive: true,
            productImages: [
              ProductVariantImage(
                id: "3b87df3d-ce4d-4ae5-f5c6-08ddd50d48f8",
                url: "https://example.com/images/gay-chong-xam.jpg",
              ),
            ],
            productVariantValues: [
              ProductVariantValue(
                id: "4018216e-2403-4044-796b-08ddd50d48fe",
                valueId: "f69617e1-3431-4b02-7caf-08ddd50b5c9b",
                valueCode: "green",
                valueLabel: "Xanh lá",
              ),
              ProductVariantValue(
                id: "24be26ee-ff9b-42fb-796c-08ddd50d48fe",
                valueId: "bec099cc-5331-4393-7cb4-08ddd50b5c9b",
                valueCode: "L",
                valueLabel: "Large",
              ),
            ],
          ),
        ],
        styles: [
          ProductStyle(
            listOfValueId: "7590b101-715d-4f64-80b4-08ddd50b9acd",
            label: "Màu sắc",
            options: [
              ProductStyleOption(
                id: "2bd17f8d-3395-430b-7cad-08ddd50b5c9b",
                label: "Đỏ",
              ),
              ProductStyleOption(
                id: "f69617e1-3431-4b02-7caf-08ddd50b5c9b",
                label: "Xanh lá",
              ),
            ],
          ),
          ProductStyle(
            listOfValueId: "b65cc639-34a9-473a-80b5-08ddd50b9acd",
            label: "Kích thước",
            options: [
              ProductStyleOption(
                id: "c1310e35-e694-4734-7cb3-08ddd50b5c9b",
                label: "Medium",
              ),
              ProductStyleOption(
                id: "bec099cc-5331-4393-7cb4-08ddd50b5c9b",
                label: "Large",
              ),
            ],
          ),
        ],
      ),
    );

    return BaseResponse.success(data: mockResponse);
  }
}