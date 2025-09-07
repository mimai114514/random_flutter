import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'providers/list_provider.dart';
import 'list_mode_page.dart';

class NavigationBase extends StatefulWidget {
  @override
  _NavigationBaseState createState() => _NavigationBaseState();
}

class _NavigationBaseState extends State<NavigationBase> {
  int _selectedIndex = 0;
  
  // 数字模式状态
  final TextEditingController _minController = TextEditingController(text: '1');
  final TextEditingController _maxController = TextEditingController(text: '100');
  bool _isChoosing = false;
  int? _chosenNumber;

  @override
  void initState() {
    super.initState();
    // 初始化时加载列表数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListProvider>(context, listen: false).loadLists();
    });
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  // 数字模式方法
  void _random() {
    if (_minController.text.isEmpty || _maxController.text.isEmpty) {
      _showErrorDialog('请输入最小值和最大值');
      return;
    }

    int? min = int.tryParse(_minController.text);
    int? max = int.tryParse(_maxController.text);

    if (min == null || max == null) {
      _showErrorDialog('请输入有效的数字');
      return;
    }

    if (min >= max) {
      _showErrorDialog('最小值必须小于最大值');
      return;
    }

    setState(() {
      _isChoosing = true;
      _chosenNumber = min + (DateTime.now().millisecondsSinceEpoch % (max - min + 1));
    });
  }

  void _confirm() {
    setState(() {
      _isChoosing = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('错误'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listProvider = Provider.of<ListProvider>(context);
    
    Widget page;
    if (_selectedIndex == 0) {
      // 主页
      page = HomePage(
        // 数字模式属性
        minController: _minController,
        maxController: _maxController,
        isChoosing: _isChoosing,
        chosenNumber: _chosenNumber,
        onMinChanged: (value) {},
        onMaxChanged: (value) {},
        onButtonPressed: _isChoosing ? _confirm : _random,
        // 列表模式属性
        listModePage: ListModePage(),
        onListButtonPressed: () => listProvider.toggleSelection(),
      );
    } else if (_selectedIndex == 1) {
      // 设置页面
      page = SettingsPage();
    } else {
      // 未知页面
      page = Center(child: Text('未知页面'));
    }

    return Scaffold(
      body: page,
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
