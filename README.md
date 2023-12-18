# Feedback Project

## Overview

- **Service for Brands**: The feedback project is a platform where brands can gain insights into how their products are perceived by users. Brands can add their existing products to the application and generate questions related to those products.

- **User Interaction**: Users who have experience with these products can provide their feedback by answering the questions. This feedback is valuable data for the brands as it comes directly from the users of their products.

- **Feedback Utilization**: The feedback received can be analyzed by the brands to understand the perception of their products among users. This understanding can guide brands in making various decisions like product improvements, price adjustments, or other modifications. In essence, it functions like a survey tool.

- **Business Cycle**: The first 100 feedbacks received by a brand are free. After that, the brand needs to pay for the service. This creates a business cycle benefiting all parties involved. The brand gets valuable user feedback, the feedback canister application gets paid for providing the service, and users can receive rewards for providing genuine feedback.

- **Rewards for Users**: Users are incentivized to provide genuine feedback as they can receive rewards. This ensures a steady flow of valuable feedback for the brands.

- **Google AI Integration**: An interesting feature of this application is the use of Google AI for generating questions and verifying the authenticity of the feedback. This ensures that the questions are relevant and the feedback received is genuine.

This project, therefore, serves as a comprehensive feedback system for brands, helping them understand their users better and make informed decisions. It also rewards users for their participation, ensuring a win-win situation for all parties involved.

### Prerequisites

Before you begin, ensure you have met the following requirements:

- **dfx**: You have installed the latest version of the DFINITY Canister SDK, `dfx`. You can download it from the DFINITY SDK page.

- **Node.js**: You have installed Node.js, version 18 or above. You can download it from the Node.js website.

- **mops**: You have installed `mops`. If not, you can install it using npm by running the command `npm install -g mops`.

- **Google AI Studio**: The project uses Google AI Studio for generating questions and verifying feedback authenticity. The model used is `Gemini Pro`. You can access Google AI Studio at Maker Suite.

Please ensure all these prerequisites are met before proceeding with the setup of the project.

## Getting Started

To get a local copy up and running, follow these simple steps:

1. **Clone the repo**: Clone the repository to your local machine. You can do this by running the following command in your terminal:

    ```bash
    git clone https://github.com/ahdrahees/feed-backy.git
    ```

After cloning the repository, you can proceed with the development setup as described in the Development section.

### Developing

Begin by opening a terminal window.

 ### Step 1: Navigate into the folder containing the project's files and start a local instance of the Internet Computer with the command:

`cd feedbacky`
`dfx start --background`

Once you've created a project and installed dependencies with `npm install` (or `pnpm install` or `yarn`), start a development server:


**Deploy the Local Internet Identity**: Run the following command to deploy the local Internet Identity:

    ```bash
    npm run localii
    ```

**Deploy the Backend**: Follow the instructions in the backend README to deploy the backend.

**Deploy the Frontend**: Follow the instructions in the frontend README to deploy the frontend.

**Update .env.development**: After deploying the backend and frontend, you will receive a canister ID. Copy this ID and paste it in the `.env.development` file.

Please ensure all these steps are followed correctly for the proper setup of the development environment.

```bash
npm run dev

# or start the server and open the app in a new browser tab
npm run dev -- --open
```

## Building

To create a production version of your app:

```bash
npm run build
```

You can preview the production build with `npm run preview`.

