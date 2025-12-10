import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../home/home_page.dart';
import '../services/api_service.dart';

class LoanOfferPage extends StatelessWidget {
  final LoanOfferResponse? offer;

  const LoanOfferPage({super.key, this.offer});

  @override
  Widget build(BuildContext context) {
    if (offer == null) {
        return const Scaffold(body: Center(child: Text('No offer details available.')));
    }

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scoring - Offer',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                offer!.approved ? 'Congratulations!' : 'Application Rejected',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: offer!.approved ? const Color(0xFF1A1F3F) : Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                offer!.approvalMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              // Status icon
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: (offer!.approved ? const Color(0xFF4CAF50) : Colors.red).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  offer!.approved ? Icons.check_circle : Icons.cancel,
                  size: 100,
                  color: offer!.approved ? const Color(0xFF4CAF50) : Colors.red,
                ),
              ),
              const SizedBox(height: 40),
              // Loan details card (only show if approved)
              if (offer!.approved)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Loan Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1F3F),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Highlight the Tier if present
                          if (offer!.loanTier != null) ...[
                             Center(
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                 decoration: BoxDecoration(
                                   color: Colors.amber.withOpacity(0.2),
                                   borderRadius: BorderRadius.circular(20),
                                   border: Border.all(color: Colors.amber),
                                 ),
                                 child: Text(
                                   '${offer!.loanTier} TIER',
                                   style: const TextStyle(
                                     fontWeight: FontWeight.bold,
                                     color: Colors.deepOrange,
                                   ),
                                 ),
                               ),
                             ),
                             const SizedBox(height: 16),
                          ],
                          _buildDetailRow('Approved Amount', currencyFormat.format(offer!.loanAmountVnd)),
                          const SizedBox(height: 16),
                          // Max eligible is redundant if same as approved, but good to show
                          _buildDetailRow('Max Eligible', currencyFormat.format(offer!.maxAmountVnd)),
                          const SizedBox(height: 16),
                          _buildDetailRow('Credit Score', offer!.creditScore.toString()),
                          const SizedBox(height: 16),
                          _buildDetailRow('Interest Rate', '${offer!.interestRate}%'),
                          const SizedBox(height: 16),
                          _buildDetailRow('Monthly Payment', offer!.monthlyPaymentVnd != null ? currencyFormat.format(offer!.monthlyPaymentVnd) : 'N/A'),
                          const SizedBox(height: 16),
                          _buildDetailRow('Term', '${offer!.loanTermMonths ?? 0} months'),
                          if (offer!.tierReason != null) ...[
                             const SizedBox(height: 16),
                             const Divider(),
                             const SizedBox(height: 8),
                             const Text('Why this tier?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                             const SizedBox(height: 4),
                             Text(offer!.tierReason!, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // Action buttons
              if (offer!.approved) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C40F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Accept Offer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4C40F7), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4C40F7),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                 SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to try again
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C40F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1F3F),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1F3F),
          ),
        ),
      ],
    );
  }
}
