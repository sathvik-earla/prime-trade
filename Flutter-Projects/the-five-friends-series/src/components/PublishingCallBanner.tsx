import React from 'react';
import { PhoneCall } from 'lucide-react';
import { PUBLISHING_PHONE_NUMBERS } from '../services/auth';

interface PublishingCallBannerProps {
  variant?: 'topbar' | 'card' | 'inline';
}

export const PublishingCallBanner: React.FC<PublishingCallBannerProps> = ({ variant = 'topbar' }) => {
  if (variant === 'topbar') {
    return (
      <div className="w-full bg-gradient-to-r from-amber-600 via-amber-500 to-amber-600 text-slate-950 py-2 px-3 sm:px-4 shadow-sm border-b border-amber-400/40 text-center select-text">
        <div className="mx-auto max-w-6xl flex flex-wrap items-center justify-center gap-1.5 sm:gap-2 text-xs sm:text-sm font-bold">
          <PhoneCall className="h-3.5 w-3.5 sm:h-4 sm:w-4 shrink-0 text-slate-950 animate-bounce" />
          <span>Call</span>
          <a
            href={`tel:${PUBLISHING_PHONE_NUMBERS[0].tel}`}
            className="inline-flex items-center font-extrabold underline decoration-slate-950 underline-offset-2 hover:text-slate-900 transition-colors"
          >
            {PUBLISHING_PHONE_NUMBERS[0].display}
          </a>
          <span>Or</span>
          <a
            href={`tel:${PUBLISHING_PHONE_NUMBERS[1].tel}`}
            className="inline-flex items-center font-extrabold underline decoration-slate-950 underline-offset-2 hover:text-slate-900 transition-colors"
          >
            {PUBLISHING_PHONE_NUMBERS[1].display}
          </a>
          <span>for publishing a book</span>
        </div>
      </div>
    );
  }

  return (
    <div className="rounded-2xl border border-amber-500/40 bg-gradient-to-r from-amber-500/10 via-amber-400/15 to-amber-500/10 p-4 text-center shadow-lg">
      <div className="flex items-center justify-center gap-2 text-xs uppercase tracking-wider font-bold text-amber-400 mb-1">
        <PhoneCall className="h-4 w-4 shrink-0 text-amber-400" />
        <span>Author &amp; Publisher Hotline</span>
      </div>
      <p className="text-sm sm:text-base font-bold text-slate-100">
        Call{' '}
        <a
          href={`tel:${PUBLISHING_PHONE_NUMBERS[0].tel}`}
          className="text-amber-400 underline decoration-amber-400 underline-offset-2 hover:text-amber-300"
        >
          {PUBLISHING_PHONE_NUMBERS[0].display}
        </a>{' '}
        Or{' '}
        <a
          href={`tel:${PUBLISHING_PHONE_NUMBERS[1].tel}`}
          className="text-amber-400 underline decoration-amber-400 underline-offset-2 hover:text-amber-300"
        >
          {PUBLISHING_PHONE_NUMBERS[1].display}
        </a>{' '}
        for publishing a book
      </p>
    </div>
  );
};
