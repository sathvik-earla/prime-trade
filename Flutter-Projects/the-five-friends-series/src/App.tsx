/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState } from 'react';
import { StoryItem, OwnerUser, ReaderUser, PurchaseRecord } from './types';
import {
  getStories,
  getBookmarks,
  getLikes,
  getReadingProgress,
  getUserPurchases,
  getUserPurchaseRecords,
  toggleBookmark,
  toggleLike,
} from './services/storage';
import {
  getCurrentOwnerSession,
  clearOwnerSession,
  getCurrentReaderSession,
  clearReaderSession,
  PUBLISHING_PHONE_NUMBERS,
} from './services/auth';
import { Header } from './components/Header';
import { BottomNav } from './components/BottomNav';
import { LibraryView } from './components/LibraryView';
import { StorybooksView } from './components/StorybooksView';
import { BookmarksView } from './components/BookmarksView';
import { MyPurchasesSection } from './components/MyPurchasesSection';
import { PublishPortal } from './components/PublishPortal';
import { ReaderModal } from './components/ReaderModal';
import { CheckoutModal } from './components/CheckoutModal';
import { CompulsoryLoginModal } from './components/CompulsoryLoginModal';
import { PublishingCallBanner } from './components/PublishingCallBanner';
import { PhoneCall } from 'lucide-react';

export default function App() {
  const [currentTab, setCurrentTab] = useState<'library' | 'storybooks' | 'bookmarks' | 'purchases' | 'owner'>('library');
  const [ownerSession, setOwnerSession] = useState<OwnerUser | null>(() => getCurrentOwnerSession());
  const [readerSession, setReaderSession] = useState<ReaderUser | null>(() => getCurrentReaderSession());
  const [stories, setStories] = useState<StoryItem[]>(() => getStories());
  const [bookmarks, setBookmarks] = useState<string[]>(() => getBookmarks());
  const [likes, setLikes] = useState<string[]>(() => getLikes());
  const [purchasedIds, setPurchasedIds] = useState<string[]>(() => getUserPurchases());
  const [purchaseRecords, setPurchaseRecords] = useState<PurchaseRecord[]>(() => getUserPurchaseRecords());
  const [progress, setProgress] = useState(() => getReadingProgress());
  const [activeReadingStory, setActiveReadingStory] = useState<StoryItem | null>(null);
  const [activeCheckoutStory, setActiveCheckoutStory] = useState<StoryItem | null>(null);

  // Sync data refresh
  const refreshData = () => {
    setStories([...getStories()]);
    setBookmarks([...getBookmarks()]);
    setLikes([...getLikes()]);
    setPurchasedIds([...getUserPurchases()]);
    setPurchaseRecords([...getUserPurchaseRecords()]);
    setProgress({ ...getReadingProgress() });
  };

  // Handlers
  const handleToggleBookmark = (storyId: string, e?: React.MouseEvent) => {
    if (e) e.stopPropagation();
    toggleBookmark(storyId);
    setBookmarks([...getBookmarks()]);
    setStories([...getStories()]);
  };

  const handleToggleLike = (storyId: string, e?: React.MouseEvent) => {
    if (e) e.stopPropagation();
    toggleLike(storyId);
    setLikes([...getLikes()]);
    setStories([...getStories()]);
  };

  const handleSelectStory = (story: StoryItem) => {
    setActiveReadingStory(story);
  };

  const handleBuyStory = (story: StoryItem, e?: React.MouseEvent) => {
    if (e) e.stopPropagation();
    setActiveCheckoutStory(story);
  };

  const handleOwnerLoginSuccess = (owner: OwnerUser) => {
    setOwnerSession(owner);
  };

  const handleReaderLoginSuccess = (reader: ReaderUser) => {
    setReaderSession(reader);
  };

  const handleLogout = () => {
    clearOwnerSession();
    clearReaderSession();
    setOwnerSession(null);
    setReaderSession(null);
    setCurrentTab('library');
  };

  // Scroll to top on tab switch
  const handleSelectTab = (tab: 'library' | 'storybooks' | 'bookmarks' | 'purchases' | 'owner') => {
    setCurrentTab(tab);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const isAuthenticated = !!ownerSession || !!readerSession;

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col font-sans selection:bg-amber-500/20 selection:text-amber-200">
      {/* Starting Announcement Banner: Call +91 9398638545 Or +91 85905 63007 for publishing a book */}
      <PublishingCallBanner variant="topbar" />

      {/* Header */}
      <Header
        currentTab={currentTab}
        onSelectTab={handleSelectTab}
        ownerSession={ownerSession}
        readerSession={readerSession}
        onOpenOwnerPortal={() => handleSelectTab('owner')}
        onLogout={handleLogout}
        purchasedCount={purchasedIds.length}
      />

      {/* COMPULSORY LOGIN GATE: User MUST login to enter and use the app */}
      {!isAuthenticated && (
        <CompulsoryLoginModal
          onReaderLoginSuccess={handleReaderLoginSuccess}
          onOwnerLoginSuccess={(owner) => {
            handleOwnerLoginSuccess(owner);
            setCurrentTab('owner');
          }}
        />
      )}

      {/* Main View Area */}
      <main className="flex-1">
        {currentTab === 'library' && (
          <LibraryView
            stories={stories}
            bookmarks={bookmarks}
            likes={likes}
            purchasedIds={purchasedIds}
            purchaseRecords={purchaseRecords}
            progress={progress}
            onSelectStory={handleSelectStory}
            onToggleBookmark={handleToggleBookmark}
            onToggleLike={handleToggleLike}
            onBuyStory={handleBuyStory}
            onGoToStorybooksTab={() => handleSelectTab('storybooks')}
            onOpenOwnerPortal={() => handleSelectTab('owner')}
          />
        )}

        {currentTab === 'purchases' && (
          <div className="mx-auto max-w-6xl px-4 py-6 sm:py-8 pb-28">
            <MyPurchasesSection
              stories={stories}
              purchasedIds={purchasedIds}
              purchaseRecords={purchaseRecords}
              onSelectStory={handleSelectStory}
              onExploreLibrary={() => handleSelectTab('library')}
            />
          </div>
        )}

        {currentTab === 'storybooks' && (
          <StorybooksView
            stories={stories}
            bookmarks={bookmarks}
            likes={likes}
            purchasedIds={purchasedIds}
            progress={progress}
            onSelectStory={handleSelectStory}
            onToggleBookmark={handleToggleBookmark}
            onToggleLike={handleToggleLike}
            onBuy={handleBuyStory}
          />
        )}

        {currentTab === 'bookmarks' && (
          <BookmarksView
            stories={stories}
            bookmarks={bookmarks}
            likes={likes}
            progress={progress}
            onSelectStory={handleSelectStory}
            onToggleBookmark={handleToggleBookmark}
            onToggleLike={handleToggleLike}
            onExploreLibrary={() => handleSelectTab('library')}
          />
        )}

        {currentTab === 'owner' && (
          <PublishPortal
            ownerSession={ownerSession}
            stories={stories}
            onLoginSuccess={handleOwnerLoginSuccess}
            onLogout={handleLogout}
            onRefreshData={refreshData}
            onPreviewStory={handleSelectStory}
          />
        )}
      </main>

      {/* Fullscreen Touch & Audio Reader for iOS and Android */}
      {activeReadingStory && (
        <ReaderModal
          story={activeReadingStory}
          initialPage={progress[activeReadingStory.id]?.lastPage || 1}
          isBookmarked={bookmarks.includes(activeReadingStory.id)}
          isLiked={likes.includes(activeReadingStory.id)}
          isPurchased={purchasedIds.includes(activeReadingStory.id)}
          onClose={() => {
            setActiveReadingStory(null);
            refreshData();
          }}
          onToggleBookmark={(id) => handleToggleBookmark(id)}
          onToggleLike={(id) => handleToggleLike(id)}
          onRequestPurchase={() => {
            setActiveCheckoutStory(activeReadingStory);
          }}
          onStoryUpdated={() => {
            refreshData();
            const updated = getStories().find((s) => s.id === activeReadingStory.id);
            if (updated) setActiveReadingStory(updated);
          }}
        />
      )}

      {/* Checkout Modal for Buying Books (Card, Apple/Google Pay, or Cash on Delivery) */}
      {activeCheckoutStory && (
        <CheckoutModal
          story={activeCheckoutStory}
          onClose={() => setActiveCheckoutStory(null)}
          onSuccess={() => {
            refreshData();
            setCurrentTab('purchases');
          }}
        />
      )}

      {/* Bottom Nav for Mobile Ergonomics (Android & iOS) */}
      <BottomNav
        currentTab={currentTab}
        onSelectTab={handleSelectTab}
        ownerSession={ownerSession}
        bookmarkCount={bookmarks.length}
        purchasedCount={purchasedIds.length}
      />

      {/* Quiet Footer with Publisher Hotline */}
      <footer className="border-t border-slate-900 bg-slate-950 py-8 px-4 text-center text-xs text-slate-500 hidden md:block">
        <div className="mx-auto max-w-6xl flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2.5">
            <img
              src="/src/assets/images/app_logo_five_friends_1790435713416.jpg"
              alt="The Five Friends Series"
              className="h-7 w-7 rounded-full object-cover border border-amber-400/60 bg-white"
            />
            <span className="font-display font-semibold text-slate-300">
              THE FIVE FRIENDS SERIES
            </span>
            <span>·</span>
            <span>Illustrated Storybooks &amp; Tales Bookstore</span>
          </div>

          <div className="flex flex-wrap items-center justify-center gap-3 text-slate-400">
            <div className="flex items-center gap-1.5 text-amber-400 font-semibold">
              <PhoneCall className="h-3.5 w-3.5" />
              <span>
                Call{' '}
                <a href={`tel:${PUBLISHING_PHONE_NUMBERS[0].tel}`} className="underline hover:text-amber-300">
                  {PUBLISHING_PHONE_NUMBERS[0].display}
                </a>{' '}
                Or{' '}
                <a href={`tel:${PUBLISHING_PHONE_NUMBERS[1].tel}`} className="underline hover:text-amber-300">
                  {PUBLISHING_PHONE_NUMBERS[1].display}
                </a>{' '}
                for publishing a book
              </span>
            </div>
            <span>·</span>
            <button
              onClick={() => handleSelectTab('owner')}
              className="text-amber-400/90 hover:underline"
            >
              {ownerSession ? 'Owner Dashboard' : 'Owner Access'}
            </button>
          </div>
        </div>
      </footer>
    </div>
  );
}
