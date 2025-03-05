#!/bin/bash

# Couleurs pour la sortie
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Fonction pour afficher les messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Vérifier les prérequis
check_prerequisites() {
    print_message "Vérification des prérequis..."
    
    # Vérifier Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js n'est pas installé"
        exit 1
    fi
    
    # Vérifier npm
    if ! command -v npm &> /dev/null; then
        print_error "npm n'est pas installé"
        exit 1
    fi
    
    # Vérifier React Native CLI
    if ! command -v react-native &> /dev/null; then
        print_message "Installation de React Native CLI..."
        npm install -g react-native-cli
    fi
    
    print_message "Prérequis vérifiés avec succès"
}

# Installer les dépendances
install_dependencies() {
    print_message "Installation des dépendances..."
    npm install
    
    # Installer les pods pour iOS
    if [ "$(uname)" == "Darwin" ]; then
        print_message "Installation des pods iOS..."
        cd ios
        pod install
        cd ..
    fi
}

# Lancer les tests
run_tests() {
    print_message "Exécution des tests..."
    npm test
}

# Build Android
build_android() {
    print_message "Build de l'application Android..."
    cd android
    ./gradlew clean
    ./gradlew assembleDebug
    ./gradlew assembleRelease
    cd ..
}

# Build iOS
build_ios() {
    if [ "$(uname)" == "Darwin" ]; then
        print_message "Build de l'application iOS..."
        cd ios
        xcodebuild -workspace YourMedia.xcworkspace -scheme YourMedia -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.0' build
        cd ..
    else
        print_warning "Build iOS ignoré (nécessite macOS)"
    fi
}

# Nettoyer les builds
clean_builds() {
    print_message "Nettoyage des builds..."
    rm -rf android/app/build
    rm -rf ios/build
}

# Fonction principale
main() {
    print_message "Démarrage du processus de build..."
    
    # Vérifier les prérequis
    check_prerequisites
    
    # Installer les dépendances
    install_dependencies
    
    # Lancer les tests
    run_tests
    
    # Nettoyer les builds précédents
    clean_builds
    
    # Build Android
    build_android
    
    # Build iOS (si sur macOS)
    build_ios
    
    print_message "Build terminé avec succès!"
}

# Exécuter le script
main 