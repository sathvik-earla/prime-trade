import React, { useState } from 'react';
import { StoryItem, ContentType } from '../types';
import {
  Bookmark,
  Heart,
  Star,
  BookOpen,
  Clock,
  UserCheck,
  ShoppingBag,
  CheckCircle,
  FileText,
  Headphones,
  Book,
  Feather,
  Layers,
  Sparkles,
  Scroll,
  Clapperboard,
} from 'lucide-react';

interface StoryCardProps {
  story: StoryItem;
  isBookmarked: boolean;
  isLiked: boolean;
  isPurchased?: boolean;
  onSelect: (story: StoryItem) => void;
  onToggleBookmark: (storyId: string, e: React.MouseEvent) => void;
  onToggleLike: (storyId: string, e: React.MouseEvent) => void;
  onBuy?: (story: StoryItem, e: React.MouseEvent) => void;
}

export const getFormatLabel = (type: ContentType) => {
  switch (type) {
    case 'storybook':
      return { label: 'Illustrated Storybook', icon: BookOpen, color: 'text-amber-400 bg-amber-500/10 border-amber-500/30' };
    case 'novel':
      return { label: 'Novel & Epic', icon: Book, color: 'text-indigo-400 bg-indigo-500/10 border-indigo-500/30' };
    case 'story':
      return { label: 'Short Story', icon: Feather, color: 'text-emerald-400 bg-emerald-500/10 border-emerald-500/30' };
    case 'comic':
      return { label: 'Graphic Novel & Comic', icon: Layers, color: 'text-cyan-400 bg-cyan-500/10 border-cyan-500/30' };
    case 'audiobook':
      return { label: 'Audiobook & Audio Story', icon: Headphones, color: 'text-rose-400 bg-rose-500/10 border-rose-500/30' };
    case 'poetry':
      return { label: 'Poetry & Verse', icon: Scroll, color: 'text-purple-400 bg-purple-500/10 border-purple-500/30' };
    case 'script':
      return { label: 'Drama & Script', icon: Clapperboard, color: 'text-orange-400 bg-orange-500/10 border-orange-500/30' };
    case 'interactive':
      return { label: 'Interactive Tale', icon: Sparkles, color: 'text-teal-400 bg-teal-500/10 border-teal-500/30' };
    default:
      return { label: 'Storybook', icon: BookOpen, color: 'text-amber-400 bg-amber-500/10 border-amber-500/30' };
  }
};

export const StoryCard: React.FC<StoryCardProps> = ({
  story,
  isBookmarked,
  isLiked,
  isPurchased = false,
  onSelect,
  onToggleBookmark,
  onToggleLike,
  onBuy,
}) => {
  const [imageError, setImageError] = useState(false);

  const isOwner1 = story.authorEmail === 'earlasathvik.rs@gmail.com';
  const isOwner2 = story.authorEmail === 'weakongames83@gmail.com';
  const isFree = !story.price || story.price <= 0;
  const formatInfo = getFormatLabel(story.type);
  const FormatIcon = formatInfo.icon;

  return (
    <div
      onClick={() => onSelect(story)}
      className="group relative flex flex-col overflow-hidden rounded-2xl border border-slate-800/80 bg-slate-900/60 transition-all duration-300 hover:-translate-y-1 hover:border-slate-700/80 hover:shadow-xl hover:shadow-amber-500/5 cursor-pointer"
    >
      {/* Cover Image Container (3:4 ratio) */}
      <div className="relative aspect-[3/4] w-full overflow-hidden bg-slate-950">
        {!imageError && story.coverImage ? (
          <img
            src={story.coverImage}
            alt={story.title}
            referrerPolicy="no-referrer"
            onError={() => setImageError(true)}
            className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
            loading="lazy"
          />
        ) : (
          <div className="flex h-full w-full flex-col items-center justify-center p-6 text-center bg-gradient-to-br from-slate-900 via-indigo-950/40 to-slate-900">
            <BookOpen className="h-10 w-10 text-amber-400/60 mb-3" />
            <span className="font-display text-sm font-semibold text-slate-300">
              {story.title}
            </span>
            <span className="text-xs text-slate-500 mt-1">{story.genre}</span>
          </div>
        )}

        {/* Ambient Gradient Scrim */}
        <div className="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/30 to-transparent" />

        {/* Top Left: Price or Unlocked Badge */}
        <div className="absolute top-3 left-3 z-10 flex flex-col gap-1.5 items-start">
          {isPurchased || isFree ? (
            <span className="flex items-center gap-1 rounded-full bg-emerald-950/80 backdrop-blur-md border border-emerald-500/40 px-2.5 py-1 text-[11px] font-bold text-emerald-300 shadow-sm">
              <CheckCircle className="h-3 w-3" />
              <span>{isFree ? 'Free Read' : 'Purchased'}</span>
            </span>
          ) : (
            <span className="flex items-center gap-1 rounded-full bg-amber-500/90 backdrop-blur-md px-2.5 py-1 text-[11px] font-black text-slate-950 shadow-md">
              <span>₹{story.price.toFixed(2)}</span>
            </span>
          )}

          {/* Format Type Badge */}
          <span className={`inline-flex items-center gap-1 rounded-full backdrop-blur-md border px-2 py-0.5 text-[10px] font-semibold ${formatInfo.color}`}>
            <FormatIcon className="h-2.5 w-2.5" />
            <span className="capitalize">{story.type}</span>
          </span>
        </div>

        {/* Top Right Floating Controls */}
        <div className="absolute top-3 right-3 flex items-center gap-1.5 z-10">
          <button
            onClick={(e) => onToggleLike(story.id, e)}
            className="flex min-h-[36px] min-w-[36px] items-center justify-center rounded-full bg-slate-950/70 backdrop-blur-md border border-slate-700/50 text-slate-300 transition-colors hover:text-rose-400 active:scale-90"
            title="Like story"
            aria-label="Like story"
          >
            <Heart
              className={`h-4 w-4 ${isLiked ? 'fill-rose-500 text-rose-500' : ''}`}
            />
          </button>
          <button
            onClick={(e) => onToggleBookmark(story.id, e)}
            className="flex min-h-[36px] min-w-[36px] items-center justify-center rounded-full bg-slate-950/70 backdrop-blur-md border border-slate-700/50 text-slate-300 transition-colors hover:text-amber-400 active:scale-90"
            title="Save to bookmarks"
            aria-label="Save to bookmarks"
          >
            <Bookmark
              className={`h-4 w-4 ${isBookmarked ? 'fill-amber-400 text-amber-400' : ''}`}
            />
          </button>
        </div>

        {/* Bottom Cover Info */}
        <div className="absolute bottom-3 left-3 right-3 z-10">
          <div className="flex items-center gap-1.5 text-xs text-amber-300/90 font-medium drop-shadow-sm">
            <span className="truncate">{formatInfo.label}</span>
            <span aria-hidden="true" className="text-slate-400">·</span>
            <span className="flex items-center gap-1 text-slate-300 shrink-0">
              <Clock className="h-3 w-3" />
              {story.readingTimeMinutes} min
            </span>
            <span aria-hidden="true" className="text-slate-400">·</span>
            <span className="flex items-center gap-0.5 text-amber-400 font-semibold tabular-nums shrink-0">
              <Star className="h-3 w-3 fill-amber-400" />
              {story.stats.rating}
            </span>
          </div>
        </div>
      </div>

      {/* Body Content */}
      <div className="flex flex-1 flex-col p-4 sm:p-5">
        <h3 className="font-display text-base sm:text-lg font-bold text-slate-100 line-clamp-1 group-hover:text-amber-300 transition-colors">
          {story.title}
        </h3>

        <p className="mt-1 text-xs text-slate-400 line-clamp-2 leading-relaxed">
          {story.subtitle || story.synopsis}
        </p>

        {/* Formats Available indicator */}
        <div className="mt-2.5 flex flex-wrap items-center gap-1 text-[10px] text-slate-400">
          <span className="text-slate-500 font-semibold">Formats:</span>
          <span className="rounded bg-slate-800/80 px-1.5 py-0.5 font-mono text-slate-300">PDF</span>
          <span className="rounded bg-slate-800/80 px-1.5 py-0.5 font-mono text-slate-300">EPUB</span>
          <span className="rounded bg-slate-800/80 px-1.5 py-0.5 font-mono text-slate-300">DOCX</span>
          <span className="rounded bg-slate-800/80 px-1.5 py-0.5 font-mono text-slate-300">TXT</span>
          <span className="rounded bg-slate-800/80 px-1.5 py-0.5 font-mono text-slate-300">HTML</span>
          {story.documentFile && (
            <span className="rounded bg-cyan-950/60 border border-cyan-500/30 px-1.5 py-0.5 text-cyan-300 font-bold">
              +Original Doc
            </span>
          )}
        </div>

        {/* Author & Purchase Action footer */}
        <div className="mt-auto pt-4 flex items-center justify-between border-t border-slate-800/70 text-xs text-slate-400">
          <div className="flex items-center gap-1.5 truncate max-w-[150px]">
            <span className="text-slate-500">By</span>
            <span className="font-medium text-slate-300 truncate">
              {story.authorName}
            </span>
            {(isOwner1 || isOwner2) && (
              <span title="Verified Story Owner" className="text-emerald-400 shrink-0">
                <UserCheck className="h-3.5 w-3.5" />
              </span>
            )}
          </div>

          <div>
            {!isPurchased && !isFree && onBuy ? (
              <button
                onClick={(e) => onBuy(story, e)}
                className="flex items-center gap-1.5 rounded-lg bg-amber-500/20 border border-amber-500/40 px-2.5 py-1 text-xs font-bold text-amber-300 hover:bg-amber-500 hover:text-slate-950 transition-colors"
              >
                <ShoppingBag className="h-3.5 w-3.5" />
                <span>Buy ₹{story.price.toFixed(2)}</span>
              </button>
            ) : (
              <span className="text-slate-500 tabular-nums">
                {story.chapters.length} {story.type === 'storybook' || story.type === 'comic' ? 'pages' : 'chapters'}
              </span>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
