import React, { useState, useEffect } from 'react';
import { Plus, Search, Moon, Sun, Eye, EyeOff, Download, Trash2 } from 'lucide-react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { format, isToday, isYesterday } from 'date-fns';
import {
  getNotes,
  saveNotes,
  createNote,
  updateNote,
  deleteNote,
  extractTitle,
  extractPreview,
  searchNotes,
  getTheme,
  saveTheme
} from './utils/noteStorage';

function App() {
  const [notes, setNotes] = useState([]);
  const [activeNoteId, setActiveNoteId] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [showPreview, setShowPreview] = useState(true);
  const [theme, setTheme] = useState('light');

  // Load initial data
  useEffect(() => {
    const loadedNotes = getNotes();
    const loadedTheme = getTheme();
    
    setNotes(loadedNotes);
    setTheme(loadedTheme);
    
    // Set active note to first one if available
    if (loadedNotes.length > 0 && !activeNoteId) {
      setActiveNoteId(loadedNotes[0].id);
    }
    
    // Apply theme to document
    document.documentElement.setAttribute('data-theme', loadedTheme);
  }, []);

  // Save notes whenever notes change
  useEffect(() => {
    if (notes.length > 0) {
      saveNotes(notes);
    }
  }, [notes]);

  // Get active note
  const activeNote = notes.find(note => note.id === activeNoteId);

  // Get filtered notes based on search
  const filteredNotes = searchNotes(notes, searchTerm);

  // Create new note
  const handleCreateNote = () => {
    const newNote = createNote();
    const updatedNotes = [newNote, ...notes];
    setNotes(updatedNotes);
    setActiveNoteId(newNote.id);
    setSearchTerm(''); // Clear search when creating new note
  };

  // Update note content
  const handleUpdateNote = (content) => {
    if (!activeNote) return;
    
    const title = extractTitle(content);
    const updatedNotes = updateNote(notes, activeNote.id, { 
      content, 
      title 
    });
    setNotes(updatedNotes);
  };

  // Delete active note
  const handleDeleteNote = () => {
    if (!activeNote) return;
    
    const updatedNotes = deleteNote(notes, activeNote.id);
    setNotes(updatedNotes);
    
    // Set active note to next available note
    if (updatedNotes.length > 0) {
      setActiveNoteId(updatedNotes[0].id);
    } else {
      setActiveNoteId(null);
    }
  };

  // Toggle theme
  const handleToggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
    saveTheme(newTheme);
    document.documentElement.setAttribute('data-theme', newTheme);
  };

  // Export note as markdown
  const handleExportNote = () => {
    if (!activeNote) return;
    
    const blob = new Blob([activeNote.content], { type: 'text/markdown' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${activeNote.title}.md`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  // Format date for display
  const formatDate = (dateString) => {
    const date = new Date(dateString);
    
    if (isToday(date)) {
      return format(date, 'h:mm a');
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return format(date, 'MMM d');
    }
  };

  return (
    <div className="app">
      {/* Sidebar */}
      <div className="sidebar">
        <div className="sidebar-header">
          <h1 className="sidebar-title">Notes</h1>
          <div className="sidebar-actions">
            <button
              className="icon-button"
              onClick={handleToggleTheme}
              title={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
            >
              {theme === 'light' ? <Moon size={16} /> : <Sun size={16} />}
            </button>
            <button
              className="icon-button"
              onClick={handleCreateNote}
              title="Create new note"
            >
              <Plus size={16} />
            </button>
          </div>
        </div>

        <div className="search-container">
          <input
            type="text"
            className="search-input"
            placeholder="Search notes..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>

        <div className="notes-list">
          {filteredNotes.length === 0 ? (
            <div className="empty-state">
              <div className="empty-state-title">No notes found</div>
              <div className="empty-state-description">
                {searchTerm ? 'Try a different search term' : 'Create your first note to get started'}
              </div>
            </div>
          ) : (
            filteredNotes.map(note => (
              <button
                key={note.id}
                className={`note-item ${note.id === activeNoteId ? 'active' : ''}`}
                onClick={() => setActiveNoteId(note.id)}
              >
                <div className="note-title">{note.title}</div>
                <div className="note-preview">{extractPreview(note.content)}</div>
                <div className="note-date">{formatDate(note.updatedAt)}</div>
              </button>
            ))
          )}
        </div>
      </div>

      {/* Main Content */}
      <div className="main-content">
        {activeNote ? (
          <>
            <div className="editor-header">
              <div className="editor-title">{activeNote.title}</div>
              <div className="editor-actions">
                <button
                  className="icon-button"
                  onClick={() => setShowPreview(!showPreview)}
                  title={showPreview ? 'Hide preview' : 'Show preview'}
                >
                  {showPreview ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
                <button
                  className="icon-button"
                  onClick={handleExportNote}
                  title="Export as markdown"
                >
                  <Download size={16} />
                </button>
                <button
                  className="icon-button"
                  onClick={handleDeleteNote}
                  title="Delete note"
                >
                  <Trash2 size={16} />
                </button>
              </div>
            </div>

            <div className="editor-container">
              <div className="editor-panel">
                <textarea
                  className="editor-textarea"
                  value={activeNote.content}
                  onChange={(e) => handleUpdateNote(e.target.value)}
                  placeholder="Start writing your note..."
                  spellCheck={false}
                />
              </div>

              {showPreview && (
                <div className="preview-panel">
                  <div className="preview-content">
                    <ReactMarkdown remarkPlugins={[remarkGfm]}>
                      {activeNote.content || '*Start writing to see preview...*'}
                    </ReactMarkdown>
                  </div>
                </div>
              )}
            </div>
          </>
        ) : (
          <div className="empty-state">
            <div className="empty-state-icon">
              <Search size={48} />
            </div>
            <div className="empty-state-title">Select a note to start editing</div>
            <div className="empty-state-description">
              Choose a note from the sidebar or create a new one to get started
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;