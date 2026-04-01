import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/routes.dart';
import '../../data/local/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ── Lottie / logo animation (used as fallback) ──
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  // ── Video player ──
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;
  bool _useVideoSplash = true; // set to false to always show fallback

  // ── Navigation guard ──
  bool _hasNavigated = false;

  // ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Set up fallback animation controller
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    // Start video (or fall back automatically)
    _initializeVideo();
  }

  // ── Video initialisation ──────────────────────
  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(
        'assets/tone/timeline.mp4', // <-- replace with your actual asset path
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: false,
        ),
      );

      _videoController!.addListener(_videoPlayerListener);

      await _videoController!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Video initialisation timeout'),
      );

      if (!mounted) return;
      setState(() => _isVideoInitialized = true);

      await _videoController!.play();
      _navigateAfterDelay(isVideoPlaying: true);
    } on PlatformException catch (e) {
      debugPrint('Platform Exception: ${e.message}');
      _handleVideoError();
    } catch (e) {
      debugPrint('Video Error: $e');
      _handleVideoError();
    }
  }

  void _videoPlayerListener() {
    if (_videoController?.value.hasError ?? false) {
      debugPrint('Video Player Error: ${_videoController!.value.errorDescription}');
      _handleVideoError();
    }
  }

  void _handleVideoError() {
    if (!mounted) return;
    setState(() {
      _hasVideoError    = true;
      _useVideoSplash   = false;
    });
    // Start fallback animation
    _ctrl.forward();
    _navigateAfterDelay(isVideoPlaying: false);
  }

  // ── Navigation ────────────────────────────────
  void _navigateAfterDelay({required bool isVideoPlaying}) {
    final delay = isVideoPlaying
        ? const Duration(seconds: 3)   // roughly match video length
        : const Duration(milliseconds: 1800); // fallback delay

    Future.delayed(delay, () async {
      if (!mounted || _hasNavigated) return;

      // Wait for content to load (Riverpod)
      await ref.read(contentLoadedProvider.future);

      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      Navigator.pushReplacementNamed(context, AppRoutes.shell);
    });
  }

  // ─────────────────────────────────────────────
  @override
  void dispose() {
    _ctrl.dispose();
    _videoController?.removeListener(_videoPlayerListener);
    _videoController?.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildSplashContent(),
    );
  }

  Widget _buildSplashContent() {
    if (_useVideoSplash && _isVideoInitialized && !_hasVideoError) {
      return _buildVideoSplash();
    }
    return _buildFallbackSplash();
  }

  // ── Video splash ──────────────────────────────
  Widget _buildVideoSplash() {
    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      ),
    );
  }

  // ── Fallback splash (original EazyConcepts UI) ─
  Widget _buildFallbackSplash() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Stack(
        children: [
          // Pink glow at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.bgPinkOverlay.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),

          // Logo & app name
          Center(
            child: ScaleTransition(
              scale: _scale,
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App icon container
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: AppColors.buttonGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.buttonPurpleStart.withOpacity(0.5),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'EC',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'EazyConcepts',
                      style: AppTextStyles.display.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Learn smarter, not harder',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading indicator
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white38,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}