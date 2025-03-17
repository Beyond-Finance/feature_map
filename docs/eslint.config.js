import js from '@eslint/js';
import prettierConfig from 'eslint-config-prettier';
import reactPlugin from 'eslint-plugin-react';
import reactHooksPlugin from 'eslint-plugin-react-hooks';
import prettierPlugin from 'eslint-plugin-prettier';

export default [
  js.configs.recommended,
  {
    files: ['**/*.{js,jsx}'],
    plugins: {
      react: reactPlugin,
      'react-hooks': reactHooksPlugin,
      prettier: prettierPlugin,
    },
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
      },
      globals: {
        document: 'readonly',
        navigator: 'readonly',
        window: 'readonly',
      },
    },
    settings: {
      react: {
        version: 'detect',
      },
    },
    rules: {
      ...reactPlugin.configs.recommended.rules,
      ...reactHooksPlugin.configs.recommended.rules,
      'prettier/prettier': 'error',
      'react/prop-types': 0, // Not implemented in this project
      'react/react-in-jsx-scope': 0, // Not required React >= 17,
      'no-unused-vars': [
        'error',
        {
          destructuredArrayIgnorePattern: '^_',
        },
      ],
    },
  },
  prettierConfig,
  {
    ignores: ['node_modules/**', 'dist/**', 'build/**'],
  },
];
