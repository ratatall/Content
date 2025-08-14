# AI Storywriter Assistant - Copilot Instructions

<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

This is a Flutter AI Storywriter Assistant app that helps authors develop compelling stories. The app integrates with OpenAI API for content generation and uses Firebase Firestore for data persistence.

## Project Structure
- Focus on clean architecture with separate layers for UI, business logic, and data
- Use provider pattern for state management
- Implement proper error handling for API calls
- Follow Flutter best practices for widget composition

## Key Features
- Character Development: Generate detailed character profiles with editable templates
- World Building: Create rich story settings through guided questionnaires  
- Scene Planning: Maintain narrative consistency across scenes
- Story Ideas: Generate creative writing prompts with genre/tone customization
- Project Management: Handle multiple writing projects with tagging system

## Technical Requirements
- OpenAI API integration for text generation
- Firebase Firestore for data persistence
- Offline caching capabilities
- Responsive UI design
- Form validation and user input handling

## Code Style
- Use meaningful variable and function names related to storytelling concepts
- Comment complex prompt engineering logic
- Implement proper loading states for API calls
- Handle edge cases for network connectivity
