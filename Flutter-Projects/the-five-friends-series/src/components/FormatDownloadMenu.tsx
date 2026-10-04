import React, { useState, useRef, useEffect } from 'react';
import { StoryItem, DocumentFormatType } from '../types';
import { downloadBookInFormat, SUPPORTED_FORMAT_OPTIONS } from '../services/formatExporter';
import {
  Download,
  FileText,
  BookOpen,
  FileEdit,
  AlignLeft,
  Hash,
  Globe,
  FileSpreadsheet,
  Code,
  Check,
  ChevronDown,
  Paperclip,
} from 'lucide-react';

interface FormatDownloadMenuProps {
  story: StoryItem;
  className?: string;
  variant?: 'button' | 'compact' | 'icon';
}

export const FormatDownloadMenu: React.FC<FormatDownloadMenuProps> = ({
  story,
  className = '',
  variant = 'button',
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [lastDownloaded, setLastDownloaded] = useState<string | null>(null);
  const menuRef = useRef<HTMLDivElement>(null);

  // Close when clicked outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };
    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen]);

  const handleDownload = (format: DocumentFormatType | 'original') => {
    downloadBookInFormat(story, format);
    setLastDownloaded(format);
    setTimeout(() => {
      setIsOpen(false);
      setLastDownloaded(null);
    }, 800);
  };

  const getFormatIcon = (formatId: string) => {
    switch (formatId) {
      case 'pdf':
        return <FileText className="h-4 w-4 text-rose-400" />;
      case 'epub':
        return <BookOpen className="h-4 w-4 text-emerald-400" />;
      case 'docx':
        return <FileEdit className="h-4 w-4 text-sky-400" />;
      case 'txt':
        return <AlignLeft className="h-4 w-4 text-slate-300" />;
      case 'md':
        return <Hash className="h-4 w-4 text-amber-400" />;
      case 'html':
        return <Globe className="h-4 w-4 text-purple-400" />;
      case 'rtf':
        return <FileSpreadsheet className="h-4 w-4 text-teal-400" />;
      case 'json':
        return <Code className="h-4 w-4 text-cyan-400" />;
      default:
        return <Download className="h-4 w-4 text-amber-400" />;
    }
  };

  return (
    <div className={`relative inline-block text-left ${className}`} ref={menuRef}>
      {variant === 'button' ? (
        <button
          type="button"
          onClick={() => setIsOpen(!isOpen)}
          className="flex items-center gap-2 rounded-xl bg-slate-800/90 hover:bg-slate-700/90 border border-slate-700 px-4 py-2.5 text-xs font-semibold text-slate-200 hover:text-white shadow-sm transition-all active:scale-95"
          title="Download book in any format (PDF, EPUB, DOCX, TXT, etc.)"
        >
          <Download className="h-4 w-4 text-amber-400" />
          <span>Download in Any Format</span>
          <ChevronDown className={`h-3.5 w-3.5 text-slate-400 transition-transform ${isOpen ? 'rotate-180' : ''}`} />
        </button>
      ) : variant === 'compact' ? (
        <button
          type="button"
          onClick={() => setIsOpen(!isOpen)}
          className="flex items-center gap-1.5 rounded-lg border border-slate-700 bg-slate-800/80 px-2.5 py-1 text-[11px] font-medium text-slate-300 hover:text-white hover:bg-slate-700 transition-colors"
          title="Download formats"
        >
          <Download className="h-3 w-3 text-amber-400" />
          <span>Download Formats</span>
          <ChevronDown className="h-3 w-3 text-slate-400" />
        </button>
      ) : (
        <button
          type="button"
          onClick={() => setIsOpen(!isOpen)}
          className="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-700 text-slate-300 hover:text-white hover:bg-slate-800 transition-colors"
          title="Download in Every Format"
        >
          <Download className="h-4 w-4 text-amber-400" />
        </button>
      )}

      {/* Dropdown Menu */}
      {isOpen && (
        <div className="absolute right-0 bottom-full sm:bottom-auto sm:top-full mb-2 sm:mb-0 sm:mt-2 z-50 w-72 origin-top-right rounded-2xl border border-slate-700/80 bg-slate-900/95 backdrop-blur-xl p-2 shadow-2xl ring-1 ring-black ring-opacity-5 animate-in fade-in zoom-in-95 duration-100">
          <div className="px-3 py-2 border-b border-slate-800">
            <span className="text-[11px] font-bold uppercase tracking-wider text-amber-400 block">
              Every Format Available
            </span>
            <span className="text-[11px] text-slate-400 block mt-0.5">
              Select any file type to save onto your device:
            </span>
          </div>

          <div className="py-1 max-h-80 overflow-y-auto divide-y divide-slate-800/50">
            {SUPPORTED_FORMAT_OPTIONS.map((opt) => (
              <button
                key={opt.id}
                type="button"
                onClick={() => handleDownload(opt.id as DocumentFormatType)}
                className="flex w-full items-start gap-2.5 px-3 py-2 text-left hover:bg-slate-800/70 rounded-xl transition-colors group"
              >
                <div className="mt-0.5 p-1 rounded-lg bg-slate-950/70 border border-slate-800 group-hover:border-amber-400/50">
                  {getFormatIcon(opt.id)}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-slate-200 group-hover:text-amber-300">
                      {opt.label}
                    </span>
                    <span className="font-mono text-[10px] text-slate-500 uppercase">
                      {opt.extension}
                    </span>
                  </div>
                  <span className="text-[10px] text-slate-400 block leading-tight truncate">
                    {opt.description}
                  </span>
                </div>
                {lastDownloaded === opt.id && (
                  <Check className="h-4 w-4 text-emerald-400 shrink-0 self-center" />
                )}
              </button>
            ))}

            {/* Original Uploaded File (if present) */}
            {story.documentFile && (
              <button
                type="button"
                onClick={() => handleDownload('original')}
                className="flex w-full items-start gap-2.5 px-3 py-2 text-left hover:bg-amber-950/30 rounded-xl transition-colors group border-t border-amber-500/20"
              >
                <div className="mt-0.5 p-1 rounded-lg bg-amber-500/10 border border-amber-500/30">
                  <Paperclip className="h-4 w-4 text-amber-400" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-amber-300">
                      Original Uploaded File
                    </span>
                  </div>
                  <span className="text-[10px] text-slate-400 block leading-tight truncate">
                    {story.documentFile.fileName} ({(story.documentFile.fileSize / 1024).toFixed(1)} KB)
                  </span>
                </div>
                {lastDownloaded === 'original' && (
                  <Check className="h-4 w-4 text-emerald-400 shrink-0 self-center" />
                )}
              </button>
            )}
          </div>
        </div>
      )}
    </div>
  );
};
