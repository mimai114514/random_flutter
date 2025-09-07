import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/list_model.dart';
import 'providers/list_provider.dart';

class ListModePage extends StatelessWidget {
  const ListModePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ListProvider>(
      builder: (context, listProvider, child) {
        if (listProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (listProvider.lists.isEmpty) {
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

        switch (listProvider.isChoosing) {
          case true:
            return Center(
              child: listProvider.selectedItem != null
                  ? Text(
                      listProvider.selectedItem!.text,
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
                    value: listProvider.selectedList ?? listProvider.lists.first,
                    items: listProvider.lists.map((list) {
                      return DropdownMenuItem<RandomList>(
                        value: list,
                        child: Text(list.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        listProvider.selectList(value);
                      }
                    },
                  ),
                ),
                SizedBox(height: 12),
                listProvider.selectedList != null
                    ? SizedBox()
                    : Text('请选择一个列表'),
              ],
            );
        }
      },
    );
  }
}
