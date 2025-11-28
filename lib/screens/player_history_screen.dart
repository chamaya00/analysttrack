import 'package:flutter/material.dart';
import '../services/espn_nfl_service.dart';
import '../models/player_models.dart';
import 'package:intl/intl.dart';

/// Screen to display historical statistics for a player
class PlayerHistoryScreen extends StatefulWidget {
  final String athleteId;
  final String athleteName;

  const PlayerHistoryScreen({
    super.key,
    required this.athleteId,
    required this.athleteName,
  });

  @override
  State<PlayerHistoryScreen> createState() => _PlayerHistoryScreenState();
}

class _PlayerHistoryScreenState extends State<PlayerHistoryScreen> {
  final ESPNNFLService _service = ESPNNFLService();
  Athlete? _athlete;
  List<PlayerStatsLogEntry>? _gameLogs;
  bool _isLoading = false;
  String? _error;

  // Season controls
  int _selectedSeason = DateTime.now().year;
  int _selectedSeasonType = 2; // Regular season

  final Map<int, String> _seasonTypes = {
    1: 'Preseason',
    2: 'Regular Season',
    3: 'Postseason',
  };

  @override
  void initState() {
    super.initState();
    _loadPlayerData();
  }

  Future<void> _loadPlayerData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load athlete details
      final athlete = await _service.getAthleteDetails(widget.athleteId);

      // Load game logs
      final gameLogs = await _service.getPlayerStatsLog(
        widget.athleteId,
        _selectedSeason,
        _selectedSeasonType,
      );

      setState(() {
        _athlete = athlete;
        _gameLogs = gameLogs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.athleteName),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlayerData,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_athlete != null) _buildPlayerHeader(),
          _buildSeasonSelector(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildPlayerHeader() {
    if (_athlete == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        children: [
          if (_athlete!.headshot != null)
            ClipOval(
              child: Image.network(
                _athlete!.headshot!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 40),
                  );
                },
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _athlete!.displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_athlete!.position != null)
                  Text(
                    'Position: ${_athlete!.position}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                if (_athlete!.jersey != null)
                  Text(
                    'Jersey: #${_athlete!.jersey}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey[200],
      child: Row(
        children: [
          // Season year selector
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedSeason,
              decoration: const InputDecoration(
                labelText: 'Season',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: List.generate(5, (index) {
                final year = DateTime.now().year - index;
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSeason = value;
                  });
                  _loadPlayerData();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          // Season type selector
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedSeasonType,
              decoration: const InputDecoration(
                labelText: 'Type',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _seasonTypes.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSeasonType = value;
                  });
                  _loadPlayerData();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading player statistics...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading stats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPlayerData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_gameLogs == null || _gameLogs!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_football, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No games found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'No statistics available for ${_seasonTypes[_selectedSeasonType]} $_selectedSeason',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _gameLogs!.length,
      itemBuilder: (context, index) {
        final gameLog = _gameLogs![index];
        return _buildGameLogCard(gameLog);
      },
    );
  }

  Widget _buildGameLogCard(PlayerStatsLogEntry gameLog) {
    final dateFormat = DateFormat('MMM d, y');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          'vs ${gameLog.opponent}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          dateFormat.format(gameLog.date),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildStatsGrid(gameLog.stats),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    if (stats.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No statistics available for this game'),
      );
    }

    final statEntries = stats.entries.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: statEntries.length,
      itemBuilder: (context, index) {
        final entry = statEntries[index];
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.value.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
