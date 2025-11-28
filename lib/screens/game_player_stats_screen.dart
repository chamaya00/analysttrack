import 'package:flutter/material.dart';
import '../services/espn_nfl_service.dart';
import '../models/player_models.dart';

/// Screen to display player statistics for a specific game
class GamePlayerStatsScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const GamePlayerStatsScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<GamePlayerStatsScreen> createState() => _GamePlayerStatsScreenState();
}

class _GamePlayerStatsScreenState extends State<GamePlayerStatsScreen> {
  final ESPNNFLService _service = ESPNNFLService();
  GameBoxscore? _boxscore;
  bool _isLoading = false;
  String? _error;
  int _selectedTeamIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBoxscore();
  }

  Future<void> _loadBoxscore() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final boxscore = await _service.getGameBoxscore(widget.eventId);
      setState(() {
        _boxscore = boxscore;
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
        title: Text(widget.eventName),
        backgroundColor: Colors.blue[700],
      ),
      body: _buildBody(),
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
              onPressed: _loadBoxscore,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_boxscore == null || _boxscore!.teams.isEmpty) {
      return const Center(
        child: Text('No player statistics available for this game'),
      );
    }

    return Column(
      children: [
        _buildTeamSelector(),
        Expanded(child: _buildStatsContent()),
      ],
    );
  }

  Widget _buildTeamSelector() {
    if (_boxscore == null) return const SizedBox.shrink();

    return Container(
      color: Colors.grey[200],
      child: Row(
        children: List.generate(_boxscore!.teams.length, (index) {
          final team = _boxscore!.teams[index];
          final isSelected = _selectedTeamIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTeamIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[700] : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Colors.blue[900]! : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  team.teamAbbreviation,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatsContent() {
    if (_boxscore == null || _selectedTeamIndex >= _boxscore!.teams.length) {
      return const SizedBox.shrink();
    }

    final team = _boxscore!.teams[_selectedTeamIndex];

    if (team.statistics.isEmpty) {
      return const Center(
        child: Text('No statistics available for this team'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: team.statistics.length,
      itemBuilder: (context, index) {
        final category = team.statistics[index];
        return _buildStatCategoryCard(category);
      },
    );
  }

  Widget _buildStatCategoryCard(StatCategory category) {
    if (category.athletes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          category.displayName ?? category.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${category.athletes.length} players'),
        children: [
          _buildStatsTable(category),
        ],
      ),
    );
  }

  Widget _buildStatsTable(StatCategory category) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          columnSpacing: 12,
          horizontalMargin: 12,
          headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
          columns: [
            const DataColumn(
              label: Text(
                'Player',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...category.labels.map((label) => DataColumn(
                  label: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )),
          ],
          rows: category.athletes.map((playerStats) {
            return DataRow(
              cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        playerStats.athlete.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (playerStats.athlete.position != null)
                        Text(
                          playerStats.athlete.position!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                ...playerStats.stats.map((stat) => DataCell(Text(stat))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
