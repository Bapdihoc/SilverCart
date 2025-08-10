import '../../../core/models/base_response.dart';
import '../../../models/category_list_response.dart';
import '../../../models/root_category_response.dart';
import 'category_repository.dart';

class CategoryRepositoryMock implements CategoryRepository {
  @override
  Future<BaseResponse<CategoryListResponse>> getListCategory() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data based on the provided response structure
    final mockResponse = CategoryListResponse(
      message: "Category getlist successfully",
      data: [
        Category(
          id: "bcf673f9-38e1-4fc1-80b3-08ddd50b9acd",
          label: "Hỗ trợ di chuyển",
          note: "mobility_aids",
          type: 0,
          values: [
            CategoryValue(
              id: "e5669704-476c-47cc-7c9b-08ddd50b5c9b",
              code: "walking_cane",
              description: "Gậy giúp người già giữ thăng bằng khi đi bộ",
              label: "Gậy chống",
              type: 0,
              childrenId: null,
              childrentLabel: null,
            ),
            CategoryValue(
              id: "e5669704-476c-47cc-7c9b-08ddd50b5c9c",
              code: "wheelchair",
              description: "Xe lăn cho người khó di chuyển",
              label: "Xe lăn",
              type: 0,
              childrenId: null,
              childrentLabel: null,
            ),
          ],
        ),
        Category(
          id: "bcf673f9-38e1-4fc1-80b3-08ddd50b9ace",
          label: "Chăm sóc sức khỏe",
          note: "health_care",
          type: 0,
          values: [
            CategoryValue(
              id: "e5669704-476c-47cc-7c9b-08ddd50b5c9d",
              code: "blood_pressure_monitor",
              description: "Máy đo huyết áp tự động",
              label: "Máy đo huyết áp",
              type: 0,
              childrenId: null,
              childrentLabel: null,
            ),
            CategoryValue(
              id: "e5669704-476c-47cc-7c9b-08ddd50b5c9e",
              code: "thermometer",
              description: "Nhiệt kế điện tử",
              label: "Nhiệt kế",
              type: 0,
              childrenId: null,
              childrentLabel: null,
            ),
          ],
        ),
        Category(
          id: "bcf673f9-38e1-4fc1-80b3-08ddd50b9acf",
          label: "Thực phẩm bổ dưỡng",
          note: "nutrition",
          type: 0,
          values: [
            CategoryValue(
              id: "e5669704-476c-47cc-7c9b-08ddd50b5c9f",
              code: "supplements",
              description: "Thực phẩm chức năng cho người cao tuổi",
              label: "Thực phẩm chức năng",
              type: 0,
              childrenId: null,
              childrentLabel: null,
            ),
            CategoryValue(
              id: "e5669704-476c-47cc-7c9b-08ddd50b5ca0",
              code: "protein_powder",
              description: "Bột protein tăng cường sức khỏe",
              label: "Bột protein",
              type: 0,
              childrenId: null,
              childrentLabel: null,
            ),
          ],
        ),
      ],
    );

    return BaseResponse.success(data: mockResponse);
  }

  @override
  Future<BaseResponse<RootCategoryResponse>> getRootListValueCategory() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data based on the provided response structure
    final mockResponse = RootCategoryResponse(
      message: "Category getlist successfully",
      data: [
        RootCategory(
          id: "2b2d5572-8327-4dee-7c95-08ddd50b5c9b",
          code: "health_care",
          description: "Các sản phẩm và dịch vụ chăm sóc sức khỏe cho người cao tuổi",
          label: "Chăm sóc sức khỏe",
          type: 0,
          childrenId: "bcf673f9-38e1-4fc1-80b3-08ddd50b9acd",
          childrentLabel: "Hỗ trợ di chuyển",
        ),
        RootCategory(
          id: "e76759aa-cfd4-4a52-7c96-08ddd50b5c9b",
          code: "mobility_aids",
          description: "Các dụng cụ hỗ trợ di chuyển như gậy, xe lăn, khung tập đi",
          label: "Hỗ trợ di chuyển",
          type: 0,
          childrenId: null,
          childrentLabel: null,
        ),
        RootCategory(
          id: "3c3e5572-8327-4dee-7c95-08ddd50b5c9c",
          code: "nutrition",
          description: "Thực phẩm và đồ uống bổ dưỡng cho người cao tuổi",
          label: "Thực phẩm bổ dưỡng",
          type: 0,
          childrenId: null,
          childrentLabel: null,
        ),
        RootCategory(
          id: "4d4f5572-8327-4dee-7c95-08ddd50b5c9d",
          code: "home_safety",
          description: "Thiết bị an toàn trong nhà cho người cao tuổi",
          label: "An toàn gia đình",
          type: 0,
          childrenId: null,
          childrentLabel: null,
        ),
      ],
    );

    return BaseResponse.success(data: mockResponse);
  }

  @override
  Future<BaseResponse<RootCategoryResponse>> getListValueCategoryById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Mock subcategory data based on parent ID
    List<RootCategory> subcategories = [];
    
    switch (id) {
      case "2b2d5572-8327-4dee-7c95-08ddd50b5c9b": // Chăm sóc sức khỏe
        subcategories = [
          RootCategory(
            id: "sub-health-1",
            code: "blood_pressure",
            description: "Thiết bị đo huyết áp và theo dõi sức khỏe tim mạch",
            label: "Đo huyết áp",
            type: 1,
            childrenId: "sub-sub-health-1",
            childrentLabel: "Máy đo tự động",
          ),
          RootCategory(
            id: "sub-health-2", 
            code: "diabetes_care",
            description: "Thiết bị chăm sóc bệnh tiểu đường",
            label: "Chăm sóc tiểu đường",
            type: 1,
            childrenId: null,
            childrentLabel: null,
          ),
          RootCategory(
            id: "sub-health-3",
            code: "medication_management",
            description: "Hộp đựng thuốc và quản lý thuốc",
            label: "Quản lý thuốc",
            type: 1,
            childrenId: null,
            childrentLabel: null,
          ),
        ];
        break;
        
      case "e76759aa-cfd4-4a52-7c96-08ddd50b5c9b": // Hỗ trợ di chuyển
        subcategories = [
          RootCategory(
            id: "sub-mobility-1",
            code: "walking_aids",
            description: "Gậy chống và thiết bị hỗ trợ đi bộ",
            label: "Hỗ trợ đi bộ",
            type: 1,
            childrenId: null,
            childrentLabel: null,
          ),
          RootCategory(
            id: "sub-mobility-2",
            code: "wheelchairs",
            description: "Xe lăn và thiết bị di chuyển",
            label: "Xe lăn",
            type: 1,
            childrenId: "sub-sub-mobility-1",
            childrentLabel: "Xe lăn điện",
          ),
          RootCategory(
            id: "sub-mobility-3",
            code: "bathroom_safety",
            description: "Thiết bị an toàn phòng tắm",
            label: "An toàn phòng tắm",
            type: 1,
            childrenId: null,
            childrentLabel: null,
          ),
        ];
        break;
        
      case "sub-sub-health-1": // Máy đo tự động (3rd level)
        subcategories = [
          RootCategory(
            id: "sub-sub-health-1-1",
            code: "automatic_bp_monitor",
            description: "Máy đo huyết áp tự động cổ tay",
            label: "Đo cổ tay",
            type: 2,
            childrenId: null,
            childrentLabel: null,
          ),
          RootCategory(
            id: "sub-sub-health-1-2",
            code: "arm_bp_monitor",
            description: "Máy đo huyết áp tự động cánh tay",
            label: "Đo cánh tay",
            type: 2,
            childrenId: null,
            childrentLabel: null,
          ),
        ];
        break;
        
      case "sub-sub-mobility-1": // Xe lăn điện (3rd level)
        subcategories = [
          RootCategory(
            id: "sub-sub-mobility-1-1",
            code: "electric_wheelchair_indoor",
            description: "Xe lăn điện sử dụng trong nhà",
            label: "Xe lăn điện trong nhà",
            type: 2,
            childrenId: null,
            childrentLabel: null,
          ),
          RootCategory(
            id: "sub-sub-mobility-1-2",
            code: "electric_wheelchair_outdoor",
            description: "Xe lăn điện sử dụng ngoài trời",
            label: "Xe lăn điện ngoài trời",
            type: 2,
            childrenId: null,
            childrentLabel: null,
          ),
        ];
        break;
        
      default:
        // No subcategories found
        subcategories = [];
    }

    final mockResponse = RootCategoryResponse(
      message: "Category getlist successfully",
      data: subcategories,
    );

    return BaseResponse.success(data: mockResponse);
  }
}
