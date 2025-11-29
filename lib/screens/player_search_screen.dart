import 'package:flutter/material.dart';
import '../services/espn_nfl_service.dart';
import '../models/player_models.dart';
import 'player_history_screen.dart';

/// Screen for searching and selecting NFL players
class PlayerSearchScreen extends StatefulWidget {
  const PlayerSearchScreen({super.key});

  @override
  State<PlayerSearchScreen> createState() => _PlayerSearchScreenState();
}

class _PlayerSearchScreenState extends State<PlayerSearchScreen> {
  final ESPNNFLService _service = ESPNNFLService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  List<Athlete>? _searchResults;
  String? _lastSearchQuery;

  // Popular players with their ESPN IDs (this is a curated list)
  final List<Map<String, String>> _popularPlayers = [
    {'id': '3139477', 'name': 'Patrick Mahomes', 'position': 'QB', 'team': 'KC'},
    {'id': '4035687', 'name': 'Lamar Jackson', 'position': 'QB', 'team': 'BAL'},
    {'id': '4361741', 'name': 'CJ Stroud', 'position': 'QB', 'team': 'HOU'},
    {'id': '3116407', 'name': 'Josh Allen', 'position': 'QB', 'team': 'BUF'},
    {'id': '4362628', 'name': 'Brock Purdy', 'position': 'QB', 'team': 'SF'},
    {'id': '4242335', 'name': 'Jalen Hurts', 'position': 'QB', 'team': 'PHI'},
    {'id': '4040715', 'name': 'Joe Burrow', 'position': 'QB', 'team': 'CIN'},
    {'id': '3052587', 'name': 'Dak Prescott', 'position': 'QB', 'team': 'DAL'},
    {'id': '3917792', 'name': 'Justin Herbert', 'position': 'QB', 'team': 'LAC'},
    {'id': '4361423', 'name': 'Anthony Richardson', 'position': 'QB', 'team': 'IND'},
    {'id': '4429160', 'name': 'Caleb Williams', 'position': 'QB', 'team': 'CHI'},
    {'id': '4426515', 'name': 'Jayden Daniels', 'position': 'QB', 'team': 'WAS'},
    {'id': '4241457', 'name': 'Derrick Henry', 'position': 'RB', 'team': 'BAL'},
    {'id': '3116593', 'name': 'Christian McCaffrey', 'position': 'RB', 'team': 'SF'},
    {'id': '4360294', 'name': 'Bijan Robinson', 'position': 'RB', 'team': 'ATL'},
    {'id': '4240021', 'name': 'Saquon Barkley', 'position': 'RB', 'team': 'PHI'},
    {'id': '4362938', 'name': 'Breece Hall', 'position': 'RB', 'team': 'NYJ'},
    {'id': '4362887', 'name': 'Jahmyr Gibbs', 'position': 'RB', 'team': 'DET'},
    {'id': '4046691', 'name': 'Justin Jefferson', 'position': 'WR', 'team': 'MIN'},
    {'id': '4239996', 'name': 'CeeDee Lamb', 'position': 'WR', 'team': 'DAL'},
    {'id': '4241986', 'name': 'Ja\'Marr Chase', 'position': 'WR', 'team': 'CIN'},
    {'id': '4033049', 'name': 'Amon-Ra St. Brown', 'position': 'WR', 'team': 'DET'},
    {'id': '4241389', 'name': 'Garrett Wilson', 'position': 'WR', 'team': 'NYJ'},
    {'id': '3128720', 'name': 'Tyreek Hill', 'position': 'WR', 'team': 'MIA'},
    {'id': '3046439', 'name': 'Travis Kelce', 'position': 'TE', 'team': 'KC'},
    {'id': '4567048', 'name': 'Sam LaPorta', 'position': 'TE', 'team': 'DET'},
    {'id': '4431353', 'name': 'Brock Bowers', 'position': 'TE', 'team': 'LV'},
    {'id': '3694650', 'name': 'George Kittle', 'position': 'TE', 'team': 'SF'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlayersByName(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _error = 'Please enter at least 2 characters to search';
        _searchResults = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _searchResults = null;
      _lastSearchQuery = query.trim();
    });

    try {
      final athletes = await _service.searchPlayers(query.trim());
      setState(() {
        _searchResults = athletes;
        _isLoading = false;
        if (athletes.isEmpty) {
          _error = 'No players found matching "$query"';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Search failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults = null;
      _error = null;
      _lastSearchQuery = null;
    });
  }

  void _viewPlayerHistory(String athleteId, String athleteName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerHistoryScreen(
          athleteId: athleteId,
          athleteName: athleteName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Search'),
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          if (_isLoading) _buildLoadingState(),
          if (!_isLoading && _searchResults != null) _buildSearchResults(),
          if (!_isLoading && _searchResults == null) ...[
            const Divider(),
            Expanded(child: _buildPopularPlayersList()),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search for NFL Players',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter player name (e.g., "Mahomes", "Jefferson")',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Player Name',
                    hintText: 'Enter at least 2 characters',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {}); // Rebuild to show/hide clear button
                  },
                  onSubmitted: _searchPlayersByName,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _searchPlayersByName(_searchController.text),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Search'),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(
                  color: _searchResults == null ? Colors.red : Colors.orange[700],
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching for players...'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults == null || _searchResults!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Results for "$_lastSearchQuery"',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_searchResults!.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _searchResults!.length,
              itemBuilder: (context, index) {
                final athlete = _searchResults![index];
                return _buildAthleteCard(athlete);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAthleteCard(Athlete athlete) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: athlete.headshot != null
            ? ClipOval(
                child: Image.network(
                  athlete.headshot!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPositionAvatar(athlete.position ?? 'N/A');
                  },
                ),
              )
            : _buildPositionAvatar(athlete.position ?? 'N/A'),
        title: Text(
          athlete.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${athlete.position ?? 'Unknown Position'}${athlete.jersey != null ? ' #${athlete.jersey}' : ''}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _viewPlayerHistory(athlete.id, athlete.displayName),
      ),
    );
  }

  Widget _buildPositionAvatar(String position) {
    return CircleAvatar(
      backgroundColor: Colors.blue[700],
      child: Text(
        position.length > 3 ? position.substring(0, 3) : position,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPopularPlayersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Popular Players',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_popularPlayers.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _popularPlayers.length,
            itemBuilder: (context, index) {
              final player = _popularPlayers[index];
              return _buildPlayerCard(
                player['name']!,
                player['position']!,
                player['team']!,
                player['id']!,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(
    String name,
    String position,
    String team,
    String athleteId,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[700],
          child: Text(
            position,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('$position - $team'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _viewPlayerHistory(athleteId, name),
      ),
    );
  }
}
