#!/bin/bash

# Date de naissance
birth_date="2001-04-13"

# Date actuelle
current_date=$(date +"%Y-%m-%d")
current_year=$(date +"%Y")
current_month=$(date +"%m")
current_day=$(date +"%d")

# Extraire l'année, le mois et le jour de naissance
birth_year=${birth_date:0:4}
birth_month=${birth_date:5:2}
birth_day=${birth_date:8:2}

# Calcul de l'âge en années, mois et jours
years=$((current_year - birth_year))
months=$((current_month - birth_month))
days=$((current_day - birth_day))

if [ $days -lt 0 ]; then
  months=$((months - 1))
  days=$((days + 30)) # Approximatif pour gérer les jours
fi

if [ $months -lt 0 ]; then
  years=$((years - 1))
  months=$((months + 12))
fi

# Calcul des jours totaux depuis la naissance
birth_epoch=$(date -j -f "%Y-%m-%d" "$birth_date" "+%s")
current_epoch=$(date "+%s")
total_days=$(( (current_epoch - birth_epoch) / 86400 ))
total_minutes=$((total_days * 1440))
total_seconds=$((total_days * 86400))

# Génération d'un chiffre aléatoire entre 0 et 1000
random_number=$(jot -r 1 0 1000)

# Contenu mis à jour

output="👋 Salut, je suis @BigSethCode
                                        
👀 Je suis intéressé par le DevOps, la programmation en Python et le C basique. J'aime aussi la robotique.

🌱 Je suis actuellement en train d'apprendre React...

📫 Vous pouvez me contacter à hdtseth@gmail.com...

💞️ Je cherche à collaborer sur (Humm)...

Je suis né le 13 avril 2001 et Aujourd'hui j'ai exactement :

**${years} ans, ${months} mois et ${days} jours.**

Soit :

**${total_days} jours**  
**${total_minutes} minutes**  
**${total_seconds} secondes**

🎲 **Chiffre aléatoire du jour : ${random_number}**

"

# Écriture dans le fichier bio.md
# echo "$output" > bio.md
echo "$output" > README.md

echo "Date info ${current_date} "
echo "Bio mise à jour avec succès dans bio.md."

cd /Users/iamroot/Documents/work/BigSethCode
git add *
git commit -m "Update: Date  No : ${random_number}"
git push origin main

echo "Bio mise à jour avec succès dans Git"