import React, { useState } from 'react';
import { StoryItem, PurchaseRecord, DeliveryAddress } from '../types';
import { completePurchase } from '../services/storage';
import {
  X,
  CheckCircle2,
  ShieldCheck,
  CreditCard,
  Smartphone,
  BookOpen,
  Lock,
  Truck,
  Banknote,
  MapPin,
  Phone,
  User,
} from 'lucide-react';

interface CheckoutModalProps {
  story: StoryItem;
  onClose: () => void;
  onSuccess: (record: PurchaseRecord) => void;
}

export const CheckoutModal: React.FC<CheckoutModalProps> = ({
  story,
  onClose,
  onSuccess,
}) => {
  const [paymentMethod, setPaymentMethod] = useState<'card' | 'apple_google' | 'cod'>('cod');
  const [buyerEmail, setBuyerEmail] = useState('');
  const [cardNumber, setCardNumber] = useState('•••• •••• •••• 4242');

  // Cash on Delivery Address Fields
  const [fullName, setFullName] = useState('');
  const [phone, setPhone] = useState('');
  const [street, setStreet] = useState('');
  const [city, setCity] = useState('');
  const [postalCode, setPostalCode] = useState('');
  const [deliveryNotes, setDeliveryNotes] = useState('');

  const [isProcessing, setIsProcessing] = useState(false);
  const [completedRecord, setCompletedRecord] = useState<PurchaseRecord | null>(null);

  const handlePay = (e: React.FormEvent) => {
    e.preventDefault();
    setIsProcessing(true);

    const deliveryAddress: DeliveryAddress | undefined =
      paymentMethod === 'cod'
        ? {
            fullName: fullName.trim() || 'Valued Customer',
            phone: phone.trim() || 'N/A',
            street: street.trim(),
            city: city.trim(),
            postalCode: postalCode.trim(),
            notes: deliveryNotes.trim() || undefined,
          }
        : undefined;

    setTimeout(() => {
      const record = completePurchase(
        story.id,
        buyerEmail.trim() || 'reader@example.com',
        paymentMethod,
        deliveryAddress
      );
      setIsProcessing(false);
      if (record) {
        setCompletedRecord(record);
        onSuccess(record);
      }
    }, 700);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/85 backdrop-blur-md overflow-y-auto">
      <div className="w-full max-w-lg my-8 overflow-hidden rounded-3xl border border-slate-800 bg-slate-900 shadow-2xl">
        {/* Header */}
        <div className="flex items-center justify-between border-b border-slate-800 p-5 sm:p-6 bg-slate-950/50">
          <div className="flex items-center gap-2.5">
            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-amber-500/20 text-amber-400">
              {paymentMethod === 'cod' ? (
                <Truck className="h-5 w-5" />
              ) : (
                <Lock className="h-5 w-5" />
              )}
            </div>
            <div>
              <h3 className="font-display text-base sm:text-lg font-bold text-slate-100">
                {completedRecord
                  ? completedRecord.paymentMethod === 'cod'
                    ? 'Cash on Delivery Order Confirmed'
                    : 'Purchase Confirmed'
                  : 'Order Book Edition'}
              </h3>
              <span className="text-xs text-slate-400">
                The Five Friends Series Bookstore
              </span>
            </div>
          </div>
          <button
            onClick={onClose}
            className="flex h-8 w-8 items-center justify-center rounded-lg text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Content */}
        {completedRecord ? (
          <div className="p-6 sm:p-8 text-center space-y-6">
            <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-emerald-500/20 text-emerald-400 border border-emerald-500/30">
              <CheckCircle2 className="h-8 w-8" />
            </div>

            <div>
              <h4 className="font-display text-xl font-bold text-slate-100">
                {completedRecord.paymentMethod === 'cod'
                  ? 'Order Successfully Placed!'
                  : 'Thank You for Your Purchase!'}
              </h4>
              <p className="mt-2 text-xs sm:text-sm text-slate-400 max-w-sm mx-auto">
                {completedRecord.paymentMethod === 'cod'
                  ? `Your order for "${story.title}" has been registered. You can read the digital copy right now while physical delivery is dispatched!`
                  : `You now have full, unlimited access to read "${story.title}" and download attached original document files.`}
              </p>
            </div>

            <div className="rounded-2xl border border-slate-800 bg-slate-950/60 p-4 text-xs space-y-2 text-left">
              <div className="flex justify-between text-slate-400">
                <span>Tracking / Order ID:</span>
                <span className="font-mono font-bold text-slate-200">
                  {completedRecord.transactionId}
                </span>
              </div>
              <div className="flex justify-between text-slate-400">
                <span>Payment Method:</span>
                <span className="font-semibold text-emerald-400">
                  {completedRecord.paymentMethod === 'cod'
                    ? 'Cash on Delivery (COD)'
                    : completedRecord.paymentMethod === 'card'
                    ? 'Credit / Debit Card'
                    : 'UPI / Google Pay'}
                </span>
              </div>
              <div className="flex justify-between text-slate-400">
                <span>Amount to Pay:</span>
                <span className="font-bold text-amber-400 text-sm">
                  ₹{story.price.toFixed(2)}
                </span>
              </div>

              {completedRecord.deliveryAddress && (
                <div className="pt-2 border-t border-slate-800 text-slate-300">
                  <div className="text-[11px] font-semibold text-slate-400 mb-1">
                    Delivery Destination:
                  </div>
                  <div>{completedRecord.deliveryAddress.fullName} · {completedRecord.deliveryAddress.phone}</div>
                  <div className="text-slate-400">
                    {completedRecord.deliveryAddress.street}, {completedRecord.deliveryAddress.city} {completedRecord.deliveryAddress.postalCode}
                  </div>
                </div>
              )}
            </div>

            <div className="flex flex-col sm:flex-row gap-3 justify-center">
              <button
                onClick={onClose}
                className="flex items-center justify-center gap-2 rounded-xl bg-amber-500 px-6 py-3 text-xs font-bold text-slate-950 shadow-lg hover:bg-amber-400 transition-all active:scale-95"
              >
                <BookOpen className="h-4 w-4" />
                <span>Open &amp; Read Digital Edition Now</span>
              </button>
            </div>
          </div>
        ) : (
          <form onSubmit={handlePay} className="p-6 sm:p-8 space-y-5">
            {/* Book Preview Summary Card */}
            <div className="flex items-center gap-4 rounded-2xl border border-slate-800 bg-slate-950/60 p-4">
              <img
                src={story.coverImage}
                alt={story.title}
                className="h-20 w-16 rounded-xl object-cover border border-slate-700 shrink-0"
              />
              <div className="flex-1 min-w-0">
                <span className="text-[11px] font-medium text-amber-400 uppercase tracking-wider block">
                  {story.type === 'storybook' ? 'Illustrated Storybook' : 'Single Story'}
                </span>
                <h4 className="font-display text-sm font-bold text-slate-100 truncate">
                  {story.title}
                </h4>
                <p className="text-xs text-slate-400 truncate mt-0.5">
                  By {story.authorName}
                </p>
                <div className="mt-2 text-base font-bold text-amber-400">
                  ₹{story.price.toFixed(2)}
                </div>
              </div>
            </div>

            {/* Payment Method Selector (Includes Cash on Delivery) */}
            <div>
              <label className="block text-xs font-medium text-slate-300 mb-2">
                Select Payment Method
              </label>
              <div className="grid grid-cols-3 gap-2">
                {/* Cash on Delivery option */}
                <button
                  type="button"
                  onClick={() => setPaymentMethod('cod')}
                  className={`flex flex-col items-center justify-center gap-1.5 rounded-xl border p-3 text-center transition-all ${
                    paymentMethod === 'cod'
                      ? 'border-emerald-400 bg-emerald-950/40 text-emerald-300 ring-2 ring-emerald-500/20 shadow-md font-bold'
                      : 'border-slate-800 bg-slate-950/50 text-slate-400 hover:text-white'
                  }`}
                >
                  <Banknote className="h-5 w-5 text-emerald-400" />
                  <span className="text-xs">Cash on Delivery</span>
                </button>

                {/* Mobile Pay */}
                <button
                  type="button"
                  onClick={() => setPaymentMethod('apple_google')}
                  className={`flex flex-col items-center justify-center gap-1.5 rounded-xl border p-3 text-center transition-all ${
                    paymentMethod === 'apple_google'
                      ? 'border-amber-400 bg-amber-500/10 text-amber-300 ring-2 ring-amber-500/20 shadow-md font-bold'
                      : 'border-slate-800 bg-slate-950/50 text-slate-400 hover:text-white'
                  }`}
                >
                  <Smartphone className="h-5 w-5 text-amber-400" />
                  <span className="text-xs">UPI / GPay / PhonePe</span>
                </button>

                {/* Card */}
                <button
                  type="button"
                  onClick={() => setPaymentMethod('card')}
                  className={`flex flex-col items-center justify-center gap-1.5 rounded-xl border p-3 text-center transition-all ${
                    paymentMethod === 'card'
                      ? 'border-amber-400 bg-amber-500/10 text-amber-300 ring-2 ring-amber-500/20 shadow-md font-bold'
                      : 'border-slate-800 bg-slate-950/50 text-slate-400 hover:text-white'
                  }`}
                >
                  <CreditCard className="h-5 w-5 text-amber-400" />
                  <span className="text-xs">Debit / Credit Card</span>
                </button>
              </div>
            </div>

            {/* CASH ON DELIVERY DETAILS FORM */}
            {paymentMethod === 'cod' && (
              <div className="rounded-2xl border border-emerald-500/30 bg-emerald-950/20 p-4 space-y-3">
                <div className="flex items-center gap-2 text-xs font-bold text-emerald-300 mb-1">
                  <Truck className="h-4 w-4" />
                  <span>Delivery Address (Pay Cash When Delivered)</span>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label className="block text-[11px] font-medium text-slate-300 mb-1">
                      Recipient Full Name *
                    </label>
                    <input
                      type="text"
                      required
                      value={fullName}
                      onChange={(e) => setFullName(e.target.value)}
                      placeholder="e.g. Rahul Sharma"
                      className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-3 py-2 text-xs text-white placeholder-slate-500 focus:border-emerald-400 focus:outline-none"
                    />
                  </div>

                  <div>
                    <label className="block text-[11px] font-medium text-slate-300 mb-1">
                      Mobile Number (For Courier Delivery) *
                    </label>
                    <input
                      type="tel"
                      required
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                      placeholder="e.g. +91 98765 43210"
                      className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-3 py-2 text-xs text-white placeholder-slate-500 focus:border-emerald-400 focus:outline-none"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-[11px] font-medium text-slate-300 mb-1">
                    Street Address / House / Flat No. *
                  </label>
                  <input
                    type="text"
                    required
                    value={street}
                    onChange={(e) => setStreet(e.target.value)}
                    placeholder="e.g. 42 Rose Garden, 3rd Cross"
                    className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-3 py-2 text-xs text-white placeholder-slate-500 focus:border-emerald-400 focus:outline-none"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-[11px] font-medium text-slate-300 mb-1">
                      City *
                    </label>
                    <input
                      type="text"
                      required
                      value={city}
                      onChange={(e) => setCity(e.target.value)}
                      placeholder="e.g. Bengaluru"
                      className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-3 py-2 text-xs text-white placeholder-slate-500 focus:border-emerald-400 focus:outline-none"
                    />
                  </div>
                  <div>
                    <label className="block text-[11px] font-medium text-slate-300 mb-1">
                      PIN Code *
                    </label>
                    <input
                      type="text"
                      required
                      value={postalCode}
                      onChange={(e) => setPostalCode(e.target.value)}
                      placeholder="e.g. 560001"
                      className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-3 py-2 text-xs text-white placeholder-slate-500 focus:border-emerald-400 focus:outline-none"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-[11px] font-medium text-slate-300 mb-1">
                    Delivery Instructions (Optional)
                  </label>
                  <input
                    type="text"
                    value={deliveryNotes}
                    onChange={(e) => setDeliveryNotes(e.target.value)}
                    placeholder="e.g. Landmark near post office or call on arrival"
                    className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-3 py-2 text-xs text-white placeholder-slate-500 focus:border-emerald-400 focus:outline-none"
                  />
                </div>

                <div className="text-[11px] text-emerald-300/90 pt-1">
                  💡 Pay <strong>₹{story.price.toFixed(2)}</strong> in cash when the book is delivered. Digital copy unlocks immediately!
                </div>
              </div>
            )}

            {/* Email for order confirmation */}
            <div>
              <label className="block text-xs font-medium text-slate-300 mb-1">
                Receipt / Tracking Email (Optional)
              </label>
              <input
                type="email"
                value={buyerEmail}
                onChange={(e) => setBuyerEmail(e.target.value)}
                placeholder="your.email@example.com"
                className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-4 py-2.5 text-xs text-white placeholder-slate-500 focus:border-amber-400 focus:outline-none"
              />
            </div>

            {/* Card Simulation Input */}
            {paymentMethod === 'card' && (
              <div className="space-y-3">
                <div>
                  <label className="block text-xs font-medium text-slate-300 mb-1">
                    Card Number
                  </label>
                  <input
                    type="text"
                    required
                    value={cardNumber}
                    onChange={(e) => setCardNumber(e.target.value)}
                    className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-4 py-2.5 text-xs text-white font-mono focus:border-amber-400 focus:outline-none"
                  />
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-medium text-slate-300 mb-1">
                      Expiry Date
                    </label>
                    <input
                      type="text"
                      defaultValue="12/28"
                      className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-4 py-2.5 text-xs text-white font-mono focus:border-amber-400 focus:outline-none"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-slate-300 mb-1">
                      CVV
                    </label>
                    <input
                      type="text"
                      defaultValue="888"
                      className="w-full rounded-xl border border-slate-700 bg-slate-950/80 px-4 py-2.5 text-xs text-white font-mono focus:border-amber-400 focus:outline-none"
                    />
                  </div>
                </div>
              </div>
            )}

            {/* Guarantee */}
            <div className="flex items-center gap-2 text-[11px] text-slate-400">
              <ShieldCheck className="h-4 w-4 text-emerald-400 shrink-0" />
              <span>
                {paymentMethod === 'cod'
                  ? 'Guaranteed Cash on Delivery · Inspect upon arrival'
                  : 'Safe & Direct Author Support · Instant Unlock'}
              </span>
            </div>

            {/* Submit button */}
            <button
              type="submit"
              disabled={isProcessing}
              className={`flex w-full min-h-[48px] items-center justify-center gap-2 rounded-xl px-4 py-3 text-sm font-bold shadow-lg transition-transform active:scale-[0.98] disabled:opacity-50 ${
                paymentMethod === 'cod'
                  ? 'bg-gradient-to-r from-emerald-500 to-teal-400 text-slate-950 shadow-emerald-500/20 hover:brightness-105'
                  : 'bg-gradient-to-r from-amber-500 to-amber-400 text-slate-950 shadow-amber-500/20 hover:brightness-105'
              }`}
            >
              {isProcessing ? (
                <span>Confirming Order...</span>
              ) : paymentMethod === 'cod' ? (
                <>
                  <Truck className="h-4 w-4" />
                  <span>Place Cash on Delivery Order (₹{story.price.toFixed(2)})</span>
                </>
              ) : (
                <>
                  <Lock className="h-4 w-4" />
                  <span>Pay ₹{story.price.toFixed(2)} &amp; Unlock Full Book</span>
                </>
              )}
            </button>
          </form>
        )}
      </div>
    </div>
  );
};
