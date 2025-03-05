# YourMedia Mobile App

Une application React Native pour la gestion de médias.

## Prérequis

- Node.js (v14 ou supérieur)
- npm ou yarn
- React Native CLI
- Android Studio (pour le développement Android)
- Xcode (pour le développement iOS, macOS uniquement)

## Installation

1. Cloner le repository :
```bash
git clone [URL_DU_REPO]
cd yourmedia-mobile
```

2. Installer les dépendances :
```bash
npm install
# ou
yarn install
```

3. Installer les dépendances iOS (macOS uniquement) :
```bash
cd ios
pod install
cd ..
```

## Démarrage

1. Démarrer le serveur Metro :
```bash
npm start
# ou
yarn start
```

2. Lancer l'application sur Android :
```bash
npm run android
# ou
yarn android
```

3. Lancer l'application sur iOS (macOS uniquement) :
```bash
npm run ios
# ou
yarn ios
```

## Structure du Projet

```
yourmedia-mobile/
├── src/
│   ├── components/     # Composants réutilisables
│   ├── screens/        # Écrans de l'application
│   └── utils/          # Utilitaires et helpers
├── App.tsx            # Point d'entrée de l'application
├── package.json       # Dépendances et scripts
└── tsconfig.json      # Configuration TypeScript
```

## Fonctionnalités

- Interface utilisateur moderne et responsive
- Navigation entre les écrans
- Gestion des médias (photos et vidéos)
- Intégration avec l'API backend

## Tests

Lancer les tests :
```bash
npm test
# ou
yarn test
```

## Contribution

1. Fork le projet
2. Créer une branche pour votre fonctionnalité
3. Commit vos changements
4. Push vers la branche
5. Ouvrir une Pull Request 