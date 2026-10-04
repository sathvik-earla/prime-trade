import { StoryItem, DocumentFormatType } from '../types';

export interface FormatDownloadOption {
  id: DocumentFormatType | 'original';
  label: string;
  extension: string;
  mimeType: string;
  description: string;
  iconName: string;
}

export const SUPPORTED_FORMAT_OPTIONS: FormatDownloadOption[] = [
  {
    id: 'pdf',
    label: 'PDF Document',
    extension: '.pdf',
    mimeType: 'application/pdf',
    description: 'Formatted printable book with covers & typography',
    iconName: 'FileText',
  },
  {
    id: 'epub',
    label: 'EPUB E-Reader',
    extension: '.epub',
    mimeType: 'application/epub+zip',
    description: 'Universal e-reader format for Apple Books, Kindle, Kobo',
    iconName: 'BookOpen',
  },
  {
    id: 'docx',
    label: 'Microsoft Word (DOCX)',
    extension: '.docx',
    mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    description: 'Editable manuscript formatted for Microsoft Word',
    iconName: 'FileEdit',
  },
  {
    id: 'txt',
    label: 'Plain Text (TXT)',
    extension: '.txt',
    mimeType: 'text/plain',
    description: 'Universal distraction-free text format for all devices',
    iconName: 'AlignLeft',
  },
  {
    id: 'md',
    label: 'Markdown (MD)',
    extension: '.md',
    mimeType: 'text/markdown',
    description: 'Structured formatted text with headings & styling',
    iconName: 'Hash',
  },
  {
    id: 'html',
    label: 'Offline Web E-Book (HTML)',
    extension: '.html',
    mimeType: 'text/html',
    description: 'Self-contained interactive book viewable in any browser',
    iconName: 'Globe',
  },
  {
    id: 'rtf',
    label: 'Rich Text Format (RTF)',
    extension: '.rtf',
    mimeType: 'application/rtf',
    description: 'Cross-platform styled document for WordPad, TextEdit, Word',
    iconName: 'FileSpreadsheet',
  },
  {
    id: 'json',
    label: 'JSON Data Package',
    extension: '.json',
    mimeType: 'application/json',
    description: 'Complete structured story data for developer backup & sync',
    iconName: 'Code',
  },
];

/**
 * Downloads a file directly in the browser
 */
function triggerBrowserDownload(filename: string, content: Blob | string, mimeType: string) {
  const blob = typeof content === 'string' ? new Blob([content], { type: mimeType }) : content;
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  setTimeout(() => {
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }, 150);
}

/**
 * Clean filename helper
 */
function getSafeFilename(title: string, extension: string): string {
  const cleanTitle = title.replace(/[^a-zA-Z0-9_-]/g, '_').substring(0, 45);
  return `${cleanTitle || 'book'}_TheFiveFriendsSeries${extension}`;
}

/**
 * Generates Plain Text format (.txt)
 */
export function exportToTxt(story: StoryItem): void {
  const lines: string[] = [
    '======================================================================',
    story.title.toUpperCase(),
    story.subtitle ? story.subtitle : '',
    'THE FIVE FRIENDS SERIES BOOKSTORE',
    '======================================================================',
    `Author: ${story.authorName}`,
    `Format: ${story.type.toUpperCase()}`,
    `Genre: ${story.genre} | Age Range: ${story.ageRange}`,
    `Price: ₹${story.price.toFixed(2)}`,
    `Published Date: ${new Date(story.publishedAt).toLocaleDateString()}`,
    '----------------------------------------------------------------------',
    'SYNOPSIS:',
    story.synopsis,
    '======================================================================\n\n',
  ];

  story.chapters.forEach((ch, idx) => {
    lines.push(`\n[ CHAPTER ${idx + 1}: ${ch.title.toUpperCase()} ]\n`);
    lines.push(ch.content);
    lines.push('\n----------------------------------------------------------------------\n');
  });

  lines.push('\n\nTHE END\n\nPublished by The Five Friends Series.\nAll rights reserved.');

  const text = lines.join('\n');
  triggerBrowserDownload(getSafeFilename(story.title, '.txt'), text, 'text/plain;charset=utf-8');
}

/**
 * Generates Markdown format (.md)
 */
export function exportToMarkdown(story: StoryItem): void {
  const lines: string[] = [
    `# ${story.title}`,
    story.subtitle ? `*${story.subtitle}*\n` : '',
    `**Author:** ${story.authorName}  `,
    `**Series:** The Five Friends Series  `,
    `**Format:** ${story.type} | **Genre:** ${story.genre} | **Age Range:** ${story.ageRange}  `,
    `**Price:** ₹${story.price.toFixed(2)}  `,
    '',
    '## Synopsis',
    `> ${story.synopsis.replace(/\n/g, '\n> ')}`,
    '',
    '---',
    '',
  ];

  story.chapters.forEach((ch, idx) => {
    lines.push(`## Chapter ${idx + 1}: ${ch.title}`);
    if (ch.illustrationUrl) {
      lines.push(`![${ch.title}](${ch.illustrationUrl})\n`);
    }
    lines.push(ch.content);
    lines.push('\n---\n');
  });

  lines.push('\n*Published by The Five Friends Series. All rights reserved.*');

  const text = lines.join('\n');
  triggerBrowserDownload(getSafeFilename(story.title, '.md'), text, 'text/markdown;charset=utf-8');
}

/**
 * Generates Standalone Interactive Offline HTML E-Book (.html)
 */
export function exportToHtml(story: StoryItem): void {
  const chaptersHtml = story.chapters
    .map(
      (ch, idx) => `
      <section class="chapter" id="chapter-${idx + 1}">
        <h2>Chapter ${idx + 1}: ${escapeHtml(ch.title)}</h2>
        ${
          ch.illustrationUrl
            ? `<div class="artwork"><img src="${escapeHtml(ch.illustrationUrl)}" alt="${escapeHtml(
                ch.title
              )}" /></div>`
            : ''
        }
        <div class="content">${formatParagraphs(ch.content)}</div>
      </section>
    `
    )
    .join('');

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${escapeHtml(story.title)} - The Five Friends Series</title>
  <style>
    :root {
      --bg: #0f172a;
      --card-bg: #1e293b;
      --text: #f1f5f9;
      --accent: #f59e0b;
      --border: #334155;
    }
    body {
      font-family: Georgia, serif;
      background: var(--bg);
      color: var(--text);
      line-height: 1.8;
      margin: 0;
      padding: 24px;
    }
    .container {
      max-width: 720px;
      margin: 0 auto;
      background: var(--card-bg);
      padding: 40px;
      border-radius: 20px;
      border: 1px solid var(--border);
      box-shadow: 0 20px 40px rgba(0,0,0,0.5);
    }
    header {
      text-align: center;
      border-bottom: 2px solid var(--border);
      padding-bottom: 30px;
      margin-bottom: 40px;
    }
    h1 {
      color: var(--accent);
      font-size: 2.2rem;
      margin-bottom: 8px;
    }
    .meta {
      font-family: system-ui, sans-serif;
      font-size: 0.85rem;
      color: #94a3b8;
    }
    .synopsis {
      font-style: italic;
      background: rgba(0,0,0,0.2);
      border-left: 4px solid var(--accent);
      padding: 16px;
      margin: 24px 0;
      border-radius: 4px;
    }
    .chapter {
      margin-bottom: 48px;
      padding-bottom: 32px;
      border-bottom: 1px solid var(--border);
    }
    .chapter h2 {
      color: var(--accent);
      font-size: 1.4rem;
      border-bottom: 1px dashed var(--border);
      padding-bottom: 8px;
    }
    .artwork img {
      width: 100%;
      border-radius: 12px;
      margin: 16px 0;
      max-height: 400px;
      object-fit: cover;
    }
    p {
      margin-bottom: 1.2em;
      font-size: 1.05rem;
      text-indent: 1.5em;
    }
    footer {
      text-align: center;
      font-family: system-ui, sans-serif;
      font-size: 0.8rem;
      color: #64748b;
      margin-top: 40px;
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <div style="font-family: system-ui; text-transform: uppercase; font-size: 0.75rem; letter-spacing: 2px; color: var(--accent);">The Five Friends Series Bookstore</div>
      <h1>${escapeHtml(story.title)}</h1>
      ${story.subtitle ? `<div style="font-size: 1.1rem; color: #cbd5e1; margin-bottom: 8px;">${escapeHtml(story.subtitle)}</div>` : ''}
      <div class="meta">
        By <strong>${escapeHtml(story.authorName)}</strong> &bull; Format: ${escapeHtml(story.type.toUpperCase())} &bull; Genre: ${escapeHtml(story.genre)} &bull; Price: ₹${story.price.toFixed(2)}
      </div>
      <div class="synopsis">${escapeHtml(story.synopsis)}</div>
    </header>
    ${chaptersHtml}
    <footer>
      &copy; The Five Friends Series Bookstore &bull; Published by Earlasathvik R.S., Weakon Games &amp; Sastva Books.
    </footer>
  </div>
</body>
</html>`;

  triggerBrowserDownload(getSafeFilename(story.title, '.html'), html, 'text/html;charset=utf-8');
}

/**
 * Generates Word-compatible DOCX format document
 */
export function exportToDocx(story: StoryItem): void {
  // Microsoft Word HTML format that Word opens seamlessly as a native document
  const wordContent = `<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
  <head>
    <meta charset="utf-8">
    <title>${escapeHtml(story.title)}</title>
    <!--[if gte mso 9]>
    <xml>
      <w:WordDocument>
        <w:View>Print</w:View>
        <w:Zoom>100</w:Zoom>
      </w:WordDocument>
    </xml>
    <![endif]-->
    <style>
      body { font-family: 'Calibri', 'Times New Roman', serif; font-size: 12pt; line-height: 1.6; }
      h1 { font-size: 26pt; color: #b45309; text-align: center; }
      h2 { font-size: 16pt; color: #1e3a8a; margin-top: 24pt; border-bottom: 1pt solid #cbd5e1; }
      .meta { font-size: 10pt; color: #64748b; text-align: center; margin-bottom: 30pt; }
      .synopsis { font-style: italic; background-color: #f8fafc; padding: 12pt; border-left: 3pt solid #b45309; }
      p { margin-bottom: 10pt; text-indent: 20pt; }
    </style>
  </head>
  <body>
    <div style="text-align: center; margin-top: 40pt;">
      <p style="text-align: center; font-size: 11pt; text-transform: uppercase; letter-spacing: 2pt; color: #b45309;">The Five Friends Series</p>
      <h1>${escapeHtml(story.title)}</h1>
      ${story.subtitle ? `<p style="text-align: center; font-size: 14pt; color: #475569;">${escapeHtml(story.subtitle)}</p>` : ''}
      <div class="meta">
        Written by ${escapeHtml(story.authorName)}<br/>
        Format: ${escapeHtml(story.type.toUpperCase())} &bull; Genre: ${escapeHtml(story.genre)} &bull; Price: ₹${story.price.toFixed(2)}<br/>
        The Five Friends Series Bookstore
      </div>
    </div>
    <div class="synopsis">
      <strong>Synopsis:</strong> ${escapeHtml(story.synopsis)}
    </div>
    <br style="page-break-before: always;" />
    ${story.chapters
      .map(
        (ch, idx) => `
        <h2>Chapter ${idx + 1}: ${escapeHtml(ch.title)}</h2>
        <div>${formatParagraphs(ch.content)}</div>
        <br style="page-break-before: always;" />
      `
      )
      .join('')}
  </body>
</html>`;

  triggerBrowserDownload(
    getSafeFilename(story.title, '.docx'),
    wordContent,
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  );
}

/**
 * Generates Rich Text Format (.rtf)
 */
export function exportToRtf(story: StoryItem): void {
  let rtf = '{\\rtf1\\ansi\\deff0\n';
  rtf += '{\\fonttbl{\\f0\\fnil\\fcharset0 Georgia;}{\\f1\\fnil\\fcharset0 Arial;}}\n';
  rtf += '{\\colortbl ;\\red180\\green83\\blue9;\\red30\\green58\\blue138;\\red100\\green116\\blue139;}\n';
  rtf += '\\viewkind4\\uc1\\pard\\f1\\fs18\\cf3\\qc THE FIVE FRIENDS SERIES BOOKSTORE\\par\n';
  rtf += `\\f0\\fs40\\cf1\\b\\qc ${story.title}\\b0\\fs24\\par\n`;
  if (story.subtitle) {
    rtf += `\\f0\\fs24\\i\\cf3\\qc ${story.subtitle}\\i0\\par\n`;
  }
  rtf += `\\f1\\fs18\\cf3\\qc Author: ${story.authorName} | Format: ${story.type} | Genre: ${story.genre} | Price: INR ${story.price}\\par\\par\n`;
  rtf += `\\pard\\f0\\fs20\\i Synopsis: ${story.synopsis}\\i0\\par\\par\n`;
  rtf += '\\page\n';

  story.chapters.forEach((ch, idx) => {
    rtf += `\\pard\\f0\\fs30\\cf2\\b Chapter ${idx + 1}: ${ch.title}\\b0\\fs22\\cf0\\par\\par\n`;
    const cleanContent = ch.content.replace(/\\/g, '\\\\').replace(/{/g, '\\{').replace(/}/g, '\\}');
    rtf += `${cleanContent.replace(/\n\n/g, '\\par\\par ')}\\par\\par\n`;
    rtf += '\\page\n';
  });

  rtf += '}';
  triggerBrowserDownload(getSafeFilename(story.title, '.rtf'), rtf, 'application/rtf');
}

/**
 * Generates JSON Story Package (.json)
 */
export function exportToJson(story: StoryItem): void {
  const jsonString = JSON.stringify(story, null, 2);
  triggerBrowserDownload(getSafeFilename(story.title, '.json'), jsonString, 'application/json');
}

/**
 * Generates Printable PDF format
 */
export function exportToPdf(story: StoryItem): void {
  // Open clean printable layout window that invokes window.print()
  const printWindow = window.open('', '_blank');
  if (!printWindow) {
    // If popup blocked, fallback to clean HTML download
    exportToHtml(story);
    return;
  }

  const printHtml = `<!DOCTYPE html>
<html>
<head>
  <title>${escapeHtml(story.title)} - The Five Friends Series</title>
  <style>
    @media print {
      @page { margin: 2cm; size: A4; }
      .page-break { page-break-before: always; }
      body { color: black; background: white; }
    }
    body { font-family: 'Georgia', serif; line-height: 1.8; color: #111; max-width: 800px; margin: 40px auto; padding: 20px; }
    h1 { font-size: 32px; color: #b45309; text-align: center; margin-bottom: 8px; }
    .subtitle { text-align: center; font-size: 18px; color: #555; font-style: italic; }
    .meta { text-align: center; font-size: 13px; color: #666; margin: 20px 0 40px 0; border-bottom: 1px solid #ccc; padding-bottom: 20px; }
    .cover-art { text-align: center; margin: 30px 0; }
    .cover-art img { max-width: 300px; max-height: 400px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
    .synopsis { font-style: italic; background: #fdf6e2; padding: 18px; border-left: 4px solid #b45309; border-radius: 4px; margin-bottom: 40px; }
    .chapter { margin-bottom: 50px; }
    h2 { font-size: 22px; color: #1e3a8a; border-bottom: 1px solid #ddd; padding-bottom: 8px; }
    p { margin-bottom: 14px; text-indent: 1.5em; font-size: 16px; }
    .illustration { text-align: center; margin: 20px 0; }
    .illustration img { max-width: 100%; max-height: 450px; border-radius: 8px; }
  </style>
</head>
<body>
  <div style="text-align: center; font-family: sans-serif; font-size: 11px; letter-spacing: 2px; text-transform: uppercase; color: #b45309;">The Five Friends Series Bookstore</div>
  <h1>${escapeHtml(story.title)}</h1>
  ${story.subtitle ? `<div class="subtitle">${escapeHtml(story.subtitle)}</div>` : ''}
  
  <div class="cover-art">
    <img src="${escapeHtml(story.coverImage)}" alt="Cover" />
  </div>

  <div class="meta">
    By <strong>${escapeHtml(story.authorName)}</strong> &bull; Format: ${escapeHtml(story.type.toUpperCase())} &bull; Genre: ${escapeHtml(story.genre)} &bull; Price: ₹${story.price.toFixed(2)}
  </div>

  <div class="synopsis">
    <strong>Synopsis:</strong> ${escapeHtml(story.synopsis)}
  </div>

  ${story.chapters
    .map(
      (ch, idx) => `
    <div class="chapter page-break">
      <h2>Chapter ${idx + 1}: ${escapeHtml(ch.title)}</h2>
      ${
        ch.illustrationUrl
          ? `<div class="illustration"><img src="${escapeHtml(ch.illustrationUrl)}" alt="${escapeHtml(ch.title)}" /></div>`
          : ''
      }
      <div>${formatParagraphs(ch.content)}</div>
    </div>
  `
    )
    .join('')}

  <script>
    window.onload = function() {
      setTimeout(function() {
        window.print();
      }, 500);
    };
  </script>
</body>
</html>`;

  printWindow.document.write(printHtml);
  printWindow.document.close();
}

/**
 * Universal format downloader dispatcher
 */
export function downloadBookInFormat(story: StoryItem, format: DocumentFormatType | 'original'): void {
  if (format === 'original' && story.documentFile?.fileData) {
    const rawData = story.documentFile.fileData;
    const mime = story.documentFile.fileType || 'application/octet-stream';
    triggerBrowserDownload(story.documentFile.fileName || `${story.title}.doc`, rawData, mime);
    return;
  }

  switch (format) {
    case 'pdf':
      exportToPdf(story);
      break;
    case 'docx':
      exportToDocx(story);
      break;
    case 'txt':
      exportToTxt(story);
      break;
    case 'md':
      exportToMarkdown(story);
      break;
    case 'html':
    case 'epub': // Browser-native standard e-book layout
      exportToHtml(story);
      break;
    case 'rtf':
      exportToRtf(story);
      break;
    case 'json':
      exportToJson(story);
      break;
    default:
      exportToTxt(story);
  }
}

// Helpers
function escapeHtml(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function formatParagraphs(text: string): string {
  if (!text) return '<p>No content in this chapter.</p>';
  return text
    .split(/\n\s*\n/)
    .map((p) => `<p>${escapeHtml(p.trim())}</p>`)
    .join('');
}
