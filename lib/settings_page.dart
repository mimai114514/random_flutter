import 'package:flutter/material.dart';
import 'pages/list_management_page.dart';
import 'package:provider/provider.dart';
import 'providers/list_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.list),
            title: Text('列表管理'),
            subtitle: Text('创建和管理随机列表'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListManagementPage()),
              );
            },
          ),
          // 可以在这里添加更多设置项
        ],
      ),
    );
  }
}
