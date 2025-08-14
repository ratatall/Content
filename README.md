# AI Storywriter Assistant

A Flutter application that helps authors develop compelling stories through AI-powered character development, world building, scene planning, and story idea generation.

## Features

### 🎭 Character Development (MVP Core)
- AI-powered character profile generation
- Detailed character templates with personality, backstory, motivations
- Editable character profiles with save functionality
- Character trait management and organization

### 🌍 World Building (Coming Soon)
- Rich story setting creation through guided questionnaires
- AI-generated world descriptions with geography, culture, politics
- Customizable world templates for different genres

### 🎬 Scene Planning (Coming Soon)
- Scene-by-scene plot development
- Narrative consistency maintenance
- Character action and dialogue suggestions

### 💡 Story Ideas (Coming Soon)
- Creative writing prompt generation
- Genre and tone customization
- Thematic exploration tools

### 📊 Project Management
- Multiple writing project support
- Tagging and organization system
- Offline caching for generated content

## Tech Stack

- **Framework**: Flutter
- **State Management**: Provider pattern
- **AI Integration**: OpenAI GPT-4o-mini API
- **Database**: Firebase Firestore
- **Local Storage**: SharedPreferences & Hive
- **Architecture**: Clean Architecture with feature-based organization

## Setup Instructions

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Firebase project
- OpenAI API key

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Firestore Database
   - Update `lib/firebase_options.dart` with your Firebase configuration

3. **OpenAI API Setup**
   - Get your API key from [OpenAI Platform](https://platform.openai.com/)
   - The app will prompt you to enter your API key on first use

4. **Run the app**
   ```bash
   flutter run
   ```

## Usage

### Character Development

1. **Open Character Development** from the dashboard
2. **Fill in the character form**:
   - Character name (required)
   - Role in story (required)
   - Genre selection (required)
   - Additional details (optional)
3. **Generate Character** using AI
4. **View and edit** generated character profiles

The app includes sophisticated AI prompt templates for character generation covering physical appearance, personality traits, backstory, motivations, skills, and character development potential.
