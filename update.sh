#!/bin/bash

set -euo pipefail

# Se placer dans le dossier du script, quel que soit le cwd appelant
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DATA_DIR="$SCRIPT_DIR/data"

# Date actuelle
current_date=$(date +"%Y-%m-%d")

# Choisit une ligne au hasard dans un fichier (portable, sans shuf)
pick_line() {
  local file="$1"
  local line
  local lines=()

  if [ ! -f "$file" ]; then
    echo ""
    return 0
  fi

  while IFS= read -r line; do
    [ -n "$line" ] && lines+=("$line")
  done < "$file"

  if [ "${#lines[@]}" -eq 0 ]; then
    echo ""
    return 0
  fi

  printf '%s\n' "${lines[$((RANDOM % ${#lines[@]}))]}"
}

# Tirage aléatoire : une citation ou un fait du jour
if (( RANDOM % 2 == 0 )); then
  selected="$(pick_line "$DATA_DIR/citations_fr.txt")"
  quote_title="📚 **Le mot du jour**"
  quote_text="« ${selected} »"
else
  selected="$(pick_line "$DATA_DIR/faits_fr.txt")"
  quote_title="🧠 **Le saviez-vous ?**"
  quote_text="${selected}"
fi

# Repli si les listes sont vides ou absentes
if [ -z "$selected" ]; then
  quote_title="🧠 **Le saviez-vous ?**"
  quote_text="Il reste toujours quelque chose à apprendre."
fi

# Contenu mis à jour
output="👋 Salut, je suis @BigSethCode
                                        
👀 Je suis intéressé par le DevOps, la programmation en Python et le C basique. J'aime aussi la robotique.

🌱 Je suis actuellement en train d'apprendre React...

📫 Vous pouvez me contacter à hdtseth@gmail.com...

💞️ Je cherche à collaborer sur (Humm)...

${quote_title}

> ${quote_text}

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
  git commit -m "Update: Bio ${current_date}"
  git push origin main
  echo "Bio mise à jour avec succès dans Git"
fi
