import React, { useState } from 'react';
import {
  PhoneCall,
  BookOpen,
  Lock,
  User,
  Mail,
  Key,
  ShieldCheck,
  AlertCircle,
  Eye,
  EyeOff,
  Sparkles,
  ArrowRight,
} from 'lucide-react';
import { OwnerUser, ReaderUser } from '../types';
import {
  loginReader,
  verifyOwnerPassword,
  setOwnerSession,
  AUTHORIZED_OWNERS,
  PUBLISHING_PHONE_NUMBERS,
} from '../services/auth';

interface CompulsoryLoginModalProps {
  onReaderLoginSuccess: (reader: ReaderUser) => void;
  onOwnerLoginSuccess: (owner: OwnerUser) => void;
}

const APP_LOGO = '/src/assets/images/app_logo_five_friends_1790435713416.jpg';

export const CompulsoryLoginModal: React.FC<CompulsoryLoginModalProps> = ({
  onReaderLoginSuccess,
  onOwnerLoginSuccess,
}) => {
  const [activeTab, setActiveTab] = useState<'reader' | 'owner'>('reader');

  // Reader Form State
  const [readerName, setReaderName] = useState('');
  const [readerEmail, setReaderEmail] = useState('');

  // Owner Form State (Locked with password RTS590)
  const [ownerPassword, setOwnerPassword] = useState('');
  const [selectedOwnerEmail, setSelectedOwnerEmail] = useState('earlasathvik.rs@gmail.com');
  const [showOwnerPassword, setShowOwnerPassword] = useState(false);
  const [ownerError, setOwnerError] = useState('');

  // Reader Submit
  const handleReaderSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!readerName.trim()) {
      return;
    }
    const reader = loginReader(readerName, readerEmail);
    onReaderLoginSuccess(reader);
  };

  // Quick 1-tap Reader Guest entry
  const handleQuickReaderLogin = (name: string, email: string) => {
    const reader = loginReader(name, email);
    onReaderLoginSuccess(reader);
  };

  // Owner Submit (strictly requires RTS590)
  const handleOwnerSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setOwnerError('');

    const res = verifyOwnerPassword(ownerPassword, selectedOwnerEmail);
    if (res.success && res.owner) {
      setOwnerSession(res.owner);
      onOwnerLoginSuccess(res.owner);
      setOwnerPassword('');
    } else {
      setOwnerError(res.message || 'Incorrect password. Owner access is locked.');
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center overflow-y-auto bg-slate-950/95 p-4 sm:p-6 backdrop-blur-md">
      <div className="relative w-full max-w-lg rounded-3xl border border-slate-800 bg-slate-900/95 p-6 sm:p-8 shadow-2xl backdrop-blur-xl animate-in fade-in zoom-in-95 duration-200">
        {/* App Logo & Header */}
        <div className="text-center">
          <div className="relative mx-auto mb-3 h-20 w-20 sm:h-24 sm:w-24">
            <img
              src={APP_LOGO}
              alt="The Five Friends Series Logo"
              className="h-full w-full rounded-full object-cover border-2 border-amber-400 shadow-xl shadow-amber-500/20 bg-white"
            />
            <div className="absolute -bottom-1 -right-1 flex h-7 w-7 items-center justify-center rounded-full bg-amber-500 text-slate-950 font-bold shadow-md">
              <Sparkles className="h-4 w-4" />
            </div>
          </div>

          <h1 className="font-display text-2xl sm:text-3xl font-bold tracking-tight text-slate-100">
            The Five Friends Series
          </h1>
          <p className="mt-1 text-xs sm:text-sm text-slate-400">
            Illustrated Storybooks, Audio Narrations &amp; Exclusive Bookstore
          </p>
        </div>

        {/* COMPULSORY STARTING BANNER: Call +91 9398638545 Or +91 85905 63007 for publishing a book */}
        <div className="mt-5 rounded-2xl border-2 border-amber-500/40 bg-gradient-to-r from-amber-500/15 via-amber-400/10 to-amber-500/15 p-3.5 sm:p-4 text-center shadow-lg shadow-amber-500/5">
          <div className="flex items-center justify-center gap-2 text-xs font-bold uppercase tracking-wider text-amber-400 mb-1.5">
            <PhoneCall className="h-4 w-4 shrink-0 text-amber-400 animate-pulse" />
            <span>Publish Your Book With Us</span>
          </div>
          <p className="text-sm sm:text-base font-bold text-slate-100 leading-snug">
            Call{' '}
            <a
              href={`tel:${PUBLISHING_PHONE_NUMBERS[0].tel}`}
              className="inline-block text-amber-300 font-extrabold underline decoration-amber-400 underline-offset-4 hover:text-amber-200 transition-colors mx-1"
            >
              {PUBLISHING_PHONE_NUMBERS[0].display}
            </a>{' '}
            Or{' '}
            <a
              href={`tel:${PUBLISHING_PHONE_NUMBERS[1].tel}`}
              className="inline-block text-amber-300 font-extrabold underline decoration-amber-400 underline-offset-4 hover:text-amber-200 transition-colors mx-1"
            >
              {PUBLISHING_PHONE_NUMBERS[1].display}
            </a>{' '}
            for publishing a book
          </p>
          <div className="mt-2 text-[11px] text-amber-300/80">
            Open 7 days a week · Direct line to story publishers &amp; editorial team
          </div>
        </div>

        {/* Compulsory Login Notice */}
        <div className="mt-4 flex items-center justify-center gap-2 text-xs font-semibold text-slate-300 bg-slate-950/60 py-2 px-3 rounded-xl border border-slate-800">
          <Lock className="h-3.5 w-3.5 text-amber-400 shrink-0" />
          <span>Login is compulsory to access stories, library &amp; bookstore</span>
        </div>

        {/* Tab Selection: Reader Login vs Owner Access */}
        <div className="mt-5 grid grid-cols-2 gap-2 rounded-xl bg-slate-950/80 p-1 border border-slate-800 text-xs">
          <button
            type="button"
            onClick={() => setActiveTab('reader')}
            className={`flex items-center justify-center gap-2 py-2.5 px-3 rounded-lg font-bold transition-all ${
              activeTab === 'reader'
                ? 'bg-amber-500 text-slate-950 shadow-md'
                : 'text-slate-400 hover:text-slate-200'
            }`}
          >
            <User className="h-4 w-4" />
            <span>Reader Sign-In</span>
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('owner')}
            className={`flex items-center justify-center gap-2 py-2.5 px-3 rounded-lg font-bold transition-all ${
              activeTab === 'owner'
                ? 'bg-amber-500 text-slate-950 shadow-md'
                : 'text-slate-400 hover:text-slate-200'
            }`}
          >
            <Lock className="h-4 w-4" />
            <span>Owner / Publisher</span>
          </button>
        </div>

        {/* TAB 1: READER SIGN-IN */}
        {activeTab === 'reader' && (
          <form onSubmit={handleReaderSubmit} className="mt-5 space-y-4">
            <div>
              <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                Your Full Name / Nickname <span className="text-amber-400">*</span>
              </label>
              <div className="relative">
                <User className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
                <input
                  type="text"
                  required
                  autoFocus
                  value={readerName}
                  onChange={(e) => setReaderName(e.target.value)}
                  placeholder="e.g. Leo Sharma"
                  className="w-full rounded-xl border border-slate-700 bg-slate-950/90 pl-10 pr-4 py-3 text-sm text-white placeholder-slate-500 focus:border-amber-400 focus:outline-none focus:ring-1 focus:ring-amber-400 transition-colors"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                Email Address <span className="text-slate-500 font-normal">(Optional for reading history)</span>
              </label>
              <div className="relative">
                <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
                <input
                  type="email"
                  value={readerEmail}
                  onChange={(e) => setReaderEmail(e.target.value)}
                  placeholder="reader@example.com"
                  className="w-full rounded-xl border border-slate-700 bg-slate-950/90 pl-10 pr-4 py-3 text-sm text-white placeholder-slate-500 focus:border-amber-400 focus:outline-none focus:ring-1 focus:ring-amber-400 transition-colors"
                />
              </div>
            </div>

            <button
              type="submit"
              className="mt-2 flex w-full min-h-[48px] items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-amber-500 to-amber-400 px-4 py-3 text-sm font-bold text-slate-950 shadow-lg shadow-amber-500/20 active:scale-[0.98] hover:brightness-105 transition-all"
            >
              <BookOpen className="h-4 w-4" />
              <span>Login to Enter Library &amp; Read Books</span>
              <ArrowRight className="h-4 w-4 ml-0.5" />
            </button>

            {/* Quick 1-tap presets */}
            <div className="pt-2 text-center">
              <span className="block text-[11px] text-slate-500 mb-2">Or enter instantly as:</span>
              <div className="grid grid-cols-2 gap-2 text-xs">
                <button
                  type="button"
                  onClick={() => handleQuickReaderLogin('Book Explorer', 'explorer@fivefriends.com')}
                  className="rounded-lg border border-slate-800 bg-slate-950/60 p-2.5 text-left hover:border-amber-400/40 hover:bg-slate-800/50 transition-colors text-slate-300"
                >
                  <div className="font-semibold text-amber-300 truncate">📖 Book Explorer</div>
                  <div className="text-[10px] text-slate-500 truncate">Quick Reader Account</div>
                </button>
                <button
                  type="button"
                  onClick={() => handleQuickReaderLogin('Young Story Lover', 'storylover@fivefriends.com')}
                  className="rounded-lg border border-slate-800 bg-slate-950/60 p-2.5 text-left hover:border-amber-400/40 hover:bg-slate-800/50 transition-colors text-slate-300"
                >
                  <div className="font-semibold text-emerald-300 truncate">✨ Story Lover</div>
                  <div className="text-[10px] text-slate-500 truncate">Instant Access</div>
                </button>
              </div>
            </div>
          </form>
        )}

        {/* TAB 2: OWNER ACCESS (LOCKED WITH PASSWORD RTS590) */}
        {activeTab === 'owner' && (
          <form onSubmit={handleOwnerSubmit} className="mt-5 space-y-4">
            <div className="rounded-xl border border-amber-500/20 bg-amber-500/5 p-3 text-xs text-amber-300 flex items-start gap-2">
              <Lock className="h-4 w-4 text-amber-400 shrink-0 mt-0.5" />
              <span>Owner access is locked. Enter the administrator password to unlock.</span>
            </div>

            {ownerError && (
              <div className="flex items-start gap-2.5 rounded-xl border border-rose-500/30 bg-rose-950/40 p-3 text-xs text-rose-300">
                <AlertCircle className="h-4 w-4 shrink-0 text-rose-400 mt-0.5" />
                <span>{ownerError}</span>
              </div>
            )}

            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label className="text-xs font-semibold text-slate-200">
                  Administrator Password <span className="text-amber-400">*</span>
                </label>
                <span className="text-[11px] text-amber-400/90 font-mono">
                  Protected with RTS590
                </span>
              </div>
              <div className="relative">
                <Key className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                <input
                  type={showOwnerPassword ? 'text' : 'password'}
                  required
                  autoFocus
                  value={ownerPassword}
                  onChange={(e) => setOwnerPassword(e.target.value)}
                  placeholder="Enter administrator password"
                  className="w-full rounded-xl border border-slate-700 bg-slate-950/90 pl-10 pr-12 py-3 text-sm text-white placeholder-slate-500 focus:border-amber-400 focus:outline-none focus:ring-1 focus:ring-amber-400 transition-colors font-mono"
                />
                <button
                  type="button"
                  onClick={() => setShowOwnerPassword(!showOwnerPassword)}
                  className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-200 p-1"
                  title={showOwnerPassword ? 'Hide password' : 'Show password'}
                >
                  {showOwnerPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </div>

            {/* Select Owner Account */}
            <div className="rounded-xl border border-slate-800/80 bg-slate-950/50 p-3">
              <span className="block text-[11px] font-semibold text-slate-400 mb-2">
                Unlock as Owner Profile:
              </span>
              <div className="grid grid-cols-2 gap-2 text-xs">
                {Object.values(AUTHORIZED_OWNERS).map((owner) => (
                  <button
                    key={owner.email}
                    type="button"
                    onClick={() => setSelectedOwnerEmail(owner.email)}
                    className={`p-2.5 rounded-lg border text-left transition-colors ${
                      selectedOwnerEmail === owner.email
                        ? 'border-amber-400 bg-amber-500/10 text-amber-300 font-semibold'
                        : 'border-slate-800 bg-slate-900/40 text-slate-400 hover:text-slate-300'
                    }`}
                  >
                    <div className="font-bold truncate">{owner.name}</div>
                    <div className="text-[10px] opacity-75 truncate">{owner.role}</div>
                  </button>
                ))}
              </div>
            </div>

            <button
              type="submit"
              className="mt-2 flex w-full min-h-[48px] items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-amber-500 to-amber-400 px-4 py-3 text-sm font-bold text-slate-950 shadow-lg shadow-amber-500/20 active:scale-[0.98] hover:brightness-105 transition-all"
            >
              <ShieldCheck className="h-4 w-4" />
              <span>Unlock Owner Dashboard &amp; App</span>
            </button>
          </form>
        )}

        <div className="mt-6 border-t border-slate-800/80 pt-4 text-center text-[11px] text-slate-500">
          The Five Friends Series · All Rights Reserved
        </div>
      </div>
    </div>
  );
};
