// Note storage utilities using localStorage

const STORAGE_KEY = 'bear-notes-clone-data';

// Generate unique ID
export const generateId = () => {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
};

// Get all notes from localStorage
export const getNotes = () => {
  try {
    const data = localStorage.getItem(STORAGE_KEY);
    return data ? JSON.parse(data).notes || [] : [];
  } catch (error) {
    console.error('Error loading notes:', error);
    return [];
  }
};

// Save notes to localStorage
export const saveNotes = (notes) => {
  try {
    const data = { notes, lastUpdated: new Date().toISOString() };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
    return true;
  } catch (error) {
    console.error('Error saving notes:', error);
    return false;
  }
};

// Create a new note
export const createNote = (title = 'Untitled Note', content = '') => {
  const note = {
    id: generateId(),
    title: title || 'Untitled Note',
    content,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    tags: []
  };
  return note;
};

// Update an existing note
export const updateNote = (notes, noteId, updates) => {
  return notes.map(note => 
    note.id === noteId 
      ? { ...note, ...updates, updatedAt: new Date().toISOString() }
      : note
  );
};

// Delete a note
export const deleteNote = (notes, noteId) => {
  return notes.filter(note => note.id !== noteId);
};

// Extract title from content (first line)
export const extractTitle = (content) => {
  if (!content) return 'Untitled Note';
  
  const lines = content.trim().split('\n');
  const firstLine = lines[0].trim();
  
  // Remove markdown formatting from title
  const title = firstLine
    .replace(/^#+\s*/, '') // Remove markdown headers
    .replace(/\*\*(.*?)\*\*/g, '$1') // Remove bold
    .replace(/\*(.*?)\*/g, '$1') // Remove italic
    .replace(/`(.*?)`/g, '$1') // Remove code
    .trim();
    
  return title || 'Untitled Note';
};

// Extract preview text from content
export const extractPreview = (content, maxLength = 100) => {
  if (!content) return '';
  
  // Remove markdown formatting for preview
  const plainText = content
    .replace(/^#+\s*/gm, '') // Remove headers
    .replace(/\*\*(.*?)\*\*/g, '$1') // Remove bold
    .replace(/\*(.*?)\*/g, '$1') // Remove italic
    .replace(/`(.*?)`/g, '$1') // Remove inline code
    .replace(/```[\s\S]*?```/g, '[Code Block]') // Replace code blocks
    .replace(/!\[.*?\]\(.*?\)/g, '[Image]') // Replace images
    .replace(/\[.*?\]\(.*?\)/g, '[Link]') // Replace links
    .replace(/^\s*[-*+]\s+/gm, '') // Remove list markers
    .replace(/^\s*\d+\.\s+/gm, '') // Remove numbered list markers
    .replace(/^\s*>\s+/gm, '') // Remove blockquotes
    .replace(/\n+/g, ' ') // Replace newlines with spaces
    .trim();
    
  return plainText.length > maxLength 
    ? plainText.substring(0, maxLength) + '...'
    : plainText;
};

// Search notes
export const searchNotes = (notes, searchTerm) => {
  if (!searchTerm.trim()) return notes;
  
  const term = searchTerm.toLowerCase();
  
  return notes.filter(note => {
    const title = note.title.toLowerCase();
    const content = note.content.toLowerCase();
    const tags = note.tags.join(' ').toLowerCase();
    
    return title.includes(term) || 
           content.includes(term) || 
           tags.includes(term);
  });
};

// Get theme from localStorage
export const getTheme = () => {
  try {
    return localStorage.getItem('bear-notes-theme') || 'light';
  } catch {
    return 'light';
  }
};

// Save theme to localStorage
export const saveTheme = (theme) => {
  try {
    localStorage.setItem('bear-notes-theme', theme);
    return true;
  } catch {
    return false;
  }
};