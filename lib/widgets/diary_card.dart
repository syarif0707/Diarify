import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';

class DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;

  const DiaryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  Color _getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 
        ? Colors.black 
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = entry.cardColor != null 
        ? Color(entry.cardColor!) 
        : Theme.of(context).cardTheme.color ?? Colors.white;
    final textColor = _getTextColorForBackground(cardColor);
    final secondaryTextColor = textColor.withOpacity(0.8);

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mood: ${entry.mood}',
                style: TextStyle(
                  fontSize: 16,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM d, yyyy - hh:mm a').format(entry.entryDate),
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                entry.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              if (entry.imagePath != null && entry.imagePath!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(entry.imagePath!),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
                if (entry.imageCaption != null && entry.imageCaption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      entry.imageCaption!,
                      style: TextStyle(
                        fontSize: 14, 
                        fontStyle: FontStyle.italic,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}