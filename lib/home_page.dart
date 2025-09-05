import 'package:flutter/material.dart';
import 'number_mode_page.dart';
import 'list_mode_page.dart';
import 'models/list_model.dart';

class HomePage extends StatefulWidget {
  // 数字模式属性
  final TextEditingController minController;
  final TextEditingController maxController;
  final bool isChoosing;
  final int? chosenNumber;
  final Function(String) onMinChanged;
  final Function(String) onMaxChanged;
  final VoidCallback onButtonPressed;
  
  // 列表模式属性
  final List<RandomList> lists;
  final RandomList? selectedList;
  final ListItem? selectedItem;
  final bool listIsChoosing;
  final bool listIsLoading;
  final Function(RandomList) onListSelected;
  final VoidCallback onListButtonPressed;

  HomePage({
    // 数字模式属性
    required this.minController,
    required this.maxController,
    required this.isChoosing,
    required this.chosenNumber,
    required this.onMinChanged,
    required this.onMaxChanged,
    required this.onButtonPressed,
    // 列表模式属性
    required this.lists,
    required this.selectedList,
    required this.selectedItem,
    required this.listIsChoosing,
    required this.listIsLoading,
    required this.onListSelected,
    required this.onListButtonPressed,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          tabs: const [Tab(text: '数字'), Tab(text: '列表')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 数字选项卡
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: NumberModePage(
                minController: widget.minController,
                maxController: widget.maxController,
                isChoosing: widget.isChoosing,
                chosenNumber: widget.chosenNumber,
                onMinChanged: widget.onMinChanged,
                onMaxChanged: widget.onMaxChanged,
                onButtonPressed: widget.onButtonPressed,
              ),
            ),
          ),
          // 列表选项卡
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: ListModePage(
                lists: widget.lists,
                selectedList: widget.selectedList,
                selectedItem: widget.selectedItem,
                isChoosing: widget.listIsChoosing,
                isLoading: widget.listIsLoading,
                onListSelected: widget.onListSelected,
                onButtonPressed: widget.onListButtonPressed,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _currentTabIndex == 0 
            ? widget.onButtonPressed 
            : widget.onListButtonPressed,
        child: Icon(
          _currentTabIndex == 0
              ? (widget.isChoosing ? Icons.check : Icons.casino)
              : (widget.listIsChoosing ? Icons.check : Icons.casino),
                ),
              ),
    );
  }
}
