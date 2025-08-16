import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChallengeCompletionDialog extends StatefulWidget {
  final String challengeType;
  final Function(Map<String, dynamic>) onComplete;

  const ChallengeCompletionDialog({
    super.key,
    required this.challengeType,
    required this.onComplete,
  });

  @override
  State<ChallengeCompletionDialog> createState() => _ChallengeCompletionDialogState();
}

class _ChallengeCompletionDialogState extends State<ChallengeCompletionDialog> {
  final TextEditingController _textController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Widget _buildContent() {
    // Simplified - all challenges use text input for now
    return _buildTextInput(
      _getChallengePrompt(),
      _getChallengeHint(),
      minLines: 4,
    );
  }
  
  String _getChallengePrompt() {
    switch (widget.challengeType) {
      case 'mindset':
        return 'Write down 3 things you\'re grateful for:';
      case 'money':
        return 'How did you save money today?';
      case 'strength':
        return 'Describe your workout:';
      case 'discipline':
        return 'What time did you wake up?';
      case 'success':
        return 'What important task did you complete?';
      default:
        return 'How did you complete today\'s challenge?';
    }
  }
  
  String _getChallengeHint() {
    switch (widget.challengeType) {
      case 'mindset':
        return 'Example:\n1. My health\n2. My family\n3. New opportunities';
      case 'money':
        return 'Example: Skipped coffee and saved \$5';
      case 'strength':
        return 'Example: 20 push-ups and 30 squats';
      case 'discipline':
        return 'Example: 6:00 AM';
      case 'success':
        return 'Example: Finished project proposal';
      default:
        return 'Share your experience...';
    }
  }

  Widget _buildTextInput(String title, String hint, {int minLines = 3}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textController,
          maxLines: null,
          minLines: minLines,
          style: const TextStyle(fontSize: 16),
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }


  bool _canComplete() {
    // For workout challenges, either text or photo is enough
    if (widget.challengeType == 'strength') {
      return _textController.text.trim().isNotEmpty || _imageFile != null;
    }
    // For all other challenges, text is required
    return _textController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                const Icon(
                  Icons.flag,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Complete Challenge',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildContent(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canComplete()
                        ? () {
                            widget.onComplete({
                              'text': _textController.text,
                              'image': _imageFile?.path,
                              'timestamp': DateTime.now().toIso8601String(),
                            });
                            Navigator.of(context).pop();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canComplete() ? Colors.blue : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Complete',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
}