import React, { useState } from 'react';
import { StoryItem, PurchaseRecord } from '../types';
import {
  ShoppingBag,
  BookOpen,
  Download,
  Truck,
  CheckCircle,
  Clock,
  MapPin,
  Phone,
  FileText,
  CreditCard,
  Banknote,
  ChevronDown,
  ChevronUp,
} from 'lucide-react';
import { downloadAttachedDocument } from '../services/storage';
import { FormatDownloadMenu } from './FormatDownloadMenu';

interface MyPurchasesSectionProps {
  stories: StoryItem[];
  purchasedIds: string[];
  purchaseRecords: PurchaseRecord[];
  onSelectStory: (story: StoryItem) => void;
  onExploreLibrary?: () => void;
}

export const MyPurchasesSection: React.FC<MyPurchasesSectionProps> = ({
  stories,
  purchasedIds,
  purchaseRecords,
  onSelectStory,
  onExploreLibrary,
}) => {
  const [expandedTxId, setExpandedTxId] = useState<string | null>(null);

  // Match purchased stories with their transaction records
  const purchasedStoriesWithRecords: { story: StoryItem; record?: PurchaseRecord }[] = [];
  for (const storyId of purchasedIds) {
    const story = stories.find((s) => s.id === storyId);
    if (story) {
      const record = purchaseRecords.find((r) => r.storyId === storyId);
      purchasedStoriesWithRecords.push({ story, record });
    }
  }

  if (purchasedStoriesWithRecords.length === 0) {
    return (
      <div className="rounded-3xl border border-slate-800 bg-slate-900/40 p-8 sm:p-12 text-center max-w-xl mx-auto my-6 shadow-xl">
        <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-amber-500/10 border border-amber-500/20 text-amber-400 mb-4">
          <ShoppingBag className="h-7 w-7" />
        </div>
        <h3 className="font-display text-lg sm:text-xl font-bold text-slate-100">
          No Purchased Stories Yet
        </h3>
        <p className="mt-2 text-xs sm:text-sm text-slate-400 leading-relaxed max-w-md mx-auto">
          When you buy books using Cash on Delivery or Card payment, your unlocked stories and delivery statuses will appear right here.
        </p>
        {onExploreLibrary && (
          <button
            onClick={onExploreLibrary}
            className="mt-6 inline-flex items-center gap-2 rounded-xl bg-amber-500 px-5 py-2.5 text-xs font-bold text-slate-950 shadow-md hover:bg-amber-400 transition-all active:scale-95"
          >
            <BookOpen className="h-4 w-4" />
            <span>Browse Bookstore</span>
          </button>
        )}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-3 border-b border-slate-800/80">
        <div>
          <h3 className="font-display text-xl sm:text-2xl font-bold text-slate-100 flex items-center gap-2.5">
            <ShoppingBag className="h-6 w-6 text-emerald-400" />
            <span>My Purchased Stories</span>
          </h3>
          <p className="text-xs text-slate-400 mt-0.5">
            Your unlocked story library and live delivery tracking for Cash on Delivery orders.
          </p>
        </div>
        <span className="rounded-full bg-emerald-500/20 px-3 py-1 text-xs font-bold text-emerald-300 w-fit">
          {purchasedStoriesWithRecords.length} {purchasedStoriesWithRecords.length === 1 ? 'Book Unlocked' : 'Books Unlocked'}
        </span>
      </div>

      <div className="grid grid-cols-1 gap-4">
        {purchasedStoriesWithRecords.map(({ story, record }) => {
          const isCod = record?.paymentMethod === 'cod';
          const deliveryStatus = record?.deliveryStatus || (isCod ? 'pending_dispatch' : 'delivered');
          const isExpanded = record?.id ? expandedTxId === record.id : false;

          return (
            <div
              key={story.id}
              className="rounded-2xl border border-slate-800 bg-slate-900/70 p-5 sm:p-6 shadow-xl transition-all hover:border-slate-700"
            >
              <div className="flex flex-col sm:flex-row gap-5 items-start justify-between">
                {/* Book Info */}
                <div className="flex gap-4 items-start flex-1 min-w-0">
                  <img
                    src={story.coverImage}
                    alt={story.title}
                    className="h-28 w-20 sm:h-32 sm:w-24 rounded-xl object-cover border border-slate-700 shrink-0 shadow-md"
                  />
                  <div className="flex-1 min-w-0 space-y-1.5">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="text-[11px] font-semibold text-amber-400 uppercase tracking-wider">
                        {story.type === 'storybook' ? 'Illustrated Storybook' : 'Single Story'}
                      </span>
                      <span className="text-slate-600">·</span>
                      <span className="text-xs text-slate-400">{story.genre}</span>
                    </div>

                    <h4 className="font-display text-base sm:text-lg font-bold text-slate-100 truncate">
                      {story.title}
                    </h4>

                    <p className="text-xs text-slate-400 line-clamp-2 leading-relaxed">
                      By {story.authorName} · {story.chapters.length} {story.type === 'storybook' ? 'pages' : 'chapters'}
                    </p>

                    {/* Order Metadata */}
                    {record && (
                      <div className="flex flex-wrap items-center gap-2 text-[11px] text-slate-400 pt-1">
                        <span className="font-mono text-slate-300 font-semibold">{record.transactionId}</span>
                        <span>·</span>
                        <span>{new Date(record.date).toLocaleDateString()}</span>
                        <span>·</span>
                        <span className="font-bold text-amber-400">₹{record.amount.toFixed(2)}</span>
                      </div>
                    )}

                    {/* Payment Method Badge */}
                    <div className="pt-1 flex items-center gap-2">
                      {isCod ? (
                        <span className="inline-flex items-center gap-1.5 rounded-full bg-amber-500/10 border border-amber-500/30 px-2.5 py-0.5 text-[11px] font-semibold text-amber-300">
                          <Banknote className="h-3.5 w-3.5 text-amber-400" />
                          <span>Cash on Delivery</span>
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/30 px-2.5 py-0.5 text-[11px] font-semibold text-emerald-300">
                          <CreditCard className="h-3.5 w-3.5 text-emerald-400" />
                          <span>Online Payment (Paid)</span>
                        </span>
                      )}
                    </div>
                  </div>
                </div>

                {/* Quick Action Buttons */}
                <div className="flex sm:flex-col gap-2 w-full sm:w-auto shrink-0 justify-end pt-2 sm:pt-0">
                  <button
                    onClick={() => onSelectStory(story)}
                    className="flex-1 sm:flex-none flex items-center justify-center gap-2 rounded-xl bg-amber-500 hover:bg-amber-400 px-4 py-2.5 text-xs font-bold text-slate-950 shadow-md transition-all active:scale-95"
                  >
                    <BookOpen className="h-4 w-4" />
                    <span>Read Book</span>
                  </button>

                  <FormatDownloadMenu story={story} variant="button" />
                </div>
              </div>

              {/* LIVE DELIVERY & FULFILLMENT STATUS TRACKER (ESPECIALLY FOR CASH ON DELIVERY) */}
              {isCod ? (
                <div className="mt-5 pt-4 border-t border-slate-800">
                  <div className="rounded-xl border border-slate-800/80 bg-slate-950/60 p-4">
                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mb-3">
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-bold text-slate-300 uppercase tracking-wider">
                          Delivery Status:
                        </span>
                        {deliveryStatus === 'pending_dispatch' && (
                          <span className="inline-flex items-center gap-1 text-xs font-bold text-amber-400">
                            <Clock className="h-3.5 w-3.5 animate-pulse" />
                            <span>Awaiting Dispatch (COD)</span>
                          </span>
                        )}
                        {deliveryStatus === 'dispatched' && (
                          <span className="inline-flex items-center gap-1 text-xs font-bold text-cyan-400">
                            <Truck className="h-3.5 w-3.5 animate-bounce" />
                            <span>Out for Delivery / Dispatched</span>
                          </span>
                        )}
                        {deliveryStatus === 'delivered' && (
                          <span className="inline-flex items-center gap-1 text-xs font-bold text-emerald-400">
                            <CheckCircle className="h-3.5 w-3.5" />
                            <span>Delivered &amp; Paid</span>
                          </span>
                        )}
                      </div>

                      {record?.deliveryAddress && (
                        <button
                          type="button"
                          onClick={() => setExpandedTxId(isExpanded ? null : record.id)}
                          className="flex items-center gap-1 text-[11px] text-slate-400 hover:text-white"
                        >
                          <span>{isExpanded ? 'Hide Delivery Details' : 'View Delivery Address'}</span>
                          {isExpanded ? <ChevronUp className="h-3 w-3" /> : <ChevronDown className="h-3 w-3" />}
                        </button>
                      )}
                    </div>

                    {/* Step Tracker Visual */}
                    <div className="grid grid-cols-3 gap-2 my-2">
                      <div className={`p-2 rounded-lg text-center border text-[11px] ${
                        deliveryStatus === 'pending_dispatch'
                          ? 'border-amber-400 bg-amber-500/10 text-amber-300 font-bold'
                          : 'border-slate-800 bg-slate-900/60 text-slate-400'
                      }`}>
                        <span>1. Order Placed</span>
                      </div>
                      <div className={`p-2 rounded-lg text-center border text-[11px] ${
                        deliveryStatus === 'dispatched'
                          ? 'border-cyan-400 bg-cyan-500/10 text-cyan-300 font-bold'
                          : 'border-slate-800 bg-slate-900/60 text-slate-400'
                      }`}>
                        <span>2. Dispatched (Courier)</span>
                      </div>
                      <div className={`p-2 rounded-lg text-center border text-[11px] ${
                        deliveryStatus === 'delivered'
                          ? 'border-emerald-400 bg-emerald-500/10 text-emerald-300 font-bold'
                          : 'border-slate-800 bg-slate-900/60 text-slate-400'
                      }`}>
                        <span>3. Delivered &amp; Paid</span>
                      </div>
                    </div>

                    <p className="text-[11px] text-slate-400 mt-2">
                      {deliveryStatus === 'pending_dispatch' &&
                        `Order confirmed. The author is preparing your physical copy. Cash of ₹${(record?.amount || story.price).toFixed(2)} will be collected upon arrival.`}
                      {deliveryStatus === 'dispatched' &&
                        `Your package is on its way. Please have ₹${(record?.amount || story.price).toFixed(2)} cash ready for the delivery agent.`}
                      {deliveryStatus === 'delivered' &&
                        `Delivered successfully and payment settled. Enjoy your book!`}
                    </p>

                    {/* Collapsible Delivery Address */}
                    {isExpanded && record?.deliveryAddress && (
                      <div className="mt-3 pt-3 border-t border-slate-800 text-xs text-slate-300 space-y-1">
                        <div className="flex items-center gap-1.5 text-slate-400">
                          <MapPin className="h-3.5 w-3.5 text-amber-400 shrink-0" />
                          <span>Recipient: <strong className="text-white">{record.deliveryAddress.fullName}</strong></span>
                        </div>
                        <div className="pl-5 text-slate-300">
                          {record.deliveryAddress.street || (record.deliveryAddress as any).streetAddress}, {record.deliveryAddress.city} {record.deliveryAddress.postalCode}
                        </div>
                        <div className="flex items-center gap-1.5 text-slate-400 pl-5">
                          <Phone className="h-3 w-3 text-cyan-400" />
                          <span>Phone: {record.deliveryAddress.phone}</span>
                        </div>
                        {record.deliveryAddress.notes && (
                          <div className="pl-5 text-slate-400 italic">
                            Notes: "{record.deliveryAddress.notes}"
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                </div>
              ) : (
                <div className="mt-4 pt-3 border-t border-slate-800/80 flex items-center justify-between text-xs text-slate-400">
                  <div className="flex items-center gap-2">
                    <CheckCircle className="h-4 w-4 text-emerald-400" />
                    <span>Instant Digital Access Unlocked · Unlimited Reading &amp; Audio</span>
                  </div>
                  {story.documentFile && (
                    <span className="text-[11px] text-cyan-400">
                      Original {story.documentFile.fileName} included
                    </span>
                  )}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
};
