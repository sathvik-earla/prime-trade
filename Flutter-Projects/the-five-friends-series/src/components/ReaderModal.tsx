import React, { useState, useEffect, useRef } from 'react';
import { StoryItem, ReaderSettings } from '../types';
import {
  X,
  ChevronLeft,
  ChevronRight,
  Volume2,
  Pause,
  Sliders,
  Bookmark,
  Heart,
  Star,
  Download,
  Lock,
  ShoppingBag,
  FileText,
  CheckCircle,
} from 'lucide-react';
import {
  saveReadingProgress,
  recordStoryRead,
  addStoryReview,
  downloadAttachedDocument,
} from '../services/storage';
import { FormatDownloadMenu } from './FormatDownloadMenu';

interface ReaderModalProps {
  story: StoryItem;
  initialPage?: number;
  isBookmarked: boolean;
  isLiked: boolean;
  isPurchased?: boolean;
  onClose: () => void;
  onToggleBookmark: (storyId: string) => void;
  onToggleLike: (storyId: string) => void;
  onStoryUpdated: () => void;
  onRequestPurchase?: () => void;
}

export const ReaderModal: React.FC<ReaderModalProps> = ({
  story,
  initialPage = 1,
  isBookmarked,
  isLiked,
  isPurchased = false,
  onClose,
  onToggleBookmark,
  onToggleLike,
  onStoryUpdated,
  onRequestPurchase,
}) => {
  const [currentPage, setCurrentPage] = useState<number>(initialPage);
  const [settingsOpen, setSettingsOpen] = useState(false);
  const [reviewOpen, setReviewOpen] = useState(false);
  const [reviewSubmitted, setReviewSubmitted] = useState(false);
  const [readerName, setReaderName] = useState('');
  const [userRating, setUserRating] = useState(5);
  const [userComment, setUserComment] = useState('');

  // Reader Customization State
  const [settings, setSettings] = useState<ReaderSettings>(() => {
    try {
      const saved = localStorage.getItem('fivefriends_reader_settings');
      if (saved) return JSON.parse(saved);
    } catch {}
    return {
      theme: 'dark',
      font: 'serif',
      fontSize: 18,
      lineSpacing: 'relaxed',
      readingMode: 'book',
    };
  });

  // Audio Speech State
  const [isSpeaking, setIsSpeaking] = useState(false);
  const [speechRate, setSpeechRate] = useState(1.0);
  const [speechPitch] = useState(1.0);
  const synthRef = useRef<SpeechSynthesis | null>(null);
  const utteranceRef = useRef<SpeechSynthesisUtterance | null>(null);

  // Touch Swipe for mobile (iOS & Android)
  const touchStartX = useRef<number>(0);
  const touchEndX = useRef<number>(0);

  const totalPages = story.chapters.length || 1;
  const currentChapter =
    story.chapters.find((c) => c.pageNumber === currentPage) ||
    story.chapters[0] || {
      id: 'default',
      pageNumber: 1,
      title: story.title,
      content: story.synopsis,
    };

  const isFree = !story.price || story.price <= 0;
  const freeLimit = story.freeSamplePages || 1;
  const isPageLocked = !isPurchased && !isFree && currentPage > freeLimit;

  // Record read count and initial progress on open
  useEffect(() => {
    recordStoryRead(story.id);
    saveReadingProgress(story.id, currentPage);
    if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
      synthRef.current = window.speechSynthesis;
    }

    return () => {
      if (synthRef.current) {
        synthRef.current.cancel();
      }
    };
  }, [story.id]);

  // Save settings when changed
  useEffect(() => {
    localStorage.setItem('fivefriends_reader_settings', JSON.stringify(settings));
  }, [settings]);

  // Page change sync
  const goToPage = (page: number) => {
    const target = Math.max(1, Math.min(page, totalPages));
    setCurrentPage(target);
    saveReadingProgress(story.id, target);

    if (synthRef.current) {
      synthRef.current.cancel();
      setIsSpeaking(false);
    }
  };

  // Keyboard controls
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'ArrowRight' || e.key === 'PageDown') {
        goToPage(currentPage + 1);
      } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
        goToPage(currentPage - 1);
      } else if (e.key === 'Escape') {
        if (settingsOpen) setSettingsOpen(false);
        else if (reviewOpen) setReviewOpen(false);
        else onClose();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [currentPage, settingsOpen, reviewOpen]);

  // Touch swipe handlers
  const handleTouchStart = (e: React.TouchEvent) => {
    touchStartX.current = e.targetTouches[0].clientX;
  };
  const handleTouchMove = (e: React.TouchEvent) => {
    touchEndX.current = e.targetTouches[0].clientX;
  };
  const handleTouchEnd = () => {
    if (!touchStartX.current || !touchEndX.current) return;
    const distance = touchStartX.current - touchEndX.current;
    if (distance > 50) {
      goToPage(currentPage + 1);
    } else if (distance < -50) {
      goToPage(currentPage - 1);
    }
    touchStartX.current = 0;
    touchEndX.current = 0;
  };

  // Audio Narration
  const toggleSpeech = () => {
    if (!synthRef.current || isPageLocked) return;

    if (isSpeaking) {
      synthRef.current.cancel();
      setIsSpeaking(false);
      return;
    }

    synthRef.current.cancel();
    const textToRead = `${currentChapter.title}. ${currentChapter.content}`;
    const utterance = new SpeechSynthesisUtterance(textToRead);
    utterance.rate = speechRate;
    utterance.pitch = speechPitch;

    utterance.onend = () => {
      setIsSpeaking(false);
      if (currentPage < totalPages && (!isPageLocked || isPurchased || isFree)) {
        goToPage(currentPage + 1);
      }
    };
    utterance.onerror = () => {
      setIsSpeaking(false);
    };

    utteranceRef.current = utterance;
    synthRef.current.speak(utterance);
    setIsSpeaking(true);
  };

  // Submit reader review
  const handleSubmitReview = (e: React.FormEvent) => {
    e.preventDefault();
    if (!readerName.trim() || !userComment.trim()) return;

    addStoryReview(story.id, {
      readerName: readerName.trim(),
      rating: userRating,
      comment: userComment.trim(),
    });

    setReviewSubmitted(true);
    onStoryUpdated();
    setTimeout(() => {
      setReviewOpen(false);
      setReviewSubmitted(false);
      setReaderName('');
      setUserComment('');
    }, 1500);
  };

  // Theme styling mapping
  const themeClasses: Record<string, string> = {
    dark: 'bg-slate-950 text-slate-100',
    night: 'bg-black text-slate-200',
    sepia: 'bg-[#f4ebd9] text-[#2c221e]',
    paper: 'bg-[#faf8f5] text-[#1c1917]',
    light: 'bg-[#fafafa] text-slate-900',
  };

  const surfaceClasses: Record<string, string> = {
    dark: 'bg-slate-900/80 border-slate-800 text-slate-200',
    night: 'bg-zinc-950/90 border-zinc-800 text-zinc-300',
    sepia: 'bg-[#ede2cb] border-[#dfd2b5] text-[#3e322a]',
    paper: 'bg-[#f0ebe1] border-[#ded7c8] text-[#292524]',
    light: 'bg-white border-slate-200 text-slate-800 shadow-sm',
  };

  return (
    <div
      className={`fixed inset-0 z-50 flex flex-col overflow-hidden ${themeClasses[settings.theme]}`}
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      {/* Top Header Bar */}
      <div
        className={`sticky top-0 z-20 flex h-14 items-center justify-between border-b px-4 backdrop-blur-md pt-safe transition-colors ${
          settings.theme === 'dark'
            ? 'border-slate-800/80 bg-slate-950/90'
            : settings.theme === 'sepia'
            ? 'border-[#dfd2b5] bg-[#f4ebd9]/90'
            : 'border-slate-200 bg-white/90'
        }`}
      >
        {/* Left: Close & Title */}
        <div className="flex items-center gap-3 truncate pr-2">
          <button
            onClick={onClose}
            className="flex min-h-[44px] min-w-[44px] items-center justify-center rounded-lg transition-opacity hover:opacity-75"
            aria-label="Close reader"
          >
            <X className="h-5 w-5" />
          </button>
          <div className="flex flex-col truncate">
            <span className="font-display text-sm font-semibold truncate">
              {story.title}
            </span>
            <span className="text-[11px] opacity-70 truncate">
              {story.authorName} · {currentChapter.title}
            </span>
          </div>
        </div>

        {/* Right Actions: Document Download, Audio, Settings, Like, Bookmark, Buy */}
        <div className="flex items-center gap-1">
          {/* Download in Every Format (PDF, EPUB, DOCX, TXT, HTML, RTF, JSON) */}
          {(isPurchased || isFree) && (
            <FormatDownloadMenu story={story} variant="compact" />
          )}

          {/* Buy Action if not purchased */}
          {!isPurchased && !isFree && onRequestPurchase && (
            <button
              onClick={onRequestPurchase}
              className="flex items-center gap-1.5 rounded-lg bg-amber-500 px-3 py-1.5 text-xs font-bold text-slate-950 shadow hover:bg-amber-400 transition-all mr-1"
            >
              <ShoppingBag className="h-3.5 w-3.5" />
              <span>Buy ₹{story.price.toFixed(2)}</span>
            </button>
          )}

          {/* Read Aloud Button */}
          {!isPageLocked && (
            <button
              onClick={toggleSpeech}
              className={`flex min-h-[44px] min-w-[44px] items-center justify-center rounded-lg transition-colors ${
                isSpeaking
                  ? 'text-amber-500 bg-amber-500/10'
                  : 'opacity-80 hover:opacity-100'
              }`}
              title={isSpeaking ? 'Pause reading aloud' : 'Read story aloud'}
              aria-label="Read aloud"
            >
              {isSpeaking ? (
                <Pause className="h-4 w-4" />
              ) : (
                <Volume2 className="h-4 w-4" />
              )}
            </button>
          )}

          {/* Settings Drawer Button */}
          <button
            onClick={() => setSettingsOpen(!settingsOpen)}
            className="flex min-h-[44px] min-w-[44px] items-center justify-center rounded-lg opacity-80 hover:opacity-100"
            title="Reading Preferences"
            aria-label="Reading preferences"
          >
            <Sliders className="h-4 w-4" />
          </button>

          {/* Bookmark Button */}
          <button
            onClick={() => onToggleBookmark(story.id)}
            className="flex min-h-[44px] min-w-[44px] items-center justify-center rounded-lg opacity-80 hover:opacity-100"
            title="Bookmark"
            aria-label="Bookmark"
          >
            <Bookmark
              className={`h-4 w-4 ${isBookmarked ? 'fill-amber-400 text-amber-400' : ''}`}
            />
          </button>

          {/* Like Button */}
          <button
            onClick={() => onToggleLike(story.id)}
            className="flex min-h-[44px] min-w-[44px] items-center justify-center rounded-lg opacity-80 hover:opacity-100"
            title="Like story"
            aria-label="Like story"
          >
            <Heart
              className={`h-4 w-4 ${isLiked ? 'fill-rose-500 text-rose-500' : ''}`}
            />
          </button>
        </div>
      </div>

      {/* Reader Settings Drawer */}
      {settingsOpen && (
        <div
          className={`absolute top-14 right-4 z-30 w-72 rounded-2xl border p-4 shadow-2xl backdrop-blur-xl ${
            settings.theme === 'dark'
              ? 'bg-slate-900/95 border-slate-700 text-slate-100'
              : settings.theme === 'sepia'
              ? 'bg-[#eae0ca]/95 border-[#d6c7a9] text-[#2c221e]'
              : 'bg-white/95 border-slate-200 text-slate-900'
          }`}
        >
          <div className="flex items-center justify-between pb-3 border-b border-black/10 dark:border-white/10">
            <span className="text-xs font-bold uppercase tracking-wider opacity-70">
              Reading Options
            </span>
            <button
              onClick={() => setSettingsOpen(false)}
              className="text-xs opacity-60 hover:opacity-100"
            >
              Close
            </button>
          </div>

          {/* Theme Selector */}
          <div className="mt-3">
            <span className="text-xs font-medium block mb-2 opacity-80">
              Color Theme
            </span>
            <div className="grid grid-cols-3 gap-2">
              <button
                onClick={() => setSettings({ ...settings, theme: 'dark' })}
                className={`py-2 px-3 text-xs font-medium rounded-lg border transition-all ${
                  settings.theme === 'dark'
                    ? 'border-amber-400 bg-slate-800 text-white shadow-sm'
                    : 'border-slate-700 bg-slate-900 text-slate-400'
                }`}
              >
                Midnight
              </button>
              <button
                onClick={() => setSettings({ ...settings, theme: 'sepia' })}
                className={`py-2 px-3 text-xs font-medium rounded-lg border transition-all ${
                  settings.theme === 'sepia'
                    ? 'border-amber-600 bg-[#ede2cb] text-[#2c221e] shadow-sm font-semibold'
                    : 'border-[#ded2b8] bg-[#f4ebd9] text-[#5e4b3c]'
                }`}
              >
                Sepia
              </button>
              <button
                onClick={() => setSettings({ ...settings, theme: 'light' })}
                className={`py-2 px-3 text-xs font-medium rounded-lg border transition-all ${
                  settings.theme === 'light'
                    ? 'border-amber-500 bg-white text-slate-900 shadow-sm font-semibold'
                    : 'border-slate-200 bg-slate-100 text-slate-600'
                }`}
              >
                Light
              </button>
            </div>
          </div>

          {/* Typography Font */}
          <div className="mt-4">
            <span className="text-xs font-medium block mb-2 opacity-80">
              Font Style
            </span>
            <div className="grid grid-cols-2 gap-2">
              <button
                onClick={() => setSettings({ ...settings, font: 'serif' })}
                className={`py-2 px-3 text-xs rounded-lg border font-serif-prose ${
                  settings.font === 'serif'
                    ? 'border-amber-500 bg-amber-500/10 font-bold'
                    : 'border-black/10 dark:border-white/10 opacity-70'
                }`}
              >
                Classic Serif
              </button>
              <button
                onClick={() => setSettings({ ...settings, font: 'sans' })}
                className={`py-2 px-3 text-xs rounded-lg border ${
                  settings.font === 'sans'
                    ? 'border-amber-500 bg-amber-500/10 font-bold'
                    : 'border-black/10 dark:border-white/10 opacity-70'
                }`}
              >
                Modern Sans
              </button>
            </div>
          </div>

          {/* Font Size Slider */}
          <div className="mt-4">
            <div className="flex justify-between text-xs opacity-80 mb-1">
              <span>Text Size</span>
              <span className="tabular-nums font-semibold">{settings.fontSize}px</span>
            </div>
            <input
              type="range"
              min="15"
              max="26"
              step="1"
              value={settings.fontSize}
              onChange={(e) =>
                setSettings({ ...settings, fontSize: Number(e.target.value) })
              }
              className="w-full accent-amber-500 cursor-pointer"
            />
          </div>

          {/* Audio Speed Rate */}
          <div className="mt-4 pt-3 border-t border-black/10 dark:border-white/10">
            <div className="flex justify-between text-xs opacity-80 mb-1">
              <span>Voice Narration Speed</span>
              <span className="tabular-nums">{speechRate.toFixed(1)}x</span>
            </div>
            <div className="flex gap-2">
              {[0.8, 1.0, 1.2].map((rate) => (
                <button
                  key={rate}
                  onClick={() => setSpeechRate(rate)}
                  className={`flex-1 py-1.5 text-xs rounded border transition-colors ${
                    speechRate === rate
                      ? 'border-amber-500 bg-amber-500/20 font-bold text-amber-400'
                      : 'border-black/10 dark:border-white/10 opacity-70'
                  }`}
                >
                  {rate}x
                </button>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Main Reading Canvas */}
      <div className="relative flex-1 overflow-y-auto px-4 py-6 sm:px-8 md:px-16 pb-28">
        <div className="mx-auto max-w-3xl">
          {/* Chapter Header */}
          <div className="mb-6 text-center">
            <span className="text-xs uppercase tracking-widest opacity-60">
              Page {currentPage} of {totalPages}
            </span>
            <h2 className="font-display mt-2 text-2xl sm:text-3xl font-bold tracking-tight">
              {currentChapter.title}
            </h2>
          </div>

          {/* PAYWALL PREVIEW CARD IF PAGE IS LOCKED */}
          {isPageLocked ? (
            <div className="my-10 rounded-3xl border border-amber-500/30 bg-slate-900/90 p-8 text-center max-w-md mx-auto shadow-2xl backdrop-blur-md">
              <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-amber-500/10 border border-amber-500/30 text-amber-400 mb-4">
                <Lock className="h-7 w-7" />
              </div>
              <h3 className="font-display text-xl font-bold text-slate-100">
                Sample Preview Finished
              </h3>
              <p className="mt-2 text-xs text-slate-300 leading-relaxed">
                You've read the free preview of <strong className="text-white">"{story.title}"</strong>. Unlock the remaining chapters and full document edition by supporting the author.
              </p>

              <div className="my-5 rounded-2xl border border-slate-800 bg-slate-950/70 p-4 text-xs flex items-center justify-between">
                <span className="text-slate-400">Complete Edition:</span>
                <span className="font-bold text-base text-amber-400">₹{story.price.toFixed(2)}</span>
              </div>

              {onRequestPurchase && (
                <button
                  onClick={onRequestPurchase}
                  className="flex w-full items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-amber-500 to-amber-400 px-6 py-3 text-sm font-bold text-slate-950 shadow-lg shadow-amber-500/20 active:scale-95 transition-transform hover:brightness-105"
                >
                  <ShoppingBag className="h-4 w-4" />
                  <span>Purchase Full Book (₹{story.price.toFixed(2)})</span>
                </button>
              )}
            </div>
          ) : (
            <>
              {/* Illustrated Page Art (If present) */}
              {currentChapter.illustrationUrl && (
                <div className="my-6 overflow-hidden rounded-2xl border border-black/10 dark:border-white/10 shadow-lg">
                  <img
                    src={currentChapter.illustrationUrl}
                    alt={currentChapter.title}
                    referrerPolicy="no-referrer"
                    className="max-h-[420px] w-full object-cover"
                  />
                </div>
              )}

              {/* Prose Content */}
              <div
                className={`transition-all ${
                  settings.font === 'serif' ? 'font-serif-prose' : 'font-sans'
                } leading-relaxed`}
                style={{ fontSize: `${settings.fontSize}px` }}
              >
                {currentChapter.content.split('\n\n').map((paragraph, idx) => (
                  <p key={idx} className="mb-5 indent-4 sm:indent-6 leading-loose">
                    {paragraph}
                  </p>
                ))}
              </div>

              {/* Download original document prompt if attached */}
              {story.documentFile && (isPurchased || isFree) && (
                <div className="my-8 rounded-2xl border border-cyan-500/30 bg-cyan-950/20 p-4 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <FileText className="h-6 w-6 text-cyan-400" />
                    <div>
                      <div className="text-xs font-bold text-slate-200">
                        {story.documentFile.fileName}
                      </div>
                      <div className="text-[10px] text-slate-400">
                        Original document file · {(story.documentFile.fileSize / 1024).toFixed(1)} KB
                      </div>
                    </div>
                  </div>
                  <button
                    onClick={() => downloadAttachedDocument(story.documentFile!, story.title)}
                    className="flex items-center gap-1.5 rounded-lg bg-cyan-500/20 border border-cyan-500/40 px-3 py-1.5 text-xs font-semibold text-cyan-300 hover:bg-cyan-500/30 transition-colors"
                  >
                    <Download className="h-3.5 w-3.5" />
                    <span>Download</span>
                  </button>
                </div>
              )}

              {/* Bottom Review & Feedback section on final page */}
              {currentPage === totalPages && (
                <div
                  className={`mt-12 rounded-2xl border p-6 text-center ${
                    surfaceClasses[settings.theme]
                  }`}
                >
                  <h4 className="font-display text-lg font-bold">You reached the end!</h4>
                  <p className="mt-1 text-xs opacity-75">
                    Enjoyed {story.title}? Leave a note for the authors.
                  </p>

                  <div className="mt-4 flex justify-center gap-3">
                    <button
                      onClick={() => setReviewOpen(true)}
                      className="flex items-center gap-2 rounded-xl bg-amber-500 px-4 py-2.5 text-xs font-semibold text-slate-950 transition-transform active:scale-95 shadow-md"
                    >
                      <Star className="h-4 w-4 fill-slate-950" />
                      <span>Rate &amp; Review Story</span>
                    </button>
                  </div>

                  {/* Reader Reviews List */}
                  {story.reviews && story.reviews.filter((r) => r.approved).length > 0 && (
                    <div className="mt-8 text-left border-t border-black/10 dark:border-white/10 pt-6">
                      <h5 className="text-xs font-bold uppercase tracking-wider opacity-70 mb-4">
                        Reader Reviews ({story.reviews.filter((r) => r.approved).length})
                      </h5>
                      <div className="space-y-3">
                        {story.reviews
                          .filter((r) => r.approved)
                          .map((review) => (
                            <div
                              key={review.id}
                              className="rounded-xl p-3 border border-black/5 dark:border-white/5 bg-black/5 dark:bg-white/5"
                            >
                              <div className="flex items-center justify-between text-xs mb-1">
                                <span className="font-semibold">{review.readerName}</span>
                                <div className="flex items-center text-amber-400">
                                  {[...Array(review.rating)].map((_, i) => (
                                    <Star key={i} className="h-3 w-3 fill-amber-400" />
                                  ))}
                                </div>
                              </div>
                              <p className="text-xs opacity-80">{review.comment}</p>
                            </div>
                          ))}
                      </div>
                    </div>
                  )}
                </div>
              )}
            </>
          )}
        </div>
      </div>

      {/* Review Modal Dialog */}
      {reviewOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-sm">
          <div className="w-full max-w-md rounded-2xl border border-slate-700 bg-slate-900 p-6 text-slate-100 shadow-2xl">
            {reviewSubmitted ? (
              <div className="flex flex-col items-center py-6 text-center">
                <CheckCircle className="h-12 w-12 text-emerald-400 mb-3 animate-bounce" />
                <h3 className="text-base font-bold">Review Submitted!</h3>
                <p className="text-xs text-slate-400 mt-1">
                  Thank you for supporting our authors.
                </p>
              </div>
            ) : (
              <form onSubmit={handleSubmitReview}>
                <div className="flex items-center justify-between pb-3 border-b border-slate-800">
                  <h3 className="text-sm font-bold">Write a Reader Review</h3>
                  <button
                    type="button"
                    onClick={() => setReviewOpen(false)}
                    className="text-slate-400 hover:text-white"
                  >
                    <X className="h-4 w-4" />
                  </button>
                </div>

                <div className="mt-4">
                  <label className="text-xs text-slate-400 block mb-1">Rating</label>
                  <div className="flex gap-2">
                    {[1, 2, 3, 4, 5].map((star) => (
                      <button
                        type="button"
                        key={star}
                        onClick={() => setUserRating(star)}
                        className="p-1 text-slate-500 hover:text-amber-400 transition-colors"
                      >
                        <Star
                          className={`h-6 w-6 ${
                            star <= userRating
                              ? 'fill-amber-400 text-amber-400'
                              : 'text-slate-600'
                          }`}
                        />
                      </button>
                    ))}
                  </div>
                </div>

                <div className="mt-4">
                  <label className="text-xs text-slate-400 block mb-1">Your Name</label>
                  <input
                    type="text"
                    required
                    value={readerName}
                    onChange={(e) => setReaderName(e.target.value)}
                    placeholder="e.g. Reader Elena"
                    className="w-full rounded-lg border border-slate-700 bg-slate-800 px-3 py-2 text-xs text-white focus:border-amber-400 focus:outline-none"
                  />
                </div>

                <div className="mt-4">
                  <label className="text-xs text-slate-400 block mb-1">Your Feedback</label>
                  <textarea
                    required
                    rows={3}
                    value={userComment}
                    onChange={(e) => setUserComment(e.target.value)}
                    placeholder="What did you love about this story or its illustrations?"
                    className="w-full rounded-lg border border-slate-700 bg-slate-800 px-3 py-2 text-xs text-white focus:border-amber-400 focus:outline-none"
                  />
                </div>

                <div className="mt-6 flex justify-end gap-2">
                  <button
                    type="button"
                    onClick={() => setReviewOpen(false)}
                    className="rounded-lg px-3 py-1.5 text-xs text-slate-400 hover:text-white"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="rounded-lg bg-amber-500 px-4 py-1.5 text-xs font-semibold text-slate-950 hover:bg-amber-400"
                  >
                    Submit Review
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}

      {/* Floating Bottom Page Navigator */}
      <div
        className={`fixed bottom-0 left-0 right-0 z-20 flex h-16 items-center justify-between border-t px-4 pb-safe backdrop-blur-md transition-colors ${
          settings.theme === 'dark'
            ? 'border-slate-800/80 bg-slate-950/90 text-slate-300'
            : settings.theme === 'sepia'
            ? 'border-[#dfd2b5] bg-[#f4ebd9]/90 text-[#3e322a]'
            : 'border-slate-200 bg-white/90 text-slate-700'
        }`}
      >
        <button
          onClick={() => goToPage(currentPage - 1)}
          disabled={currentPage <= 1}
          className="flex min-h-[44px] min-w-[44px] items-center gap-1 rounded-xl px-3 text-xs font-medium disabled:opacity-30 disabled:pointer-events-none hover:bg-black/5 dark:hover:bg-white/5 active:scale-95"
          aria-label="Previous page"
        >
          <ChevronLeft className="h-5 w-5" />
          <span className="hidden sm:inline">Previous</span>
        </button>

        {/* Page Dots / Progress Indicator */}
        <div className="flex items-center gap-2">
          <span className="text-xs font-semibold tabular-nums">
            {currentPage} / {totalPages}
          </span>
          <div className="hidden sm:flex items-center gap-1.5">
            {story.chapters.map((ch) => (
              <button
                key={ch.id}
                onClick={() => goToPage(ch.pageNumber)}
                className={`h-2 rounded-full transition-all ${
                  ch.pageNumber === currentPage
                    ? 'w-6 bg-amber-500'
                    : 'w-2 bg-slate-600/40 hover:bg-slate-500'
                }`}
                title={`Page ${ch.pageNumber}: ${ch.title}`}
              />
            ))}
          </div>
        </div>

        <button
          onClick={() => goToPage(currentPage + 1)}
          disabled={currentPage >= totalPages}
          className="flex min-h-[44px] min-w-[44px] items-center gap-1 rounded-xl px-3 text-xs font-medium disabled:opacity-30 disabled:pointer-events-none hover:bg-black/5 dark:hover:bg-white/5 active:scale-95"
          aria-label="Next page"
        >
          <span className="hidden sm:inline">Next</span>
          <ChevronRight className="h-5 w-5" />
        </button>
      </div>
    </div>
  );
};
