import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/list_model.dart';
import '../providers/list_provider.dart';

class ListDetailPage extends StatefulWidget {
  final RandomList list;

  const ListDetailPage({Key? key, required this.list}) : super(key: key);

  @override
  _ListDetailPageState createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  late RandomList _list;

  @override
  void initState() {
    super.initState();
    _list = widget.list;
  }

  void _saveList() {
    // 使用Provider保存列表
    Provider.of<ListProvider>(context, listen: false).saveList(_list);
  }

  void _showEditListDialog() {
    final TextEditingController nameController = TextEditingController(
      text: _list.name,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
                title: Text('编辑列表'),
                content: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '列表名称',
                    hintText: '请输入列表名称',
                  ),
                  autofocus: true,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('取消'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (nameController.text.trim().isNotEmpty) {
                        final updatedList = _list.copyWith(
                          name: nameController.text.trim(),
                        );

                        setState(() {
                          _list = updatedList;
                        });

                        _saveList();
                        Navigator.pop(context);
                      }
                    },
                    child: Text('保存'),
                  ),
                ],
              ),
    );
  }

  Future<void> _deleteList() async {
    final confirmed =
        await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                        title: Text('删除列表'),
                        content: Text('确定要删除列表 "${_list.name}" 吗？这将删除所有列表项。'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('取消'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('删除'),
                          ),
                        ],
                      ),
            ) ??
            false;

    if (confirmed) {
      // 使用Provider删除列表
      Provider.of<ListProvider>(context, listen: false).deleteList(_list.id);
      Navigator.pop(context);
    }
  }

  void _showAddItemDialog() {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
                title: Text('添加列表项'),
                content: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: '列表项文本',
                    hintText: '请输入列表项文本',
                  ),
                  autofocus: true,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (textController.text.trim().isNotEmpty) {
                        final newItem = ListItem(
                          id: Uuid().v4(),
                          text: textController.text.trim(),
                        );

                        setState(() {
                          final updatedItems = List<ListItem>.from(_list.items);
                          updatedItems.add(newItem);
                          _list = _list.copyWith(items: updatedItems);
                        });

                        _saveList();
                        Navigator.pop(context);
                      }
                    },
                    child: Text('添加'),
                  ),
                ],
              ),
    );
  }

  void _showEditItemDialog(ListItem item) {
    final TextEditingController textController = TextEditingController(
      text: item.text,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
                title: Text('编辑列表项'),
                content: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: '列表项文本',
                    hintText: '请输入列表项文本',
                  ),
                  autofocus: true,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (textController.text.trim().isNotEmpty) {
                        final updatedItem = item.copyWith(
                          text: textController.text.trim(),
                        );

                        setState(() {
                          final itemIndex = _list.items.indexWhere(
                            (i) => i.id == item.id,
                          );
                          if (itemIndex != -1) {
                            final updatedItems = List<ListItem>.from(_list.items);
                            updatedItems[itemIndex] = updatedItem;
                            _list = _list.copyWith(items: updatedItems);
                          }
                        });

                        _saveList();
                        Navigator.pop(context);
                      }
                    },
                    child: Text('保存'),
                  ),
                ],
              ),
    );
  }

  void _deleteItem(ListItem item) {
    setState(() {
      final updatedItems = List<ListItem>.from(_list.items);
      updatedItems.removeWhere((i) => i.id == item.id);
      _list = _list.copyWith(items: updatedItems);
    });

    _saveList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("列表管理 - ${_list.name}"),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit_list') {
                _showEditListDialog();
              } else if (value == 'delete_list') {
                _deleteList();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit_list',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('编辑列表'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete_list',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20),
                    SizedBox(width: 8),
                    Text('删除列表'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _list.items.isEmpty
          ? Center(child: Text('暂无列表项，点击右下角按钮添加'))
          : ListView.builder(
              itemCount: _list.items.length,
              itemBuilder: (context, index) {
                final item = _list.items[index];
                return ListTile(
                  title: Text(item.text),
                  subtitle: Text('使用次数: ${item.usageCount}'),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit_item') {
                        _showEditItemDialog(item);
                      } else if (value == 'delete_item') {
                        _deleteItem(item);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit_item',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('编辑'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete_item',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20),
                            SizedBox(width: 8),
                            Text('删除'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
