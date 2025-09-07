import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/history_model.dart';
import 'providers/history_provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 初始化时加载历史记录
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false).loadHistoryRecords();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '数字模式'),
            Tab(text: '列表模式'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: '清除所有历史记录',
            onPressed: () => _showClearHistoryDialog(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          NumberHistoryTab(),
          ListHistoryTab(),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除历史记录'),
        content: const Text('确定要清除所有历史记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<HistoryProvider>(context, listen: false).clearHistoryRecords();
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class NumberHistoryTab extends StatelessWidget {
  const NumberHistoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, child) {
        if (historyProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final numberRecords = historyProvider.numberHistoryRecords;

        if (numberRecords.isEmpty) {
          return const Center(child: Text('暂无数字模式历史记录'));
        }

        return ListView.builder(
          itemCount: numberRecords.length,
          itemBuilder: (context, index) {
            final record = numberRecords[index];
            return ListTile(
              title: Text(
                record.result,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  Text(
                    record.formattedTimestamp,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '范围: ${record.range}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ListHistoryTab extends StatelessWidget {
  const ListHistoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, child) {
        if (historyProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final listRecords = historyProvider.listHistoryRecords;

        if (listRecords.isEmpty) {
          return const Center(child: Text('暂无列表模式历史记录'));
        }

        return ListView.builder(
          itemCount: listRecords.length,
          itemBuilder: (context, index) {
            final record = listRecords[index];
            return ListTile(
              title: Text(
                record.result,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  Text(
                    record.formattedTimestamp,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '列表: ${record.listName}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}