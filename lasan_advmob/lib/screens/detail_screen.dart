import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lasan_advmob/widgets/custom_text.dart';
import 'package:lasan_advmob/models/article_model.dart';
import 'package:lasan_advmob/services/article_service.dart';

class DetailScreen extends StatefulWidget {
  final String title;
  final String body;
  final Article? article; // if provided, enables editing existing article

  const DetailScreen({super.key, required this.title, required this.body, this.article});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isEditMode = false;
  bool _isSaving = false;
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _bodyController = TextEditingController(text: widget.body);
  }

  Future<void> _saveEdits() async {
    if (_isSaving) return;
    if (widget.article == null) {
      setState(() => _isEditMode = false);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final updated = {
        'title': _titleController.text.trim(),
        'name': widget.article!.name,
        'content': _bodyController.text
            .split(RegExp(r'[\n]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'isActive': widget.article!.isActive,
      };

      await ArticleService().updateArticle(widget.article!.aid, updated);
      if (mounted) {
        setState(() => _isEditMode = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: CustomText(
          text: _isEditMode ? 'Edit Article' : 'Detail Screen',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          if (widget.article != null)
            IconButton(
              icon: Icon(_isEditMode ? Icons.close : Icons.edit),
              onPressed: _isSaving
                  ? null
                  : () => setState(() => _isEditMode = !_isEditMode),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Placeholder(fallbackHeight: 200.h),
            SizedBox(height: 10.h),
            if (!_isEditMode) ...[
              CustomText(
                text: widget.title,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 20.h),
              CustomText(text: widget.body, fontSize: 16.sp),
            ] else ...[
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _bodyController,
                minLines: 6,
                maxLines: 12,
                decoration: const InputDecoration(
                  labelText: 'Content (newline separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveEdits,
                  icon: _isSaving
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving…' : 'Save changes'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
