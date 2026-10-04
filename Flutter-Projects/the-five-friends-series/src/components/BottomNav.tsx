import React from 'react';
import { BookOpen, BookMarked, Bookmark, ShieldCheck, Lock, ShoppingBag } from 'lucide-react';
import { OwnerUser } from '../types';

interface BottomNavProps {
  currentTab: 'library' | 'storybooks' | 'bookmarks' | 'purchases' | 'owner';
  onSelectTab: (tab: 'library' | 'storybooks' | 'bookmarks' | 'purchases' | 'owner') => void;
  ownerSession: OwnerUser | null;
  bookmarkCount: number;
  purchasedCount?: number;
}

export const BottomNav: React.FC<BottomNavProps> = ({
  currentTab,
  onSelectTab,
  ownerSession,
  bookmarkCount,
  purchasedCount = 0,
}) => {
  return (
    <nav className="fixed bottom-0 left-0 right-0 z-40 block md:hidden border-t border-slate-800/90 bg-slate-950/95 backdrop-blur-lg pb-safe">
      <div className="grid grid-cols-5 items-center h-16 px-1">
        {/* Library Tab */}
        <button
          onClick={() => onSelectTab('library')}
          className={`relative flex min-h-[44px] min-w-[44px] flex-col items-center justify-center transition-colors ${
            currentTab === 'library' ? 'text-amber-400' : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <BookOpen className="h-5 w-5" strokeWidth={currentTab === 'library' ? 2.5 : 1.8} />
          <span className="mt-0.5 text-[10px] font-medium tracking-tight">Library</span>
          {currentTab === 'library' && (
            <span className="absolute bottom-1 h-1 w-1 rounded-full bg-amber-400" />
          )}
        </button>

        {/* My Purchases Tab */}
        <button
          onClick={() => onSelectTab('purchases')}
          className={`relative flex min-h-[44px] min-w-[44px] flex-col items-center justify-center transition-colors ${
            currentTab === 'purchases' ? 'text-emerald-400' : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <div className="relative">
            <ShoppingBag className="h-5 w-5" strokeWidth={currentTab === 'purchases' ? 2.5 : 1.8} />
            {purchasedCount > 0 && (
              <span className="absolute -top-1 -right-2 flex h-4 w-4 items-center justify-center rounded-full bg-emerald-500 text-[9px] font-bold text-slate-950">
                {purchasedCount}
              </span>
            )}
          </div>
          <span className="mt-0.5 text-[10px] font-medium tracking-tight">Purchases</span>
          {currentTab === 'purchases' && (
            <span className="absolute bottom-1 h-1 w-1 rounded-full bg-emerald-400" />
          )}
        </button>

        {/* Storybooks Tab */}
        <button
          onClick={() => onSelectTab('storybooks')}
          className={`relative flex min-h-[44px] min-w-[44px] flex-col items-center justify-center transition-colors ${
            currentTab === 'storybooks' ? 'text-amber-400' : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <BookMarked className="h-5 w-5" strokeWidth={currentTab === 'storybooks' ? 2.5 : 1.8} />
          <span className="mt-0.5 text-[10px] font-medium tracking-tight">Storybooks</span>
          {currentTab === 'storybooks' && (
            <span className="absolute bottom-1 h-1 w-1 rounded-full bg-amber-400" />
          )}
        </button>

        {/* Bookmarks Tab */}
        <button
          onClick={() => onSelectTab('bookmarks')}
          className={`relative flex min-h-[44px] min-w-[44px] flex-col items-center justify-center transition-colors ${
            currentTab === 'bookmarks' ? 'text-amber-400' : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <div className="relative">
            <Bookmark className="h-5 w-5" strokeWidth={currentTab === 'bookmarks' ? 2.5 : 1.8} />
            {bookmarkCount > 0 && (
              <span className="absolute -top-1 -right-2 flex h-4 w-4 items-center justify-center rounded-full bg-amber-500 text-[9px] font-bold text-slate-950">
                {bookmarkCount}
              </span>
            )}
          </div>
          <span className="mt-0.5 text-[10px] font-medium tracking-tight">Saved</span>
          {currentTab === 'bookmarks' && (
            <span className="absolute bottom-1 h-1 w-1 rounded-full bg-amber-400" />
          )}
        </button>

        {/* Owner Access Tab */}
        <button
          onClick={() => onSelectTab('owner')}
          className={`relative flex min-h-[44px] min-w-[44px] flex-col items-center justify-center transition-colors ${
            currentTab === 'owner'
              ? 'text-amber-400'
              : ownerSession
              ? 'text-emerald-400 hover:text-emerald-300'
              : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <div className="relative">
            {ownerSession ? (
              <ShieldCheck className="h-5 w-5" strokeWidth={currentTab === 'owner' ? 2.5 : 1.8} />
            ) : (
              <Lock className="h-5 w-5" strokeWidth={currentTab === 'owner' ? 2.5 : 1.8} />
            )}
            {ownerSession && (
              <span className="absolute -top-1 -right-1 h-2 w-2 rounded-full bg-emerald-400 ring-2 ring-slate-950" />
            )}
          </div>
          <span className="mt-0.5 text-[10px] font-medium tracking-tight">
            Owner
          </span>
          {currentTab === 'owner' && (
            <span className="absolute bottom-1 h-1 w-1 rounded-full bg-amber-400" />
          )}
        </button>
      </div>
    </nav>
  );
};
