import React from 'react';
import { BookOpen, ShieldCheck, Lock, ShoppingBag, LogOut, User } from 'lucide-react';
import { OwnerUser, ReaderUser } from '../types';

interface HeaderProps {
  currentTab: 'library' | 'storybooks' | 'bookmarks' | 'purchases' | 'owner';
  onSelectTab: (tab: 'library' | 'storybooks' | 'bookmarks' | 'purchases' | 'owner') => void;
  ownerSession: OwnerUser | null;
  readerSession?: ReaderUser | null;
  onOpenOwnerPortal: () => void;
  onOpenFlutterCode?: () => void;
  onLogout?: () => void;
  purchasedCount?: number;
}

const APP_LOGO = '/src/assets/images/app_logo_five_friends_1790435713416.jpg';

export const Header: React.FC<HeaderProps> = ({
  currentTab,
  onSelectTab,
  ownerSession,
  readerSession,
  onOpenOwnerPortal,
  onLogout,
  purchasedCount = 0,
}) => {
  return (
    <header className="sticky top-0 z-30 w-full border-b border-slate-800/80 bg-slate-950/85 backdrop-blur-md">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4 sm:px-6">
        {/* Zone 1: Single text element wordmark with official logo */}
        <button
          onClick={() => onSelectTab('library')}
          className="group flex items-center gap-2.5 sm:gap-3 text-left focus:outline-none"
        >
          <img
            src={APP_LOGO}
            alt="The Five Friends Series Logo"
            className="h-10 w-10 sm:h-11 sm:w-11 rounded-full object-cover border-2 border-amber-400 shadow-md shadow-amber-500/20 transition-transform group-hover:scale-105 shrink-0 bg-white"
          />
          <div className="flex flex-col">
            <span className="font-display text-sm sm:text-base font-bold tracking-wider text-slate-100 group-hover:text-amber-300 transition-colors">
              THE FIVE FRIENDS
            </span>
            <span className="text-[10px] tracking-widest text-amber-400 font-bold uppercase -mt-0.5">
              Series Bookstore
            </span>
          </div>
        </button>

        {/* Zone 2: Clean text navigation links */}
        <nav className="hidden md:flex items-center gap-6 text-sm font-medium text-slate-400">
          <button
            onClick={() => onSelectTab('library')}
            className={`transition-colors hover:text-slate-100 ${
              currentTab === 'library' ? 'font-semibold text-amber-400' : ''
            }`}
          >
            Library
          </button>
          <button
            onClick={() => onSelectTab('purchases')}
            className={`flex items-center gap-1.5 transition-colors hover:text-slate-100 ${
              currentTab === 'purchases' ? 'font-semibold text-emerald-400' : ''
            }`}
          >
            <span>My Purchases</span>
            {purchasedCount > 0 && (
              <span className="flex h-4 min-w-[16px] px-1 items-center justify-center rounded-full bg-emerald-500/20 text-emerald-300 text-[10px] font-bold">
                {purchasedCount}
              </span>
            )}
          </button>
          <button
            onClick={() => onSelectTab('storybooks')}
            className={`transition-colors hover:text-slate-100 ${
              currentTab === 'storybooks' ? 'font-semibold text-amber-400' : ''
            }`}
          >
            Storybooks
          </button>
          <button
            onClick={() => onSelectTab('bookmarks')}
            className={`transition-colors hover:text-slate-100 ${
              currentTab === 'bookmarks' ? 'font-semibold text-amber-400' : ''
            }`}
          >
            Bookmarks
          </button>
        </nav>

        {/* Zone 3: Actions - Reader & Owner Status & Logout */}
        <div className="flex items-center gap-2 sm:gap-2.5">
          {/* Reader Profile Pill */}
          {readerSession && !ownerSession && (
            <div className="hidden sm:flex items-center gap-1.5 rounded-xl border border-slate-800 bg-slate-900/60 px-2.5 py-1 text-xs text-slate-300">
              <div className="flex h-5 w-5 items-center justify-center rounded-full bg-gradient-to-tr from-amber-500 to-amber-300 text-slate-950 font-bold text-[10px]">
                {readerSession.name.charAt(0).toUpperCase()}
              </div>
              <span className="max-w-[100px] truncate font-medium">{readerSession.name}</span>
            </div>
          )}

          {/* Owner Status */}
          {ownerSession ? (
            <button
              onClick={onOpenOwnerPortal}
              className={`flex items-center gap-2 rounded-xl border px-3 py-1.5 text-xs font-semibold transition-all active:scale-[0.98] ${
                currentTab === 'owner'
                  ? 'border-emerald-400 bg-emerald-950 text-emerald-300 ring-2 ring-emerald-500/20 shadow-md'
                  : 'border-emerald-500/40 bg-emerald-950/40 text-emerald-300 hover:bg-emerald-900/50'
              }`}
            >
              <ShieldCheck className="h-4 w-4 text-emerald-400" />
              <span className="hidden sm:inline">Owner:</span>
              <span className="max-w-[120px] truncate font-semibold">
                {ownerSession.name}
              </span>
            </button>
          ) : (
            <button
              onClick={onOpenOwnerPortal}
              className={`flex items-center gap-1.5 rounded-xl border px-3 py-1.5 text-xs font-semibold transition-all active:scale-[0.98] ${
                currentTab === 'owner'
                  ? 'border-amber-400 bg-amber-500/20 text-amber-300 ring-2 ring-amber-500/20 shadow-md'
                  : 'border-amber-500/30 bg-amber-500/10 text-amber-300 hover:bg-amber-500/20'
              }`}
            >
              <Lock className="h-3.5 w-3.5" />
              <span className="hidden sm:inline">Owner Access</span>
            </button>
          )}

          {/* Sign Out / Lock App Button */}
          {onLogout && (readerSession || ownerSession) && (
            <button
              onClick={onLogout}
              title="Sign Out / Lock App"
              className="flex items-center gap-1 rounded-xl border border-slate-800 bg-slate-900/60 hover:bg-slate-800/80 px-2.5 py-1.5 text-xs text-slate-400 hover:text-slate-200 transition-colors"
            >
              <LogOut className="h-3.5 w-3.5" />
              <span className="hidden md:inline">Sign Out</span>
            </button>
          )}
        </div>
      </div>
    </header>
  );
};
