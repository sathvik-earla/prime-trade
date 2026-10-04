import { OwnerUser, ReaderUser } from '../types';

export const AUTHORIZED_OWNERS: Record<string, OwnerUser> = {
  'earlasathvik.rs@gmail.com': {
    email: 'earlasathvik.rs@gmail.com',
    name: 'Earlasathvik R.S.',
    role: 'Primary Owner & Senior Story Author',
    avatarColor: 'from-amber-600 to-rose-600',
  },
  'weakongames83@gmail.com': {
    email: 'weakongames83@gmail.com',
    name: 'Weakon Games',
    role: 'Co-Owner & Creative Storybook Director',
    avatarColor: 'from-cyan-600 to-indigo-600',
  },
  'sastva.book@gmail.com': {
    email: 'sastva.book@gmail.com',
    name: 'Sastva Books',
    role: 'Co-Owner & Literary Publishing Partner',
    avatarColor: 'from-emerald-600 to-teal-600',
  },
  'randomuser1234@gmail.com': {
    email: 'randomuser1234@gmail.com',
    name: 'Random User',
    role: 'Co-Owner & Publishing Associate',
    avatarColor: 'from-purple-600 to-pink-600',
  },
};

export const MASTER_PASSWORD = 'RTS590';

export const PUBLISHING_PHONE_NUMBERS = [
  { display: '+91 9398638545', tel: '+919398638545' },
  { display: '+91 85905 63007', tel: '+918590563007' },
];

export const PUBLISHING_CALL_TEXT = 'Call +91 9398638545 Or +91 85905 63007 for publishing a book';

const OWNER_SESSION_KEY = 'fablecraft_owner_session';
const READER_SESSION_KEY = 'fablecraft_reader_session';

/**
 * Strict password verification for Owner Access.
 * Owner access is locked with password RTS590.
 */
export function verifyOwnerPassword(
  passwordInput: string,
  selectedOwnerEmail = 'earlasathvik.rs@gmail.com'
): { success: boolean; owner?: OwnerUser; message?: string } {
  const cleanPassword = passwordInput.trim();

  if (!cleanPassword) {
    return {
      success: false,
      message: 'Please enter the administrator password to unlock owner access.',
    };
  }

  if (cleanPassword === MASTER_PASSWORD) {
    const targetEmail = selectedOwnerEmail.trim().toLowerCase();
    const owner = AUTHORIZED_OWNERS[targetEmail] || AUTHORIZED_OWNERS['earlasathvik.rs@gmail.com'];
    return {
      success: true,
      owner,
    };
  }

  return {
    success: false,
    message: 'Incorrect password. Owner access is locked.',
  };
}

/**
 * Backward compatible helper that verifies the password RTS590
 */
export function verifyByPasswordOrGmail(
  passwordInput: string,
  selectedOwnerEmail = 'earlasathvik.rs@gmail.com'
): {
  success: boolean;
  owner?: OwnerUser;
  message?: string;
  isPasswordMatch?: boolean;
} {
  const result = verifyOwnerPassword(passwordInput, selectedOwnerEmail);
  return {
    ...result,
    isPasswordMatch: result.success,
  };
}

export function verifyByPasswordOnly(
  password: string,
  ownerEmail = 'earlasathvik.rs@gmail.com'
): {
  success: boolean;
  owner?: OwnerUser;
  message?: string;
} {
  return verifyOwnerPassword(password, ownerEmail);
}

// -------------------------------------------------------------
// OWNER SESSION HELPERS
// -------------------------------------------------------------

export function getCurrentOwnerSession(): OwnerUser | null {
  try {
    const raw = localStorage.getItem(OWNER_SESSION_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    if (parsed && AUTHORIZED_OWNERS[parsed.email]) {
      return parsed;
    }
    return null;
  } catch {
    return null;
  }
}

export function setOwnerSession(owner: OwnerUser): void {
  localStorage.setItem(OWNER_SESSION_KEY, JSON.stringify(owner));
}

export function clearOwnerSession(): void {
  localStorage.removeItem(OWNER_SESSION_KEY);
}

// -------------------------------------------------------------
// READER SESSION HELPERS (Compulsory Login)
// -------------------------------------------------------------

export function getCurrentReaderSession(): ReaderUser | null {
  try {
    const raw = localStorage.getItem(READER_SESSION_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    if (parsed && parsed.email) {
      return parsed;
    }
    return null;
  } catch {
    return null;
  }
}

export function setReaderSession(reader: ReaderUser): void {
  localStorage.setItem(READER_SESSION_KEY, JSON.stringify(reader));
}

export function clearReaderSession(): void {
  localStorage.removeItem(READER_SESSION_KEY);
}

/**
 * Creates or logs in a reader with name and email
 */
export function loginReader(name: string, email: string): ReaderUser {
  const cleanName = name.trim() || 'Book Reader';
  const cleanEmail = email.trim().toLowerCase() || 'reader@fivefriends.com';
  
  const colors = [
    'from-amber-500 to-rose-500',
    'from-blue-500 to-indigo-600',
    'from-emerald-500 to-teal-600',
    'from-purple-500 to-pink-500',
  ];
  const avatarColor = colors[Math.abs(cleanEmail.split('').reduce((acc, c) => acc + c.charCodeAt(0), 0)) % colors.length];

  const reader: ReaderUser = {
    id: 'reader-' + Date.now(),
    name: cleanName,
    email: cleanEmail,
    avatarColor,
    loginTime: new Date().toISOString(),
  };

  setReaderSession(reader);
  return reader;
}
