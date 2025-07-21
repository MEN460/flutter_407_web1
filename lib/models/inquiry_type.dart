// Enhanced InquiryType enum with display names and better organization
enum InquiryType {
  general('general', 'General Inquiry'),
  cancellation('cancellation', 'Booking Cancellation'),
  refund('refund', 'Refund Request'),
  modification('modification', 'Booking Modification'),
  seatChange('seat_change', 'Seat Change'),
  baggage('baggage', 'Baggage Issue'),
  checkin('checkin', 'Check-in Issue'),
  flightChange('flight_change', 'Flight Change'),
  specialAssistance('special_assistance', 'Special Assistance'),
  complaint('complaint', 'Complaint'),
  feedback('feedback', 'Feedback'),
  other('other', 'Other');

  const InquiryType(this.value, this.displayName);
  final String value;
  final String displayName;

  static InquiryType fromString(String value) {
    for (final type in InquiryType.values) {
      if (type.value == value.toLowerCase()) {
        return type;
      }
    }
    return InquiryType.general;
  }

  @override
  String toString() => value;
}

enum InquiryStatus {
  pending('pending', 'Pending Review'),
  inProgress('in_progress', 'In Progress'),
  waitingForCustomer('waiting_for_customer', 'Waiting for Customer'),
  resolved('resolved', 'Resolved'),
  closed('closed', 'Closed');

  const InquiryStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static InquiryStatus fromString(String value) {
    for (final status in InquiryStatus.values) {
      if (status.value == value.toLowerCase()) {
        return status;
      }
    }
    return InquiryStatus.pending;
  }

  @override
  String toString() => value;
}

enum InquiryPriority {
  low('low', 'Low Priority'),
  medium('medium', 'Medium Priority'),
  high('high', 'High Priority'),
  urgent('urgent', 'Urgent');

  const InquiryPriority(this.value, this.displayName);
  final String value;
  final String displayName;

  static InquiryPriority fromString(String value) {
    for (final priority in InquiryPriority.values) {
      if (priority.value == value.toLowerCase()) {
        return priority;
      }
    }
    return InquiryPriority.medium;
  }

  @override
  String toString() => value;
}
