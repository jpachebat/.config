# Weekly Note-Taking System

A comprehensive note-taking workflow built around weekly planning and daily execution.

## Directory Structure

```
~/work/notes/
├── daily/              # Daily notes (YYYY-MM-DD.md)
│   ├── 2025-11-10.md
│   ├── 2025-11-11.md
│   └── ...
├── weekly/             # Weekly planning/review notes
│   ├── 2025-W46.md
│   ├── 2025-W47.md
│   └── ...
└── Templates/
    ├── daily.md        # Daily note template
    └── weekly.md       # Weekly note template
```

## Weekly Workflow

### 1. Start of Week (Sunday)
Press `<leader>Ow` to create/open this week's note.

**What happens:**
- Creates weekly note: `weekly/2025-WXX.md`
- Auto-generates 7 daily notes for the week in `daily/`
- Each daily note gets a unique philosophy quote
- Weekly note includes links to all daily notes

**Weekly note sections:**
- Weekly Objectives: 3-5 main goals for the week
- Daily Notes: Links to all 7 daily notes
- Weekly Planning: Focus areas (Research, Development, Admin)
- DEADLINE This Week: Time-sensitive items
- Weekly Review: Completed at end of week

### 2. During the Week
Use daily notes for day-to-day work:
- `<leader>Od` - Open today's note
- `<leader>Ot` - Open tomorrow's note
- `<leader>Oy` - Open yesterday's note

**Daily note sections:**
- Philosophy quote (auto-generated, unique per day)
- Tasks: Daily checklist
- Work Log: What you accomplished
- Quick Capture: Fleeting thoughts/ideas
- Perso: Personal items

### 3. End of Week (Saturday)
Return to weekly note and complete the review section:
- Wins: What went well
- Challenges: What was difficult
- Learnings: What you discovered
- Next Week Priorities: Carry-forward items

### 4. Planning Ahead
- `<leader>On` - Create/open next week's note
- `<leader>Op` - Open previous week's note (for reference)

## Keybindings

**Daily Notes:**
- `<leader>Od` - Today
- `<leader>Ot` - Tomorrow
- `<leader>Oy` - Yesterday

**Weekly Notes:**
- `<leader>Ow` - This week (auto-creates all 7 dailies)
- `<leader>On` - Next week (auto-creates all 7 dailies)
- `<leader>Op` - Previous week

**Note Management:**
- `<leader>ON` - New note
- `<leader>Os` - Search notes
- `<leader>Oq` - Quick switch
- `<leader>OT` - Insert template

## Philosophy Quotes

Each daily note gets a unique philosophy quote based on the date:
- 20 carefully curated quotes from philosophers
- Same date = same quote (consistent)
- Authors: Socrates, Aristotle, Nietzsche, Camus, Kant, Buddha, etc.

Example:
```markdown
> The unexamined life is not worth living.
> — Socrates
```

## Templates

### Daily Template
```markdown
# {{date}}

> {{quote}}
> — {{author}}

## Tasks
- [ ]

## Work Log


## Quick Capture


## Perso
```

### Weekly Template
```markdown
# Week {{week}} - {{year}} ({{start_date}} - {{end_date}})

## Weekly Objectives
- [ ]
- [ ]
- [ ]

## Daily Notes
{{daily_links}}

## Weekly Planning

### Focus Areas
- Research:
- Development:
- Admin:

### DEADLINE This Week


## Weekly Review (End of Week)

### Wins


### Challenges


### Learnings


### Next Week Priorities
```

## Migration from week/ to daily/

Your old daily notes are in `~/work/notes/week/`. To migrate:

```bash
# Manual migration (if you want to preserve old notes)
cd ~/work/notes
mv week/* daily/

# Or keep week/ as archive and start fresh in daily/
# (recommended - clean slate)
```

New daily notes will be created in `daily/` going forward.

## Week Numbering

- Weeks start on **Sunday**
- ISO week numbering (Week 1 = first week with Thursday in new year)
- Format: `YYYY-WNN` (e.g., `2025-W46`)

## Tips

1. **Start each week**: Press `<leader>Ow` on Sunday to plan
2. **Daily execution**: Use `<leader>Od` each morning
3. **End of week review**: Complete review section on Saturday
4. **Link freely**: Use `[[YYYY-MM-DD]]` to reference other days
5. **DEADLINE tracking**: Add DEADLINE items in weekly note for overview
6. **Migrate tasks**: Move incomplete tasks from daily → next day or weekly objectives

## Implementation Files

- `nvim/lua/neotex/obsidian/weekly.lua` - Week calculation utilities
- `nvim/lua/neotex/obsidian/weekly-commands.lua` - Note creation logic
- `nvim/lua/neotex/plugins/text/obsidian.lua` - Obsidian.nvim config
- `nvim/lua/neotex/plugins/editor/which-key.lua` - Keybindings
- `~/work/notes/Templates/daily.md` - Daily template
- `~/work/notes/Templates/weekly.md` - Weekly template
