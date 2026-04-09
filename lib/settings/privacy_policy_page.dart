import 'package:flutter/material.dart';
import '../utils/app_localization.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.t('Privacy Policy', 'Chính sách bảo mật'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            context.t(
              'PRIVACY AND POLICY FOR SWIN CREDIT MOBILE APPLICATION',
              'CHÍNH SÁCH QUYỀN RIÊNG TƯ ỨNG DỤNG SWIN CREDIT',
            ),
            context.t(
              'Effective Date: x Month, 2025',
              'Ngày hiệu lực: Tháng x, 2025',
            ),
          ),

          _buildSection(
            context.t('Introduction', 'Giới thiệu'),
            context.t(
              'This Privacy Policy ("Policy") explains how Swin Credit ("we," "us," "our") collects, uses, shares, and protects the information you provide when using our mobile application ("App"). The App provides a hybrid credit scoring service that combines traditional and alternative data for financial assessment in Vietnam.\n\nBy using the App, you consent to the practices described in this Policy. We reserve the right to update this Policy at any time. Significant changes will be communicated to you via the App or email. We recommend reviewing this page periodically.',
              'Chính sách Quyền riêng tư này ("Chính sách") giải thích cách Swin Credit ("chúng tôi", "của chúng tôi") thu thập, sử dụng, chia sẻ và bảo vệ thông tin mà Người dùng cung cấp khi sử dụng ứng dụng di động ("Ứng dụng") của chúng tôi. Ứng dụng cung cấp dịch vụ chấm điểm tín dụng kết hợp giữa dữ liệu truyền thống và dữ liệu thay thế để đánh giá tài chính tại Việt Nam.\n\nBằng việc sử dụng Ứng dụng, Người dùng đồng ý với các thông lệ được mô tả trong Chính sách này. Chúng tôi bảo lưu quyền cập nhật Chính sách này bất kỳ lúc nào. Mọi thay đổi quan trọng sẽ được thông báo đến Người dùng qua Ứng dụng hoặc email. Chúng tôi khuyến nghị Người dùng nên thường xuyên xem lại Chính sách này.',
            ),
          ),

          _buildSection(
            context.t('Information We Collect', 'Thông Tin Chúng Tôi Thu Thập'),
            context.t(
              'When you use the App, we may collect the following data:\n\n'
                  '• Personal Information: Name, email address, phone number, date of birth, national ID number, address, employment details, income information, and education level.\n'
                  '• Identity Verification (eKYC) Data: Photos of your national ID card (front and back) and a selfie for facial verification.\n'
                  '• Financial & Credit Data: Loan history, repayment behavior, debt-to-income ratio, credit utilization, and other financial indicators.\n'
                  '• Device Information: IP address, device type, operating system, unique device identifiers.\n'
                  '• App Usage Data: Features accessed, time spent, interaction patterns.\n'
                  '• Location Data: Only if you grant permission, for location-based services.\n'
                  '• Other Data: Preferences, loan purpose, and any information you voluntarily provide during the loan application process.',
              'Khi sử dụng Ứng dụng, chúng tôi có thể thu thập các dữ liệu sau:\n\n'
                  '• Thông tin cá nhân: Họ tên, địa chỉ email, số điện thoại, ngày tháng năm sinh, số căn cước công dân, địa chỉ, thông tin nghề nghiệp, thu nhập và trình độ học vấn.\n'
                  '• Dữ liệu xác thực điện tử (eKYC): Ảnh chụp căn cước công dân (mặt trước và mặt sau) và ảnh chân dung để xác thực khuôn mặt.\n'
                  '• Dữ liệu tài chính và tín dụng: Lịch sử vay vốn, hành vi trả nợ, tỷ lệ nợ trên thu nhập, tỷ lệ sử dụng tín dụng và các chỉ số tài chính khác.\n'
                  '• Thông tin thiết bị: Địa chỉ IP, loại thiết bị, hệ điều hành, mã định danh duy nhất của thiết bị.\n'
                  '• Dữ liệu sử dụng Ứng dụng: Các tính năng được truy cập, thời gian sử dụng, hành vi tương tác.\n'
                  '• Dữ liệu vị trí: Chỉ được thu thập nếu Người dùng cấp quyền, nhằm phục vụ các dịch vụ dựa trên vị trí.\n'
                  '• Dữ liệu khác: Sở thích, mục đích vay vốn và bất kỳ thông tin nào Người dùng tự nguyện cung cấp trong quá trình đăng ký vay.',
            ),
          ),

          _buildSection(
            context.t('Why We Collect Your Data', 'Mục Đích Thu Thập Dữ Liệu'),
            context.t(
              'We collect and use your data to:\n\n'
                  '• Generate your hybrid credit score using traditional and alternative data.\n'
                  '• Process loan applications and determine eligibility.\n'
                  '• Verify your identity via eKYC to comply with regulations.\n'
                  '• Improve App functionality and user experience.\n'
                  '• Provide customer support and respond to inquiries.\n'
                  '• Send notifications, updates, or promotional messages (only with your consent).\n'
                  '• Conduct analytics to understand usage trends and enhance our scoring models.\n'
                  '• Ensure security, prevent fraud, and protect against unauthorized access.',
              'Chúng tôi thu thập và sử dụng dữ liệu của Người dùng nhằm:\n\n'
                  '• Tạo điểm tín dụng kết hợp dựa trên dữ liệu truyền thống và dữ liệu thay thế.\n'
                  '• Xử lý hồ sơ vay vốn và xác định tính đủ điều kiện.\n'
                  '• Xác minh danh tính qua eKYC để tuân thủ các quy định pháp luật.\n'
                  '• Cải thiện chức năng và trải nghiệm người dùng của Ứng dụng.\n'
                  '• Cung cấp hỗ trợ khách hàng và giải đáp các thắc mắc.\n'
                  '• Gửi thông báo, cập nhật hoặc tin nhắn quảng cáo (chỉ khi có sự đồng ý của Người dùng).\n'
                  '• Thực hiện phân tích để hiểu xu hướng sử dụng và nâng cao mô hình chấm điểm.\n'
                  '• Đảm bảo an ninh, ngăn chặn gian lận và bảo vệ khỏi các hành vi truy cập trái phép.',
            ),
          ),

          _buildSection(
            context.t(
              'How We Protect Your Data',
              'Biện Pháp Bảo Vệ Dữ Liệu Người Dùng',
            ),
            context.t(
              'We implement industry-standard security measures, including encryption, secure servers, and access controls, to protect your data from unauthorized access, disclosure, or modification. All data is stored and processed in controlled environments, including Dockerized containers for the machine learning model and API.',
              'Chúng tôi áp dụng các biện pháp bảo mật theo tiêu chuẩn ngành, bao gồm mã hóa, máy chủ an toàn và kiểm soát truy cập, nhằm bảo vệ dữ liệu của Người dùng khỏi các hành vi truy cập, tiết lộ hoặc sửa đổi trái phép. Toàn bộ dữ liệu được lưu trữ và xử lý trong môi trường được kiểm soát, bao gồm các container Docker hóa cho mô hình máy học và API.',
            ),
          ),

          _buildSection(
            context.t('Data Sharing and Disclosure', 'Chia Sẻ Và Tiết Lộ Dữ Liệu'),
            context.t(
              'We do not sell your personal data. We may share your information only in the following cases:\n\n'
                  '• With financial institutions or credit bureaus in Vietnam for credit assessment purposes.\n'
                  '• With third-party service providers who assist in eKYC verification, cloud hosting, or analytics (under strict confidentiality agreements).\n'
                  '• When required by law or to comply with legal processes in Vietnam.\n'
                  '• To protect our rights, users, or the public.',
              'Chúng tôi không bán dữ liệu cá nhân của Người dùng. Chúng tôi chỉ có thể chia sẻ thông tin trong các trường hợp sau:\n\n'
                  '• Với các tổ chức tài chính hoặc trung tâm thông tin tín dụng tại Việt Nam phục vụ mục đích đánh giá tín dụng.\n'
                  '• Với các nhà cung cấp dịch vụ bên thứ ba hỗ trợ xác thực eKYC, lưu trữ đám mây hoặc phân tích dữ liệu (theo các thỏa thuận bảo mật nghiêm ngặt).\n'
                  '• Khi pháp luật yêu cầu hoặc để tuân thủ các quy trình pháp lý tại Việt Nam.\n'
                  '• Để bảo vệ quyền lợi, người dùng hoặc an toàn cộng đồng của chúng tôi.',
            ),
          ),

          _buildSection(
            context.t('Permissions and Device Access', 'Quyền Truy Cập Thiết Bị'),
            context.t(
              'The App may request access to certain device features:\n\n'
                  '• Camera & Photos: For capturing ID cards and selfies during eKYC.\n'
                  '• Microphone: Only if voice-based features are used (currently not active).\n'
                  '• Location: For location-based services (if you grant permission).\n'
                  '• Storage: To upload documents or save verification results.',
              'Ứng dụng có thể yêu cầu quyền truy cập vào một số tính năng của thiết bị:\n\n'
                  '• Camera và Ảnh: Để chụp ảnh căn cước công dân và ảnh chân dung trong quá trình eKYC.\n'
                  '• Micrô: Chỉ khi sử dụng các tính năng dựa trên giọng nói (hiện chưa được kích hoạt).\n'
                  '• Vị trí: Phục vụ các dịch vụ dựa trên vị trí (nếu Người dùng cấp quyền).\n'
                  '• Bộ nhớ: Để tải lên tài liệu hoặc lưu kết quả xác thực.',
            ),
          ),

          _buildSection(
            context.t('Your Rights', 'Quyền của Người Dùng'),
            context.t(
              'Under Vietnam\'s Personal Data Protection Decree (PDPD) and applicable laws, you have the right to:\n\n'
                  '• Access, correct, or delete your personal data.\n'
                  '• Withdraw consent for data processing (where applicable).\n'
                  '• Request an explanation of automated decisions (e.g., credit score outcomes).\n'
                  '• Lodge a complaint with the relevant data protection authority.\n\n'
                  'To exercise these rights, contact us at: 104198640@student.swin.edu.au',
              'Theo Nghị định về Bảo vệ Dữ liệu Cá nhân của Việt Nam và các quy định pháp luật liên quan, Người dùng có quyền:\n\n'
                  '• Truy cập, chỉnh sửa hoặc xóa dữ liệu cá nhân của mình.\n'
                  '• Rút lại sự đồng ý đối với việc xử lý dữ liệu (nếu có).\n'
                  '• Yêu cầu giải thích về các quyết định tự động (ví dụ: kết quả điểm tín dụng).\n'
                  '• Khiếu nại đến cơ quan quản lý bảo vệ dữ liệu có thẩm quyền.\n\n'
                  'Để thực hiện các quyền này, vui lòng liên hệ chúng tôi qua địa chỉ: 104198640@student.swin.edu.au',
            ),
          ),

          _buildSection(
            context.t('Data Retention', 'Thời Gian Lưu Trữ Dữ Liệu'),
            context.t(
              'We retain your data only as long as necessary to provide the Service, comply with legal obligations, resolve disputes, or enforce agreements. eKYC data is retained in accordance with Vietnamese financial regulations.',
              'Chúng tôi lưu trữ dữ liệu của Người dùng chỉ trong thời gian cần thiết để cung cấp Dịch vụ, tuân thủ các nghĩa vụ pháp lý, giải quyết tranh chấp hoặc thực thi các thỏa thuận. Dữ liệu eKYC được lưu trữ theo quy định của pháp luật tài chính Việt Nam.',
            ),
          ),

          _buildSection(
            context.t('Third-Party Services', 'Dịch Vụ Của Bên Thứ Ba'),
            context.t(
              'Our App may integrate with third-party services (e.g., Firebase for notifications). These services have their own privacy policies, and we encourage you to review them.',
              'Ứng dụng của chúng tôi có thể tích hợp với các dịch vụ của bên thứ ba (ví dụ: Firebase cho thông báo). Các dịch vụ này có chính sách quyền riêng tư riêng, và chúng tôi khuyến khích Người dùng xem xét các chính sách đó.',
            ),
          ),

          _buildSection(
            context.t(
              'International Data Transfers',
              'Chuyển Dữ Liệu sang Quốc Tế',
            ),
            context.t(
              'Your data is processed and stored primarily in Vietnam. If transferred internationally, we ensure adequate protection as required by Vietnamese law.',
              'Dữ liệu của Người dùng được xử lý và lưu trữ chủ yếu tại Việt Nam. Trong trường hợp được chuyển ra nước ngoài, chúng tôi đảm bảo các biện pháp bảo vệ phù hợp theo yêu cầu của pháp luật Việt Nam.',
            ),
          ),

          _buildSection(
            context.t('Children\'s Privacy', 'Quyền Riêng Tư Của Trẻ Em'),
            context.t(
              'Our App is not intended for users under 18. We do not knowingly collect data from minors.',
              'Ứng dụng của chúng tôi không dành cho người dùng dưới 18 tuổi. Chúng tôi không cố ý thu thập dữ liệu từ người chưa thành niên.',
            ),
          ),

          _buildSection(
            context.t('Changes to This Policy', 'Thay Đổi Đối Với Chính Sách Này'),
            context.t(
              'We may update this Policy periodically. The updated version will be notified in the App with a revised effective date.',
              'Chúng tôi có thể cập nhật Chính sách này định kỳ. Phiên bản cập nhật sẽ được thông báo qua Ứng dụng với ngày hiệu lực sửa đổi.',
            ),
          ),

          _buildSection(
            context.t('Contact Us', 'Liên Hệ'),
            context.t(
              'If you have questions about this Policy or our data practices, contact:\n\n'
                  'Swinburne University of Technology\n'
                  'Email: 104198640@student.swin.edu.au\n'
                  'Project Supervisor: Dr. Sam Nguyen\n'
                  'Client: Mr. Khai Nguyen Nguyen Hoang',
              'Nếu Quý khách có thắc mắc về Chính sách này hoặc các hoạt động liên quan đến dữ liệu của chúng tôi, vui lòng liên hệ:\n\n'
                  'Đại học Swinburne Vietnam Hồ Chí Minh\n'
                  'Email: 104198640@student.swin.edu.au\n'
                  'Giảng viên hướng dẫn: TS. Sam Nguyễn\n'
                  'Khách hàng: Ông Nguyễn Hoàng Khải Nguyên',
            ),
          ),

          const SizedBox(height: 40),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.t(
                            'Privacy policy downloaded',
                            'Đã tải chính sách bảo mật',
                          ),
                        ),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_outlined, size: 20),
                  label: Text(context.t('Download PDF', 'Tải PDF')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4D4AF9),
                    side: const BorderSide(color: Color(0xFF4D4AF9)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check, size: 20),
                  label: Text(context.t('Accept', 'Đồng ý')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D4AF9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
