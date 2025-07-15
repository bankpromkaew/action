# Setting Up Next.js Web Version for Pronote App

## Current Situation
Your pronote app is currently a macOS Swift application, but you want to deploy to Vercel which requires a web application.

## Steps to Create Next.js Version

### 1. Create a new Next.js project
```bash
npx create-next-app@latest pronote-web --typescript --tailwind --eslint --app
cd pronote-web
```

### 2. Basic Vercel Configuration
Create `vercel.json`:
```json
{
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm install",
  "outputDirectory": ".next"
}
```

### 3. Required package.json structure
```json
{
  "name": "pronote-web",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  }
}
```

### 4. Project Structure for Vercel Detection
```
pronote-web/
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   └── globals.css
├── components/
├── public/
├── package.json
├── next.config.js
├── tailwind.config.js
└── tsconfig.json
```

### 5. Vercel Deployment
1. Connect your GitHub repo to Vercel
2. Set the root directory to your Next.js folder
3. Vercel will auto-detect the framework

## Features to Implement in Web Version
Based on your macOS app, you could create:
- Web-based note editor with markdown support
- Slash commands interface
- Formatting toolbar
- Command palette (Cmd+P)
- Real-time markdown preview
- Export/import functionality