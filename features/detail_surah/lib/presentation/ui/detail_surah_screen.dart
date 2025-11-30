import 'dart:async';
import 'package:common/utils/provider/preference_settings_provider.dart';
import 'package:common/utils/state/view_data_state.dart';
import 'package:dependencies/bloc/bloc.dart';
import 'package:dependencies/provider/provider.dart';
import 'package:dependencies/show_up_animation/show_up_animation.dart';
import 'package:detail_surah/presentation/bloc/bloc.dart';
import 'package:detail_surah/presentation/cubits/last_read/last_read_cubit.dart';
import 'package:detail_surah/presentation/models/recitation_settings.dart';
import 'package:detail_surah/presentation/ui/widget/verses_widget.dart';
import 'package:detail_surah/presentation/ui/widget/settings_bottom_sheet.dart';
import 'package:detail_surah/presentation/ui/widget/translation_bottom_sheet.dart';
import 'package:detail_surah/presentation/ui/widget/listen_bottom_sheet.dart';
import 'package:detail_surah/presentation/services/recitation_detector_service.dart';
import 'package:detail_surah/presentation/services/multi_verse_letter_to_word_service.dart' show MultiVerseLetterToWordRecitationService;
import 'package:detail_surah/presentation/services/audio_recording_service.dart';
import 'package:detail_surah/presentation/services/whisper_api_service.dart';
import 'package:quran/domain/entities/detail_surah_entity.dart' show VerseEntity;
import 'package:dependencies/just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:resources/styles/color.dart';
import 'package:resources/styles/text_styles.dart';

class DetailSurahScreen extends StatefulWidget {
  final int id;

  const DetailSurahScreen({super.key, required this.id});

  @override
  State<DetailSurahScreen> createState() => _DetailSurahScreenState();
}

class _DetailSurahScreenState extends State<DetailSurahScreen> {
  RecitationSettings _settings = RecitationSettings();
  final AudioPlayer _globalPlayer = AudioPlayer();
  bool _isGlobalRecording = false;
  final Map<int, GlobalKey> _verseKeys = {};
  RecitationDetectionResult? _globalDetectionResult; // Single accuracy result for all verses (word-level from letter checking)
  String? _globalRecordingPath; // Path to the global recording
  final AudioRecordingService _globalRecordingService = AudioRecordingService();
  Map<int, RecitationDetectionResult> _verseDetectionResults = {}; // verse index -> word-level result (from letter checking)
  int _lastRecitedVerseIndex = -1; // Last verse that was actually recited
  int _currentPlayingVerseIndex = -1; // Current verse being played
  bool _isPlayingAllVerses = false; // Whether we're playing all verses consecutively
  
  final List<TranslationOption> _translations = [
    TranslationOption(name: 'English - Saheeh International', code: 'en', language: 'English'),
    TranslationOption(name: 'Arabic - Tafsir Al-Muyassar', code: 'ar', language: 'Arabic'),
    TranslationOption(name: 'English - Yusuf Ali', code: 'en', language: 'English'),
    TranslationOption(name: 'English - Pickthall', code: 'en', language: 'English'),
  ];
  
  final List<ReciterOption> _reciters = [
    ReciterOption(name: 'Abdul Basit', id: 'abdul_basit'),
    ReciterOption(name: 'Mishary Rashid', id: 'mishary_rashid'),
    ReciterOption(name: 'Saad Al-Ghamdi', id: 'saad_al_ghamdi'),
    ReciterOption(name: 'Abdur Rahman As-Sudais', id: 'abdur_rahman'),
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<DetailSurahBloc>().add(FetchDetailSurah(id: widget.id));
      context.read<LastReadCubit>().getLastRead();
    });
  }
  
  @override
  void dispose() {
    _globalPlayer.dispose();
    _globalRecordingService.dispose();
    super.dispose();
  }
  
  Future<void> _playVerseSequence(List<VerseEntity> verses, int startIndex) async {
    if (startIndex >= verses.length || !_isPlayingAllVerses) {
      setState(() {
        _isPlayingAllVerses = false;
        _currentPlayingVerseIndex = -1;
      });
      return;
    }
    
    try {
      setState(() {
        _currentPlayingVerseIndex = startIndex;
      });
      
      await _globalPlayer.setUrl(verses[startIndex].audio.primary);
      await _globalPlayer.play();
      
      // Listen for when this verse finishes - use a subscription to avoid multiple listeners
      StreamSubscription<PlayerState>? subscription;
      subscription = _globalPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed && _isPlayingAllVerses) {
          // Small delay before moving to next verse (reduced from default)
          subscription?.cancel();
          Future.delayed(const Duration(milliseconds: 200), () {
            if (_isPlayingAllVerses) {
              _playVerseSequence(verses, startIndex + 1);
            }
          });
        }
      }, onError: (error) {
        print('Error in verse playback: $error');
        subscription?.cancel();
        // Continue to next verse even if there's an error
        if (_isPlayingAllVerses) {
          Future.delayed(const Duration(milliseconds: 200), () {
            _playVerseSequence(verses, startIndex + 1);
          });
        }
      });
    } catch (e) {
      print('Error playing verse $startIndex: $e');
      // Continue to next verse even if there's an error
      if (_isPlayingAllVerses) {
        _playVerseSequence(verses, startIndex + 1);
      }
    }
  }
  
  Future<void> _processGlobalRecording(String audioPath, List<VerseEntity> verses) async {
    try {
      print('🎤 Transcribing audio...');
      final whisperService = WhisperApiService();
      final transcription = await whisperService.transcribeAudio(audioPath, isRealtime: false);
      
      if (transcription != null && transcription.isNotEmpty && mounted) {
        print('✅ Transcription: "$transcription"');
        print('🔍 Processing letter-based word-level detection for ${verses.length} verses...');
        
        // Use letter-level checking but word-level results
        final multiResult = MultiVerseLetterToWordRecitationService.detectMultiVerseRecitationLetterBasedWordLevel(
          verses,
          transcription,
        );
        
        print('📊 Detection results: accuracy=${multiResult.overallAccuracy}%, verses=${multiResult.lastRecitedVerseIndex + 1}');
        
        // Store verse-specific word-level results (from letter checking)
        setState(() {
          _verseDetectionResults = multiResult.verseResults;
          _lastRecitedVerseIndex = multiResult.lastRecitedVerseIndex;
          
          // Create a combined result for display
          _globalDetectionResult = RecitationDetectionResult(
            wordComparisons: [],
            accuracy: multiResult.overallAccuracy,
            correctCount: multiResult.totalCorrectWords,
            wrongCount: 0,
            missingCount: 0,
            totalWords: multiResult.totalWords,
          );
        });
        
        print('✅ State updated with letter-based word-level detection results');
        
        // Clean up audio file
        await _globalRecordingService.deleteRecordingFile(audioPath);
      } else {
        print('⚠️ Empty or null transcription');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not transcribe audio. Please try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error processing global recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing recording: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  void _showSettingsDialog(BuildContext context, PreferenceSettingsProvider prefSetProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsBottomSheet(
        settings: _settings,
        onSettingsChanged: (newSettings) {
          setState(() {
            _settings = newSettings;
          });
        },
        prefSetProvider: prefSetProvider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceSettingsProvider>(
      builder: (context, prefSetProvider, _) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
              child: BlocBuilder<DetailSurahBloc, DetailSurahState>(
                builder: (context, state) {
                  final status = state.statusDetailSurah.status;

                  if (status.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: prefSetProvider.isDarkTheme
                            ? Colors.white
                            : kPurplePrimary,
                      ),
                    );
                  } else if (status.isNoData) {
                    return Center(child: Text(state.statusDetailSurah.message));
                  } else if (status.isError) {
                    return Center(child: Text(state.statusDetailSurah.message));
                  } else if (status.isHasData) {
                    final surah = state.statusDetailSurah.data;

                    if (context.read<LastReadCubit>().state.data.isEmpty) {
                      context.read<LastReadCubit>().addLastRead(surah!);
                    } else {
                      context.read<LastReadCubit>().updateLastRead(surah!);
                    }

                    return Column(
                      children: [
                        // Header with back button and surah name
                        ShowUpAnimation(
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(
                                  Icons.arrow_back,
                                  size: 24.0,
                                  color: kGrey,
                                ),
                              ),
                              const SizedBox(width: 18.0),
                              Text(
                                surah.name.transliteration.id,
                                style: kHeading6.copyWith(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: prefSetProvider.isDarkTheme
                                      ? Colors.white
                                      : kPurpleSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // Buttons row
                        ShowUpAnimation(
                          child: Row(
                            children: [
                              // Recite button (opens bottom sheet)
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => SettingsBottomSheet(
                                        settings: _settings,
                                        onSettingsChanged: (newSettings) {
                                          setState(() {
                                            _settings = newSettings;
                                          });
                                        },
                                        prefSetProvider: prefSetProvider,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: prefSetProvider.isDarkTheme
                                          ? kBlackDark
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: kGreenAccent.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Recite',
                                        style: kHeading6.copyWith(
                                          fontSize: 14.0,
                                          color: prefSetProvider.isDarkTheme
                                              ? Colors.white
                                              : kBlackDark,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              // Translate button (opens bottom sheet)
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => TranslationBottomSheet(
                                        translations: _translations,
                                        selectedTranslation: _settings.selectedTranslation,
                                        onTranslationSelected: (value) {
                                          setState(() {
                                            _settings = _settings.copyWith(
                                              selectedTranslation: value,
                                            );
                                          });
                                        },
                                        prefSetProvider: prefSetProvider,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: prefSetProvider.isDarkTheme
                                          ? kBlackDark
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: kGreenAccent.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Translate',
                                        style: kHeading6.copyWith(
                                          fontSize: 14.0,
                                          color: prefSetProvider.isDarkTheme
                                              ? Colors.white
                                              : kBlackDark,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              // Listen button (opens bottom sheet)
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => ListenBottomSheet(
                                        reciters: _reciters,
                                        selectedReciter: _settings.selectedReciter,
                                        onReciterSelected: (value) {
                                          setState(() {
                                            _settings = _settings.copyWith(
                                              selectedReciter: value,
                                            );
                                          });
                                        },
                                        prefSetProvider: prefSetProvider,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: prefSetProvider.isDarkTheme
                                          ? kBlackDark
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: kGreenAccent.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Listen',
                                        style: kHeading6.copyWith(
                                          fontSize: 14.0,
                                          color: prefSetProvider.isDarkTheme
                                              ? Colors.white
                                              : kBlackDark,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              // Mic button - triggers global recording across all verses
                              InkWell(
                                onTap: () async {
                                  if (_isGlobalRecording) {
                                    // Stop recording
                                    print('🛑 Stopping recording...');
                                    setState(() {
                                      _isGlobalRecording = false;
                                    });
                                    
                                    final path = await _globalRecordingService.stopRecording();
                                    if (path != null && status.isHasData && surah != null) {
                                      // Process the recording with letter-level detection
                                      await _processGlobalRecording(path, surah!.verses);
                                    } else {
                                      print('❌ Failed to stop recording or no path returned');
                                    }
                                  } else {
                                    // Start recording
                                    print('🎤 Mic button tapped - starting recording...');
                                    final hasPermission = await _globalRecordingService.hasPermission();
                                    if (!hasPermission) {
                                      final permissionGranted = await _globalRecordingService.requestPermission();
                                      if (!permissionGranted) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Microphone permission is required. Please allow access when prompted.'),
                                              duration: Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                        return;
                                      }
                                    }
                                    
                                    // Start recording
                                    final path = await _globalRecordingService.startRecording();
                                    if (path != null) {
                                      print('✅ Recording started: $path');
                                    setState(() {
                                      _isGlobalRecording = true;
                                      _globalRecordingPath = path;
                                      _globalDetectionResult = null; // Clear previous results
                                      _verseDetectionResults = {}; // Clear verse results
                                      _lastRecitedVerseIndex = -1; // Reset
                                    });
                                    } else {
                                      print('❌ Failed to start recording');
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Failed to start recording. Please try again.'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: _isGlobalRecording
                                        ? Colors.red.withOpacity(0.2)
                                        : kGreenAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color: _isGlobalRecording
                                          ? Colors.red
                                          : kGreenAccent.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.mic,
                                    size: 20.0,
                                    color: _isGlobalRecording
                                        ? Colors.red
                                        : kGreenAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              // Play button
                              StreamBuilder<PlayerState>(
                                stream: _globalPlayer.playerStateStream,
                                builder: (context, snapshot) {
                                  final playerState = snapshot.data;
                                  final playing = playerState?.playing ?? false;
                                  
                                  return InkWell(
                                    onTap: () async {
                                      if (status.isHasData && surah != null && surah!.verses.isNotEmpty) {
                                        if (playing) {
                                          await _globalPlayer.pause();
                                          setState(() {
                                            _isPlayingAllVerses = false;
                                            _currentPlayingVerseIndex = -1;
                                          });
                                        } else {
                                          // Start playing all verses consecutively
                                          setState(() {
                                            _isPlayingAllVerses = true;
                                            _currentPlayingVerseIndex = 0;
                                          });
                                          _playVerseSequence(surah!.verses, 0);
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: kGreenAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color: kGreenAccent.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Icon(
                                        playing ? Icons.pause : Icons.play_arrow,
                                        size: 20.0,
                                        color: kGreenAccent,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Single accuracy bar (banner removed)
                                if (_globalDetectionResult != null) ...[
                                  const SizedBox(height: 16.0),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0.0),
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: kGreenAccent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(color: kGreenAccent.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.assessment,
                                          color: kGreenAccent,
                                          size: 20.0,
                                        ),
                                        const SizedBox(width: 8.0),
                                        Text(
                                          'Accuracy: ${_globalDetectionResult!.accuracy.toStringAsFixed(1)}%',
                                          style: kHeading6.copyWith(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                            color: kGreenAccent,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${_globalDetectionResult!.correctCount}/${_globalDetectionResult!.totalWords} correct',
                                          style: kHeading6.copyWith(
                                            fontSize: 12.0,
                                            color: prefSetProvider.isDarkTheme
                                                ? kGreyLight
                                                : kBlackDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20.0),
                                ShowUpAnimation(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: surah.verses.length,
                                          itemBuilder: (context, index) {
                                            if (!_verseKeys.containsKey(index)) {
                                              _verseKeys[index] = GlobalKey();
                                            }
                                            return VersesWidget(
                                              key: _verseKeys[index],
                                              verses: surah.verses[index],
                                              prefSetProvider: prefSetProvider,
                                              surah:
                                                  surah.name.transliteration.id,
                                              settings: _settings,
                                              isRecording: false, // Disable per-verse recording, use global instead
                                              onDetectionResult: null, // Global recording handles this
                                              detectionResult: _verseDetectionResults[index], // Only set if this verse was recited (word-level from letter checking)
                                              isCurrentlyPlaying: _currentPlayingVerseIndex == index, // Highlight current verse
                                              globalPlayer: _globalPlayer, // Pass global player for consecutive playback
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: Text('Error BLoC'));
                  }
                },
              ),
                ),
                // Settings button in bottom left with black padding
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    height: 100.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          kBlackBackground,
                          kBlackBackground.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0, left: 24.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SettingsBottomSheet(
                                settings: _settings,
                                onSettingsChanged: (newSettings) {
                                  setState(() {
                                    _settings = newSettings;
                                  });
                                },
                                prefSetProvider: prefSetProvider,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kGreenAccent.withOpacity(0.2),
                              border: Border.all(color: kGreenAccent, width: 2.0),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: kGreenAccent,
                              size: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
