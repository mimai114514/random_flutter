import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/list_model.dart';
import '../services/list_storage_service.dart';

class ListDetailPage extends StatefulWidget {
  final RandomList list;

  const ListDetailPage({Key? key, required this.list}) : super(key: key);

  @override
  _ListDetailPageState createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  late RandomList _list;
  final ListStorageService _storageService = ListStorageService();

  @override
  void initState() {
    super.initState();
    _list = widget.list;
  }

  Future<void> _saveList() async {
    await _storageService.saveList(_list);
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

                        await _saveList();
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
      await _storageService.deleteList(_list.id);
      Navigator.pop(context);
    }
  }

  void _showAddItemDialog() {
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('添加列表项'),
            content: TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: '内容',
                hintText: '请输入列表项内容',
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
                  if (contentController.text.trim().isNotEmpty) {
                    final newItem = ListItem(
                      id: Uuid().v4(),
                      content: contentController.text.trim(),
                    );

                    setState(() {
                      _list.addItem(newItem);
                    });

                    await _saveList();
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
    final TextEditingController contentController = TextEditingController(
      text: item.content,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('编辑列表项'),
            content: TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: '内容',
                hintText: '请输入列表项内容',
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
                  if (contentController.text.trim().isNotEmpty) {
                    final updatedItem = item.copyWith(
                      content: contentController.text.trim(),
                    );

                    setState(() {
                      _list.updateItem(updatedItem);
                    });

                    await _saveList();
                    Navigator.pop(context);
                  }
                },
                child: Text('保存'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteItem(String itemId) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('删除列表项'),
                content: Text('确定要删除此列表项吗？'),
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
      setState(() {
        _list.removeItem(itemId);
      });

      await _saveList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('列表详情-${_list.name}'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditListDialog();
              } else if (value == 'delete') {
                _deleteList();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('编辑列表'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
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
      body:
          _list.items.isEmpty
              ? Center(child: Text('暂无列表项，点击右下角按钮添加'))
              : ListView.builder(
                itemCount: _list.items.length,
                itemBuilder: (context, index) {
                  final item = _list.items[index];
                  return ListTile(
                    key: ValueKey(item.id),
                    title: Text(item.content),
                    subtitle: Text('使用次数: ${item.usageCount}'),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditItemDialog(item);
                        } else if (value == 'delete') {
                          _deleteItem(item.id);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('编辑'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
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
