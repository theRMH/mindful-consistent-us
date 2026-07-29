import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config/theme.dart';

class CountryCode {
  final String name;
  final String dialCode;
  final String flag;
  const CountryCode({required this.name, required this.dialCode, required this.flag});
}

const List<CountryCode> kCountryCodes = [
  CountryCode(name: 'United States', dialCode: '+1', flag: '🇺🇸'),
  CountryCode(name: 'India', dialCode: '+91', flag: '🇮🇳'),
  CountryCode(name: 'United Kingdom', dialCode: '+44', flag: '🇬🇧'),
  CountryCode(name: 'Canada', dialCode: '+1', flag: '🇨🇦'),
  CountryCode(name: 'Australia', dialCode: '+61', flag: '🇦🇺'),
  CountryCode(name: 'UAE', dialCode: '+971', flag: '🇦🇪'),
  CountryCode(name: 'Singapore', dialCode: '+65', flag: '🇸🇬'),
  CountryCode(name: 'Germany', dialCode: '+49', flag: '🇩🇪'),
  CountryCode(name: 'France', dialCode: '+33', flag: '🇫🇷'),
  CountryCode(name: 'Netherlands', dialCode: '+31', flag: '🇳🇱'),
  CountryCode(name: 'Switzerland', dialCode: '+41', flag: '🇨🇭'),
  CountryCode(name: 'Sweden', dialCode: '+46', flag: '🇸🇪'),
  CountryCode(name: 'Norway', dialCode: '+47', flag: '🇳🇴'),
  CountryCode(name: 'Denmark', dialCode: '+45', flag: '🇩🇰'),
  CountryCode(name: 'New Zealand', dialCode: '+64', flag: '🇳🇿'),
  CountryCode(name: 'Sri Lanka', dialCode: '+94', flag: '🇱🇰'),
  CountryCode(name: 'Malaysia', dialCode: '+60', flag: '🇲🇾'),
  CountryCode(name: 'South Africa', dialCode: '+27', flag: '🇿🇦'),
  CountryCode(name: 'Brazil', dialCode: '+55', flag: '🇧🇷'),
  CountryCode(name: 'Japan', dialCode: '+81', flag: '🇯🇵'),
  CountryCode(name: 'South Korea', dialCode: '+82', flag: '🇰🇷'),
  CountryCode(name: 'Pakistan', dialCode: '+92', flag: '🇵🇰'),
  CountryCode(name: 'Bangladesh', dialCode: '+880', flag: '🇧🇩'),
  CountryCode(name: 'Saudi Arabia', dialCode: '+966', flag: '🇸🇦'),
  CountryCode(name: 'Kuwait', dialCode: '+965', flag: '🇰🇼'),
  CountryCode(name: 'Qatar', dialCode: '+974', flag: '🇶🇦'),
  CountryCode(name: 'Bahrain', dialCode: '+973', flag: '🇧🇭'),
  CountryCode(name: 'Oman', dialCode: '+968', flag: '🇴🇲'),
];

class CountryCodePicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const CountryCodePicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final entry = kCountryCodes.firstWhere(
      (c) => c.dialCode == selected,
      orElse: () => kCountryCodes.first,
    );
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(entry.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 4),
            Text(
              entry.dialCode,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: AppFontWeights.semiBold,
                color: AppTheme.figmaGreen,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppTheme.figmaGreen, size: 18),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CountryPickerSheet(selected: selected, onChanged: onChanged),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _CountryPickerSheet({required this.selected, required this.onChanged});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = kCountryCodes
        .where((c) =>
            c.name.toLowerCase().contains(_query.toLowerCase()) ||
            c.dialCode.contains(_query))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppTheme.figmaLightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search country...',
                hintStyle: GoogleFonts.inter(color: AppTheme.figmaMutedGray, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppTheme.figmaGreen, size: 20),
                filled: true,
                fillColor: AppTheme.figmaBgGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final c = filtered[i];
                final isSelected = c.dialCode == widget.selected;
                return ListTile(
                  leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                  title: Text(
                    c.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected ? AppFontWeights.semiBold : AppFontWeights.regular,
                      color: isSelected ? AppTheme.figmaGreen : AppTheme.figmaCharcoal,
                    ),
                  ),
                  trailing: Text(
                    c.dialCode,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: AppFontWeights.semiBold,
                      color: AppTheme.figmaGreen,
                    ),
                  ),
                  onTap: () {
                    widget.onChanged(c.dialCode);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
