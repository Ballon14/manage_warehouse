import 'package:flutter/material.dart';

enum ReportPeriod {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  all;

  String get label {
    switch (this) {
      case ReportPeriod.today:
        return 'Hari Ini';
      case ReportPeriod.thisWeek:
        return 'Minggu Ini';
      case ReportPeriod.thisMonth:
        return 'Bulan Ini';
      case ReportPeriod.thisYear:
        return 'Tahun Ini';
      case ReportPeriod.all:
        return 'Semua';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportPeriod.today:
        return Icons.today;
      case ReportPeriod.thisWeek:
        return Icons.date_range;
      case ReportPeriod.thisMonth:
        return Icons.calendar_month;
      case ReportPeriod.thisYear:
        return Icons.calendar_today;
      case ReportPeriod.all:
        return Icons.all_inclusive;
    }
  }
}
