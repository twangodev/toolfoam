import 'package:flutter/material.dart';
import 'package:toolfoam/pages/layouts_page.dart';
import 'package:toolfoam/pages/tools_page.dart';
import 'package:toolfoam/widgets/breadcrumb.dart';
import 'package:toolfoam/widgets/buttons/collection_manager_button.dart';

import '../data/tf_collection.dart';
import '../widgets/animation_timings.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

  final _pageController = PageController();

  int? _selectedPage = 0;
  TFCollection? _selectedCollection;

  _dismiss() {
    Navigator.of(context).pop();
  }

  _onCollectionSelected(TFCollection? collection) {
    _dismiss();
    setState(() {
      _selectedCollection = collection;
    });
  }

  List<BreadcrumbItem> _createBreadcrumbItems() {
    List<BreadcrumbItem> items = [];
    items.add(BreadcrumbItem(text: 'Toolfoam', onTap: () {
      _onCollectionSelected(null);
    }));

    if (_selectedCollection == null) {
      return items;
    }

    items.add(BreadcrumbItem(text: _selectedCollection!.name, onTap: () {}));

    if (_selectedPage == 0) {
      items.add(BreadcrumbItem(text: "Tools", onTap: () {}));
    } else if (_selectedPage == 1) {
      items.add(BreadcrumbItem(text: "Layouts", onTap: () {}));
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
                  child: Text(_selectedCollection?.name ?? 'Toolfoam',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ),
                CollectionManagerButton(
                  selectedCollection: _selectedCollection,
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
          selectedIndex: _selectedPage,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedPage = index;
              _pageController.animateToPage(index,
                duration: AnimationDurations.normal,
                curve: Curves.easeInOut
              );
            });
          },
          children: [
            _drawerHeader(),
            const NavigationDrawerDestination(icon: Icon(Icons.construction_rounded), label: Text('Tools')),
            const NavigationDrawerDestination(icon: Icon(Icons.space_dashboard_rounded), label: Text('Layouts')),
          ]
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Breadcrumb(
          items: _createBreadcrumbItems(),
        ),
        backgroundColor: colorScheme.surface,
      ),
      drawer: _buildDrawer(context),
      body: Center(
        child: PageView(
          controller: _pageController,
          onPageChanged: (int index) {
            setState(() {
              _selectedPage = index;
            });
          },
          children: [
            ToolsPage(
              selectedCollection: _selectedCollection,
              onCollectionSelected: _onCollectionSelected,
            ),
            LayoutsPage(
              selectedCollection: _selectedCollection,
              onCollectionSelected: _onCollectionSelected,
            ),
          ]
        ),
      ),
    );
  }

}

