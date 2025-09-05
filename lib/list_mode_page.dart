import 'package:flutter/material.dart';
import 'models/list_model.dart';

class ListModePage extends StatelessWidget {
  final List<RandomList> lists;
  final RandomList? selectedList;
  final ListItem? selectedItem;
  final bool isChoosing;
  final bool isLoading;
  final Function(RandomList) onListSelected;
  final VoidCallback onButtonPressed;

  const ListModePage({
    Key? key,
    required this.lists,
    required this.selectedList,
    required this.selectedItem,
    required this.isChoosing,
    required this.isLoading,
    required this.onListSelected,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (lists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('暂无可用列表'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 导航到设置页面的列表管理
                Navigator.pushNamed(context, '/settings');
              },
              child: Text('前往创建列表'),
            ),
          ],
        ),
      );
    }

    switch (isChoosing) {
      case true:
        return Center(
          child: selectedItem != null
              ? Text(
                  selectedItem!.content,
                  style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )
              : Text('未选中项目'),
        );
      case false:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<RandomList>(
                decoration: InputDecoration(
                  labelText: '选择列表',
                  border: OutlineInputBorder(),
                ),
                value: selectedList ?? lists.first,
                items: lists.map((list) {
                  return DropdownMenuItem<RandomList>(
                    value: list,
                    child: Text(list.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onListSelected(value);
                  }
                },
              ),
            ),
            SizedBox(height: 12),
            selectedList != null
                ? Text(
                    '点击下方按钮从 ${selectedList!.name} 中随机抽取',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  )
                : Text('请选择一个列表'),
          ],
        );
    }
  }
}
