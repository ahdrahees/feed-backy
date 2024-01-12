# Feedbacky Project

## Overview

- **Service for Brands**: The feedback project is a platform where brands can gain insights into how their products are perceived by users. Brands can add their existing products to the application and generate questions related to those products using AI. The feedback from users is then evaluated by AI.

- **User Interaction**: Users who have experience with these products can provide their feedback by answering the questions. This feedback is valuable data for brands because it comes directly from their product users. By providing feedback, users can earn points based on the AI's evaluation.

- **Feedback Utilization**: The feedback received can be analyzed by the brands to understand the perception of their products among users. This understanding can guide brands in making various decisions like product improvements, price adjustments, or other modifications. In essence, it functions like a survey tool.

- **Business Cycle**: The first 100 feedbacks received by a brand are free. After that, the brand needs to pay for the service. This creates a business cycle benefiting all parties involved. The brand gets valuable user feedback, the feedback canister application gets paid for providing the service, and users can receive rewards for providing genuine feedback.

- **Rewards for Users**: Users are incentivized to provide genuine feedback as they can receive rewards. This ensures a steady flow of valuable feedback for the brands.

- **Google AI Studio Integration**: An interesting feature of this application is the use of Google AI Studio (Gemini Pro Model) for generating questions and verifying the authenticity of the feedback. This ensures that the questions are relevant and the feedback received is genuine.

This project, therefore, serves as a comprehensive feedback system for brands, helping them understand their users better and make informed decisions. It also rewards users for their participation, ensuring a win-win situation for all parties involved.

### Prerequisites

Before you begin, ensure you have met the following requirements:

- **dfx**: You have installed the latest version of the DFINITY Canister SDK, `dfx`. You can download it from the DFINITY SDK page.

- **Node.js**: You have installed Node.js, version 18 or above. You can download it from the Node.js website.

- **mops**: You have installed `mops`. If not, you can install it using npm by running the command `npm install -g mops`.

- **Google AI Studio**: The project uses Google AI Studio for generating questions and verifying feedback authenticity. The model used is `Gemini Pro`. You can get an API Key from [Google AI Studio](https://makersuite.google.com/) for free. If it is difficult to get the API key, feel free to use this API key `AIzaSyB5sOCEeMiu4ZrWyAA6MwziuS-DX2tHr6U`.

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
`npm i`
`dfx start --background --clean`

Once you've created a project and installed dependencies with `npm install` (or `pnpm install` or `yarn`), start a development server:

**Installing Motoko Packages**: Run the following command to install Motoko Packages:
 ```
    mops install
 ```

**Deploy the Local Internet Identity**: Run the following command to deploy the local Internet Identity:
```
    npm run localii
```
**Deploy the Local ICP Ledger Canister**: Run the following command to deploy the ICP Ledger Caniter locally and this script will mint 100 Local ICP tokens to your default identity:
```
    npm run localicpledger
```
**Deploy the Backend**: Run the following command to to deploy the backend locally.
```
    dfx deploy backend
```

**Deploy the Frontend**: Run the following command to to deploy the frontend locally.
```
dfx deploy frontend
```

**Rename the .env.devlopment.example & .env.production.example**: Rename the `.env.devlopment.example` to `.env.devlopment`. And rename & `.env.production.example` to `.env.production` if you are deploying in mainnet.

**Update .env.development**: After deploying the backend and frontend, you will receive a canister ID. Copy this ID and paste it in the `.env.development` file and also copy & paste the API key from Google Studio AI. If you deploying in mainnet update the .env.production before deploying the front-end.

Please ensure all these steps are followed correctly for the proper setup of the development environment.

To start vite server open a new terminal tab in the same directory and run the following command:

```bash
npm run dev

# or start the server and open the app in a new browser tab
npm run dev -- --open
```
## How to interact with this application locally:

You can interact with application locally in two ways feel free to follow one of them:
1. Using vite server. You can copy the vite local server url in the `npm run dev` terminal tab and interact through browser.
2. Using frontend canister. follow this url `http://YOUR_FRONTEND_CANISTER_ID.localhost:8080` replace the `YOUR_FRONTEND_CANISTER_ID` with your frontend canister ID in the url (If necessary replace the port number in the url with your local instance of the Internet Computer running port number in case you are not able to access frontend canister locally).

## How to transfer ICP Local token:
100 ICP Local token minted by the local ICP ledger canister will be available in the account of your `default` identity.
To use default Identity :
```
dfx identity use default
```
To check balance of ICP Local tokens in default identity:
```
dfx ledger balance
```
To get your ICP local address in the default identity :
```
dfx ledger account-id
```
To check balance of ICP Local tokens of any address :
```
dfx ledger balance <ADDRESS>
```
To transfer ICP to other address:
```
dfx ledger transfer --amount <AMOUNT> <ADDRESS> --memo 0
```

## Building

To create a production version of your app:

```bash
npm run build
```

You can preview the production build with `npm run preview`.

