#!/bin/bash

set -euo pipefail

# Date de naissance
birth_date="2001-04-13"

# Se placer dans le dossier du script, quel que soit le cwd appelant
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Date actuelle (10# évite l'interprétation octale de "08"/"09")
current_date=$(date +"%Y-%m-%d")
current_year=$(date +"%Y")
current_month=$((10#$(date +"%m")))
current_day=$((10#$(date +"%d")))

# Extraire l'année, le mois et le jour de naissance
birth_year=$((10#${birth_date:0:4}))
birth_month=$((10#${birth_date:5:2}))
birth_day=$((10#${birth_date:8:2}))

# Nombre de jours d'un mois donné (gère les années bissextiles)
days_in_month() {
  local y=$1 m=$2
  case $m in
    1|3|5|7|8|10|12) echo 31 ;;
    4|6|9|11) echo 30 ;;
    2)
      if (( y % 400 == 0 || (y % 4 == 0 && y % 100 != 0) )); then
        echo 29
      else
        echo 28
      fi
      ;;
    *) echo 0 ;;
  esac
}

# Calcul de l'âge en années, mois et jours
years=$((current_year - birth_year))
months=$((current_month - birth_month))
days=$((current_day - birth_day))

if (( days < 0 )); then
  months=$((months - 1))
  prev_month=$((current_month - 1))
  prev_month_year=$current_year
  if (( prev_month == 0 )); then
    prev_month=12
    prev_month_year=$((current_year - 1))
  fi
  days=$((days + $(days_in_month "$prev_month_year" "$prev_month")))
fi

if (( months < 0 )); then
  years=$((years - 1))
  months=$((months + 12))
fi

# Calcul des jours totaux depuis la naissance
case "$(uname -s)" in
  Darwin)
    birth_epoch=$(date -j -f "%Y-%m-%d" "$birth_date" "+%s")
    ;;
  *)
    birth_epoch=$(date -d "$birth_date" +%s)
    ;;
esac
current_epoch=$(date "+%s")
total_days=$(( (current_epoch - birth_epoch) / 86400 ))
total_minutes=$((total_days * 1440))
total_seconds=$((total_days * 86400))

# Génération d'un chiffre aléatoire entre 0 et 1000
case "$(uname -s)" in
  Darwin)
    random_number=$(jot -r 1 0 1000)
    ;;
  *)
    if command -v shuf >/dev/null 2>&1; then
      random_number=$(shuf -i 0-1000 -n 1)
    else
      random_number=$((RANDOM % 1001))
    fi
    ;;
esac

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

# Écriture dans le fichier README.md
echo "$output" > README.md

echo "Date info ${current_date} "
echo "Bio mise à jour avec succès dans README.md."

# Mode test : on n'effectue aucune opération Git
if [ "${NO_PUSH:-0}" = "1" ]; then
  echo "Mode test (NO_PUSH=1) : étapes Git ignorées."
  exit 0
fi

git add -A
if git diff --cached --quiet; then
  echo "Aucun changement à committer."
else
  git commit -m "Update: Date  No : ${random_number}"
  git push origin main
  echo "Bio mise à jour avec succès dans Git"
fi
