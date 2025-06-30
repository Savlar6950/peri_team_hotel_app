import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ListAllEntries extends StatefulWidget {
  final bool isSuperuser;
  final VoidCallback? onUpdate;

  const ListAllEntries({
    super.key,
    required this.isSuperuser,
    this.onUpdate,
  });

  @override
  State<ListAllEntries> createState() => _ListAllEntriesState();
}

class _ListAllEntriesState extends State<ListAllEntries> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('hotels');
  List<Map<dynamic, dynamic>> _allEntries = [];
  List<Map<dynamic, dynamic>> _filteredEntries = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime _parseTimestamp(dynamic ts) {
    try {
      if (ts is int) {
        return DateTime.fromMillisecondsSinceEpoch(ts, isUtc: true);
      } else if (ts is String) {
        return DateTime.parse(ts).toUtc();
      }
    } catch (_) {}
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    final snapshot = await _dbRef.get();
    final List<Map<dynamic, dynamic>> entries = [];

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        final data = child.value as Map<dynamic, dynamic>;
        data['key'] = child.key;
        entries.add(data);
      }

      entries.sort((a, b) {
        final aTime = _parseTimestamp(a['timestamp']);
        final bTime = _parseTimestamp(b['timestamp']);
        return bTime.compareTo(aTime);
      });
    }

    setState(() {
      _allEntries = entries;
      _filteredEntries = entries;
      _loading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredEntries = List.from(_allEntries);
      } else {
        _filteredEntries = _allEntries
            .where((entry) =>
                (entry['postcode'] ?? '').toString().toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _confirmDelete(String key) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Do you want to delete this entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _dbRef.child(key).remove();
              widget.onUpdate?.call();
              _loadEntries();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCSV() async {
    final headers = ['Hotel Name', 'Postcode', 'Reason', 'Added By', 'Date (GMT)', 'Full Address'];
    final csvData = StringBuffer()..writeln(headers.join(','));

    for (final e in _filteredEntries) {
      final date = DateFormat('yyyy-MM-dd HH:mm:ss').format(_parseTimestamp(e['timestamp']));
      final row = [
        e['hotelName'] ?? '',
        e['postcode'] ?? '',
        e['description'] ?? '',
        e['user'] ?? '',
        date,
        e['fullAddress'] ?? ''
      ];
      csvData.writeln(row.map((cell) => '"$cell"').join(','));
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/hotel_entries.csv');
    await file.writeAsString(csvData.toString());
    await Share.shareXFiles([XFile(file.path)], text: 'All Hotel Entries Exported');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF392A87),
      appBar: AppBar(
        title: const Text("All Hotel Entries"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export to CSV',
            onPressed: _filteredEntries.isNotEmpty ? _exportToCSV : null,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Search by postcode',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredEntries.isEmpty
                      ? const Center(
                          child: Text('No matching entries found.',
                              style: TextStyle(color: Colors.white)))
                      : ListView.separated(
                          itemCount: _filteredEntries.length,
                          separatorBuilder: (_, __) => const Divider(color: Colors.white),
                          itemBuilder: (context, index) {
                            final e = _filteredEntries[index];
                            final date = DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(_parseTimestamp(e['timestamp']));

                            return ListTile(
                              title: Text(
                                '${e['hotelName']} (${e['postcode']})',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Reason: ${e['description']}\nAdded by: ${e['user']} on $date\n${e['fullAddress'] ?? ""}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              onLongPress: widget.isSuperuser && e['key'] != null
                                  ? () => _confirmDelete(e['key'])
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
