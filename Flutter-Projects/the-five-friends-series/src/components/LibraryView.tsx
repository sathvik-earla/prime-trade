import React, { useState } from 'react';
import { StoryItem, StoryGenre, ContentType, PurchaseRecord } from '../types';
import { StoryCard } from './StoryCard';
import { MyPurchasesSection } from './MyPurchasesSection';
import { Search, Sparkles, BookOpen, Clock, Star, ShoppingBag, PlusCircle, CheckCircle, Truck, PhoneCall } from 'lucide-react';
import { PUBLISHING_PHONE_NUMBERS } from '../services/auth';

interface LibraryViewProps {
  stories: StoryItem[];
  bookmarks: string[];
  likes: string[];
  purchasedIds?: string[];
  purchaseRecords?: PurchaseRecord[];
  progress: Record<string, { lastPage: number; updatedAt: string }>;
  onSelectStory: (story: StoryItem) => void;
  onToggleBookmark: (storyId: string, e: React.MouseEvent) => void;
  onToggleLike: (storyId: string, e: React.MouseEvent) => void;
  onBuyStory?: (story: StoryItem, e: React.MouseEvent) => void;
  onGoToStorybooksTab: () => void;
  onOpenOwnerPortal: () => void;
}

export const LibraryView: React.FC<LibraryViewProps> = ({
  stories,
  bookmarks,
  likes,
  purchasedIds = [],
  purchaseRecords = [],
  progress,
  onSelectStory,
  onToggleBookmark,
  onToggleLike,
  onBuyStory,
  onGoToStorybooksTab,
  onOpenOwnerPortal,
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedGenre, setSelectedGenre] = useState<string>('All');
  const [selectedFormat, setSelectedFormat] = useState<string>('All'); // 'All' | 'purchases' | 'storybook' | 'story'

  const publishedStories = stories.filter((s) => s.status === 'published');
  const featuredStory = publishedStories.find((s) => s.featured) || publishedStories[0];

  // Check if any purchased story has COD awaiting delivery
  const codPendingCount = purchaseRecords.filter(
    (r) => r.paymentMethod === 'cod' && r.deliveryStatus !== 'delivered'
  ).length;

  const filteredStories = publishedStories.filter((story) => {
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      const matchTitle = story.title.toLowerCase().includes(q);
      const matchAuthor = story.authorName.toLowerCase().includes(q);
      const matchSynopsis = story.synopsis.toLowerCase().includes(q);
      const matchGenre = story.genre.toLowerCase().includes(q);
      if (!matchTitle && !matchAuthor && !matchSynopsis && !matchGenre) return false;
    }

    if (selectedFormat !== 'All' && selectedFormat !== 'purchases') {
      if (story.type !== selectedFormat) return false;
    }
    if (selectedGenre !== 'All' && story.genre !== selectedGenre) return false;

    return true;
  });

  const formatOptions = [
    { id: 'All', label: 'All Formats' },
    { id: 'storybook', label: 'Storybooks' },
    { id: 'novel', label: 'Novels' },
    { id: 'story', label: 'Short Stories' },
    { id: 'comic', label: 'Comics' },
    { id: 'audiobook', label: 'Audiobooks' },
    { id: 'poetry', label: 'Poetry' },
    { id: 'script', label: 'Scripts' },
    { id: 'interactive', label: 'Interactive' },
  ];

  const genres: (string | StoryGenre)[] = [
    'All',
    'Bedtime',
    'Fantasy',
    'Adventure',
    'Mythology',
    'Sci-Fi',
  ];

  return (
    <div className="mx-auto max-w-6xl px-4 py-6 sm:py-8 pb-28">
      {/* PURCHASES NOTIFICATION CALLOUT BANNER (if user has purchases) */}
      {purchasedIds.length > 0 && selectedFormat !== 'purchases' && (
        <div className="mb-6 flex flex-col sm:flex-row sm:items-center justify-between gap-3 rounded-2xl border border-emerald-500/30 bg-emerald-950/20 p-4 backdrop-blur-sm">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-emerald-500/20 text-emerald-400">
              <ShoppingBag className="h-5 w-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-xs font-bold text-slate-100">
                  You have {purchasedIds.length} purchased {purchasedIds.length === 1 ? 'story' : 'stories'}
                </span>
                {codPendingCount > 0 && (
                  <span className="flex items-center gap-1 rounded-full bg-amber-500/20 px-2 py-0.5 text-[10px] font-bold text-amber-300">
                    <Truck className="h-3 w-3 animate-pulse" />
                    <span>{codPendingCount} COD in Delivery</span>
                  </span>
                )}
              </div>
              <p className="text-[11px] text-slate-400">
                View your unlocked library, reading progress, and live delivery status.
              </p>
            </div>
          </div>

          <button
            onClick={() => setSelectedFormat('purchases')}
            className="flex items-center justify-center gap-1.5 rounded-xl bg-emerald-500/20 hover:bg-emerald-500/30 border border-emerald-500/40 px-4 py-2 text-xs font-bold text-emerald-300 transition-colors w-fit self-end sm:self-auto"
          >
            <span>View My Purchases</span>
            <span>→</span>
          </button>
        </div>
      )}

      {/* VIEW MODE 1: DEDICATED MY PURCHASES VIEW */}
      {selectedFormat === 'purchases' ? (
        <div className="space-y-6">
          <button
            onClick={() => setSelectedFormat('All')}
            className="inline-flex items-center gap-1.5 text-xs text-slate-400 hover:text-amber-400 transition-colors mb-2"
          >
            <span>← Back to Complete Bookstore Catalog</span>
          </button>

          <MyPurchasesSection
            stories={stories}
            purchasedIds={purchasedIds}
            purchaseRecords={purchaseRecords}
            onSelectStory={onSelectStory}
            onExploreLibrary={() => setSelectedFormat('All')}
          />
        </div>
      ) : (
        /* VIEW MODE 2: MAIN BOOKSTORE CATALOG */
        <>
          {/* Starting Banner: Call +91 9398638545 Or +91 85905 63007 for publishing a book */}
          <div className="mb-6 rounded-2xl border border-amber-500/30 bg-gradient-to-r from-amber-500/10 via-amber-400/15 to-amber-500/10 p-3.5 sm:p-4 text-center shadow-md">
            <div className="flex items-center justify-center gap-2 text-xs font-bold uppercase tracking-wider text-amber-400 mb-1">
              <PhoneCall className="h-4 w-4 shrink-0 text-amber-400" />
              <span>Story Authors &amp; Creators Helpline</span>
            </div>
            <p className="text-sm sm:text-base font-bold text-slate-100">
              Call{' '}
              <a
                href={`tel:${PUBLISHING_PHONE_NUMBERS[0].tel}`}
                className="text-amber-400 underline decoration-amber-400 underline-offset-2 hover:text-amber-300 font-extrabold mx-0.5"
              >
                {PUBLISHING_PHONE_NUMBERS[0].display}
              </a>{' '}
              Or{' '}
              <a
                href={`tel:${PUBLISHING_PHONE_NUMBERS[1].tel}`}
                className="text-amber-400 underline decoration-amber-400 underline-offset-2 hover:text-amber-300 font-extrabold mx-0.5"
              >
                {PUBLISHING_PHONE_NUMBERS[1].display}
              </a>{' '}
              for publishing a book
            </p>
          </div>

          {/* Featured Hero Banner */}
          {featuredStory && !searchQuery && selectedGenre === 'All' && selectedFormat === 'All' && (
            <div
              onClick={() => onSelectStory(featuredStory)}
              className="group relative mb-10 overflow-hidden rounded-3xl border border-slate-800 bg-gradient-to-r from-slate-900 via-slate-900 to-indigo-950/40 p-6 sm:p-10 shadow-2xl transition-all duration-300 hover:border-slate-700 cursor-pointer"
            >
              <div className="absolute right-0 top-0 bottom-0 w-full sm:w-1/2 opacity-25 sm:opacity-35 pointer-events-none overflow-hidden">
                <img
                  src={featuredStory.coverImage}
                  alt=""
                  className="h-full w-full object-cover blur-sm scale-110"
                />
                <div className="absolute inset-0 bg-gradient-to-r from-slate-900 via-slate-900/80 to-transparent" />
              </div>

              <div className="relative z-10 flex flex-col md:flex-row items-center gap-8 justify-between">
                <div className="max-w-xl">
                  <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-amber-400 mb-3">
                    <Sparkles className="h-4 w-4" />
                    <span>Featured Edition for Sale</span>
                    <span aria-hidden="true" className="text-slate-600">·</span>
                    <span className="text-slate-400 normal-case font-normal">
                      By {featuredStory.authorName}
                    </span>
                  </div>

                  <h2 className="font-display text-2xl sm:text-4xl font-extrabold text-slate-100 group-hover:text-amber-200 transition-colors">
                    {featuredStory.title}
                  </h2>

                  <p className="mt-3 text-xs sm:text-sm text-slate-300 leading-relaxed line-clamp-3">
                    {featuredStory.subtitle || featuredStory.synopsis}
                  </p>

                  <div className="mt-4 flex flex-wrap items-center gap-2 text-xs text-slate-400 font-medium">
                    <span className="font-bold text-amber-400 text-sm">
                      ₹{featuredStory.price ? featuredStory.price.toFixed(2) : '0.00'}
                    </span>
                    <span aria-hidden="true">·</span>
                    <span>
                      {featuredStory.type === 'storybook'
                        ? 'Illustrated Storybook'
                        : 'Single Story'}
                    </span>
                    <span aria-hidden="true">·</span>
                    <span className="flex items-center gap-1">
                      <Clock className="h-3.5 w-3.5" />
                      {featuredStory.readingTimeMinutes} min read
                    </span>
                    <span aria-hidden="true">·</span>
                    <span className="flex items-center gap-1 text-amber-400 font-semibold tabular-nums">
                      <Star className="h-3.5 w-3.5 fill-amber-400" />
                      {featuredStory.stats.rating}
                    </span>
                  </div>

                  <div className="mt-6 flex flex-wrap items-center gap-3">
                    {purchasedIds.includes(featuredStory.id) || featuredStory.price <= 0 ? (
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          onSelectStory(featuredStory);
                        }}
                        className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-400 px-5 py-2.5 text-xs font-bold text-slate-950 shadow-lg active:scale-95"
                      >
                        <BookOpen className="h-4 w-4" />
                        <span>Read Purchased Book</span>
                      </button>
                    ) : (
                      <>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            if (onBuyStory) onBuyStory(featuredStory, e);
                          }}
                          className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-amber-500 to-amber-400 px-5 py-2.5 text-xs font-bold text-slate-950 shadow-lg shadow-amber-500/20 active:scale-95 hover:brightness-105"
                        >
                          <ShoppingBag className="h-4 w-4" />
                          <span>Buy for ${featuredStory.price.toFixed(2)}</span>
                        </button>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            onSelectStory(featuredStory);
                          }}
                          className="flex items-center gap-1.5 rounded-xl border border-slate-700 bg-slate-900/80 px-4 py-2.5 text-xs font-semibold text-slate-300 hover:text-white"
                        >
                          <BookOpen className="h-3.5 w-3.5" />
                          <span>Free Sample Preview</span>
                        </button>
                      </>
                    )}
                  </div>
                </div>

                <div className="relative aspect-[3/4] w-48 sm:w-56 shrink-0 overflow-hidden rounded-2xl border border-slate-700/60 shadow-2xl hidden md:block">
                  <img
                    src={featuredStory.coverImage}
                    alt={featuredStory.title}
                    className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
                  />
                </div>
              </div>
            </div>
          )}

          {/* If bookstore has published books: Search & Filter Toolbar */}
          {publishedStories.length > 0 ? (
            <>
              <div className="mb-8 space-y-4">
                <div className="relative">
                  <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
                  <input
                    type="text"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    placeholder="Search books for sale by title, author, or genre..."
                    className="w-full rounded-2xl border border-slate-800 bg-slate-900/80 pl-11 pr-4 py-3 text-sm text-slate-100 placeholder-slate-500 focus:border-amber-400 focus:outline-none focus:ring-1 focus:ring-amber-400 transition-colors"
                  />
                  {searchQuery && (
                    <button
                      onClick={() => setSearchQuery('')}
                      className="absolute right-4 top-1/2 -translate-y-1/2 text-xs text-slate-400 hover:text-white"
                    >
                      Clear
                    </button>
                  )}
                </div>

                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <div className="flex items-center gap-1 p-1 bg-slate-900 border border-slate-800 rounded-xl overflow-x-auto">
                    {formatOptions.map((opt) => (
                      <button
                        key={opt.id}
                        onClick={() => setSelectedFormat(opt.id)}
                        className={`px-3 py-1.5 text-xs font-medium rounded-lg transition-colors whitespace-nowrap ${
                          selectedFormat === opt.id
                            ? 'bg-amber-500 text-slate-950 font-bold shadow-sm'
                            : 'text-slate-400 hover:text-slate-200'
                        }`}
                      >
                        {opt.label}
                      </button>
                    ))}

                    {/* Dedicated My Purchases Filter Tab */}
                    {purchasedIds.length > 0 && (
                      <button
                        onClick={() => setSelectedFormat('purchases')}
                        className={`flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium rounded-lg transition-colors whitespace-nowrap ${
                          selectedFormat === 'purchases'
                            ? 'bg-emerald-500 text-slate-950 font-bold shadow-sm'
                            : 'text-emerald-400 hover:text-emerald-300'
                        }`}
                      >
                        <ShoppingBag className="h-3.5 w-3.5" />
                        <span>My Purchases ({purchasedIds.length})</span>
                      </button>
                    )}
                  </div>

                  <div className="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0">
                    {genres.map((genre) => (
                      <button
                        key={genre}
                        onClick={() => setSelectedGenre(genre)}
                        className={`px-3 py-1.5 text-xs font-medium rounded-lg transition-colors whitespace-nowrap border ${
                          selectedGenre === genre
                            ? 'border-amber-400/80 bg-amber-500/10 text-amber-300 font-semibold'
                            : 'border-slate-800 bg-slate-900/40 text-slate-400 hover:text-slate-200 hover:border-slate-700'
                        }`}
                      >
                        {genre}
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              {/* Book Catalog Grid */}
              {filteredStories.length > 0 ? (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                  {filteredStories.map((story) => (
                    <StoryCard
                      key={story.id}
                      story={story}
                      isBookmarked={bookmarks.includes(story.id)}
                      isLiked={likes.includes(story.id)}
                      isPurchased={purchasedIds.includes(story.id)}
                      onSelect={onSelectStory}
                      onToggleBookmark={onToggleBookmark}
                      onToggleLike={onToggleLike}
                      onBuy={onBuyStory}
                    />
                  ))}
                </div>
              ) : (
                <div className="rounded-2xl border border-slate-800 bg-slate-900/40 py-16 text-center">
                  <BookOpen className="mx-auto h-12 w-12 text-slate-600 mb-3" />
                  <h3 className="font-display text-base font-bold text-slate-300">
                    No matching books found
                  </h3>
                  <p className="mt-1 text-xs text-slate-500">
                    Try modifying your search or genre filter.
                  </p>
                </div>
              )}
            </>
          ) : (
            /* Empty Storefront State - Clean slate ready for owners to add files */
            <div className="space-y-8">
              {/* If user has purchased books, show them even if catalog is clean */}
              {purchasedIds.length > 0 && (
                <MyPurchasesSection
                  stories={stories}
                  purchasedIds={purchasedIds}
                  purchaseRecords={purchaseRecords}
                  onSelectStory={onSelectStory}
                />
              )}

              <div className="rounded-3xl border border-slate-800 bg-slate-900/50 p-8 sm:p-14 text-center max-w-2xl mx-auto my-6 shadow-xl">
                <img
                  src="/src/assets/images/app_logo_five_friends_1790435713416.jpg"
                  alt="The Five Friends Series"
                  className="mx-auto h-24 w-24 sm:h-28 sm:w-28 rounded-full object-cover border-2 border-amber-400 shadow-xl shadow-amber-500/10 mb-5 bg-white"
                />
                <span className="text-xs font-semibold uppercase tracking-wider text-amber-400 block mb-1">
                  Storefront Ready for Publications
                </span>
                <h2 className="font-display text-2xl sm:text-3xl font-bold text-slate-100">
                  The Five Friends Series Bookstore
                </h2>
                <p className="mt-3 text-xs sm:text-sm text-slate-400 leading-relaxed max-w-md mx-auto">
                  Existing default books have been cleared. As an owner, you can now upload story document files, set prices, and offer your books for sale.
                </p>

                <div className="mt-8 flex flex-col sm:flex-row items-center justify-center gap-3">
                  <button
                    onClick={onOpenOwnerPortal}
                    className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-amber-500 to-amber-400 px-6 py-3 text-xs font-bold text-slate-950 shadow-lg shadow-amber-500/20 active:scale-95 transition-transform hover:brightness-105"
                  >
                    <PlusCircle className="h-4 w-4" />
                    <span>Owner Access: Upload Stories &amp; Set Prices</span>
                  </button>
                </div>
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
};
