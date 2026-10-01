/// ฿1,250
String baht(int amount) {
  final digits = amount.abs().toString();
  final out = StringBuffer(amount < 0 ? '-฿' : '฿');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}

/// 24-hour clock, the way Thai shops show pickup times: 14:05
String clock(DateTime time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
