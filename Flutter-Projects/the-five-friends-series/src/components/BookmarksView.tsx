import React from 'react';
import { StoryItem } from '../types';
import { StoryCard } from './StoryCard';
import { Bookmark, BookOpen, ShoppingBag, CheckCircle2, Download } from 'lucide-react';
import { downloadAttachedDocument } from '../services/storage';

interface BookmarksViewProps {
  stories: StoryItem[];
  bookmarks: string[];
  likes: string[];
  purchasedIds?: string[];
  progress: Record<string, { lastPage: number; updatedAt: string }>;
  onSelectStory: (story: StoryItem) => void;
  onToggleBookmark: (storyId: string, e: React.MouseEvent) => void;
  onToggleLike: (storyId: string, e: React.MouseEvent) => void;
  onExploreLibrary: () => void;
}

export const BookmarksView: React.FC<BookmarksViewProps> = ({
  stories,
  bookmarks,
  likes,
  purchasedIds = [],
  progress,
  onSelectStory,
  onToggleBookmark,
  onToggleLike,
  onExploreLibrary,
}) => {
  const purchasedStories = stories.filter((s) => purchasedIds.includes(s.id));
  const bookmarkedStories = stories.filter((s) => bookmarks.includes(s.id));

  return (
    <div className="mx-auto max-w-6xl px-4 py-6 sm:py-8 pb-28 space-y-10">
      {/* SECTION 1: MY PURCHASED BOOKS */}
      <div>
        <div className="mb-6 flex items-center justify-between pb-4 border-b border-slate-800">
          <div>
            <h2 className="font-display text-2xl font-bold text-slate-100 flex items-center gap-2.5">
              <ShoppingBag className="h-6 w-6 text-emerald-400" />
              <span>Purchased Books &amp; Downloads</span>
            </h2>
            <p className="text-xs text-slate-400 mt-1">
              Books you have purchased and unlocked for unlimited reading and document download.
            </p>
          </div>

          <span className="text-xs font-semibold text-emerald-400 tabular-nums">
            {purchasedStories.length} {purchasedStories.length === 1 ? 'book' : 'books'}
          </span>
        </div>

        {purchasedStories.length > 0 ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {purchasedStories.map((story) => (
              <StoryCard
                key={story.id}
                story={story}
                isBookmarked={bookmarks.includes(story.id)}
                isLiked={likes.includes(story.id)}
                isPurchased={true}
                onSelect={onSelectStory}
                onToggleBookmark={onToggleBookmark}
                onToggleLike={onToggleLike}
              />
            ))}
          </div>
        ) : (
          <div className="rounded-2xl border border-slate-800/80 bg-slate-900/30 p-8 text-center max-w-md mx-auto">
            <ShoppingBag className="h-10 w-10 text-slate-600 mx-auto mb-3" />
            <h4 className="text-sm font-bold text-slate-300">No purchased books yet</h4>
            <p className="mt-1 text-xs text-slate-500">
              When you purchase a book from the bookstore, it will appear here permanently.
            </p>
          </div>
        )}
      </div>

      {/* SECTION 2: SAVED BOOKMARKS */}
      <div>
        <div className="mb-6 flex items-center justify-between pb-4 border-b border-slate-800">
          <div>
            <h3 className="font-display text-xl font-bold text-slate-100 flex items-center gap-2.5">
              <Bookmark className="h-5 w-5 text-amber-400 fill-amber-400" />
              <span>Saved Bookmarks</span>
            </h3>
            <p className="text-xs text-slate-400 mt-1">
              Books saved to your personal reading wishlist on this device.
            </p>
          </div>

          <span className="text-xs font-semibold text-slate-400 tabular-nums">
            {bookmarkedStories.length} {bookmarkedStories.length === 1 ? 'saved' : 'saved'}
          </span>
        </div>

        {bookmarkedStories.length > 0 ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {bookmarkedStories.map((story) => (
              <StoryCard
                key={story.id}
                story={story}
                isBookmarked={true}
                isLiked={likes.includes(story.id)}
                isPurchased={purchasedIds.includes(story.id)}
                onSelect={onSelectStory}
                onToggleBookmark={onToggleBookmark}
                onToggleLike={onToggleLike}
              />
            ))}
          </div>
        ) : (
          <div className="rounded-2xl border border-slate-800/80 bg-slate-900/30 p-8 text-center max-w-md mx-auto">
            <Bookmark className="h-10 w-10 text-slate-600 mx-auto mb-3" />
            <h4 className="text-sm font-bold text-slate-300">No bookmarks saved</h4>
            <p className="mt-1 text-xs text-slate-500">
              Tap the bookmark icon on any book to add it to your wishlist.
            </p>
            <button
              onClick={onExploreLibrary}
              className="mt-4 inline-flex items-center gap-2 rounded-xl bg-amber-500 px-4 py-2 text-xs font-bold text-slate-950 hover:bg-amber-400"
            >
              <BookOpen className="h-3.5 w-3.5" />
              <span>Browse Bookstore</span>
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
