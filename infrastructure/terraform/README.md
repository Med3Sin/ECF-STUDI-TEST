# Infrastructure Terraform - YourMedia

Ce répertoire contient la configuration Terraform pour déployer l'infrastructure de l'application YourMedia sur AWS.

## Prérequis

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.0.0)
- [AWS CLI](https://aws.amazon.com/cli/) configuré avec vos credentials
- Un compte AWS avec les permissions nécessaires

## Structure du projet

```
infrastructure/terraform/
├── modules/
│   ├── networking/    # Configuration réseau (VPC, sous-réseaux, etc.)
│   ├── compute/       # Configuration des instances EC2
│   ├── database/      # Configuration de la base de données RDS
│   └── storage/       # Configuration du stockage S3
├── main.tf           # Configuration principale
├── variables.tf      # Définition des variables
├── outputs.tf        # Sorties de l'infrastructure
├── terraform.tfvars.example  # Exemple de variables
└── .gitignore       # Fichiers à ignorer
```

## Configuration

1. Copiez le fichier d'exemple des variables :
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Modifiez le fichier `terraform.tfvars` avec vos valeurs :
   - Région AWS
   - Environnement (development, production)
   - Configuration réseau
   - Identifiants de base de données

## Déploiement

1. Initialisez Terraform :
   ```bash
   terraform init
   ```

2. Vérifiez le plan de déploiement :
   ```bash
   terraform plan
   ```

3. Appliquez la configuration :
   ```bash
   terraform apply
   ```

## Destruction de l'infrastructure

Pour supprimer l'infrastructure :
```bash
terraform destroy
```

## Sécurité

- Ne jamais commiter le fichier `terraform.tfvars` dans Git
- Utiliser des mots de passe forts pour la base de données
- En production, utiliser AWS Secrets Manager pour les secrets
- Vérifier régulièrement les logs CloudWatch

## Monitoring

L'infrastructure inclut :
- Dashboard CloudWatch pour le monitoring
- Alertes SNS pour les seuils critiques
- Métriques pour EC2, RDS, et S3

## Support

Pour toute question ou problème, contacter l'équipe DevOps. 