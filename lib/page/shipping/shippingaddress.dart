import 'package:badminstoreapp/data/model/usermodel.dart';
import 'package:flutter/material.dart';
import '../../data/model/provincemodel.dart';
import '../../data/model/wardmodel.dart';
import '../../data/data/tinhthanhdata.dart';
import '../../data/data/phuongxadata.dart';
import '../../data/model/usermodel.dart';
import 'payment.dart';

class ShippingAddressScreen extends StatefulWidget {
  final double subtotal; // Thêm parameter để nhận subtotal
  final UserModel? user;
  
  const ShippingAddressScreen({Key? key, required this.subtotal, this.user}) : super(key: key);

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  ProvinceModel? _selectedProvince;
  WardModel? _selectedWard;
  
  // Danh sách tỉnh/thành phố và phường/xã
  List<ProvinceModel> _provinces = [];
  List<WardModel> _allWards = [];
  
  // Data loaders
  final TinhThanhData _tinhThanhData = TinhThanhData();
  final PhuongXaData _phuongXaData = PhuongXaData();
  
  // Loading states
  bool _isLoadingProvinces = true;
  bool _isLoadingWards = true;
  
  // Lấy danh sách phường/xã theo id tỉnh thành
  List<WardModel> get _filteredWards {
    if (_selectedProvince == null) return [];
    return _allWards.where((ward) => ward.idTinhThanh == _selectedProvince!.id).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load provinces
      final provinces = await _tinhThanhData.loadData();
      setState(() {
        _provinces = provinces;
        _isLoadingProvinces = false;
      });
      
      // Load wards
      final wards = await _phuongXaData.loadData();
      setState(() {
        _allWards = wards;
        _isLoadingWards = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoadingProvinces = false;
        _isLoadingWards = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFB382), // Màu cam nhạt
              Color(0xFFFF8C42), // Màu cam đậm
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF8B4513),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo_shopname.png',
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              
              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgressStep(1, 'Giao hàng', true),
                    _buildProgressLine(true),
                    _buildProgressStep(2, 'Thanh toán', false),
                    _buildProgressLine(false),
                    _buildProgressStep(3, 'Xác nhận', false),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Form content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text(
                          'Thông tin giao hàng',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Họ và tên người nhận
                        const Text(
                          'Họ và tên người nhận',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'Nhập họ và tên người nhận',
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Số điện thoại
                        const Text(
                          'Số điện thoại',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _phoneController,
                          hintText: 'Ví dụ: 0979123xxx (10 ký tự số)',
                          keyboardType: TextInputType.phone,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Tỉnh/Thành phố
                        const Text(
                          'Tỉnh/ thành phố',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _isLoadingProvinces
                            ? _buildLoadingDropdown('Đang tải dữ liệu...')
                            : _buildDropdown<ProvinceModel>(
                                value: _selectedProvince,
                                hint: 'Chọn tỉnh / thành phố',
                                items: _provinces,
                                displayText: (province) => province.tenTinhThanh ?? '',
                                onChanged: (value) {
                                  setState(() {
                                    _selectedProvince = value;
                                    _selectedWard = null; // Reset ward khi đổi tỉnh
                                  });
                                },
                              ),
                        
                        const SizedBox(height: 20),
                        
                        // Phường/Xã
                        const Text(
                          'Phường/Xã',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _isLoadingWards
                            ? _buildLoadingDropdown('Đang tải dữ liệu...')
                            : _buildDropdown<WardModel>(
                                value: _selectedWard,
                                hint: _selectedProvince == null
                                    ? 'Vui lòng chọn tỉnh/thành phố trước'
                                    : 'Chọn phường/xã',
                                items: _filteredWards,
                                displayText: (ward) => ward.tenPhuongXa ?? '',
                                onChanged: _selectedProvince == null
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _selectedWard = value;
                                        });
                                      },
                              ),
                        
                        const SizedBox(height: 20),
                        
                        // Số nhà/Tên đường
                        const Text(
                          'Số nhà/Tên đường',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _addressController,
                          hintText: 'Nhập số nhà/tên đường',
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Xác nhận địa chỉ button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF8C42),
                                Color(0xFFFF6B1A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // Truyền subtotal tới PaymentScreen
                              _validateAndConfirm();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Xác nhận địa chỉ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateAndConfirm() {
    if (_nameController.text.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập họ và tên người nhận');
      return;
    }
    
    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập số điện thoại');
      return;
    }
    
    if (_selectedProvince == null) {
      _showErrorSnackBar('Vui lòng chọn tỉnh/thành phố');
      return;
    }
    
    if (_selectedWard == null) {
      _showErrorSnackBar('Vui lòng chọn phường/xã');
      return;
    }
    
    if (_addressController.text.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập số nhà/tên đường');
      return;
    }
    
    // Validation passed - handle address confirmation
    _showSuccessSnackBar('Địa chỉ đã được xác nhận thành công!');
    
    // Here you can navigate to the next screen or save the address
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          subtotal: widget.subtotal,
          user: widget.user,
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildProgressStep(int step, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : const Color(0xFFFF8C42),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.green : const Color(0xFF8B4513),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? Colors.green : Colors.grey.withOpacity(0.5),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFF8B4513),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Color(0xFF8B4513).withOpacity(0.7),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDropdown(String text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: Color(0xFF8B4513).withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) displayText,
    required Function(T?)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        hint: Text(
          hint,
          style: TextStyle(
            color: Color(0xFF8B4513).withOpacity(0.7),
          ),
        ),
        style: const TextStyle(
          color: Color(0xFF8B4513),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        dropdownColor: const Color(0xFFFFB382),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              displayText(item),
              style: const TextStyle(
                color: Color(0xFF8B4513),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}