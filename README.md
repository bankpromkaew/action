<header>

# Bear Notes Clone

A beautiful, minimalist markdown note-taking app inspired by [Bear](https://bear.app/). Built with React and modern web technologies.

## ✨ Features

- **Clean, Bear-inspired interface** - Minimal design focused on writing
- **Live markdown preview** - See your formatted text as you type
- **Fast search** - Quickly find notes by title or content
- **Dark/Light themes** - Switch between themes with one click
- **Local storage** - All your notes are saved locally in your browser
- **Export notes** - Download your notes as markdown files
- **Responsive design** - Works great on desktop and mobile
- **Keyboard shortcuts** - Efficient note-taking workflow

## 🚀 Getting Started

### Prerequisites

- Node.js (v16 or higher)
- npm or yarn

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd bear-notes-clone
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm run dev
```

4. Open [http://localhost:3000](http://localhost:3000) in your browser

## 🎯 Usage

### Creating Notes
- Click the **+** button in the sidebar header
- Start typing to create your first note
- The note title is automatically extracted from the first line

### Organizing Notes
- Use the search bar to quickly find notes
- Notes are automatically sorted by last modified date
- Click on any note in the sidebar to open it

### Markdown Support
- Full GitHub Flavored Markdown support
- Live preview shows formatted text
- Toggle preview with the eye icon
- Supports tables, code blocks, lists, and more

### Themes
- Click the moon/sun icon to toggle between light and dark themes
- Your theme preference is automatically saved

### Exporting
- Click the download icon to export the current note as a markdown file

## 🛠️ Built With

- **React 18** - Modern React with hooks
- **Vite** - Fast build tool and dev server
- **React Markdown** - Markdown rendering
- **Lucide React** - Beautiful icons
- **date-fns** - Date formatting
- **CSS Variables** - Dynamic theming

## 🎨 Bear-Inspired Design

This app recreates the essential Bear experience:

- **Three-pane layout** - Sidebar, editor, and preview
- **Clean typography** - Readable fonts and proper spacing
- **Subtle animations** - Smooth transitions and hover effects
- **Intuitive navigation** - Easy note switching and search
- **Focus on writing** - Distraction-free editing experience

## 📱 Browser Support

Works in all modern browsers:
- Chrome/Chromium
- Firefox
- Safari
- Edge

## 💾 Data Storage

Notes are stored locally in your browser using localStorage. Your data:
- Stays private and secure
- Persists between sessions
- Is not sent to any external servers
- Can be exported as markdown files

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the beautiful [Bear](https://bear.app/) notes app
- Icons by [Lucide](https://lucide.dev/)
- Markdown parsing by [React Markdown](https://github.com/remarkjs/react-markdown)
