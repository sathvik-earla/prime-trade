export interface OwnerUser {
  email: string;
  name: string;
  role: string;
  avatarColor: string;
}

export interface ReaderUser {
  id: string;
  name: string;
  email: string;
  avatarColor?: string;
  loginTime: string;
}

export interface Chapter {
  id: string;
  pageNumber: number;
  title: string;
  content: string;
  illustrationUrl?: string;
  audioNarration?: string;
  characterSpeech?: { speaker: string; text: string }[];
  choices?: { label: string; targetPage: number }[];
}

export interface Review {
  id: string;
  readerName: string;
  rating: number; // 1 - 5
  comment: string;
  date: string;
  approved: boolean;
}

export type DocumentFormatType =
  | 'pdf'
  | 'epub'
  | 'docx'
  | 'txt'
  | 'md'
  | 'html'
  | 'json'
  | 'rtf'
  | 'audio'
  | 'cbz';

export interface DocumentAttachment {
  fileName: string;
  fileSize: number; // in bytes
  fileType: string;
  formatType?: DocumentFormatType;
  fileData?: string; // base64 or text data
  uploadedAt: string;
}

export interface DeliveryAddress {
  fullName: string;
  phone: string;
  street: string;
  city: string;
  postalCode: string;
  notes?: string;
}

export interface PurchaseRecord {
  id: string;
  storyId: string;
  storyTitle: string;
  amount: number;
  date: string;
  buyerEmail?: string;
  transactionId: string;
  paymentMethod: 'card' | 'apple_google' | 'cod';
  deliveryAddress?: DeliveryAddress;
  deliveryStatus?: 'pending_dispatch' | 'dispatched' | 'delivered';
}

export type ContentType =
  | 'storybook'    // Illustrated Storybook (Full-color picture book)
  | 'novel'        // Novel & Multi-Chapter Book (Chapters, table of contents)
  | 'story'        // Short Story / Tale (Single-sitting narrative)
  | 'comic'        // Graphic Novel & Comic Book (Visual sequential art)
  | 'audiobook'    // Audiobook & Audio Story (Voice narrated audio experience)
  | 'poetry'       // Poetry & Verse Collection (Stanzas & poetic meter)
  | 'script'       // Drama, Play & Screenplay (Acts, scenes, character cues)
  | 'interactive'; // Interactive / Choice-based tale (Branching paths)

export type StoryGenre =
  | 'Fantasy'
  | 'Adventure'
  | 'Bedtime'
  | 'Sci-Fi'
  | 'Mythology'
  | 'Mystery'
  | 'Poetry'
  | 'Historical'
  | 'Comedy';

export type AgeRange = 'All Ages' | 'Children (4-8)' | 'Young Adult' | 'Adults';

export interface StoryItem {
  id: string;
  title: string;
  subtitle: string;
  synopsis: string;
  authorName: string;
  authorEmail: string;
  type: ContentType;
  genre: StoryGenre;
  ageRange: AgeRange;
  coverImage: string;
  price: number; // Price in INR (₹) e.g. 199, 299
  freeSamplePages: number; // How many pages non-buyers can read as a preview (default 1)
  documentFile?: DocumentAttachment; // The attached document file containing the story
  readingTimeMinutes: number;
  status: 'published' | 'draft';
  publishedAt: string;
  featured?: boolean;
  chapters: Chapter[];
  stats: {
    reads: number;
    likes: number;
    bookmarks: number;
    purchases: number;
    revenue: number;
    rating: number;
    ratingCount: number;
  };
  reviews: Review[];
}

export type ReaderTheme = 'light' | 'sepia' | 'dark' | 'night' | 'paper';
export type ReaderFont = 'serif' | 'sans' | 'dyslexic' | 'mono';
export type ReadingMode = 'paginated' | 'scroll' | 'audio' | 'spread';

export interface ReaderSettings {
  theme: ReaderTheme;
  font: ReaderFont;
  fontSize: number; // px
  readingMode: ReadingMode;
}
