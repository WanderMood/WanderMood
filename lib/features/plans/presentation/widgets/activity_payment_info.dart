import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/plans/domain/models/activity.dart';

class ActivityPaymentInfo extends StatelessWidget {
  final Activity activity;

  const ActivityPaymentInfo({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), color: _getIconColor(context), size: 16),
          const SizedBox(width: 4),
          Text(
            _getLabel(),
            style: GoogleFonts.poppins(
              color: _getIconColor(context),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (activity.paymentType) {
      case PaymentType.free:
        return Colors.green.shade50;
      case PaymentType.ticket:
        return Colors.amber.shade50;
      case PaymentType.reservation:
        return Colors.blue.shade50;
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (activity.paymentType) {
      case PaymentType.free:
        return Colors.green.shade100;
      case PaymentType.ticket:
        return Colors.amber.shade100;
      case PaymentType.reservation:
        return Colors.blue.shade100;
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (activity.paymentType) {
      case PaymentType.free:
        return Colors.green.shade700;
      case PaymentType.ticket:
        return Colors.amber.shade700;
      case PaymentType.reservation:
        return Colors.blue.shade700;
    }
  }

  IconData _getIcon() {
    switch (activity.paymentType) {
      case PaymentType.free:
        return Icons.check_circle_outline;
      case PaymentType.ticket:
        return Icons.confirmation_number_outlined;
      case PaymentType.reservation:
        return Icons.calendar_today_outlined;
    }
  }

  String _getLabel() {
    switch (activity.paymentType) {
      case PaymentType.free:
        return 'Free Activity';
      case PaymentType.ticket:
        return 'Ticket Required';
      case PaymentType.reservation:
        return 'Reservation Required';
    }
  }
} 