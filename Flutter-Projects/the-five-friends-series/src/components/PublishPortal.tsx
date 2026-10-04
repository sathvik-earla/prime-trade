import React, { useState } from 'react';
import {
  OwnerUser,
  StoryItem,
  Chapter,
  ContentType,
  StoryGenre,
  AgeRange,
  DocumentAttachment,
  PurchaseRecord,
} from '../types';
import {
  verifyOwnerPassword,
  verifyByPasswordOrGmail,
  setOwnerSession,
  clearOwnerSession,
  MASTER_PASSWORD,
  AUTHORIZED_OWNERS,
} from '../services/auth';
import {
  saveOrUpdateStory,
  deleteStory,
  resetToSeedStories,
  clearAllBooks,
  toggleReviewApproval,
  deleteReview,
  getAllTransactions,
  updateDeliveryStatus,
} from '../services/storage';
import {
  ShieldCheck,
  Lock,
  Feather,
  Plus,
  Trash2,
  Edit,
  Eye,
  EyeOff,
  CheckCircle2,
  AlertCircle,
  LogOut,
  Image as ImageIcon,
  BookOpen,
  Layers,
  ArrowUp,
  ArrowDown,
  Download,
  Upload,
  RefreshCw,
  Star,
  Sparkles,
  Key,
  Mail,
  DollarSign,
  FileText,
  FileUp,
  TrendingUp,
  ShoppingBag,
  Truck,
} from 'lucide-react';

interface PublishPortalProps {
  ownerSession: OwnerUser | null;
  stories: StoryItem[];
  onLoginSuccess: (owner: OwnerUser) => void;
  onLogout: () => void;
  onRefreshData: () => void;
  onPreviewStory: (story: StoryItem) => void;
}

// App logo & default cover artwork
const APP_LOGO = '/src/assets/images/app_logo_five_friends_1790435713416.jpg';
const DEFAULT_CUSTOM_COVER = '/src/assets/images/app_logo_five_friends_1790435713416.jpg';

export const PublishPortal: React.FC<PublishPortalProps> = ({
  ownerSession,
  stories,
  onLoginSuccess,
  onLogout,
  onRefreshData,
  onPreviewStory,
}) => {
  // Owner Password Lock state (Requires password RTS590)
  const [passwordInput, setPasswordInput] = useState('');
  const [selectedOwnerEmail, setSelectedOwnerEmail] = useState('earlasathvik.rs@gmail.com');
  const [showPassword, setShowPassword] = useState(false);
  const [authError, setAuthError] = useState('');

  // Admin Dashboard view tabs: 'new' | 'manage' | 'sales' | 'reviews' | 'backup'
  const [adminTab, setAdminTab] = useState<'new' | 'manage' | 'sales' | 'reviews' | 'backup'>('new');

  // Story Form State
  const [editingStoryId, setEditingStoryId] = useState<string | null>(null);
  const [formTitle, setFormTitle] = useState('');
  const [formSubtitle, setFormSubtitle] = useState('');
  const [formSynopsis, setFormSynopsis] = useState('');
  const [formAuthorName, setFormAuthorName] = useState(ownerSession?.name || '');
  const [formAuthorEmail, setFormAuthorEmail] = useState(
    ownerSession?.email || 'earlasathvik.rs@gmail.com'
  );
  const [formType, setFormType] = useState<ContentType>('storybook');
  const [formGenre, setFormGenre] = useState<StoryGenre>('Fantasy');
  const [formAgeRange, setFormAgeRange] = useState<AgeRange>('All Ages');
  const [formCoverImage, setFormCoverImage] = useState(DEFAULT_CUSTOM_COVER);
  const [formPrice, setFormPrice] = useState<number>(199); // Price in ₹ INR
  const [formFreeSamplePages, setFormFreeSamplePages] = useState<number>(1);
  const [formDocument, setFormDocument] = useState<DocumentAttachment | undefined>(undefined);
  const [formReadingTime, setFormReadingTime] = useState(5);
  const [formStatus, setFormStatus] = useState<'published' | 'draft'>('published');
  const [formFeatured, setFormFeatured] = useState(false);
  const [formNotification, setFormNotification] = useState<string | null>(null);
  const [isParsingDoc, setIsParsingDoc] = useState(false);

  // Chapter / Page list state
  const [chapters, setChapters] = useState<Chapter[]>([
    {
      id: 'p-1',
      pageNumber: 1,
      title: 'Chapter 1: The Beginning',
      content: '',
      illustrationUrl: DEFAULT_CUSTOM_COVER,
    },
  ]);

  // Handle Owner Verification strictly requiring password RTS590
  const handleVerifyLogin = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    setAuthError('');

    const res = verifyOwnerPassword(passwordInput, selectedOwnerEmail);
    if (res.success && res.owner) {
      setOwnerSession(res.owner);
      onLoginSuccess(res.owner);
      setFormAuthorName(res.owner.name);
      setFormAuthorEmail(res.owner.email);
      setPasswordInput('');
    } else {
      setAuthError(res.message || 'Incorrect password. Owner access is locked.');
    }
  };

  // Reset form
  const resetForm = () => {
    setEditingStoryId(null);
    setFormTitle('');
    setFormSubtitle('');
    setFormSynopsis('');
    setFormAuthorName(ownerSession?.name || 'Authorized Owner');
    setFormAuthorEmail(ownerSession?.email || 'earlasathvik.rs@gmail.com');
    setFormType('storybook');
    setFormGenre('Fantasy');
    setFormAgeRange('All Ages');
    setFormCoverImage(DEFAULT_CUSTOM_COVER);
    setFormPrice(199);
    setFormFreeSamplePages(1);
    setFormDocument(undefined);
    setFormReadingTime(5);
    setFormStatus('published');
    setFormFeatured(false);
    setChapters([
      {
        id: 'p-1',
        pageNumber: 1,
        title: 'Chapter 1: The Beginning',
        content: '',
        illustrationUrl: DEFAULT_CUSTOM_COVER,
      },
    ]);
  };

  // Load existing story for editing
  const handleEditStory = (story: StoryItem) => {
    setEditingStoryId(story.id);
    setFormTitle(story.title);
    setFormSubtitle(story.subtitle || '');
    setFormSynopsis(story.synopsis);
    setFormAuthorName(story.authorName);
    setFormAuthorEmail(story.authorEmail);
    setFormType(story.type);
    setFormGenre(story.genre);
    setFormAgeRange(story.ageRange);
    setFormCoverImage(story.coverImage);
    setFormPrice(story.price ?? 4.99);
    setFormFreeSamplePages(story.freeSamplePages ?? 1);
    setFormDocument(story.documentFile);
    setFormReadingTime(story.readingTimeMinutes);
    setFormStatus(story.status);
    setFormFeatured(story.featured || false);
    setChapters(
      story.chapters.length > 0
        ? [...story.chapters]
        : [
            {
              id: 'p-1',
              pageNumber: 1,
              title: 'Chapter 1: The Beginning',
              content: story.synopsis,
              illustrationUrl: story.coverImage,
            },
          ]
    );
    setAdminTab('new');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // Custom cover image file upload handler
  const handleCustomCoverUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (event) => {
      const dataUrl = event.target?.result as string;
      if (dataUrl) {
        setFormCoverImage(dataUrl);
      }
    };
    reader.readAsDataURL(file);
  };

  // Document file upload handler
  const handleDocumentUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsParsingDoc(true);

    const isTextOrMarkdown =
      file.type.includes('text') ||
      file.name.endsWith('.txt') ||
      file.name.endsWith('.md');

    const reader = new FileReader();

    reader.onload = (event) => {
      const result = event.target?.result as string;

      // Create Document Attachment record
      const attachment: DocumentAttachment = {
        fileName: file.name,
        fileSize: file.size,
        fileType: file.type || file.name.split('.').pop() || 'document',
        fileData: result,
        uploadedAt: new Date().toISOString(),
      };
      setFormDocument(attachment);

      // If text/markdown, parse chapters and text
      if (isTextOrMarkdown && typeof result === 'string') {
        const textContent = result;

        // Auto suggest title from file name if title is empty
        if (!formTitle) {
          const suggestedTitle = file.name
            .replace(/\.[^/.]+$/, '')
            .replace(/[_-]/g, ' ')
            .replace(/\b\w/g, (l) => l.toUpperCase());
          setFormTitle(suggestedTitle);
        }

        // Split by chapter headings or large breaks
        const rawChapters = textContent.split(/(?=^#+\s|^Chapter\s+\d+|^PAGE\s+\d+)/gim);

        if (rawChapters.length > 1) {
          const parsedChapters: Chapter[] = rawChapters.map((chunk, idx) => {
            const lines = chunk.trim().split('\n');
            const heading = lines[0].replace(/^#+\s*/, '').trim() || `Chapter ${idx + 1}`;
            const body = lines.slice(1).join('\n').trim();

            return {
              id: `p-${idx + 1}`,
              pageNumber: idx + 1,
              title: heading,
              content: body || lines[0],
              illustrationUrl: formCoverImage,
            };
          });

          setChapters(parsedChapters);
          if (!formSynopsis && parsedChapters[0]?.content) {
            setFormSynopsis(parsedChapters[0].content.slice(0, 180) + '...');
          }
        } else {
          // Single long story or novella
          setChapters([
            {
              id: 'p-1',
              pageNumber: 1,
              title: formTitle || file.name.replace(/\.[^/.]+$/, ''),
              content: textContent,
              illustrationUrl: formCoverImage,
            },
          ]);
          if (!formSynopsis) {
            setFormSynopsis(textContent.slice(0, 180) + '...');
          }
        }
      } else {
        // Non-plain-text (e.g. PDF, DOCX, EPUB)
        if (!formTitle) {
          const cleanName = file.name
            .replace(/\.[^/.]+$/, '')
            .replace(/[_-]/g, ' ')
            .replace(/\b\w/g, (l) => l.toUpperCase());
          setFormTitle(cleanName);
        }
        if (!chapters[0]?.content) {
          setChapters([
            {
              id: 'p-1',
              pageNumber: 1,
              title: `Document Edition: ${file.name}`,
              content: `This publication includes the complete uploaded document "${file.name}" (${(file.size / 1024).toFixed(1)} KB). Purchasers can read the full edition and download the original file directly.`,
              illustrationUrl: formCoverImage,
            },
          ]);
        }
      }

      setIsParsingDoc(false);
    };

    if (isTextOrMarkdown) {
      reader.readAsText(file);
    } else {
      reader.readAsDataURL(file);
    }
  };

  // Chapter helpers
  const handleAddPage = () => {
    const nextNumber = chapters.length + 1;
    const newPage: Chapter = {
      id: `p-${Date.now()}`,
      pageNumber: nextNumber,
      title: `Page ${nextNumber}: New Chapter`,
      content: '',
      illustrationUrl: formCoverImage,
    };
    setChapters([...chapters, newPage]);
  };

  const handleUpdatePage = (index: number, field: keyof Chapter, val: any) => {
    const updated = [...chapters];
    updated[index] = { ...updated[index], [field]: val };
    setChapters(updated);
  };

  const handleRemovePage = (index: number) => {
    if (chapters.length <= 1) return;
    const updated = chapters
      .filter((_, i) => i !== index)
      .map((ch, i) => ({ ...ch, pageNumber: i + 1 }));
    setChapters(updated);
  };

  const handleMovePage = (index: number, direction: 'up' | 'down') => {
    if (
      (direction === 'up' && index === 0) ||
      (direction === 'down' && index === chapters.length - 1)
    )
      return;
    const targetIndex = direction === 'up' ? index - 1 : index + 1;
    const updated = [...chapters];
    const temp = updated[index];
    updated[index] = updated[targetIndex];
    updated[targetIndex] = temp;
    const reindexed = updated.map((ch, i) => ({ ...ch, pageNumber: i + 1 }));
    setChapters(reindexed);
  };

  // Submit / Publish story
  const handleSaveStory = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formTitle.trim() || !formSynopsis.trim()) {
      alert('Please provide a title and synopsis for the book.');
      return;
    }

    const storyId = editingStoryId || `story-${Date.now()}`;
    const existing = stories.find((s) => s.id === storyId);

    const newStory: StoryItem = {
      id: storyId,
      title: formTitle.trim(),
      subtitle: formSubtitle.trim(),
      synopsis: formSynopsis.trim(),
      authorName: formAuthorName.trim() || ownerSession?.name || 'Authorized Owner',
      authorEmail: formAuthorEmail,
      type: formType,
      genre: formGenre,
      ageRange: formAgeRange,
      coverImage: formCoverImage,
      price: Number(formPrice) || 0,
      freeSamplePages: Number(formFreeSamplePages) || 1,
      documentFile: formDocument,
      readingTimeMinutes: formReadingTime,
      status: formStatus,
      publishedAt: existing?.publishedAt || new Date().toISOString().split('T')[0],
      featured: formFeatured,
      chapters: chapters.map((c, i) => ({ ...c, pageNumber: i + 1 })),
      stats: existing?.stats || {
        reads: 0,
        likes: 0,
        bookmarks: 0,
        purchases: 0,
        revenue: 0,
        rating: 5.0,
        ratingCount: 1,
      },
      reviews: existing?.reviews || [],
    };

    saveOrUpdateStory(newStory);
    onRefreshData();

    setFormNotification(
      editingStoryId
        ? `"${formTitle}" successfully updated!`
        : `"${formTitle}" published for sale at ₹${newStory.price.toFixed(2)}!`
    );

    setTimeout(() => {
      setFormNotification(null);
      resetForm();
      setAdminTab('manage');
    }, 1200);
  };

  // Content manager delete
  const handleDeleteStory = (id: string, title: string) => {
    if (confirm(`Are you sure you want to permanently delete "${title}"?`)) {
      deleteStory(id);
      onRefreshData();
    }
  };

  // Clear all books
  const handleClearAllBooks = () => {
    if (confirm('Are you sure you want to remove all books from the app? You can upload your own document files.')) {
      clearAllBooks();
      onRefreshData();
    }
  };

  // JSON Export
  const handleExportBackup = () => {
    const dataStr =
      'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(stories, null, 2));
    const downloadAnchor = document.createElement('a');
    downloadAnchor.setAttribute('href', dataStr);
    downloadAnchor.setAttribute('download', `fivefriends_store_backup_${Date.now()}.json`);
    document.body.appendChild(downloadAnchor);
    downloadAnchor.click();
    downloadAnchor.remove();
  };

  // JSON Import
  const handleImportBackup = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (event) => {
      try {
        const parsed = JSON.parse(event.target?.result as string);
        if (Array.isArray(parsed)) {
          localStorage.setItem('fivefriends_store_books_v3', JSON.stringify(parsed));
          onRefreshData();
          alert('Stories database loaded successfully!');
        } else {
          alert('Invalid backup file format.');
        }
      } catch (err) {
        alert('Failed to parse backup file.');
      }
    };
    reader.readAsText(file);
  };

  // Transactions list
  const transactions = getAllTransactions();
  const totalSalesRevenue = stories.reduce((acc, s) => acc + (s.stats.revenue || 0), 0);
  const totalCopiesSold = stories.reduce((acc, s) => acc + (s.stats.purchases || 0), 0);

  // -------------------------------------------------------------
  // STATE 1: OWNER ACCESS LOCKED (Requires Password RTS590)
  // -------------------------------------------------------------
  if (!ownerSession) {
    return (
      <div className="mx-auto max-w-lg px-4 py-10 sm:py-14">
        <div className="rounded-3xl border border-slate-800 bg-slate-900/90 p-6 sm:p-10 shadow-2xl backdrop-blur-xl">
          <div className="text-center">
            <img
              src={APP_LOGO}
              alt="The Five Friends Series"
              className="mx-auto h-20 w-20 rounded-full object-cover border-2 border-amber-400 shadow-xl shadow-amber-500/10 mb-4 bg-white"
            />
            <div className="inline-flex items-center gap-1.5 rounded-full bg-amber-500/10 border border-amber-500/30 px-3 py-1 text-xs font-bold text-amber-400 mb-2">
              <Lock className="h-3.5 w-3.5" />
              <span>Owner Access Locked</span>
            </div>
            <h2 className="font-display text-2xl sm:text-3xl font-bold text-slate-100">
              The Five Friends Series
            </h2>
            <p className="mt-2 text-xs sm:text-sm text-slate-400 leading-relaxed max-w-sm mx-auto">
              This area is restricted to authorized owners. Enter the administrator password to unlock the publishing dashboard.
            </p>
          </div>

          {/* Error Message */}
          {authError && (
            <div className="mt-5 flex items-start gap-2.5 rounded-xl border border-rose-500/30 bg-rose-950/40 p-3.5 text-xs text-rose-300">
              <AlertCircle className="h-4 w-4 shrink-0 text-rose-400 mt-0.5" />
              <span>{authError}</span>
            </div>
          )}

          {/* PASSWORD LOCK FORM */}
          <form onSubmit={handleVerifyLogin} className="mt-6 space-y-4">
            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label className="text-xs font-semibold text-slate-200">
                  Administrator Password
                </label>
                <span className="text-[11px] text-amber-400/90 font-mono">
                  Password Protected
                </span>
              </div>
              <div className="relative">
                <div className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400">
                  <Key className="h-4 w-4" />
                </div>
                <input
                  type={showPassword ? 'text' : 'password'}
                  autoFocus
                  required
                  value={passwordInput}
                  onChange={(e) => setPasswordInput(e.target.value)}
                  placeholder="Enter administrator password"
                  className="w-full rounded-xl border border-slate-700 bg-slate-950/90 pl-10 pr-12 py-3 text-sm text-white placeholder-slate-500 focus:border-amber-400 focus:outline-none focus:ring-1 focus:ring-amber-400 transition-colors font-mono"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-200 p-1"
                  title={showPassword ? 'Hide password' : 'Show password'}
                >
                  {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </div>

            {/* Select Account to Sign In As */}
            <div className="rounded-xl border border-slate-800/80 bg-slate-950/50 p-3.5">
              <span className="block text-[11px] font-semibold text-slate-400 mb-2">
                Unlock as Owner Account:
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
              <Key className="h-4 w-4" />
              <span>Unlock Owner Dashboard</span>
            </button>
          </form>

          <div className="mt-5 text-center text-[11px] text-slate-500">
            Locked for verified owners · Password required
          </div>
        </div>
      </div>
    );
  }

  // -------------------------------------------------------------
  // STATE 2: OWNER VERIFIED -> ADMINISTRATIVE DASHBOARD
  // -------------------------------------------------------------
  return (
    <div className="mx-auto max-w-6xl px-4 py-6 sm:py-8 pb-28">
      {/* Owner Header Bar */}
      <div className="mb-8 flex flex-col sm:flex-row sm:items-center justify-between gap-4 rounded-2xl border border-emerald-500/30 bg-emerald-950/30 p-5 backdrop-blur-md">
        <div className="flex items-center gap-3.5">
          <div
            className={`flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-tr ${ownerSession.avatarColor} text-white shadow-md font-bold text-lg`}
          >
            {ownerSession.name.charAt(0)}
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="font-display text-lg font-bold text-slate-100">
                {ownerSession.name}
              </span>
              <span className="rounded bg-emerald-500/20 px-2 py-0.5 text-[10px] font-semibold text-emerald-300">
                Verified Owner
              </span>
            </div>
            <div className="text-xs text-slate-400">
              {ownerSession.role}
            </div>
          </div>
        </div>

        {/* Quick Stats & Sign Out */}
        <div className="flex items-center gap-4">
          <div className="hidden md:flex items-center gap-6 text-xs text-slate-400 border-r border-slate-800 pr-4">
            <div>
              <span className="block text-slate-500 text-[10px]">Total Titles</span>
              <span className="text-sm font-bold text-slate-200 tabular-nums">
                {stories.length}
              </span>
            </div>
            <div>
              <span className="block text-slate-500 text-[10px]">Copies Sold</span>
              <span className="text-sm font-bold text-emerald-400 tabular-nums">
                {totalCopiesSold}
              </span>
            </div>
            <div>
              <span className="block text-slate-500 text-[10px]">Gross Revenue</span>
              <span className="text-sm font-bold text-amber-400 tabular-nums">
                ₹{totalSalesRevenue.toFixed(2)}
              </span>
            </div>
          </div>

          <button
            onClick={() => {
              clearOwnerSession();
              onLogout();
            }}
            className="flex items-center gap-1.5 rounded-xl border border-slate-700/80 bg-slate-900/60 px-3.5 py-2 text-xs font-medium text-slate-300 hover:bg-slate-800 hover:text-white transition-colors"
          >
            <LogOut className="h-4 w-4" />
            <span>Sign Out</span>
          </button>
        </div>
      </div>

      {/* Admin Subnav Tabs */}
      <div className="mb-6 flex overflow-x-auto pb-2 border-b border-slate-800 gap-2">
        <button
          onClick={() => {
            setAdminTab('new');
            if (!editingStoryId) resetForm();
          }}
          className={`flex items-center gap-2 px-4 py-2.5 text-xs font-semibold rounded-xl transition-colors whitespace-nowrap ${
            adminTab === 'new'
              ? 'bg-amber-500 text-slate-950 shadow-md font-bold'
              : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900'
          }`}
        >
          <Feather className="h-4 w-4" />
          <span>{editingStoryId ? 'Edit Book' : 'Publish & Sell New Book'}</span>
        </button>

        <button
          onClick={() => setAdminTab('manage')}
          className={`flex items-center gap-2 px-4 py-2.5 text-xs font-semibold rounded-xl transition-colors whitespace-nowrap ${
            adminTab === 'manage'
              ? 'bg-amber-500 text-slate-950 shadow-md font-bold'
              : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900'
          }`}
        >
          <Layers className="h-4 w-4" />
          <span>Catalog ({stories.length})</span>
        </button>

        <button
          onClick={() => setAdminTab('sales')}
          className={`flex items-center gap-2 px-4 py-2.5 text-xs font-semibold rounded-xl transition-colors whitespace-nowrap ${
            adminTab === 'sales'
              ? 'bg-amber-500 text-slate-950 shadow-md font-bold'
              : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900'
          }`}
        >
          <TrendingUp className="h-4 w-4" />
          <span>Sales &amp; Earnings (₹{totalSalesRevenue.toFixed(2)})</span>
        </button>

        <button
          onClick={() => setAdminTab('reviews')}
          className={`flex items-center gap-2 px-4 py-2.5 text-xs font-semibold rounded-xl transition-colors whitespace-nowrap ${
            adminTab === 'reviews'
              ? 'bg-amber-500 text-slate-950 shadow-md font-bold'
              : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900'
          }`}
        >
          <Star className="h-4 w-4" />
          <span>Customer Reviews</span>
        </button>

        <button
          onClick={() => setAdminTab('backup')}
          className={`flex items-center gap-2 px-4 py-2.5 text-xs font-semibold rounded-xl transition-colors whitespace-nowrap ${
            adminTab === 'backup'
              ? 'bg-amber-500 text-slate-950 shadow-md font-bold'
              : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900'
          }`}
        >
          <Download className="h-4 w-4" />
          <span>Data Tools</span>
        </button>
      </div>

      {/* Notification Toast */}
      {formNotification && (
        <div className="mb-6 flex items-center gap-3 rounded-2xl border border-emerald-500/40 bg-emerald-950/60 p-4 text-xs font-semibold text-emerald-300 shadow-xl">
          <CheckCircle2 className="h-5 w-5 text-emerald-400 shrink-0" />
          <span>{formNotification}</span>
        </div>
      )}

      {/* ------------------------------------------------------- */}
      {/* TAB 1: PUBLISH & SELL NEW BOOK / STORYBOOK */}
      {/* ------------------------------------------------------- */}
      {adminTab === 'new' && (
        <form onSubmit={handleSaveStory} className="space-y-8">
          {/* SECTION 1: DOCUMENT FILE UPLOAD (THE PRIMARY WORKFLOW) */}
          <div className="rounded-3xl border border-amber-500/40 bg-gradient-to-b from-slate-900 via-slate-900 to-amber-950/20 p-6 sm:p-8 shadow-xl">
            <div className="flex items-center gap-2.5 mb-2">
              <FileUp className="h-6 w-6 text-amber-400" />
              <h3 className="font-display text-lg sm:text-xl font-bold text-slate-100">
                1. Upload Story Document File
              </h3>
            </div>
            <p className="text-xs text-slate-400 mb-6">
              Upload your story manuscript or book file in any format (<code className="text-amber-300">.pdf, .epub, .docx, .txt, .md, .rtf, .html, .json, .mp3, .cbz</code>).
              Uploading text/markdown files will automatically parse chapters and title!
            </p>

            <label className="group relative flex flex-col items-center justify-center rounded-2xl border-2 border-dashed border-slate-700 bg-slate-950/60 p-8 text-center cursor-pointer hover:border-amber-400 hover:bg-slate-900/60 transition-all">
              <input
                type="file"
                accept=".txt,.md,.markdown,.pdf,.docx,.doc,.epub,.rtf,.html,.htm,.json,.mp3,.m4a,.wav,.aac,.cbz,.cbr"
                onChange={handleDocumentUpload}
                className="hidden"
              />
              <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-amber-500/10 text-amber-400 group-hover:scale-110 transition-transform mb-3">
                <FileUp className="h-7 w-7" />
              </div>
              <span className="text-sm font-bold text-slate-200 group-hover:text-amber-300 transition-colors">
                {isParsingDoc ? 'Reading & Parsing Document...' : 'Click to Upload or Drag & Drop Story File'}
              </span>
              <span className="text-xs text-slate-500 mt-1">
                Every format supported: PDF, EPUB, Word (DOCX), TXT, Markdown (MD), RTF, HTML, JSON, Audio &amp; Comic
              </span>
            </label>

            {/* Display Attached Document Card */}
            {formDocument && (
              <div className="mt-4 flex items-center justify-between rounded-xl border border-emerald-500/40 bg-emerald-950/30 p-4">
                <div className="flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-emerald-500/20 text-emerald-400">
                    <FileText className="h-5 w-5" />
                  </div>
                  <div>
                    <div className="text-xs font-bold text-slate-100">
                      {formDocument.fileName}
                    </div>
                    <div className="text-[11px] text-slate-400">
                      {(formDocument.fileSize / 1024).toFixed(1)} KB · Document file attached for purchasers
                    </div>
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => setFormDocument(undefined)}
                  className="text-xs text-rose-400 hover:text-rose-300 hover:underline p-1"
                >
                  Remove File
                </button>
              </div>
            )}
          </div>

          {/* SECTION 2: BOOK PRICING & SELLING CONFIGURATION */}
          <div className="rounded-3xl border border-slate-800 bg-slate-900/60 p-6 sm:p-8">
            <div className="flex items-center gap-2.5 mb-2">
              <DollarSign className="h-6 w-6 text-amber-400" />
              <h3 className="font-display text-lg font-bold text-slate-100">
                2. Pricing &amp; Commercial Settings
              </h3>
            </div>
            <p className="text-xs text-slate-400 mb-6">
              Set the price customers pay to purchase this book and how many preview pages are accessible for free.
            </p>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <div>
                <label className="block text-xs font-medium text-slate-300 mb-1.5">
                  Sale Price (₹ INR) *
                </label>
                <div className="relative">
                  <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-sm font-bold text-slate-400">₹</span>
                  <input
                    type="number"
                    step="1"
                    min="0"
                    required
                    value={formPrice}
                    onChange={(e) => setFormPrice(Number(e.target.value))}
                    className="w-full rounded-xl border border-slate-700 bg-slate-950/80 pl-9 pr-4 py-2.5 text-sm text-white font-bold focus:border-amber-400 focus:outline-none"
                  />
                </div>
                <div className="mt-2 flex flex-wrap gap-2">
                  {[99, 149, 199, 299, 399, 499].map((p) => (
                    <button
                      key={p}
                      type="button"
                      onClick={() => setFormPrice(p)}
                      className={`px-2.5 py-1 text-xs rounded-lg border transition-colors ${
                        formPrice === p
                          ? 'border-amber-400 bg-amber-500/20 text-amber-300 font-bold'
                          : 'border-slate-800 bg-slate-950 text-slate-400 hover:text-slate-200'
                      }`}
                    >
                      ₹{p}
                    </button>
                  ))}
                  <button
                    type="button"
                    onClick={() => setFormPrice(0)}
                    className={`px-2.5 py-1 text-xs rounded-lg border transition-colors ${
                      formPrice === 0
                        ? 'border-emerald-400 bg-emerald-500/20 text-emerald-300 font-bold'
                        : 'border-slate-800 bg-slate-950 text-slate-400 hover:text-slate-200'
                    }`}
                  >
                    Free
                  </button>
                </div>
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-300 mb-1.5">
                  Free Sample Preview Pages (Teaser)
                </label>
                <input
                  type="number"
                  min="0"
                  max="10"
                  value={formFreeSamplePages}
                  onChange={(e) => setFormFreeSamplePages(Number(e.target.value))}
                  className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-4 py-2.5 text-sm text-white focus:border-amber-400 focus:outline-none"
                />
                <span className="mt-1.5 block text-[11px] text-slate-500">
                  Non-buyers can read {formFreeSamplePages} {formFreeSamplePages === 1 ? 'page' : 'pages'} before seeing the purchase prompt.
                </span>
              </div>
            </div>
          </div>

          {/* SECTION 3: BOOK DETAILS & METADATA */}
          <div className="rounded-3xl border border-slate-800 bg-slate-900/60 p-6 sm:p-8">
            <h3 className="font-display text-lg font-bold text-slate-100 mb-1">
              3. Book Details &amp; Attribution
            </h3>
            <p className="text-xs text-slate-400 mb-6">
              Story title, blurb synopsis, genre classification, and author pen-name.
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="md:col-span-2">
                <label className="block text-xs font-medium text-slate-300 mb-1.5">
                  Book Title *
                </label>
                <input
                  type="text"
                  required
                  value={formTitle}
                  onChange={(e) => setFormTitle(e.target.value)}
                  placeholder="e.g. The Boy Who Caught a Falling Star"
                  className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-4 py-2.5 text-sm text-white focus:border-amber-400 focus:outline-none"
                />
              </div>

              <div className="md:col-span-2">
                <label className="block text-xs font-medium text-slate-300 mb-1.5">
                  Subtitle / Tagline
                </label>
                <input
                  type="text"
                  value={formSubtitle}
                  onChange={(e) => setFormSubtitle(e.target.value)}
                  placeholder="e.g. A fable about holding wonder without keeping it captive"
                  className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-4 py-2.5 text-sm text-white focus:border-amber-400 focus:outline-none"
                />
              </div>

              <div className="md:col-span-2">
                <label className="block text-xs font-medium text-slate-300 mb-1.5">
                  Synopsis / Blurb *
                </label>
                <textarea
                  required
                  rows={3}
                  value={formSynopsis}
                  onChange={(e) => setFormSynopsis(e.target.value)}
                  placeholder="Provide an overview for store customers..."
                  className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-4 py-2.5 text-sm text-white focus:border-amber-400 focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-300 mb-1.5">
                  Format Type
                </label>
                <select
                  value={formType}
                  onChange={(e) => setFormType(e.target.value as ContentType)}
                  className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-3.5 py-2.5 text-xs text-white focus:border-amber-400 focus:outline-none"
                >
                  <option value="storybook">Illustrated Storybook (Full-Color Art &amp; Pages)</option>
                  <option value="novel">Novel &amp; Multi-Chapter Book (Chapters &amp; Table of Contents)</option>
                  <option value="story">Short Story / Standalone Tale (Prose Fiction)</option>
                  <option value="comic">Graphic Novel &amp; Comic Book (Sequential Art &amp; Panels)</option>
                  <option value="audiobook">Audiobook &amp; Audio Story (Voice Narration &amp; Audio Track)</option>
                  <option value="poetry">Poetry &amp; Verse Collection (Stanzas &amp; Lyrical Meter)</option>
                  <option value="script">Drama, Play &amp; Screenplay (Acts, Scenes &amp; Dialogue)</option>
                  <option value="interactive">Interactive / Choice Adventure (Branching Paths)</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-300 mb-1.5">
                  Genre
                </label>
                <select
                  value={formGenre}
                  onChange={(e) => setFormGenre(e.target.value as StoryGenre)}
                  className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-3.5 py-2.5 text-xs text-white focus:border-amber-400 focus:outline-none"
                >
                  <option value="Fantasy">Fantasy</option>
                  <option value="Adventure">Adventure</option>
                  <option value="Bedtime">Bedtime</option>
                  <option value="Sci-Fi">Sci-Fi</option>
                  <option value="Mythology">Mythology</option>
                  <option value="Mystery">Mystery</option>
                  <option value="Poetry">Poetry</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-300 mb-1.5">
                  Author Pen Name
                </label>
                <input
                  type="text"
                  value={formAuthorName}
                  onChange={(e) => setFormAuthorName(e.target.value)}
                  className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-3.5 py-2.5 text-xs text-white focus:border-amber-400 focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-300 mb-1.5">
                  Estimated Reading Time (minutes)
                </label>
                <input
                  type="number"
                  min="1"
                  max="180"
                  value={formReadingTime}
                  onChange={(e) => setFormReadingTime(Number(e.target.value))}
                  className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-3.5 py-2.5 text-xs text-white focus:border-amber-400 focus:outline-none"
                />
              </div>
            </div>
          </div>

          {/* SECTION 4: CUSTOM BOOK COVERS */}
          <div className="rounded-3xl border border-slate-800 bg-slate-900/60 p-6 sm:p-8">
            <div className="flex items-center gap-2.5 mb-2">
              <ImageIcon className="h-6 w-6 text-amber-400" />
              <h3 className="font-display text-lg sm:text-xl font-bold text-slate-100">
                4. Custom Book Covers
              </h3>
            </div>
            <p className="text-xs text-slate-400 mb-6">
              Upload your custom book cover artwork or provide a custom image URL.
            </p>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 items-start">
              {/* Cover Live Preview Card */}
              <div className="flex flex-col items-center">
                <span className="text-xs font-semibold text-slate-400 mb-2">
                  Live Cover Preview (3:4 Ratio)
                </span>
                <div className="relative aspect-[3/4] w-48 overflow-hidden rounded-2xl border-2 border-amber-400/60 bg-slate-950 shadow-xl shadow-amber-500/10">
                  <img
                    src={formCoverImage || DEFAULT_CUSTOM_COVER}
                    alt="Custom Book Cover Preview"
                    className="h-full w-full object-cover"
                    onError={(e) => {
                      (e.target as HTMLImageElement).src = DEFAULT_CUSTOM_COVER;
                    }}
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-slate-950/80 via-transparent to-transparent pointer-events-none" />
                  <div className="absolute bottom-2 left-2 right-2 text-center pointer-events-none">
                    <span className="text-[11px] font-bold text-white line-clamp-1">
                      {formTitle || 'Your Book Title'}
                    </span>
                  </div>
                </div>
                {formCoverImage && formCoverImage !== DEFAULT_CUSTOM_COVER && (
                  <button
                    type="button"
                    onClick={() => setFormCoverImage(DEFAULT_CUSTOM_COVER)}
                    className="mt-2.5 text-xs text-rose-400 hover:text-rose-300 hover:underline"
                  >
                    Reset to Default Logo Cover
                  </button>
                )}
              </div>

              {/* Upload & URL Inputs */}
              <div className="md:col-span-2 space-y-4">
                {/* Upload Image File */}
                <div>
                  <label className="block text-xs font-medium text-slate-300 mb-1.5">
                    Upload Custom Cover Image File
                  </label>
                  <label className="group flex flex-col items-center justify-center rounded-2xl border-2 border-dashed border-slate-700 bg-slate-950/60 p-6 text-center cursor-pointer hover:border-amber-400 hover:bg-slate-900/60 transition-all">
                    <input
                      type="file"
                      accept="image/*,.jpg,.jpeg,.png,.webp,.svg,.avif"
                      onChange={handleCustomCoverUpload}
                      className="hidden"
                    />
                    <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-amber-500/10 text-amber-400 group-hover:scale-110 transition-transform mb-2">
                      <ImageIcon className="h-5 w-5" />
                    </div>
                    <span className="text-xs font-bold text-slate-200 group-hover:text-amber-300">
                      Click to Browse or Drag Custom Cover Image
                    </span>
                    <span className="text-[11px] text-slate-500 mt-0.5">
                      Supports JPG, PNG, WEBP, SVG, AVIF (Portrait 3:4 recommended)
                    </span>
                  </label>
                </div>

                {/* Or Custom URL */}
                <div>
                  <label className="block text-xs font-medium text-slate-300 mb-1.5">
                    Or Enter Custom Image URL
                  </label>
                  <input
                    type="url"
                    value={formCoverImage}
                    onChange={(e) => setFormCoverImage(e.target.value)}
                    placeholder="https://example.com/your-custom-cover.jpg"
                    className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-4 py-2.5 text-xs text-white focus:border-amber-400 focus:outline-none"
                  />
                  <span className="text-[11px] text-slate-500 mt-1 block">
                    Paste any public image web link to use as the cover.
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* SECTION 5: CHAPTERS & PAGES CONTENT */}
          <div className="rounded-3xl border border-slate-800 bg-slate-900/60 p-6 sm:p-8">
            <div className="flex items-center justify-between pb-4 border-b border-slate-800 mb-6">
              <div>
                <h3 className="font-display text-lg font-bold text-slate-100">
                  5. Book Content &amp; Pages ({chapters.length})
                </h3>
                <p className="text-xs text-slate-400 mt-0.5">
                  Review or edit text for each page/chapter.
                </p>
              </div>
              <button
                type="button"
                onClick={handleAddPage}
                className="flex items-center gap-1.5 rounded-xl bg-amber-500/10 border border-amber-500/30 px-3.5 py-2 text-xs font-semibold text-amber-300 hover:bg-amber-500/20"
              >
                <Plus className="h-4 w-4" />
                <span>Add Page</span>
              </button>
            </div>

            <div className="space-y-6">
              {chapters.map((chapter, index) => (
                <div
                  key={chapter.id}
                  className="rounded-xl border border-slate-800 bg-slate-950/50 p-5"
                >
                  <div className="flex items-center justify-between mb-4 pb-3 border-b border-slate-800/60">
                    <span className="font-display text-xs font-bold uppercase tracking-wider text-amber-400">
                      Page {chapter.pageNumber} {chapter.pageNumber <= formFreeSamplePages && '(Free Preview)'}
                    </span>

                    <div className="flex items-center gap-1">
                      <button
                        type="button"
                        disabled={index === 0}
                        onClick={() => handleMovePage(index, 'up')}
                        className="p-1 text-slate-400 hover:text-white disabled:opacity-30"
                      >
                        <ArrowUp className="h-4 w-4" />
                      </button>
                      <button
                        type="button"
                        disabled={index === chapters.length - 1}
                        onClick={() => handleMovePage(index, 'down')}
                        className="p-1 text-slate-400 hover:text-white disabled:opacity-30"
                      >
                        <ArrowDown className="h-4 w-4" />
                      </button>
                      {chapters.length > 1 && (
                        <button
                          type="button"
                          onClick={() => handleRemovePage(index)}
                          className="p-1 text-rose-400/80 hover:text-rose-400 ml-2"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      )}
                    </div>
                  </div>

                  <div className="space-y-4">
                    <div>
                      <label className="block text-[11px] font-medium text-slate-400 mb-1">
                        Page Title
                      </label>
                      <input
                        type="text"
                        value={chapter.title}
                        onChange={(e) =>
                          handleUpdatePage(index, 'title', e.target.value)
                        }
                        className="w-full rounded-lg border border-slate-700 bg-slate-900 px-3 py-2 text-xs text-white focus:border-amber-400 focus:outline-none"
                      />
                    </div>

                    <div>
                      <label className="block text-[11px] font-medium text-slate-400 mb-1">
                        Prose Content
                      </label>
                      <textarea
                        rows={5}
                        required
                        value={chapter.content}
                        onChange={(e) =>
                          handleUpdatePage(index, 'content', e.target.value)
                        }
                        className="w-full rounded-lg border border-slate-700 bg-slate-900 px-3 py-2 font-serif-prose text-xs text-white focus:border-amber-400 focus:outline-none leading-relaxed"
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* SECTION 6: PUBLISH ACTION BUTTONS */}
          <div className="flex flex-col sm:flex-row items-center justify-between gap-4 rounded-3xl border border-slate-800 bg-slate-900/60 p-6">
            <div className="flex items-center gap-4">
              <label className="flex items-center gap-2 text-xs text-slate-300 cursor-pointer">
                <input
                  type="checkbox"
                  checked={formStatus === 'published'}
                  onChange={(e) =>
                    setFormStatus(e.target.checked ? 'published' : 'draft')
                  }
                  className="rounded border-slate-700 bg-slate-950 text-amber-500 focus:ring-amber-400"
                />
                <span>Set as Publicly Available for Sale</span>
              </label>

              <label className="flex items-center gap-2 text-xs text-slate-300 cursor-pointer">
                <input
                  type="checkbox"
                  checked={formFeatured}
                  onChange={(e) => setFormFeatured(e.target.checked)}
                  className="rounded border-slate-700 bg-slate-950 text-amber-500 focus:ring-amber-400"
                />
                <span>Feature on Bookstore Hero</span>
              </label>
            </div>

            <div className="flex items-center gap-3 w-full sm:w-auto">
              <button
                type="button"
                onClick={resetForm}
                className="w-1/2 sm:w-auto rounded-xl border border-slate-700 px-4 py-2.5 text-xs font-medium text-slate-400 hover:text-white"
              >
                Clear Form
              </button>
              <button
                type="submit"
                className="w-1/2 sm:w-auto flex items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-amber-500 to-amber-400 px-6 py-2.5 text-xs font-bold text-slate-950 shadow-lg shadow-amber-500/20 active:scale-95 transition-transform"
              >
                <ShoppingBag className="h-4 w-4" />
                <span>
                  {editingStoryId ? 'Save & Update Book' : `Publish for Sale (₹${Number(formPrice).toFixed(2)})`}
                </span>
              </button>
            </div>
          </div>
        </form>
      )}

      {/* ------------------------------------------------------- */}
      {/* TAB 2: MANAGE INVENTORY / CATALOG */}
      {/* ------------------------------------------------------- */}
      {adminTab === 'manage' && (
        <div className="space-y-4">
          <div className="flex items-center justify-between pb-3">
            <h3 className="font-display text-base font-bold text-slate-100">
              Published Titles ({stories.length})
            </h3>
            <button
              onClick={() => {
                resetForm();
                setAdminTab('new');
              }}
              className="flex items-center gap-1.5 rounded-xl bg-amber-500 px-3.5 py-1.5 text-xs font-bold text-slate-950 shadow-md"
            >
              <Plus className="h-3.5 w-3.5" />
              <span>Add New Title</span>
            </button>
          </div>

          {stories.length > 0 ? (
            <div className="grid grid-cols-1 gap-3">
              {stories.map((story) => (
                <div
                  key={story.id}
                  className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 rounded-xl border border-slate-800 bg-slate-900/60 p-4 transition-all hover:border-slate-700"
                >
                  <div className="flex items-center gap-4">
                    <img
                      src={story.coverImage}
                      alt={story.title}
                      className="h-16 w-12 rounded-lg object-cover shrink-0 border border-slate-700"
                    />
                    <div>
                      <div className="flex items-center gap-2">
                        <h4 className="font-display text-sm font-bold text-slate-100">
                          {story.title}
                        </h4>
                        <span className="rounded bg-amber-500/20 px-2 py-0.5 text-xs font-black text-amber-400">
                          ₹{story.price ? story.price.toFixed(2) : '0.00'}
                        </span>
                      </div>
                      <div className="mt-1 flex flex-wrap items-center gap-2 text-xs text-slate-400">
                        <span>{story.authorName}</span>
                        <span aria-hidden="true">·</span>
                        <span>{story.genre}</span>
                        <span aria-hidden="true">·</span>
                        <span>{story.chapters.length} pages</span>
                        <span aria-hidden="true">·</span>
                        <span className="text-emerald-400 font-semibold">
                          {story.stats.purchases || 0} sales (₹{(story.stats.revenue || 0).toFixed(2)})
                        </span>
                        {story.documentFile && (
                          <span className="rounded bg-cyan-500/10 text-cyan-300 px-1.5 py-0.5 text-[10px]">
                            Document Attached
                          </span>
                        )}
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 self-end sm:self-center">
                    <button
                      onClick={() => onPreviewStory(story)}
                      className="flex min-h-[36px] min-w-[36px] items-center justify-center rounded-lg border border-slate-700 text-slate-300 hover:text-white hover:bg-slate-800"
                      title="Preview in Reader"
                    >
                      <Eye className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => handleEditStory(story)}
                      className="flex min-h-[36px] min-w-[36px] items-center justify-center rounded-lg border border-slate-700 text-slate-300 hover:text-amber-400 hover:bg-slate-800"
                      title="Edit Price & Content"
                    >
                      <Edit className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => handleDeleteStory(story.id, story.title)}
                      className="flex min-h-[36px] min-w-[36px] items-center justify-center rounded-lg border border-rose-500/30 text-rose-400 hover:bg-rose-950/40"
                      title="Delete Book"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="rounded-2xl border border-slate-800 bg-slate-900/40 p-12 text-center">
              <BookOpen className="h-10 w-10 text-slate-600 mx-auto mb-3" />
              <h4 className="text-sm font-bold text-slate-300">Catalog is currently empty</h4>
              <p className="mt-1 text-xs text-slate-500">
                Upload your story document files and set prices to start selling books.
              </p>
            </div>
          )}
        </div>
      )}

      {/* ------------------------------------------------------- */}
      {/* TAB 3: SALES & REVENUE DASHBOARD */}
      {/* ------------------------------------------------------- */}
      {adminTab === 'sales' && (
        <div className="space-y-6">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="rounded-2xl border border-amber-500/30 bg-slate-900/80 p-5">
              <div className="text-xs text-slate-400 font-medium mb-1">Gross Sales Revenue</div>
              <div className="text-2xl font-black text-amber-400 tabular-nums">
                ₹{totalSalesRevenue.toFixed(2)}
              </div>
              <div className="text-[11px] text-slate-500 mt-1">Direct support from readers</div>
            </div>

            <div className="rounded-2xl border border-emerald-500/30 bg-slate-900/80 p-5">
              <div className="text-xs text-slate-400 font-medium mb-1">Total Copies Sold</div>
              <div className="text-2xl font-black text-emerald-400 tabular-nums">
                {totalCopiesSold} books
              </div>
              <div className="text-[11px] text-slate-500 mt-1">Unlocked across reader devices</div>
            </div>

            <div className="rounded-2xl border border-cyan-500/30 bg-slate-900/80 p-5">
              <div className="text-xs text-slate-400 font-medium mb-1">Active Titles for Sale</div>
              <div className="text-2xl font-black text-cyan-400 tabular-nums">
                {stories.length} titles
              </div>
              <div className="text-[11px] text-slate-500 mt-1">Published in Bookstore</div>
            </div>
          </div>

          <div className="rounded-2xl border border-slate-800 bg-slate-900/60 p-6">
            <h4 className="font-display text-sm font-bold text-slate-100 mb-4">
              Recent Sales &amp; Order Transactions
            </h4>

            {transactions.length > 0 ? (
              <div className="divide-y divide-slate-800">
                {transactions.map((tx) => (
                  <div key={tx.id} className="py-4 space-y-2 text-xs">
                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="font-semibold text-slate-100 text-sm">
                            {tx.storyTitle}
                          </span>
                          {tx.paymentMethod === 'cod' ? (
                            <span className="flex items-center gap-1 rounded bg-emerald-500/20 text-emerald-300 px-2 py-0.5 text-[10px] font-bold">
                              <Truck className="h-3 w-3" />
                              <span>Cash on Delivery</span>
                            </span>
                          ) : (
                            <span className="rounded bg-amber-500/20 text-amber-300 px-2 py-0.5 text-[10px] font-bold">
                              Digital Payment
                            </span>
                          )}
                        </div>
                        <div className="text-[11px] text-slate-400 font-mono mt-0.5">
                          {tx.transactionId} · {new Date(tx.date).toLocaleString()} · {tx.buyerEmail}
                        </div>
                      </div>

                      <div className="flex items-center gap-3 self-end sm:self-center">
                        <div className="font-black text-amber-400 text-base tabular-nums">
                          ₹{tx.amount.toFixed(2)}
                        </div>

                        {tx.paymentMethod === 'cod' && (
                          <select
                            value={tx.deliveryStatus || 'pending_dispatch'}
                            onChange={(e) => {
                              updateDeliveryStatus(
                                tx.transactionId,
                                e.target.value as 'pending_dispatch' | 'dispatched' | 'delivered'
                              );
                              onRefreshData();
                            }}
                            className={`rounded-lg px-2.5 py-1 text-[11px] font-bold border focus:outline-none ${
                              tx.deliveryStatus === 'delivered'
                                ? 'border-emerald-500/40 bg-emerald-950/60 text-emerald-300'
                                : tx.deliveryStatus === 'dispatched'
                                ? 'border-cyan-500/40 bg-cyan-950/60 text-cyan-300'
                                : 'border-amber-500/40 bg-amber-950/60 text-amber-300'
                            }`}
                          >
                            <option value="pending_dispatch">📦 Pending Dispatch</option>
                            <option value="dispatched">🚚 Dispatched</option>
                            <option value="delivered">✅ Delivered &amp; Paid</option>
                          </select>
                        )}
                      </div>
                    </div>

                    {/* Delivery Address Details for COD */}
                    {tx.deliveryAddress && (
                      <div className="rounded-xl border border-slate-800/80 bg-slate-950/60 p-3 text-[11px] text-slate-300 flex flex-col sm:flex-row sm:items-center justify-between gap-2">
                        <div>
                          <span className="font-bold text-slate-200">
                            {tx.deliveryAddress.fullName}
                          </span>{' '}
                          <span className="text-slate-400">({tx.deliveryAddress.phone})</span>:
                          <div className="text-slate-400">
                            {tx.deliveryAddress.street}, {tx.deliveryAddress.city}{' '}
                            {tx.deliveryAddress.postalCode}
                          </div>
                          {tx.deliveryAddress.notes && (
                            <div className="text-slate-500 italic mt-0.5">
                              Note: {tx.deliveryAddress.notes}
                            </div>
                          )}
                        </div>
                        <div className="text-[10px] text-emerald-400 font-semibold shrink-0">
                          Collect ${tx.amount.toFixed(2)} cash on doorstep
                        </div>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            ) : (
              <div className="py-12 text-center text-xs text-slate-500">
                No orders recorded yet. As readers buy books, transactions will show up here live.
              </div>
            )}
          </div>
        </div>
      )}

      {/* ------------------------------------------------------- */}
      {/* TAB 4: REVIEWS MODERATION */}
      {/* ------------------------------------------------------- */}
      {adminTab === 'reviews' && (
        <div className="rounded-2xl border border-slate-800 bg-slate-900/60 p-6">
          <h3 className="font-display text-base font-bold text-slate-100 mb-1">
            Customer Reviews &amp; Moderation
          </h3>
          <p className="text-xs text-slate-400 mb-6">
            Manage feedback and star ratings submitted by readers.
          </p>

          <div className="space-y-4">
            {stories.flatMap((s) =>
              (s.reviews || []).map((rev) => (
                <div
                  key={rev.id}
                  className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 rounded-xl border border-slate-800 bg-slate-950/50 p-4"
                >
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-bold text-slate-200">
                        {rev.readerName}
                      </span>
                      <span className="text-xs text-slate-500">on "{s.title}"</span>
                      <span className="text-[11px] text-slate-500">· {rev.date}</span>
                    </div>
                    <div className="mt-1 flex items-center gap-1 text-amber-400">
                      {[...Array(rev.rating)].map((_, i) => (
                        <Star key={i} className="h-3 w-3 fill-amber-400" />
                      ))}
                    </div>
                    <p className="mt-2 text-xs text-slate-300">{rev.comment}</p>
                  </div>

                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => {
                        toggleReviewApproval(s.id, rev.id);
                        onRefreshData();
                      }}
                      className={`rounded-lg px-2.5 py-1.5 text-xs font-medium border transition-colors ${
                        rev.approved
                          ? 'border-emerald-500/40 bg-emerald-950/30 text-emerald-300'
                          : 'border-slate-700 bg-slate-800 text-slate-400'
                      }`}
                    >
                      {rev.approved ? 'Approved' : 'Hidden'}
                    </button>
                    <button
                      onClick={() => {
                        deleteReview(s.id, rev.id);
                        onRefreshData();
                      }}
                      className="rounded-lg p-1.5 text-rose-400 hover:bg-rose-950/40"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </div>
                </div>
              ))
            )}

            {stories.every((s) => !s.reviews || s.reviews.length === 0) && (
              <div className="py-12 text-center text-xs text-slate-500">
                No reviews submitted yet.
              </div>
            )}
          </div>
        </div>
      )}

      {/* ------------------------------------------------------- */}
      {/* TAB 5: DATA TOOLS & INVENTORY RESET */}
      {/* ------------------------------------------------------- */}
      {adminTab === 'backup' && (
        <div className="rounded-2xl border border-slate-800 bg-slate-900/60 p-6 space-y-6">
          <div>
            <h3 className="font-display text-base font-bold text-slate-100 mb-1">
              Data Tools &amp; Catalog Management
            </h3>
            <p className="text-xs text-slate-400">
              Export database, restore from backup, or clear catalog to start fresh.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="rounded-xl border border-slate-800 bg-slate-950/50 p-5">
              <Download className="h-6 w-6 text-amber-400 mb-2" />
              <h4 className="text-xs font-bold text-slate-200">Export Catalog</h4>
              <p className="text-[11px] text-slate-400 mt-1 mb-4">
                Save all books and attached documents to a JSON file.
              </p>
              <button
                onClick={handleExportBackup}
                className="w-full rounded-lg bg-amber-500 px-3 py-2 text-xs font-bold text-slate-950 shadow hover:bg-amber-400"
              >
                Export JSON
              </button>
            </div>

            <div className="rounded-xl border border-slate-800 bg-slate-950/50 p-5">
              <Upload className="h-6 w-6 text-cyan-400 mb-2" />
              <h4 className="text-xs font-bold text-slate-200">Restore Catalog</h4>
              <p className="text-[11px] text-slate-400 mt-1 mb-4">
                Load catalog from an existing JSON backup.
              </p>
              <label className="block w-full text-center rounded-lg border border-slate-700 bg-slate-800 px-3 py-2 text-xs font-medium text-slate-200 cursor-pointer hover:bg-slate-700">
                Upload Backup
                <input
                  type="file"
                  accept=".json"
                  onChange={handleImportBackup}
                  className="hidden"
                />
              </label>
            </div>

            <div className="rounded-xl border border-rose-500/20 bg-rose-950/20 p-5">
              <Trash2 className="h-6 w-6 text-rose-400 mb-2" />
              <h4 className="text-xs font-bold text-rose-200">Clear All Books</h4>
              <p className="text-[11px] text-slate-400 mt-1 mb-4">
                Wipe all books from the app to begin with a completely clean bookstore.
              </p>
              <button
                onClick={handleClearAllBooks}
                className="w-full rounded-lg border border-rose-500/40 text-rose-300 px-3 py-2 text-xs font-bold hover:bg-rose-950/50 transition-colors"
              >
                Wipe Catalog
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
