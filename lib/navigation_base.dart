import 'package:flutter/material.dart';
import 'dart:math';
import 'number_mode_page.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'models/list_model.dart';
import 'services/list_storage_service.dart';

class NavigationBase extends StatefulWidget {
  const NavigationBase({super.key});

  @override
  State<NavigationBase> createState() => _NavigationBaseState();
}

class _NavigationBaseState extends State<NavigationBase> {
  var _PageIndex = 0;

  // 数字模式状态
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  var _IsChoosing = false;
  var _ChosenNumber;
  var _MinNumber;
  var _MaxNumber;

  // 列表模式状态
  final ListStorageService _listStorageService = ListStorageService();
  List<RandomList> _lists = [];
  RandomList? _selectedList;
  ListItem? _selectedItem;
  bool _listIsChoosing = false;
  bool _listIsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  // 列表模式方法
  Future<void> _loadLists() async {
    setState(() {
      _listIsLoading = true;
    });

    final lists = await _listStorageService.getLists();
    setState(() {
      _lists = lists;
      _listIsLoading = false;
      // 如果之前选择了列表，尝试找到对应的列表
      if (_selectedList != null) {
        _selectedList = lists.firstWhere(
          (list) => list.id == _selectedList!.id,
          orElse: () {
            if (lists.isNotEmpty) {
              return lists.first;
            }
            return lists.first; // 返回第一个列表作为默认值，因为前面已经检查过lists不为空
          },
        );
      } else if (lists.isNotEmpty) {
        // 默认选中第一个列表
        _selectedList = lists.first;
      }
    });
  }

  void _selectList(RandomList list) {
    setState(() {
      _selectedList = list;
      _selectedItem = null;
      _listIsChoosing = false;
    });
  }

  Future<void> _getRandomListItem() async {
    if (_selectedList == null || _selectedList!.items.isEmpty) {
      _showErrorDialog('当前列表为空，无法抽取项目');
      return;
    }

    // 更新列表使用次数
    await _listStorageService.updateListUsage(_selectedList!.id);

    // 随机选择一个项目
    final randomItem = _selectedList!.getRandomItem();
    if (randomItem != null) {
      // 更新项目使用次数
      await _listStorageService.updateListItemUsage(
        _selectedList!.id,
        randomItem.id,
      );

      setState(() {
        _selectedItem = randomItem;
        _listIsChoosing = true;
      });
    }
  }

  void _resetListSelection() {
    setState(() {
      _listIsChoosing = false;
      _selectedItem = null;
    });
  }

  void _onListButtonPressed() {
    if (_listIsChoosing) {
      _resetListSelection();
    } else {
      _getRandomListItem();
    }
  }

  void random() {
    if (_MinNumber == null || _MaxNumber == null) {
      _showErrorDialog('请输入有效的数字');
      return;
    }

    if (_MinNumber >= _MaxNumber) {
      _showErrorDialog('最小值必须小于最大值');
      return;
    }

    final random = Random();
    setState(() {
      _ChosenNumber = _MinNumber + random.nextInt(_MaxNumber - _MinNumber + 1);
      _IsChoosing = true;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('错误'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void confirm() {
    setState(() {
      _IsChoosing = false;
    });
  }

  void onPressed() {
    switch (_IsChoosing) {
      case true:
        confirm();
        break;
      case false:
        random();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_PageIndex) {
      case 0:
        page = HomePage(
          // 数字模式属性
          minController: _minController,
          maxController: _maxController,
          isChoosing: _IsChoosing,
          chosenNumber: _ChosenNumber,
          onMinChanged:
              (value) => setState(() {
                _MinNumber = int.tryParse(value);
              }),
          onMaxChanged:
              (value) => setState(() {
                _MaxNumber = int.tryParse(value);
              }),
          onButtonPressed: onPressed,
          // 列表模式属性
          lists: _lists,
          selectedList: _selectedList,
          selectedItem: _selectedItem,
          listIsChoosing: _listIsChoosing,
          listIsLoading: _listIsLoading,
          onListSelected: _selectList,
          onListButtonPressed: _onListButtonPressed,
        );
        break;
      case 1:
        page = SettingsPage();
        break;
      default:
        page = const Center(child: Text('Unknown Page'));
    }

    return Scaffold(
      body: page,
      bottomNavigationBar: NavigationBar(
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedIndex: _PageIndex,
        onDestinationSelected: (int index) {
          if (index != _PageIndex) {
            setState(() {
              _PageIndex = index;
            });
          }
        },
      ),
    );
  }
}
