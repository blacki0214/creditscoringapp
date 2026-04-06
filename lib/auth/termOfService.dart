import 'package:flutter/material.dart';
import '../utils/app_localization.dart';

class TermOfServicePage extends StatelessWidget {
  const TermOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.t('Terms of Service', 'Điều khoản dịch vụ'),
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t('Terms of Service', 'Điều khoản dịch vụ'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.t(
                  'These Terms of Service ("Terms") govern your access to and use of the Swin Credit Mobile App ("App", "Service", "we", "us", or "our"). This App is developed as a university-based project for credit scoring and loan assessment simulation purposes for users in Vietnam.\n\nBy creating an account or using the App, you agree to be bound by these Terms. If you do not agree, you must not use the App.',
                  'Các Điều khoản Dịch vụ này ("Điều khoản") điều chỉnh quyền truy cập và sử dụng Ứng dụng di động Swin Credit ("Ứng dụng", "Dịch vụ", "chúng tôi", hoặc "của chúng tôi"). Ứng dụng này được phát triển như một dự án trong khuôn khổ đại học nhằm mô phỏng chấm điểm tín dụng và đánh giá hồ sơ vay vốn cho người dùng tại Việt Nam.\n\nBằng cách tạo tài khoản hoặc sử dụng Ứng dụng, người dùng đồng ý tuân thủ các Điều khoản này. Nếu không đồng ý, người dùng không được phép sử dụng Ứng dụng.',
                ),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF3E4566),
                ),
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                'Nature of the Service',
                'Tính Chất Của Dịch Vụ',
                'Swin Credit Mobile App is a technology platform that provides credit scoring analysis and loan eligibility assessment tools based on user-provided data. The App is not a bank, credit institution, or licensed lending organization.\n\nThe App does not directly provide loans, collect repayments, or execute lending contracts. Any loan offers displayed are simulated, educational, or provided by third-party partners (if applicable).',
                'Swin Credit là nền tảng công nghệ cung cấp các công cụ phân tích chấm điểm tín dụng và đánh giá mức độ đủ điều kiện vay vốn dựa trên dữ liệu do người dùng cung cấp. Ứng dụng không phải là ngân hàng, tổ chức tín dụng hoặc tổ chức cho vay được cấp phép.\n\nỨng dụng không trực tiếp cung cấp khoản vay, thu hồi nợ hoặc thực hiện hợp đồng cho vay. Mọi đề xuất khoản vay hiển thị chỉ mang tính chất mô phỏng, giáo dục hoặc được cung cấp bởi các đối tác bên thứ ba (nếu có).',
              ),
              _buildSection(
                context,
                'Eligibility',
                'Điều Kiện Sử Dụng',
                'You must be at least 18 years old and legally capable under Vietnamese law to use this App. By using the App, you confirm that the information you provide is accurate and that you are legally eligible to enter into agreements.',
                'Người dùng phải từ đủ 18 tuổi trở lên và có năng lực hành vi dân sự đầy đủ theo quy định của pháp luật Việt Nam để sử dụng Ứng dụng này. Khi sử dụng Ứng dụng, người dùng xác nhận rằng thông tin cung cấp là chính xác và có đủ tư cách pháp lý để tham gia vào các thỏa thuận.',
              ),
              _buildSection(
                context,
                'Account Registration and Security',
                'Đăng Ký Tài Khoản Và Bảo Mật',
                'When creating an account, you agree to provide true, accurate, and complete information and to keep it updated.\n\nYou are responsible for:\n- Maintaining the confidentiality of your login credentials\n- All activities conducted under your account\n- Immediately notifying us of any unauthorized access or security breach\n\nWe are not liable for losses caused by your failure to protect your account credentials.',
                'Khi tạo tài khoản, người dùng đồng ý cung cấp thông tin trung thực, chính xác và đầy đủ, đồng thời duy trì cập nhật các thông tin đó.\n\nNgười dùng chịu trách nhiệm về:\n- Việc duy trì tính bảo mật của thông tin đăng nhập;\n- Mọi hoạt động diễn ra dưới tài khoản của mình;\n- Thông báo ngay cho chúng tôi về bất kỳ hành vi truy cập trái phép hoặc vi phạm bảo mật nào.\n\nChúng tôi không chịu trách nhiệm đối với các tổn thất phát sinh do người dùng không bảo vệ đầy đủ thông tin đăng nhập của mình.',
              ),
              _buildSection(
                context,
                'User Data and Consent to Data Processing',
                'Dữ Liệu Người Dùng Và Sự Đồng Ý Xử Lý Dữ Liệu',
                'Because this is a credit scoring and loan assessment App, we need to collect and process user data.\n\nBy using the App, you explicitly consent to our collection and processing of the following categories of data:\n- Identity and profile information you provide\n- Financial and income-related information you input\n- App usage data and behavioral analytics\n- Device and technical data\n\nYour data is used for:\n- Credit scoring and risk analysis\n- Improving scoring models and system performance\n- Academic research and project evaluation purposes\n- Generating reports and insights in anonymized or aggregated form\n\nWe process personal data in accordance with applicable Vietnamese data protection regulations, including Decree No. 13/2023/ND-CP on Personal Data Protection (as applicable).\n\nWe do not sell your personal data. Data may be anonymized and used for research and system improvement.',
                'Do đây là Ứng dụng chấm điểm tín dụng và đánh giá hồ sơ vay vốn, chúng tôi cần thu thập và xử lý dữ liệu của người dùng.\n\nBằng việc sử dụng Ứng dụng, người dùng đồng ý rõ ràng cho việc chúng tôi thu thập và xử lý các loại dữ liệu sau:\n- Thông tin nhận dạng và hồ sơ cá nhân do người dùng cung cấp;\n- Thông tin tài chính và thu nhập do người dùng nhập;\n- Dữ liệu sử dụng Ứng dụng và phân tích hành vi;\n- Dữ liệu thiết bị và dữ liệu kỹ thuật.\n\nDữ liệu của người dùng được sử dụng cho các mục đích:\n- Chấm điểm tín dụng và phân tích rủi ro;\n- Cải thiện mô hình chấm điểm và hiệu suất hệ thống;\n- Nghiên cứu học thuật và đánh giá dự án;\n- Tạo báo cáo và thông tin dưới dạng ẩn danh hoặc tổng hợp.\n\nChúng tôi xử lý dữ liệu cá nhân theo quy định hiện hành của Việt Nam về bảo vệ dữ liệu, bao gồm Nghị định số 13/2023/NĐ-CP về Bảo vệ dữ liệu cá nhân (trong phạm vi áp dụng).\n\nChúng tôi không bán dữ liệu cá nhân của người dùng. Dữ liệu có thể được ẩn danh và sử dụng cho mục đích nghiên cứu và cải thiện hệ thống.',
              ),
              _buildSection(
                context,
                'No Service Fees',
                'Không Thu Phí Dịch Vụ',
                'The App does not charge users any service fees for using its core features in this project version. If any paid features are introduced in the future, they will be clearly disclosed and subject to separate terms.',
                'Ứng dụng không thu bất kỳ khoản phí dịch vụ nào từ người dùng đối với các tính năng cốt lõi trong phiên bản dự án này. Nếu có bất kỳ tính năng trả phí nào được giới thiệu trong tương lai, các tính năng đó sẽ được công bố rõ ràng và chịu sự điều chỉnh bởi các điều khoản riêng.',
              ),
              _buildSection(
                context,
                'User Responsibilities and Prohibited Uses',
                'Trách Nhiệm Của Người Dùng Và Các Hành Vi Bị Cấm',
                'You agree not to:\n- Provide false or misleading financial or identity information\n- Use the App for fraud or unlawful purposes\n- Attempt to bypass security or scoring mechanisms\n- Reverse engineer or disrupt the system\n- Upload malicious code or harmful content\n\nWe may suspend or terminate accounts that violate these rules.',
                'Người dùng đồng ý không thực hiện các hành vi sau:\n- Cung cấp thông tin tài chính hoặc nhân thân sai lệch hoặc mang tính chất lừa đảo;\n- Sử dụng Ứng dụng cho mục đích gian lận hoặc bất hợp pháp;\n- Cố gắng vượt qua hoặc vô hiệu hóa các cơ chế bảo mật hoặc chấm điểm;\n- Dịch ngược hoặc can thiệp vào hệ thống;\n- Tải lên mã độc hoặc nội dung có hại.\n\nChúng tôi có quyền tạm ngưng hoặc chấm dứt tài khoản của người dùng vi phạm các quy tắc này.',
              ),
              _buildSection(
                context,
                'Credit Scores and Results Disclaimer',
                'Miễn Trừ Trách Nhiệm Đối Với Kết Quả Chấm Điểm Tín Dụng',
                'Credit scores, risk ratings, and loan eligibility results generated by the App are algorithm-based estimates only.\n\nThey:\n- Do not guarantee loan approval\n- Do not represent official credit bureau scores\n- Must not be considered financial advice\n- Are provided for reference and evaluation purposes only\n\nYou are solely responsible for decisions made based on App results.',
                'Điểm tín dụng, xếp hạng rủi ro và kết quả đánh giá mức độ đủ điều kiện vay vốn do Ứng dụng tạo ra chỉ là các ước tính dựa trên thuật toán.\n\nCác kết quả này:\n- Không đảm bảo khoản vay được phê duyệt;\n- Không đại diện cho điểm tín dụng chính thức từ trung tâm thông tin tín dụng;\n- Không được coi là lời khuyên tài chính;\n- Chỉ được cung cấp nhằm mục đích tham khảo và đánh giá.\n\nNgười dùng hoàn toàn chịu trách nhiệm đối với các quyết định được đưa ra dựa trên kết quả của Ứng dụng.',
              ),
              _buildSection(
                context,
                'Third-Party Services',
                'Dịch Vụ Của Bên Thứ Ba',
                'The App may integrate APIs or third-party data services. We are not responsible for:\n- Accuracy of third-party data\n- Availability of third-party systems\n- External websites or services linked from the App',
                'Ứng dụng có thể tích hợp API hoặc dịch vụ dữ liệu của bên thứ ba. Chúng tôi không chịu trách nhiệm về:\n- Tính chính xác của dữ liệu từ bên thứ ba;\n- Tính sẵn sàng của hệ thống bên thứ ba;\n- Các trang web hoặc dịch vụ bên ngoài được liên kết từ Ứng dụng.',
              ),
              _buildSection(
                context,
                'Intellectual Property',
                'Quyền Sở Hữu Trí Tuệ',
                'All software, algorithms, scoring models, text, graphics, and design in the App are owned by the project team or its licensors and are protected by intellectual property laws.\n\nYou may not copy, modify, or redistribute the App or its components without permission.',
                'Toàn bộ phần mềm, thuật toán, mô hình chấm điểm, văn bản, đồ họa và thiết kế trong Ứng dụng thuộc sở hữu của nhóm dự án hoặc các bên cấp phép và được bảo vệ bởi các quy định về sở hữu trí tuệ.\n\nNgười dùng không được sao chép, sửa đổi hoặc phân phối lại Ứng dụng hoặc bất kỳ thành phần nào của Ứng dụng khi chưa được phép.',
              ),
              _buildSection(
                context,
                'Limitation of Liability',
                'Giới Hạn Trách Nhiệm',
                'To the maximum extent permitted by Vietnamese law, the App is provided "as is" without warranties of any kind.\n\nWe are not liable for:\n- Financial losses from user decisions\n- Incorrect credit assessments due to inaccurate input data\n- Service interruptions or technical errors\n- Indirect or consequential damages',
                'Trong phạm vi tối đa được pháp luật Việt Nam cho phép, Ứng dụng được cung cấp "nguyên trạng" và không có bất kỳ bảo đảm nào.\n\nChúng tôi không chịu trách nhiệm về:\n- Tổn thất tài chính phát sinh từ quyết định của người dùng;\n- Đánh giá tín dụng không chính xác do dữ liệu đầu vào sai lệch;\n- Gián đoạn dịch vụ hoặc lỗi kỹ thuật;\n- Các thiệt hại gián tiếp hoặc phát sinh.',
              ),
              _buildSection(
                context,
                'Termination',
                'Chấm dứt sử dụng',
                'We may suspend or terminate your access if:\n- You violate these Terms\n- You misuse the system\n- Required by law or university policy\n\nYou may stop using the App at any time.',
                'Chúng tôi có quyền tạm ngưng hoặc chấm dứt quyền truy cập của người dùng nếu:\n- Người dùng vi phạm các Điều khoản này;\n- Người dùng sử dụng hệ thống sai mục đích;\n- Theo yêu cầu của pháp luật hoặc chính sách của trường đại học.\n\nNgười dùng có thể ngừng sử dụng Ứng dụng bất kỳ lúc nào.',
              ),
              _buildSection(
                context,
                'Governing Law and Jurisdiction',
                'Luật Điều Chỉnh Và Thẩm Quyền Giải Quyết Tranh Chấp',
                'These Terms are governed by the laws of the Socialist Republic of Vietnam. Any disputes arising from these Terms shall be subject to the competent courts of Vietnam.',
                'Các Điều khoản này được điều chỉnh bởi pháp luật của nước Cộng hòa Xã hội Chủ nghĩa Việt Nam. Mọi tranh chấp phát sinh từ các Điều khoản này sẽ thuộc thẩm quyền giải quyết của Tòa án có thẩm quyền tại Việt Nam.',
              ),
              _buildSection(
                context,
                'Changes to Terms',
                'Thay Đổi Điều Khoản',
                'We may update these Terms from time to time. Updated versions will be posted in the App. Continued use after updates means you accept the revised Terms.',
                'Chúng tôi có thể cập nhật các Điều khoản này theo thời gian. Các phiên bản cập nhật sẽ được đăng tải trong Ứng dụng. Việc tiếp tục sử dụng Ứng dụng sau khi có cập nhật đồng nghĩa với việc người dùng chấp nhận các Điều khoản đã sửa đổi.',
              ),
              _buildSection(
                context,
                'Contact',
                'Liên Hệ',
                'For questions regarding these Terms, please contact:\n\nSwin Credit\nSwinburne University of Technology\nEmail: 104198640@student.swin.edu.au\n\nBy using the App, you acknowledge that you have read and agreed to these Terms of Service.',
                'Đối với các câu hỏi liên quan đến Điều khoản này, vui lòng liên hệ:\n\nSwin Credit\nĐại học Swinburne Vietnam Hồ Chí Minh\nEmail: 104198640@student.swin.edu.au\n\nBằng việc sử dụng Ứng dụng, người dùng xác nhận đã đọc và đồng ý với các Điều khoản Dịch vụ này.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String enTitle,
    String viTitle,
    String enBody,
    String viBody,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t(enTitle, viTitle),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1F3F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t(enBody, viBody),
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF3E4566),
            ),
          ),
        ],
      ),
    );
  }
}
