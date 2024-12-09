# Feature Metrics Vite Application

When the feature map gem is installed within a particular codebase, developers can use the command line to generate a static HTML file (no server required) that can be opened in a browser and includes useful information about the features in the codebase. To support the creation of this file, we've decided to create a small Vite JS powered application within the feature map gem so we can design, develop and build this self contained HTML file using modern front end tooling.

## Prerequisites

Before running the application, ensure that you have the following installed:

- Node.js `v20.18.0`
- npm `10.8.2`

## Technologies Used

The front end docs application is built using the following technologies:

- [React](https://react.dev/): A JavaScript library for building user interfaces.
- [Vite](https://vite.dev/): A fast build tool and development server for modern web applications.
- [Tailwind CSS](https://tailwindcss.com/): A utility-first CSS framework for rapid UI development.

## Project Structure

The application has the following structure:

- `src/main.jsx`: The entry point of the application.
- `src/App.jsx`: The main component of the application.
- `src/components/`: Directory containing reusable components used in the application.
- `index.html`: The HTML template for the application.
- `package.json`: The project configuration and dependencies.
- `vite.config.js`: The Vite configuration file.
- `tailwind.config.js`: The Tailwind CSS configuration file.

```
featuremap
├── bin
│   └── featuremap
├── docs
│   ├── node_modules
│   ├── src
│   │   ├── components
│   │   │   ├── AbcSizeIcon.jsx
│   │   │   ├── CyclomaticComplexityIcon.jsx
│   │   │   ├── LinesOfCodeIcon.jsx
│   │   │   ├── FeatureTable.jsx
│   │   │   └── MetricCard.jsx
│   │   ├── data
│   │   │   └── sample_features.js
│   │   ├── scripts
│   │   │   └── app.js
│   │   ├── styles
│   │   │   └── app.css
│   │   ├── App.jsx
│   │   └── main.jsx
│   ├── build-plugin.js
│   ├── index.html
│   ├── package-lock.json
│   ├── package.json
│   ├── postcss.config.js
│   ├── README.md
│   ├── tailwind.config.js
│   └── vite.config.js
│   ├── .gitignore
├── lib
│   └── feature_map
│       ├── code_features
│       ├── doc_server.rb
│       ├── documentation_site.rb
│       ├── extension_loader.rb
│       ├── feature_assigner.rb
│       ├── feature_metrics_calculator.rb
│       ├── glob_cache.rb
│       ├── lines_of_code_calculator.rb
│       └── metrics_file.rb
└── README.md
```

## Getting Started

To get started with the application, follow these steps:

1. Navigate to the `docs` directory within the gem's codebase.

1. Install the project dependencies by running: `npm install`

1. Start the development server by running: `npm run dev`

1. Open your browser and visit `http://localhost:5173/` to see the application running (Vite uses port 5173 by default)


## Building for Production

To build the application for production and generate the static HTML file, run: `npm run build`

This will create an optimized and minified version of the application in the following directory: `lib/feature_map/private/docs/index.html`

## Viewing the Generated File

To preview the generated static HTML file, you can open in your finder and click to open the static file in your default browser. Additionally, Vite does provide a command to preview the built file: `npm run preview`


## Publication

This gem is integrated into other Beyond Finance applications directly via Github. Pushing out a pull request in this repo, getting it reviewed and approved, and merging the changes back to main are all that is needed to publish a new version of this gem and incorporate the changes into downstream applications.
