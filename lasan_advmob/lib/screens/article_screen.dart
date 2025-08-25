import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lasan_advmob/screens/detail_screen.dart';
import 'package:lasan_advmob/services/article_service.dart';
import '../models/article_model.dart';
import '../widgets/custom_text.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late Future<List<Article>> _futureArticles;
  final TextEditingController _searchController = TextEditingController();
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];

  @override
  void initState() {
    super.initState();
    _futureArticles = _getAllArticles();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Article>> _getAllArticles() async {
    final response = await ArticleService().getAllArticle();
    final articles = (response).map((e) => Article.fromJson(e)).toList();
    setState(() {
      _allArticles = articles;
      _filteredArticles = articles;
    });
    return articles;
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredArticles = _allArticles.where((article) {
        final titleLower = article.title.toLowerCase();
        return titleLower.contains(query);
      }).toList();
    });
  }

  Future<void> _openAddArticleDialog() async {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final contentController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;
    bool isActive = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSaving, 
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            List<String> _toList(String raw) {
              return raw
                .split(RegExp(r'[\n,]'))
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            }

            Future<void> save() async {
              if (isSaving) return;
              if (!formKey.currentState!.validate()) return;

              setLocalState(() => isSaving = true);
              try {
                final payload = {
                  'title': titleController.text.trim(),
                  'name': authorController.text.trim(),
                  'content': _toList(contentController.text),
                  'isActive': isActive,
                };
                
                final Map res = await ArticleService().createArticle(payload);

                final created = (res['article']  ?? res);
                final newArticle = Article.fromJson(created);

                setState(() {
                  _allArticles.insert(0, newArticle);
                  // Refresh filtered view based on current query
                  _onSearchChanged();
                });

                if (ctx.mounted) Navigator.of(ctx).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Article added.')),
                  );
                }
              } catch (e) {
                setLocalState(() => isSaving = false);
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Failed to add $e')));
                }
              }
            }
            return AlertDialog(
              title: const Text('Add Article'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: authorController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Author / Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => 
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: contentController,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Content (one item per line or comma-separated)',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (v) {
                          final items = v == null
                            ? []
                            : v
                                .trim()
                                .split(RegExp(r'[\n,]'))
                                .where((s) => s.trim().isNotEmpty)
                                .toList();
                          return items.isEmpty
                            ? 'At least one content item'
                            : null;
                        },
                      ),
                      SizedBox(height: 8.h),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        value: isActive,
                        onChanged: (val) => setLocalState(() => isActive = val),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(ctx).pop(), 
                  child: const Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: isSaving ? null : () { save(); },
                    icon: Icon(Icons.save),
                    label: (Text('Save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statusChip(bool active) {
    return Chip(
      label: Text(active ? 'Active' : 'Inactive'),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: active ? Colors.green : Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddArticleDialog,
        icon: const Icon(Icons.add), 
        label: const Text('Add'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search articles...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                ),
              ),

            SizedBox(height: 10.h),

            FutureBuilder<List<Article>>(
              future: _futureArticles,
              builder: (context, snapshot) {
                if(snapshot.hasError) {
                  return SizedBox(
                    height: ScreenUtil().screenHeight * 0.6,
                    child: const Center(
                      child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CustomText(
                        text: 'No equipment article to display...',
                      ),
                    ),
                    ),
                  );
                }

                if(snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: ScreenUtil().screenHeight * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator.adaptive(strokeWidth: 3.sp),
                          SizedBox(height: 10.h),
                          const CustomText(
                            text: 'Waiting for the equipment articles to display...',
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (_filteredArticles.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: const Center(
                      child: CustomText(
                        text: 'No equipment article to display...',
                      ),
                    ), 
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  shrinkWrap: true,
                  itemCount: _filteredArticles.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final article = _filteredArticles[index];
                    final preview = article.content.isNotEmpty
                      ? article.content.first
                      : '';
                    return Card(
                      elevation: 1,
                      child: InkWell(
                        onTap: () {
                          debugPrint('Tapped index $index: ${article.aid}');
                          final body = article.content.isNotEmpty
                              ? article.content.join('\n\n')
                              : '';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(
                                title: article.title.isEmpty
                                    ? 'Untitled'
                                    : article.title,
                                body: body,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(15),
                            vertical: ScreenUtil().setHeight(15),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: CustomText(
                                            text: article.title.isEmpty
                                              ? 'Untitled'
                                              : article.title,
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.bold,
                                            maxLines: 2,
                                            ),
                                          ),
                                          _statusChip(article.isActive),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomText(
                                      text: article.name,
                                      fontSize: 13.sp,
                                    ),
                                    if (preview.isNotEmpty) ...[
                                      SizedBox(height: 6.h),
                                      CustomText(
                                        text: preview,
                                        fontSize: 12.sp,
                                        maxLines: 2,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}









            // FutureBuilder<List<Article>>(
            //     future: _futureArticles,
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return Center(
            //           child: Column(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               CircularProgressIndicator.adaptive(strokeWidth: 3.sp),
            //               SizedBox(height: 10.h),
            //               CustomText(
            //                 text: 'Loading articles...',
            //                 fontSize: 14.sp,
            //               ),
            //             ],
            //           ),
            //         );
            //       } else if (snapshot.hasError) {
            //         return Center(
            //           child: Padding(
            //             padding: EdgeInsets.symmetric(horizontal: 24.w),
            //             child: CustomText(
            //               text: 'Failed to load articles.',
            //               fontSize: 14.sp,
            //             ),
            //           ),
            //         );
            //       } else if (_filteredArticles.isEmpty) {
            //         return Center(
            //           child: Padding(
            //             padding: EdgeInsets.symmetric(horizontal: 24.w),
            //             child: CustomText(
            //               text: 'No articles to display.',
            //               fontSize: 14.sp,
            //             ),
            //           ),
            //         );
            //       }
            //       return ListView.separated(
            //         padding: EdgeInsets.symmetric(
            //           horizontal: 20.w,
            //           vertical: 10.h,
            //         ),
            //         itemCount: _filteredArticles.length,
            //         separatorBuilder: (_, __) => SizedBox(height: 8.h),
            //         itemBuilder: (context, index) {
            //           final article = _filteredArticles[index];
            //           return Card(
            //             elevation: 1,
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(12.r),
            //             ),
            //             child: InkWell(
            //               borderRadius: BorderRadius.circular(12.r),
            //               onTap: () {
            //                 Navigator.push(
            //                   context,
            //                   MaterialPageRoute(
            //                     builder: (context) => DetailScreen(
            //                       title: article.title,
            //                       body: article.body,
            //                     ),
            //                   ),
            //                 );
            //                 debugPrint('Index $index tapped');
            //               },
            //               child: Padding(
            //                 padding: EdgeInsets.symmetric(
            //                   horizontal: 16.w,
            //                   vertical: 14.h,
            //                 ),
            //                 child: Row(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     // Placeholder for image or thumbnail
            //                     Placeholder(
            //                       fallbackHeight: 100.h,
            //                       fallbackWidth: 100.w,
            //                     ),
            //                     SizedBox(width: 10.w),
            //                     Expanded(
            //                       child: Column(
            //                         crossAxisAlignment:
            //                             CrossAxisAlignment.start,
            //                         children: [
            //                           // Title
            //                           CustomText(
            //                             text: article.title,
            //                             fontSize: 20.sp,
            //                             fontWeight: FontWeight.w700,
            //                             maxLines: 2,
            //                             overflow: TextOverflow.ellipsis,
            //                           ),
            //                           SizedBox(height: 6.h),
            //                           // Body preview
            //                           CustomText(
            //                             text: article.body,
            //                             fontSize: 13.sp,
            //                             maxLines: 3,
            //                             overflow: TextOverflow.ellipsis,
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ),
            //           );
            //         },
            //       );
            //     },
            //   ),
            
          
