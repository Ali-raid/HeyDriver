import 'package:flutter/material.dart';

class ScrollViewWidget extends StatelessWidget {
  final Widget body;
  final Widget? header;
  final Widget? footer;

  const ScrollViewWidget({
    Key? key,
    required this.body,
    this.header,
    this.footer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          stretch: header != null,
          pinned: true,
          toolbarHeight: 0.0,
        ),
        SliverToBoxAdapter(
          child: header,
        ),
        SliverSafeArea(
          bottom: false,
          sliver: SliverToBoxAdapter(
            child: body,
          ),
        ),
        if (footer != null)
          SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: SafeArea(
                  top: false,
                  child: footer!,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
