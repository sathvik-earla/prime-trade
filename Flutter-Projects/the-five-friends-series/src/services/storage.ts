import { StoryItem, Review, PurchaseRecord, DocumentAttachment } from '../types';
import { SEED_STORIES } from '../data/seedStories';

// Using v3 storage key to ensure previously cached demo books are cleared
const STORAGE_KEY_STORIES = 'fivefriends_store_books_v3';
const STORAGE_KEY_BOOKMARKS = 'fivefriends_user_bookmarks_v3';
const STORAGE_KEY_LIKES = 'fivefriends_user_likes_v3';
const STORAGE_KEY_PROGRESS = 'fivefriends_reading_progress_v3';
const STORAGE_KEY_PURCHASES = 'fivefriends_user_purchases_v3';
const STORAGE_KEY_TRANSACTIONS = 'fivefriends_all_transactions_v3';

export function getStories(): StoryItem[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY_STORIES);
    if (!raw) {
      localStorage.setItem(STORAGE_KEY_STORIES, JSON.stringify(SEED_STORIES));
      return SEED_STORIES;
    }
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : SEED_STORIES;
  } catch {
    return SEED_STORIES;
  }
}

export function saveStories(stories: StoryItem[]): void {
  localStorage.setItem(STORAGE_KEY_STORIES, JSON.stringify(stories));
}

export function saveOrUpdateStory(story: StoryItem): void {
  const current = getStories();
  const index = current.findIndex((s) => s.id === story.id);
  if (index >= 0) {
    current[index] = story;
  } else {
    current.unshift(story);
  }
  saveStories(current);
}

export function deleteStory(id: string): void {
  const current = getStories();
  const filtered = current.filter((s) => s.id !== id);
  saveStories(filtered);
}

export function clearAllBooks(): void {
  localStorage.setItem(STORAGE_KEY_STORIES, JSON.stringify([]));
}

export function resetToSeedStories(): void {
  clearAllBooks();
}

// Purchases & Selling
export function getUserPurchases(): string[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY_PURCHASES);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

export function isStoryPurchased(storyId: string, price: number): boolean {
  if (price <= 0) return true; // Free book
  const list = getUserPurchases();
  return list.includes(storyId);
}

export function completePurchase(
  storyId: string,
  buyerEmail = 'customer@example.com',
  paymentMethod: 'card' | 'apple_google' | 'cod' = 'apple_google',
  deliveryAddress?: import('../types').DeliveryAddress
): PurchaseRecord | null {
  const stories = getStories();
  const story = stories.find((s) => s.id === storyId);
  if (!story) return null;

  // Add to user purchased list (instantly unlocks digital reader access as well)
  const userPurchases = getUserPurchases();
  if (!userPurchases.includes(storyId)) {
    userPurchases.push(storyId);
    localStorage.setItem(STORAGE_KEY_PURCHASES, JSON.stringify(userPurchases));
  }

  // Update story sales & revenue stats
  story.stats.purchases = (story.stats.purchases || 0) + 1;
  story.stats.revenue = Number(((story.stats.revenue || 0) + (story.price || 0)).toFixed(2));
  saveStories(stories);

  // Record transaction for owner dashboard
  const transaction: PurchaseRecord = {
    id: 'tx-' + Date.now(),
    storyId,
    storyTitle: story.title,
    amount: story.price || 0,
    date: new Date().toISOString(),
    buyerEmail,
    transactionId: (paymentMethod === 'cod' ? 'COD-' : 'ORD-') + Math.random().toString(36).substring(2, 9).toUpperCase(),
    paymentMethod,
    deliveryAddress,
    deliveryStatus: paymentMethod === 'cod' ? 'pending_dispatch' : undefined,
  };

  const allTx = getAllTransactions();
  allTx.unshift(transaction);
  localStorage.setItem(STORAGE_KEY_TRANSACTIONS, JSON.stringify(allTx));

  return transaction;
}

export function updateDeliveryStatus(
  transactionId: string,
  status: 'pending_dispatch' | 'dispatched' | 'delivered'
): void {
  const allTx = getAllTransactions();
  const tx = allTx.find((t) => t.transactionId === transactionId || t.id === transactionId);
  if (tx) {
    tx.deliveryStatus = status;
    localStorage.setItem(STORAGE_KEY_TRANSACTIONS, JSON.stringify(allTx));
  }
}

export function getAllTransactions(): PurchaseRecord[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY_TRANSACTIONS);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

export function getUserPurchaseRecords(): PurchaseRecord[] {
  const all = getAllTransactions();
  const purchasedIds = getUserPurchases();
  return all.filter((t) => purchasedIds.includes(t.storyId));
}

// User interactions: Bookmarks
export function getBookmarks(): string[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY_BOOKMARKS);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

export function toggleBookmark(storyId: string): boolean {
  const list = getBookmarks();
  const exists = list.includes(storyId);
  const updated = exists ? list.filter((id) => id !== storyId) : [...list, storyId];
  localStorage.setItem(STORAGE_KEY_BOOKMARKS, JSON.stringify(updated));

  const stories = getStories();
  const story = stories.find((s) => s.id === storyId);
  if (story) {
    story.stats.bookmarks = Math.max(0, story.stats.bookmarks + (exists ? -1 : 1));
    saveStories(stories);
  }

  return !exists;
}

// User interactions: Likes
export function getLikes(): string[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY_LIKES);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

export function toggleLike(storyId: string): boolean {
  const list = getLikes();
  const exists = list.includes(storyId);
  const updated = exists ? list.filter((id) => id !== storyId) : [...list, storyId];
  localStorage.setItem(STORAGE_KEY_LIKES, JSON.stringify(updated));

  const stories = getStories();
  const story = stories.find((s) => s.id === storyId);
  if (story) {
    story.stats.likes = Math.max(0, story.stats.likes + (exists ? -1 : 1));
    saveStories(stories);
  }

  return !exists;
}

// Reading progress
export function getReadingProgress(): Record<string, { lastPage: number; updatedAt: string }> {
  try {
    const raw = localStorage.getItem(STORAGE_KEY_PROGRESS);
    return raw ? JSON.parse(raw) : {};
  } catch {
    return {};
  }
}

export function saveReadingProgress(storyId: string, pageNumber: number): void {
  const current = getReadingProgress();
  current[storyId] = {
    lastPage: pageNumber,
    updatedAt: new Date().toISOString(),
  };
  localStorage.setItem(STORAGE_KEY_PROGRESS, JSON.stringify(current));
}

// Increment reads counter
export function recordStoryRead(storyId: string): void {
  const stories = getStories();
  const story = stories.find((s) => s.id === storyId);
  if (story) {
    story.stats.reads += 1;
    saveStories(stories);
  }
}

// Add review
export function addStoryReview(storyId: string, review: Omit<Review, 'id' | 'date' | 'approved'>): void {
  const stories = getStories();
  const story = stories.find((s) => s.id === storyId);
  if (!story) return;

  const newReview: Review = {
    id: 'rev-' + Date.now(),
    date: new Date().toISOString().split('T')[0],
    approved: true,
    ...review,
  };

  story.reviews = [newReview, ...(story.reviews || [])];
  
  const totalRatings = story.reviews.reduce((acc, r) => acc + r.rating, 0);
  story.stats.ratingCount = story.reviews.length;
  story.stats.rating = Number((totalRatings / story.reviews.length).toFixed(1));

  saveStories(stories);
}

export function toggleReviewApproval(storyId: string, reviewId: string): void {
  const stories = getStories();
  const story = stories.find((s) => s.id === storyId);
  if (!story) return;

  const review = story.reviews.find((r) => r.id === reviewId);
  if (review) {
    review.approved = !review.approved;
    saveStories(stories);
  }
}

export function deleteReview(storyId: string, reviewId: string): void {
  const stories = getStories();
  const story = stories.find((s) => s.id === storyId);
  if (!story) return;

  story.reviews = story.reviews.filter((r) => r.id !== reviewId);
  if (story.reviews.length > 0) {
    const totalRatings = story.reviews.reduce((acc, r) => acc + r.rating, 0);
    story.stats.ratingCount = story.reviews.length;
    story.stats.rating = Number((totalRatings / story.reviews.length).toFixed(1));
  } else {
    story.stats.ratingCount = 0;
    story.stats.rating = 5.0;
  }
  saveStories(stories);
}

// Download attached document helper
export function downloadAttachedDocument(doc: DocumentAttachment, title: string): void {
  if (!doc.fileData) return;
  const link = document.createElement('a');
  link.href = doc.fileData;
  link.download = doc.fileName || `${title.replace(/\s+/g, '_')}.${doc.fileType || 'txt'}`;
  document.body.appendChild(link);
  link.click();
  link.remove();
}
