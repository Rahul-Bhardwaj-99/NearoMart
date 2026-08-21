import 'package:flutter/material.dart';
import 'package:nearomart/app/core/values/colors.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool isLoading;
  final bool centerTitle;
  final bool showAppBar;
  final Color? backgroundColor;
  final Widget? leading;
  final bool resizeToAvoidBottomInset;

  const BaseScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.isLoading = false,
    this.centerTitle = true,
    this.showAppBar = true,
    this.backgroundColor,
    this.leading,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: backgroundColor ?? AppColors.background,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: showAppBar
              ? AppBar(
                  title: titleWidget ??
                      (title != null
                          ? Text(
                              title!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : null),
                  centerTitle: centerTitle,
                  actions: actions,
                  leading: leading,
                )
              : null,
          body: body,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
        ),
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
