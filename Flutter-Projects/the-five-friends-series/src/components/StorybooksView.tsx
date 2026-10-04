import React, { useState } from 'react';
import { StoryItem, ContentType } from '../types';
import { StoryCard } from './StoryCard';
import { BookMarked, Sparkles, BookOpen, Book, Layers, Headphones, Scroll, Clapperboard } from 'lucide-react';

interface StorybooksViewProps {
  stories: StoryItem[];
  bookmarks: string[];
  likes: string[];
  purchasedIds?: string[];
  progress: Record<string, { lastPage: number; updatedAt: string }>;
  onSelectStory: (story: StoryItem) => void;
  onToggleBookmark: (storyId: string, e: React.MouseEvent) => void;
  onToggleLike: (storyId: string, e: React.MouseEvent) => void;
  onBuy?: (story: StoryItem, e: React.MouseEvent) => void;
}

export const StorybooksView: React.FC<StorybooksViewProps> = ({
  stories,
  bookmarks,
  likes,
  purchasedIds = [],
  onSelectStory,
  onToggleBookmark,
  onToggleLike,
  onBuy,
}) => {
  const [activeFormat, setActiveFormat] = useState<string>('all');

  const publishedStories = stories.filter((s) => s.status === 'published');
  
  const formatCategories = [
    { id: 'all', label: 'All Formatted Editions', icon: Sparkles },
    { id: 'storybook', label: 'Illustrated Storybooks', icon: BookOpen },
    { id: 'novel', label: 'Novels & Epics', icon: Book },
    { id: 'comic', label: 'Graphic Novels & Comics', icon: Layers },
    { id: 'audiobook', label: 'Audiobooks', icon: Headphones },
    { id: 'poetry', label: 'Poetry & Verse', icon: Scroll },
    { id: 'script', label: 'Drama & Scripts', icon: Clapperboard },
  ];

  const displayedStories = publishedStories.filter((s) => {
    if (activeFormat === 'all') {
      return s.type !== 'story'; // show all rich format editions
    }
    return s.type === activeFormat;
  });

  return (
    <div className="mx-auto max-w-6xl px-4 py-6 sm:py-8 pb-28">
      <div className="mb-6 pb-4 border-b border-slate-800">
        <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-amber-400 mb-1">
          <Sparkles className="h-3.5 w-3.5" />
          <span>Every Format Type Available</span>
        </div>
        <h2 className="font-display text-2xl sm:text-3xl font-bold text-slate-100 flex items-center gap-2.5">
          <BookMarked className="h-7 w-7 text-amber-400" />
          <span>Illustrated Storybooks &amp; Rich Editions</span>
        </h2>
        <p className="text-xs text-slate-400 mt-1 max-w-xl">
          Explore all publication formats: full-color illustrated storybooks, long-form novels, graphic novels, audiobooks, and poetry with touch page flips, voice narration, and document downloads.
        </p>

        {/* Format Selector Pills */}
        <div className="mt-4 flex flex-wrap items-center gap-1.5 p-1 bg-slate-900 border border-slate-800 rounded-xl overflow-x-auto">
          {formatCategories.map((fmt) => {
            const Icon = fmt.icon;
            return (
              <button
                key={fmt.id}
                onClick={() => setActiveFormat(fmt.id)}
                className={`flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium rounded-lg transition-colors whitespace-nowrap ${
                  activeFormat === fmt.id
                    ? 'bg-amber-500 text-slate-950 font-bold shadow-sm'
                    : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                <Icon className="h-3.5 w-3.5" />
                <span>{fmt.label}</span>
              </button>
            );
          })}
        </div>
      </div>

      {displayedStories.length > 0 ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {displayedStories.map((story) => (
            <StoryCard
              key={story.id}
              story={story}
              isBookmarked={bookmarks.includes(story.id)}
              isLiked={likes.includes(story.id)}
              isPurchased={purchasedIds.includes(story.id)}
              onSelect={onSelectStory}
              onToggleBookmark={onToggleBookmark}
              onToggleLike={onToggleLike}
              onBuy={onBuy}
            />
          ))}
        </div>
      ) : (
        <div className="rounded-2xl border border-slate-800 bg-slate-900/40 p-12 text-center max-w-md mx-auto">
          <BookMarked className="h-10 w-10 text-slate-600 mx-auto mb-3" />
          <h4 className="text-sm font-bold text-slate-300">No {activeFormat !== 'all' ? activeFormat : ''} books published yet</h4>
          <p className="mt-1 text-xs text-slate-500">
            Owners can upload document files in any format type and set pricing via the Owner Access dashboard.
          </p>
        </div>
      )}
    </div>
  );
};
