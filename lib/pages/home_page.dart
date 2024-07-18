import 'package:flutter/material.dart';
import 'package:toolfoam/pages/layouts_page.dart';
import 'package:toolfoam/pages/tools_page.dart';
import 'package:toolfoam/widgets/breadcrumb.dart';
import 'package:toolfoam/widgets/buttons/collection_manager_button.dart';

import '../models/tf_collection.dart';
import '../widgets/animation_timings.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

  final _pageController = PageController();
  final TextBreadcrumbItem _headerBreadcrumbItem = const TextBreadcrumbItem(text: 'Toolfoam');

  String? name;
  int? selectedPage = 0;
  TfCollection? selectedCollection;
  List<BreadcrumbItem> breadcrumbItems = [];

  _onCollectionSelected(TfCollection? collection) {
    setState(() {
      selectedCollection = collection;
    });
    syncCollectionDetails();
  }

  List<BreadcrumbItem> _createBreadcrumbItems() {
    List<BreadcrumbItem> items = [];
    items.add(_headerBreadcrumbItem);

    if (selectedCollection == null) {
      return items;
    }

    items.add(
      RenameableBreadcrumbItem(
        text: name ?? selectedCollection?.uuid ?? 'Unknown Project',
        onRename: (String newName) async {
          await selectedCollection?.rename(newName);
          syncCollectionDetails();
        }
      )
    ); // TODO fix null name condition

    if (selectedPage == 0) {
      items.add(TextBreadcrumbItem(text: 'Tools', onTap: () {}));
    } else if (selectedPage == 1) {
      items.add(TextBreadcrumbItem(text: 'Layouts', onTap: () {}));
    }

    return items;
  }

  Widget _drawerHeader() {
    return DrawerHeader(
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(name ?? 'Toolfoam',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ),
                CollectionManagerButton(
                  selectedCollection: selectedCollection,
                  onCollectionSelected: _onCollectionSelected,
                )
              ]
            )
          )
        ]
      )
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Stack(
      children: [
        NavigationDrawer(
          selectedIndex: selectedPage,
          onDestinationSelected: (int index) {
            setState(() {
              selectedPage = index;
              _pageController.animateToPage(index,
                duration: AnimationDurations.normal,
                curve: Curves.easeInOut
              );
            });
          },
          children: [
            _drawerHeader(),
            const NavigationDrawerDestination(icon: Icon(Icons.construction_rounded, fill: 1,), label: Text('Tools')),
            const NavigationDrawerDestination(icon: Icon(Icons.space_dashboard_rounded, fill: 1), label: Text('Layouts')),
          ]
        ),
      ],
    );
  }

  void syncCollectionDetails() async {
    String? updatedName = await selectedCollection?.getName();

    setState(() {
      name = updatedName;
      breadcrumbItems = _createBreadcrumbItems();
    });
  }

  @override
  void initState() {
    super.initState();

    syncCollectionDetails();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Breadcrumb(items: breadcrumbItems),
        backgroundColor: colorScheme.surface,
      ),
      drawer: _buildDrawer(context),
      body: Center(
        child: PageView(
          controller: _pageController,
          onPageChanged: (int index) {
            setState(() {
              selectedPage = index;
            });
          },
          children: [
            ToolsPage(
              selectedCollection: selectedCollection,
              onCollectionSelected: _onCollectionSelected,
              breadcrumbItems: breadcrumbItems,
            ),
            LayoutsPage(
              selectedCollection: selectedCollection,
              onCollectionSelected: _onCollectionSelected,
            ),
          ]
        ),
      ),
    );
  }

}

