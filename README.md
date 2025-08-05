# 🌲 InterFor_shiny – Interventions forestières Saguenay (1910–2029)

**InterFor_shiny** est une application Shiny interactive permettant de visualiser les interventions forestières (ex. coupes, plantations, éclaircies) dans 4 unités d’aménagement du Saguenay, regroupées par périodes de 10 ans entre 1910 et 2029.

---

## 🔗 Lien vers l'application

👉 [Application en ligne sur shinyapps.io](https://hgesdrn.shinyapps.io/InterFor_shiny/)

---

## 🎯 Objectif

Cette application vise à explorer l’évolution spatiale et temporelle des interventions forestières réalisées dans 4 unités d’aménagement du Saguenay :

- 02371
- 02471
- 02571
- 02751

L’utilisateur peut :
- Sélectionner une période de 10 ans
- Choisir un type d’intervention (ex. CP, PL, EPC…)
- Visualiser les polygones sur une carte interactive
- Suivre l’évolution par territoire à l’aide d’un graphique `facet_wrap`

---

## 📂 Structure des données

Les données sont hébergées directement dans ce dépôt GitHub :
https://github.com/hgesdrn/InterFor_shiny



Chaque fichier `.qs` contient les polygones pour une période donnée.

---

## 🧪 Technologies utilisées

- R + Shiny
- Packages : `sf`, `leaflet`, `ggplot2`, `shinyWidgets`, `qs`, `dplyr`, `tidyr`
- Hébergement : [shinyapps.io](https://www.shinyapps.io)
- Automatisation : GitHub Actions

---

## 🚀 Déploiement automatique

Le déploiement de cette application est automatisé avec **GitHub Actions** à chaque mise à jour du dépôt `main`.

Fichier de configuration : `.github/workflows/deploy.yml`

Secrets GitHub utilisés :
- `SHINYAPPS_TOKEN`
- `SHINYAPPS_SECRET`

---

## 🖼️ Aperçu de l’application

![aperçu](https://user-images.githubusercontent.com/INSERT/SCREENSHOT.png)

> *(Tu peux remplacer ce lien avec une capture d’écran de ton app une fois qu’elle est en ligne)*

---

## 📅 Historique des interventions forestières

L’application couvre les types d’interventions suivants :

| Code     | Description                                 |
|----------|---------------------------------------------|
| CP       | Coupe partielle                             |
| CR       | Coupe de récupération                       |
| EPC      | Éclaircie précommerciale                    |
| PL       | Plantation                                  |
| CT-CPR   | Coupe protection régénératon & Coupe totale |

---

## 👤 Auteur

Développée par **Hugues Dorion** – 2025  
Université du Québec à Chicoutimi  
🌐 [GitHub](https://github.com/hgesdrn)

---

## 📄 Licence

Ce projet est sous licence MIT.  
