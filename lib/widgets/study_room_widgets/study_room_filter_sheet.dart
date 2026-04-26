import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_room_filters.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

//stateful widget because the filter controls undate while the user is interacting with them
//for example, moving the slider, toggling the switch, or changing the dropdown selections
//uses a bottom sheet to present the filter options
class StudyRoomFilterSheet extends StatefulWidget {
  final StudyRoomFilters initialFilters;

  const StudyRoomFilterSheet({super.key, required this.initialFilters});

  @override
  State<StudyRoomFilterSheet> createState() => _StudyRoomFilterSheetState();
}

class _StudyRoomFilterSheetState extends State<StudyRoomFilterSheet> {
  static const List<String> _campusOptions = [
    'Atlanta',
    'Clarkston',
    'Decatur',
    'Dunwoody',
    'Newton',
  ];

  static const Map<String, List<String>> _campusBuildingOptions = {
    'Atlanta': ['Library Link', 'Library North', 'Study Commons'],
    'Clarkston': ['Clarkston Library'],
    'Decatur': ['Decatur Library'],
    'Dunwoody': ['Dunwoody Library'],
    'Newton': ['Newton Library'],
  };

  late String? _selectedCampus;
  late String? _selectedBuilding;
  late bool _notFull;
  late int _minCapacity;

  @override
  void initState() {
    super.initState();

    _selectedCampus = widget.initialFilters.campus;
    _selectedBuilding = widget.initialFilters.building;
    _notFull = widget.initialFilters.notFull;
    _minCapacity = widget.initialFilters.minCapacity;
  }

  //returns the building choices for the currently selected campus
  //or all buildings if no campus is selected
  List<String> get _availableBuildingOptions {
    if (_selectedCampus == null) {
      return _campusBuildingOptions.values
          .expand((buildings) => buildings)
          .toSet()
          .toList()
        ..sort();
    }

    return _campusBuildingOptions[_selectedCampus] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.bottomSheet,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitle(context),
            AppSpacing.gapLg,
            _buildCampusDropdown(),
            AppSpacing.gapMd,
            _buildBuildingDropdown(),
            AppSpacing.gapMd,
            _buildNotFullSwitch(context),
            _buildCapacitySlider(context),
            AppSpacing.gapMd,
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }


  //several individual builder widgets to make the things easier to edit
  Widget _buildTitle(BuildContext context) {
    return Text(
      'Filter Study Rooms',
      style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildCampusDropdown() {
    return DropdownMenuFormField<String?>(
      key: ValueKey(_selectedCampus),
      initialSelection: _selectedCampus,
      label: const Text('Campus'),
      expandedInsets: EdgeInsets.zero,
      //requestFocusOnTap: true,
      dropdownMenuEntries: [
        const DropdownMenuEntry<String?>(value: null, label: 'All campuses'),
        ..._campusOptions.map((campus) {
          return DropdownMenuEntry<String?>(value: campus, label: campus);
        }),
      ],
      onSelected: _onCampusChanged,
    );
  }

  Widget _buildBuildingDropdown() {
    final buildingKey =
        '${_selectedCampus ?? 'all'}|${_selectedBuilding ?? 'all'}|${_availableBuildingOptions.join(',')}';

    return DropdownMenuFormField<String?>(
      key: ValueKey(buildingKey),
      initialSelection: _selectedBuilding,
      label: const Text('Building'),
      expandedInsets: EdgeInsets.zero,
      //requestFocusOnTap: true,
      dropdownMenuEntries: [
        const DropdownMenuEntry<String?>(value: null, label: 'All buildings'),
        ..._availableBuildingOptions.map((building) {
          return DropdownMenuEntry<String?>(value: building, label: building);
        }),
      ],
      onSelected: _onBuildingChanged,
    );
  }

  Widget _buildNotFullSwitch(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        'Only show rooms with available seats',
        style: context.text.bodyMedium,
      ),
      value: _notFull,
      onChanged: _onNotFullChanged,
    );
  }

  Widget _buildCapacitySlider(BuildContext context) {
    return Row(
      children: [
        Text('Minimum capacity', style: context.text.bodyMedium),
        AppSpacing.horizontalGapSm,
        Expanded(
          child: Slider(
            min: 0,
            max: 16,
            divisions: 16,
            value: _minCapacity.toDouble(),
            label: '$_minCapacity',
            onChanged: _onMinCapacityChanged,
          ),
        ),
        SizedBox(
          width: AppSpacing.xxl,
          child: Text(
            '$_minCapacity',
            textAlign: TextAlign.end,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        TextButton(onPressed: _clearFilters, child: const Text('Clear')),
        const Spacer(),
        FilledButton(onPressed: _applyFilters, child: const Text('Apply')),
      ],
    );
  }

  //helper methods for various state changes
  void _onCampusChanged(String? campus) {
    setState(() {
      _selectedCampus = campus;

      final validBuildings = campus == null
          ? _availableBuildingOptions
          : _campusBuildingOptions[campus] ?? [];

      if (_selectedBuilding != null &&
          !validBuildings.contains(_selectedBuilding)) {
        _selectedBuilding = null;
      }
    });
  }

  void _onBuildingChanged(String? building) {
    setState(() {
      _selectedBuilding = building;
    });
  }

  void _onNotFullChanged(bool value) {
    setState(() {
      _notFull = value;
    });
  }

  void _onMinCapacityChanged(double value) {
    setState(() {
      _minCapacity = value.toInt();
    });
  }

  void _clearFilters() {
    Navigator.pop(context, const StudyRoomFilters());
  }

  void _applyFilters() {
    Navigator.pop(
      context,
      StudyRoomFilters(
        campus: _selectedCampus,
        building: _selectedBuilding,
        minCapacity: _minCapacity,
        notFull: _notFull,
      ),
    );
  }
}
