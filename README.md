<img src="./.github/screenshots/header.png#gh-light-mode-only" width="100%" alt="Header light mode"/>
<img src="./.github/screenshots/header-dark.png#gh-dark-mode-only" width="100%" alt="Header dark mode"/>

___

# Kirvano

The modern customer support platform, an open-source alternative to Intercom, Zendesk, Salesforce Service Cloud etc.

<p>
  <a href="https://codeclimate.com/github/kirvano/kirvano/maintainability"><img src="https://api.codeclimate.com/v1/badges/e6e3f66332c91e5a4c0c/maintainability" alt="Maintainability"></a>
  <img src="https://img.shields.io/circleci/build/github/kirvano/kirvano" alt="CircleCI Badge">
    <a href="https://hub.docker.com/r/kirvano/kirvano/"><img src="https://img.shields.io/docker/pulls/kirvano/kirvano" alt="Docker Pull Badge"></a>
  <a href="https://hub.docker.com/r/kirvano/kirvano/"><img src="https://img.shields.io/docker/cloud/build/kirvano/kirvano" alt="Docker Build Badge"></a>
  <img src="https://img.shields.io/github/commit-activity/m/kirvano/kirvano" alt="Commits-per-month">
  <a title="Crowdin" target="_self" href="https://kirvano.crowdin.com/kirvano"><img src="https://badges.crowdin.net/e/37ced7eba411064bd792feb3b7a28b16/localized.svg"></a>
  <a href="https://discord.gg/cJXdrwS"><img src="https://img.shields.io/discord/647412545203994635" alt="Discord"></a>
  <a href="https://status.kirvano.com"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fkirvano%2Fstatus%2Fmaster%2Fapi%2Fkirvano%2Fuptime.json" alt="uptime"></a>
  <a href="https://status.kirvano.com"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fkirvano%2Fstatus%2Fmaster%2Fapi%2Fkirvano%2Fresponse-time.json" alt="response time"></a>
  <a href="https://artifacthub.io/packages/helm/kirvano/kirvano"><img src="https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/artifact-hub" alt="Artifact HUB"></a>
</p>


<p>
  <a href="https://heroku.com/deploy?template=https://github.com/kirvano/kirvano/tree/master" alt="Deploy to Heroku">
     <img width="150" alt="Deploy" src="https://www.herokucdn.com/deploy/button.svg"/>
  </a>
  <a href="https://marketplace.digitalocean.com/apps/kirvano?refcode=f2238426a2a8" alt="Deploy to DigitalOcean">
     <img width="200" alt="Deploy to DO" src="https://www.deploytodo.com/do-btn-blue.svg"/>
  </a>
</p>

<img src="./.github/screenshots/dashboard.png#gh-light-mode-only" width="100%" alt="Chat dashboard dark mode"/>
<img src="./.github/screenshots/dashboard-dark.png#gh-dark-mode-only" width="100%" alt="Chat dashboard"/>

---

Kirvano is the modern, open-source, and self-hosted customer support platform designed to help businesses deliver exceptional customer support experience. Built for scale and flexibility, Kirvano gives you full control over your customer data while providing powerful tools to manage conversations across channels.

### ✨ Captain – AI Agent for Support

Supercharge your support with Captain, Kirvano’s AI agent. Captain helps automate responses, handle common queries, and reduce agent workload—ensuring customers get instant, accurate answers. With Captain, your team can focus on complex conversations while routine questions are resolved automatically. Read more about Captain [here](https://chwt.app/captain-docs).

### 💬 Omnichannel Support Desk

Kirvano centralizes all customer conversations into one powerful inbox, no matter where your customers reach out from. It supports live chat on your website, email, Facebook, Instagram, Twitter, WhatsApp, Telegram, Line, SMS etc.

### 📚 Help center portal

Publish help articles, FAQs, and guides through the built-in Help Center Portal. Enable customers to find answers on their own, reduce repetitive queries, and keep your support team focused on more complex issues.

### 🗂️ Other features

#### Collaboration & Productivity

- Private Notes and @mentions for internal team discussions.
- Labels to organize and categorize conversations.
- Keyboard Shortcuts and a Command Bar for quick navigation.
- Canned Responses to reply faster to frequently asked questions.
- Auto-Assignment to route conversations based on agent availability.
- Multi-lingual Support to serve customers in multiple languages.
- Custom Views and Filters for better inbox organization.
- Business Hours and Auto-Responders to manage response expectations.
- Teams and Automation tools for scaling support workflows.
- Agent Capacity Management to balance workload across the team.

#### Customer Data & Segmentation
- Contact Management with profiles and interaction history.
- Contact Segments and Notes for targeted communication.
- Campaigns to proactively engage customers.
- Custom Attributes for storing additional customer data.
- Pre-Chat Forms to collect user information before starting conversations.

#### Integrations
- Slack Integration to manage conversations directly from Slack.
- Dialogflow Integration for chatbot automation.
- Dashboard Apps to embed internal tools within Kirvano.
- Shopify Integration to view and manage customer orders right within Kirvano.
- Use Google Translate to translate messages from your customers in realtime.
- Create and manage Linear tickets within Kirvano.

#### Reports & Insights
- Live View of ongoing conversations for real-time monitoring.
- Conversation, Agent, Inbox, Label, and Team Reports for operational visibility.
- CSAT Reports to measure customer satisfaction.
- Downloadable Reports for offline analysis and reporting.


## Documentation

Detailed documentation is available at [kirvano.com/help-center](https://www.kirvano.com/help-center).

## Translation process

The translation process for Kirvano web and mobile app is managed at [https://translate.kirvano.com](https://translate.kirvano.com) using Crowdin. Please read the [translation guide](https://www.kirvano.com/docs/contributing/translating-kirvano-to-your-language) for contributing to Kirvano.

## Branching model

We use the [git-flow](https://nvie.com/posts/a-successful-git-branching-model/) branching model. The base branch is `develop`.
If you are looking for a stable version, please use the `master` or tags labelled as `v1.x.x`.

## Deployment

### Heroku one-click deploy

Deploying Kirvano to Heroku is a breeze. It's as simple as clicking this button:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/kirvano/kirvano/tree/master)

Follow this [link](https://www.kirvano.com/docs/environment-variables) to understand setting the correct environment variables for the app to work with all the features. There might be breakages if you do not set the relevant environment variables.


### DigitalOcean 1-Click Kubernetes deployment

Kirvano now supports 1-Click deployment to DigitalOcean as a kubernetes app.

<a href="https://marketplace.digitalocean.com/apps/kirvano?refcode=f2238426a2a8" alt="Deploy to DigitalOcean">
  <img width="200" alt="Deploy to DO" src="https://www.deploytodo.com/do-btn-blue.svg"/>
</a>

### Other deployment options

For other supported options, checkout our [deployment page](https://kirvano.com/deploy).

## Security

Looking to report a vulnerability? Please refer our [SECURITY.md](./SECURITY.md) file.

## Community

If you need help or just want to hang out, come, say hi on our [Discord](https://discord.gg/cJXdrwS) server.

## Contributors

Thanks goes to all these [wonderful people](https://www.kirvano.com/docs/contributors):

<a href="https://github.com/kirvano/kirvano/graphs/contributors"><img src="https://opencollective.com/kirvano/contributors.svg?width=890&button=false" /></a>


*Kirvano* &copy; 2017-2025, Kirvano Inc - Released under the MIT License.
