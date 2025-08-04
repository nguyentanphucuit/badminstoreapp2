import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'BADMINSTORE',
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '🏸 Ứng dụng Cầu Lông - Nơi hội tụ đam mê thể thao',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Ứng dụng của chúng tôi, khách hàng sẽ tìm thấy đầy đủ sản phẩm phục vụ môn cầu lông, từ người mới bắt đầu đến vận động viên chuyên nghiệp.',
                style: TextStyle(fontSize: 16, color: Colors.brown),
              ),
              SizedBox(height: 20),
              Text(
                '🎯 Sản phẩm nổi bật:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
              ),
              SizedBox(height: 8),
              Text(
                '- Vợt cầu lông: đa dạng thương hiệu, phù hợp mọi cấp độ\n'
                '- Giày cầu lông: độ bám tốt, nhẹ, êm chân\n'
                '- Quần áo thể thao: áo, quần, váy thi đấu chuyên dụng\n'
                '- Balo & Túi: kiểu dáng thể thao, tiện lợi\n'
                '- Phụ kiện: grip, tất, băng tay, khăn thể thao, ống tay...',
                style: TextStyle(fontSize: 15, color: Colors.brown),
              ),
              SizedBox(height: 20),
              Text(
                '🛠 Dịch vụ tại cửa hàng:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
              ),
              SizedBox(height: 8),
              Text(
                '- Tư vấn sản phẩm phù hợp\n'
                '- Căng vợt theo yêu cầu\n'
                '- Giao hàng nhanh & linh hoạt\n'
                '- Hỗ trợ kỹ thuật và bảo hành uy tín',
                style: TextStyle(fontSize: 15, color: Colors.brown),
              ),
              SizedBox(height: 20),
              Text(
                '💡 Sứ mệnh của chúng tôi:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
              ),
              SizedBox(height: 8),
              Text(
                'Mang đến sản phẩm tốt nhất, dịch vụ chuyên nghiệp và tạo dựng cộng đồng đam mê thể thao là mục tiêu của chúng tôi. Chúng tôi tin rằng cầu lông không chỉ là môn thể thao mà còn là phong cách sống.',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.brown),
              ),
              SizedBox(height: 20),
              Text(
                '📍 Thông tin liên hệ:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
              ),
              SizedBox(height: 8),
              Text(
                '- Địa chỉ: 123 Nguyễn Huệ, Phường Sài Gòn, TP.HCM\n'
                '- Hotline: 0903535807\n'
                '- Email: phuctran5807@gmail.com\n'
                '- Website: www.caulongshop.vn',
                style: TextStyle(fontSize: 15, color: Colors.brown),
              ),
              SizedBox(height: 20),
              Text(
                '🎉 Cảm ơn bạn đã tin tưởng và đồng hành cùng cửa hàng cầu lông. Hãy cùng nhau chia sẻ đam mê và năng lượng tích cực nhé!',
                style: TextStyle(fontSize: 16, color: Color(0xFF8B4513)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
