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
  final TextEditingController _playerIdController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  Athlete? _foundPlayer;

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
    {'id': '4426515', 'name': 'Breece Hall', 'position': 'RB', 'team': 'NYJ'},
    {'id': '4362887', 'name': 'Jahmyr Gibbs', 'position': 'RB', 'team': 'DET'},
    {'id': '4046691', 'name': 'Justin Jefferson', 'position': 'WR', 'team': 'MIN'},
    {'id': '4239996', 'name': 'CeeDee Lamb', 'position': 'WR', 'team': 'DAL'},
    {'id': '4241986', 'name': 'Ja\'Marr Chase', 'position': 'WR', 'team': 'CIN'},
    {'id': '4362628', 'name': 'Amon-Ra St. Brown', 'position': 'WR', 'team': 'DET'},
    {'id': '4241389', 'name': 'Garrett Wilson', 'position': 'WR', 'team': 'NYJ'},
    {'id': '3128720', 'name': 'Tyreek Hill', 'position': 'WR', 'team': 'MIA'},
    {'id': '3046439', 'name': 'Travis Kelce', 'position': 'TE', 'team': 'KC'},
    {'id': '4241389', 'name': 'Sam LaPorta', 'position': 'TE', 'team': 'DET'},
    {'id': '4241478', 'name': 'Brock Bowers', 'position': 'TE', 'team': 'LV'},
    {'id': '3694650', 'name': 'George Kittle', 'position': 'TE', 'team': 'SF'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _playerIdController.dispose();
    super.dispose();
  }

  Future<void> _lookupPlayerById(String athleteId) async {
    if (athleteId.trim().isEmpty) {
      setState(() {
        _error = 'Please enter a player ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _foundPlayer = null;
    });

    try {
      final athlete = await _service.getAthleteDetails(athleteId.trim());
      setState(() {
        _foundPlayer = athlete;
        _isLoading = false;
      });

      // Navigate to player history
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerHistoryScreen(
              athleteId: athlete.id,
              athleteName: athlete.displayName,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Player not found. Please check the ID and try again.';
        _isLoading = false;
      });
    }
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
          const Divider(),
          Expanded(child: _buildPopularPlayersList()),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search by Player ID',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter ESPN Player ID to view statistics',
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
                  controller: _playerIdController,
                  decoration: InputDecoration(
                    labelText: 'Player ID',
                    hintText: 'e.g., 3139477',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person_search),
                    errorText: _error,
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: _lookupPlayerById,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _lookupPlayerById(_playerIdController.text),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Search'),
              ),
            ],
          ),
        ],
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
