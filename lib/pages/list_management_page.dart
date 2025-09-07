import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/list_model.dart';
import '../providers/list_provider.dart';
import 'list_detail_page.dart';

class ListManagementPage extends StatefulWidget {
  const ListManagementPage({Key? key}) : super(key: key);

  @override
  _ListManagementPageState createState() => _ListManagementPageState();
}

class _ListManagementPageState extends State<ListManagementPage> {
  @override
  void initState() {
    super.initState();
    // 使用Provider加载列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListProvider>(context, listen: false).loadLists();
    });
  }

  void _showAddListDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('添加新列表'),
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
                    final newList = RandomList(
                      id: Uuid().v4(),
                      name: nameController.text.trim(),
                      items: [],
                    );

                    // 使用Provider保存列表
                    Provider.of<ListProvider>(context, listen: false).saveList(newList);
                    Navigator.pop(context);
                  }
                },
                child: Text('添加'),
              ),
            ],
          ),
    );
  }

  void _showEditListDialog(RandomList list) {
    final TextEditingController nameController = TextEditingController(
      text: list.name,
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
                    final updatedList = list.copyWith(
                      name: nameController.text.trim(),
                    );

                    // 使用Provider保存列表
                    Provider.of<ListProvider>(context, listen: false).saveList(updatedList);
                    Navigator.pop(context);
                  }
                },
                child: Text('保存'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteList(RandomList list) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('删除列表'),
                content: Text('确定要删除列表 "${list.name}" 吗？这将删除所有列表项。'),
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
      Provider.of<ListProvider>(context, listen: false).deleteList(list.id);
    }
  }

  void _navigateToListDetail(RandomList list) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListDetailPage(list: list)),
    ).then((_) {
      // 返回时刷新列表
      Provider.of<ListProvider>(context, listen: false).loadLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('列表管理')),
      body: Consumer<ListProvider>(
        builder: (context, listProvider, child) {
          if (listProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (listProvider.lists.isEmpty) {
            return Center(child: Text('暂无列表，点击右下角按钮添加'));
          }
          
          return ListView.builder(
            itemCount: listProvider.lists.length,
            itemBuilder: (context, index) {
              final list = listProvider.lists[index];
              return ListTile(
                title: Text(list.name),
                subtitle: Text(
                  '${list.itemCount} 项 | 使用次数: ${list.usageCount}',
                ),
                onTap: () => _navigateToListDetail(list),
                trailing: IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () => _navigateToListDetail(list),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddListDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
