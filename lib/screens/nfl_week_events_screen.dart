import 'package:flutter/material.dart';
import '../models/event_models.dart';
import '../services/espn_nfl_service.dart';

/// Screen displaying NFL events for a specific week
class NFLWeekEventsScreen extends StatefulWidget {
  const NFLWeekEventsScreen({super.key});

  @override
  State<NFLWeekEventsScreen> createState() => _NFLWeekEventsScreenState();
}

class _NFLWeekEventsScreenState extends State<NFLWeekEventsScreen> {
  final ESPNNFLService _service = ESPNNFLService();

  // Controllers for input fields - properly disposed
  late final TextEditingController _seasonController;
  late final TextEditingController _weekController;

  // State variables
  List<EventDetails>? _events;
  bool _isLoading = false;
  String? _error;
  int _loadingProgress = 0;
  int _loadingTotal = 0;

  int _season = 2025;
  int _seasonType = 2; // Regular season
  int _week = 1;

  @override
  void initState() {
    super.initState();
    _seasonController = TextEditingController(text: _season.toString());
    _weekController = TextEditingController(text: _week.toString());
    _loadEvents();
  }

  @override
  void dispose() {
    _seasonController.dispose();
    _weekController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _loadingProgress = 0;
      _loadingTotal = 0;
    });

    try {
      final events = await _service.getAllWeekEventsWithDetails(
        _season,
        _seasonType,
        _week,
        onProgress: (current, total) {
          setState(() {
            _loadingProgress = current;
            _loadingTotal = total;
          });
        },
      );

      setState(() {
        _events = events;
        _isLoading = false;
      });
    } on ESPNServiceException catch (e) {
      setState(() {
        _error = _formatError(e);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Unexpected error: $e';
        _isLoading = false;
      });
    }
  }

  String _formatError(ESPNServiceException e) {
    if (e.isNetworkError) {
      return 'Network error. Check your connection.';
    } else if (e.isClientError) {
      return 'Invalid request. Check season/week values.';
    } else if (e.isServerError) {
      return 'ESPN server error. Try again later.';
    } else {
      return e.message;
    }
  }

  void _updateSeason(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed >= 2000 && parsed <= 2030) {
      _season = parsed;
    }
  }

  void _updateWeek(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed >= 1 && parsed <= 18) {
      _week = parsed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFL Week $_week - $_season'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildControls(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Season',
                      border: OutlineInputBorder(),
                      hintText: '2025',
                    ),
                    keyboardType: TextInputType.number,
                    controller: _seasonController,
                    onChanged: _updateSeason,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Week',
                      border: OutlineInputBorder(),
                      hintText: '1-18',
                    ),
                    keyboardType: TextInputType.number,
                    controller: _weekController,
                    onChanged: _updateWeek,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 1, label: Text('Preseason')),
                      ButtonSegment(value: 2, label: Text('Regular')),
                      ButtonSegment(value: 3, label: Text('Postseason')),
                    ],
                    selected: {_seasonType},
                    onSelectionChanged: (Set<int> selected) {
                      setState(() {
                        _seasonType = selected.first;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _loadEvents,
                icon: const Icon(Icons.refresh),
                label: const Text('Load Events'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_events == null || _events!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_football, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No events found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return _buildEventsList();
  }

  Widget _buildLoadingState() {
    final progress = _loadingTotal > 0
        ? _loadingProgress / _loadingTotal
        : null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
            ),
          ),
          const SizedBox(height: 24),
          if (_loadingTotal > 0)
            Text(
              'Loading events... $_loadingProgress/$_loadingTotal',
              style: const TextStyle(fontSize: 16),
            )
          else
            const Text(
              'Loading events...',
              style: TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadEvents,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return ListView.builder(
      itemCount: _events!.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final event = _events![index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(EventDetails event) {
    final homeTeam = event.competition?.homeTeam;
    final awayTeam = event.competition?.awayTeam;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showEventDetails(event),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event name and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.shortName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${event.date.month}/${event.date.day}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Teams and scores if available
              if (homeTeam != null && awayTeam != null) ...[
                _buildTeamRow(awayTeam, isHome: false),
                const SizedBox(height: 4),
                _buildTeamRow(homeTeam, isHome: true),
              ],

              // Status indicator
              const SizedBox(height: 8),
              _buildStatusChip(event),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamRow(Competitor team, {required bool isHome}) {
    return Row(
      children: [
        if (isHome)
          const Icon(Icons.home, size: 16, color: Colors.grey)
        else
          const SizedBox(width: 16),
        const SizedBox(width: 8),
        Text(
          team.abbreviation,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (team.score != null)
          Text(
            team.score.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip(EventDetails event) {
    Color color;
    String label;

    if (event.isCompleted) {
      color = Colors.grey;
      label = 'Final';
    } else if (event.isInProgress) {
      color = Colors.green;
      label = 'Live';
    } else {
      color = Colors.blue;
      label = 'Scheduled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showEventDetails(EventDetails event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Event ID', event.id),
              _buildDetailRow('Date', event.date.toString()),
              if (event.competition?.venue != null)
                _buildDetailRow('Venue', event.competition!.venue!),
              if (event.competition?.homeTeam != null) ...[
                const Divider(),
                _buildDetailRow('Home', event.competition!.homeTeam!.name),
                if (event.competition!.homeTeam!.score != null)
                  _buildDetailRow(
                    'Score',
                    event.competition!.homeTeam!.score.toString(),
                  ),
              ],
              if (event.competition?.awayTeam != null) ...[
                const Divider(),
                _buildDetailRow('Away', event.competition!.awayTeam!.name),
                if (event.competition!.awayTeam!.score != null)
                  _buildDetailRow(
                    'Score',
                    event.competition!.awayTeam!.score.toString(),
                  ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
