// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:common/utils/provider/preference_settings_provider.dart';
import 'package:dependencies/bloc/bloc.dart';
import 'package:dependencies/just_audio/just_audio.dart';
import 'package:detail_surah/presentation/cubits/bookmark_verses/bookmark_verses_cubit.dart';
import 'package:detail_surah/presentation/services/audio_recording_service.dart';
import 'package:detail_surah/presentation/services/recitation_detector_service.dart';
import 'package:detail_surah/presentation/services/whisper_api_service.dart';
import 'package:detail_surah/presentation/services/arabic_text_utils.dart';
import 'package:detail_surah/presentation/utils/arabic_numerals.dart';
import 'package:detail_surah/presentation/models/recitation_settings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran/domain/entities/detail_surah_entity.dart';
import 'package:resources/extensions/context_extensions.dart';
import 'package:resources/styles/color.dart';
import 'package:resources/styles/text_styles.dart';

class VersesWidget extends StatefulWidget {
  final VerseEntity verses;
  final PreferenceSettingsProvider prefSetProvider;
  final String surah;
  final RecitationSettings? settings;
  final bool isRecording; // External recording trigger
  final Function(RecitationDetectionResult)? onDetectionResult; // Callback for detection result
  final RecitationDetectionResult? detectionResult; // External detection result (from global recording) - word-level from letter checking
  final bool isCurrentlyPlaying; // Whether this verse is currently being played
  final AudioPlayer? globalPlayer; // Global player for consecutive playback
  final AudioPlayer player = AudioPlayer();

  VersesWidget({
    super.key,
    required this.verses,
    required this.prefSetProvider,
    required this.surah,
    this.settings,
    this.isRecording = false,
    this.onDetectionResult,
    this.detectionResult,
    this.isCurrentlyPlaying = false,
    this.globalPlayer,
  });

  @override
  State<VersesWidget> createState() => _VersesWidgetState();
}

class _VersesWidgetState extends State<VersesWidget> {
  bool isBookmark = false;
  bool isRecording = false;
  bool isProcessing = false;
  String? recordingPath;
  RecitationDetectionResult? _localDetectionResult; // Local detection result from per-verse recording
  
  final AudioRecordingService _audioRecordingService = AudioRecordingService();
  final WhisperApiService _whisperApiService = WhisperApiService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await context
          .read<BookmarkVersesCubit>()
          .loadBookmarkVerse(widget.verses.number.inQuran);

      if (context.read<BookmarkVersesCubit>().state.isBookmark) {
        setState(() {
          isBookmark = true;
        });
      } else {
        setState(() {
          isBookmark = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(VersesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If external recording trigger changed, update recording state
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording && !isRecording) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _toggleRecording();
        });
      } else if (!widget.isRecording && isRecording) {
        _toggleRecording(); // Stop recording
      }
    }
  }

  @override
  void dispose() {
    widget.player.dispose();
    _audioRecordingService.dispose();
    super.dispose();
  }

  Future<void> setAudioUrl() async {
    try {
      await widget.player.setAudioSource(
          AudioSource.uri(Uri.parse(widget.verses.audio.primary)));
    } catch (e) {
      log("Error loading audio source: $e");
    }
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.player.stop();
    }
  }

  Future<void> _toggleRecording() async {
    if (isRecording) {
      // Stop recording
      setState(() {
        isRecording = false;
        isProcessing = true;
      });

      final path = await _audioRecordingService.stopRecording();
      if (path != null) {
        setState(() {
          recordingPath = path;
        });

        // Transcribe and detect mistakes
        await _processRecording(path);
      } else {
        setState(() {
          isProcessing = false;
        });
      }
    } else {
      // Start recording - request permission first
      if (mounted) {
        print('🎤 Mic button tapped - checking permission...');
        
        // Always request permission explicitly (even if we think we have it)
        // This ensures the iOS popup appears
        print('Requesting microphone permission...');
        final permissionGranted = await _audioRecordingService.requestPermission();
        print('Permission granted: $permissionGranted');
        
        if (!permissionGranted) {
          // Permission was denied
          print('Permission not granted, checking if permanently denied...');
          final isPermanentlyDenied = await _audioRecordingService.shouldShowRequestRationale();
          print('Permanently denied: $isPermanentlyDenied');
          
          if (isPermanentlyDenied) {
            // Show dialog to open Settings
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Microphone Permission Required'),
                  content: const Text(
                    'Microphone access is required to record your recitation. Please enable it in Settings.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await openAppSettings();
                      },
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Microphone permission is required. Please allow access when prompted.'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
          return;
        }
        
        // Now start recording
        print('Starting recording...');
        final path = await _audioRecordingService.startRecording();
        if (path != null) {
          print('Recording started successfully: $path');
          setState(() {
            isRecording = true;
            recordingPath = path;
            _localDetectionResult = null; // Clear previous results
          });
        } else {
          print('Failed to start recording');
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
    }
  }

  Future<void> _processRecording(String audioPath) async {
    try {
      // Show processing indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing recitation...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Transcribe audio
      final transcription = await _whisperApiService.transcribeAudio(audioPath);

      if (transcription != null && mounted) {
        // Detect mistakes
        final result = RecitationDetectorService.detectMistakes(
          widget.verses.text.arab,
          transcription,
        );

        setState(() {
          _localDetectionResult = result;
          isProcessing = false;
        });

        // Callback to parent for global accuracy display
        if (widget.onDetectionResult != null) {
          widget.onDetectionResult!(result);
        }

        // Show accuracy
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Accuracy: ${result.accuracy.toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: result.accuracy >= 80
                ? kGreenAccent
                : result.accuracy >= 60
                    ? Colors.orange
                    : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        // Clean up audio file
        await _audioRecordingService.deleteRecordingFile(audioPath);
      } else {
        setState(() {
          isProcessing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to transcribe audio. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      log('Error processing recording: $e');
      setState(() {
        isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while processing your recitation.'),
          ),
        );
      }
    }
  }

  Widget _buildHighlightedText({double textSize = 28.0, int? currentWordIndex}) {
    final arabicText = widget.verses.text.arab;
    final words = ArabicTextUtils.splitIntoWords(arabicText);
    
    // Use external detection result if available (from global recording), otherwise use local
    final detectionResult = widget.detectionResult ?? _localDetectionResult;
    
    // If playing audio, show grey highlight for current/next word
    if (detectionResult == null && currentWordIndex != null) {
      return Wrap(
        textDirection: TextDirection.rtl,
        alignment: WrapAlignment.end,
        children: words.asMap().entries.map((entry) {
          final index = entry.key;
          final word = entry.value;
          final isCurrentWord = index == currentWordIndex;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              '$word ',
              textAlign: TextAlign.right,
              style: kHeading6.copyWith(
                fontSize: textSize,
                fontWeight: FontWeight.w500,
                color: widget.prefSetProvider.isDarkTheme
                    ? Colors.white
                    : kBlackDark,
                backgroundColor: isCurrentWord ? Colors.grey.withOpacity(0.3) : null,
              ),
            ),
          );
        }).toList(),
      );
    }
    
    if (detectionResult == null) {
      // No detection result, show normal text
      return Text(
        arabicText,
        textAlign: TextAlign.right,
        style: kHeading6.copyWith(
          fontSize: textSize,
          fontWeight: FontWeight.w500,
          color: widget.prefSetProvider.isDarkTheme
              ? Colors.white
              : kBlackDark,
        ),
      );
    }

    // Build highlighted text with word-level colors (from letter checking)
    final wordComparisons = detectionResult!.wordComparisons;

    return Wrap(
      textDirection: TextDirection.rtl,
      alignment: WrapAlignment.end,
      children: words.asMap().entries.map((entry) {
        final index = entry.key;
        final word = entry.value;
        
        // Find matching comparison
        final comparison = wordComparisons.firstWhere(
          (wc) => wc.index == index,
          orElse: () => WordComparison(
            word: word,
            status: WordStatus.correct,
            index: index,
          ),
        );

        Color wordColor;
        switch (comparison.status) {
          case WordStatus.correct:
            wordColor = kGreenAccent;
            break;
          case WordStatus.wrong:
            wordColor = Colors.red;
            break;
          case WordStatus.missing:
            wordColor = kMikadoYellow;
            break;
        }

        final currentTextSize = widget.settings?.textSize ?? 28.0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Text(
            '$word ',
            textAlign: TextAlign.right,
            style: kHeading6.copyWith(
              fontSize: currentTextSize,
              fontWeight: FontWeight.w500,
              color: wordColor,
              backgroundColor: wordColor.withOpacity(0.2),
            ),
          ),
        );
      }).toList(),
    );
  }
  

  void _showNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter your note...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Save note logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note saved')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textSize = widget.settings?.textSize ?? 28.0;
    
    return GestureDetector(
      onLongPress: () {
        // Show options for flag/note
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    isBookmark ? Icons.bookmark : Icons.bookmark_border,
                    color: kGreenAccent,
                  ),
                  title: Text(isBookmark ? 'Remove Bookmark' : 'Add Bookmark'),
                  onTap: () async {
                    Navigator.pop(context);
                    if (isBookmark) {
                      await context
                          .read<BookmarkVersesCubit>()
                          .removeBookmarkVerse(widget.verses, widget.surah);
                      context.showCustomFlashMessage(
                        status: 'success',
                        title: 'Remove Bookmark Verse',
                        darkTheme: widget.prefSetProvider.isDarkTheme,
                        message:
                            'Surah ${widget.surah} Verse ${widget.verses.number.inSurah} successfully removed from Bookmark',
                      );
                    } else {
                      await context
                          .read<BookmarkVersesCubit>()
                          .saveBookmarkVerse(widget.verses, widget.surah);
                      context.showCustomFlashMessage(
                        status: 'success',
                        title: 'Add Bookmark Verse',
                        darkTheme: widget.prefSetProvider.isDarkTheme,
                        message:
                            'Surah ${widget.surah} Verse ${widget.verses.number.inSurah} successfully added to Bookmark',
                      );
                    }
                    setState(() {
                      isBookmark = !isBookmark;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.note, color: kGreenAccent),
                  title: const Text('Add Note'),
                  onTap: () {
                    Navigator.pop(context);
                    _showNoteDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 24.0), // More spacing between ayahs
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with Arabic text and verse number
            StreamBuilder<Duration?>(
              stream: widget.isCurrentlyPlaying && widget.globalPlayer != null 
                  ? widget.globalPlayer!.positionStream 
                  : widget.player.positionStream,
              builder: (context, snapshot) {
                // Calculate current word index based on audio position
                int? currentWordIndex;
                if (snapshot.hasData && widget.isCurrentlyPlaying && widget.globalPlayer != null) {
                  final playerState = widget.globalPlayer!.playerState;
                  if (playerState.playing) {
                    final position = snapshot.data!;
                    final totalDuration = widget.globalPlayer!.duration ?? Duration.zero;
                    if (totalDuration.inMilliseconds > 0) {
                      // Add a small offset to make highlight appear slightly ahead (anticipate the word)
                      final offsetMs = 150; // 150ms ahead
                      final adjustedPosition = position + Duration(milliseconds: offsetMs);
                      final progress = (adjustedPosition.inMilliseconds / totalDuration.inMilliseconds).clamp(0.0, 1.0);
                      final words = ArabicTextUtils.splitIntoWords(widget.verses.text.arab);
                      currentWordIndex = (progress * words.length).floor().clamp(0, words.length - 1);
                    }
                  }
                } else if (snapshot.hasData && !widget.isCurrentlyPlaying) {
                  final playerState = widget.player.playerState;
                  if (playerState.playing) {
                    final position = snapshot.data!;
                    final totalDuration = widget.player.duration ?? Duration.zero;
                    if (totalDuration.inMilliseconds > 0) {
                      // Add a small offset to make highlight appear slightly ahead
                      final offsetMs = 150; // 150ms ahead
                      final adjustedPosition = position + Duration(milliseconds: offsetMs);
                      final progress = (adjustedPosition.inMilliseconds / totalDuration.inMilliseconds).clamp(0.0, 1.0);
                      final words = ArabicTextUtils.splitIntoWords(widget.verses.text.arab);
                      currentWordIndex = (progress * words.length).floor().clamp(0, words.length - 1);
                    }
                  }
                }
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Arabic numeral verse number (on left side, vertically centered)
                    Container(
                      width: 35.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        color: kGreenAccent,
                      ),
                      child: Center(
                        child: Text(
                          ArabicNumerals.convert(widget.verses.number.inSurah),
                          style: kHeading6.copyWith(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    // Arabic text (right-aligned, takes available space)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _buildHighlightedText(
                          textSize: textSize,
                          currentWordIndex: currentWordIndex,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            // Accuracy display removed - will be shown under banner instead
          const SizedBox(height: 8.0), // Reduced spacing between Arabic and translation
          // English text aligned to right (same alignment as Arabic, not extending beyond)
          Row(
            children: [
              const SizedBox(width: 47.0), // Space for numeral + spacing
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.verses.text.transliteration.en,
                        textAlign: TextAlign.right,
                        style: kHeading6.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color:
                              widget.prefSetProvider.isDarkTheme ? kGreyLight : kBlackDark,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        widget.verses.translation.en,
                        textAlign: TextAlign.right,
                        style: kHeading6.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: widget.prefSetProvider.isDarkTheme
                              ? kGreyLight
                              : kBlackDark.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}