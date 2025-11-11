# Task Management Demo

## Format des tâches avec dates

### Exemples valides (avec - ou *):

- [ ] Faire le rapport @251120
* [ ] Appeler Jean @251120 14:30
- [ ] Review code @20251125
* [x] Meeting terminé @251115 10:00
- [ ] Déploiement prod @251230 23:59
* [ ] Lire le livre @260115

### Tâches sans dates (non détectées par TasksTelescope):

- [ ] Une tâche normale
- [ ] Autre chose à faire

## Utilisation:

1. **Créer une tâche avec date**:
   - `- [ ] Description @YYMMDD HH:MM` (tiret)
   - `* [ ] Description @YYMMDD HH:MM` (astérisque)
2. **Rechercher toutes les tâches**: `<leader>tk` (TasksTelescope)
3. **Anciennes DEADLINE** (doublon, à migrer): `DEADLINE 20251120`

## Migration DEADLINE → Tasks:

Avant:
```
DEADLINE 20251120 - Finir le projet
```

Après:
```
- [ ] Finir le projet @251120
```

## Features:

- ✓ Support YYMMDD et YYYYMMDD
- ✓ Heure optionnelle (HH:MM)
- ✓ Tri par date/heure
- ✓ Affichage relatif (today, +3d, -2d)
- ✓ Distingue tâches complétées [x] vs incomplètes [ ]
- ✓ Jump to task dans fichier
