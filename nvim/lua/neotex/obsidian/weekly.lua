local M = {}

-- Get ISO week number (starting Sunday)
-- Returns: year, week_number, start_date, end_date
function M.get_week_info(offset)
  offset = offset or 0
  local current = os.time() + (offset * 7 * 24 * 60 * 60)
  local date = os.date("*t", current)

  -- Find Sunday of current week
  local day_of_week = date.wday - 1 -- 0 = Sunday
  local sunday = os.time(date) - (day_of_week * 24 * 60 * 60)

  -- Calculate week number (Sunday start)
  local sunday_date = os.date("*t", sunday)
  local jan1 = os.time({year = sunday_date.year, month = 1, day = 1, hour = 0})
  local jan1_wday = os.date("*t", jan1).wday - 1

  -- Days from Jan 1 to this Sunday
  local days_from_jan1 = math.floor((sunday - jan1) / (24 * 60 * 60))
  local week = math.floor((days_from_jan1 + jan1_wday) / 7) + 1

  -- Saturday is 6 days after Sunday
  local saturday = sunday + (6 * 24 * 60 * 60)

  return {
    year = sunday_date.year,
    week = week,
    sunday = os.date("%Y-%m-%d", sunday),
    saturday = os.date("%Y-%m-%d", saturday),
    sunday_ts = sunday,
    saturday_ts = saturday,
  }
end

-- Format week filename: YYYY-WNN.md
function M.get_week_filename(offset)
  local info = M.get_week_info(offset)
  return string.format("%d-W%02d.md", info.year, info.week)
end

-- Get all daily note dates for a week
function M.get_week_dailies(offset)
  local info = M.get_week_info(offset)
  local dailies = {}
  local days = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}

  for i = 0, 6 do
    local ts = info.sunday_ts + (i * 24 * 60 * 60)
    table.insert(dailies, {
      date = os.date("%Y-%m-%d", ts),
      day = days[i + 1],
    })
  end

  return dailies
end

-- German philosophy quotes (in German) for daily notes
-- Kant, Nietzsche, Heidegger, Schopenhauer, Wittgenstein, Hegel, Arendt
local quotes = {
  {"Sapere aude! Habe Mut, dich deines eigenen Verstandes zu bedienen!", "Kant"},
  {"Wer mit Ungeheuern kämpft, mag zusehn, dass er nicht dabei zum Ungeheuer wird.", "Nietzsche"},
  {"Wovon man nicht sprechen kann, darüber muss man schweigen.", "Wittgenstein"},
  {"Die Grenzen meiner Sprache bedeuten die Grenzen meiner Welt.", "Wittgenstein"},
  {"Ohne Musik wäre das Leben ein Irrtum.", "Nietzsche"},
  {"Handle so, dass du die Menschheit sowohl in deiner Person, als in der Person eines jeden andern jederzeit zugleich als Zweck, niemals bloß als Mittel brauchst.", "Kant"},
  {"Die Welt ist alles, was der Fall ist.", "Wittgenstein"},
  {"Man muss noch Chaos in sich haben, um einen tanzenden Stern gebären zu können.", "Nietzsche"},
  {"Der Mensch kann zwar tun, was er will, aber er kann nicht wollen, was er will.", "Schopenhauer"},
  {"Die Aufgabe ist nicht sowohl zu sehen, was noch keiner gesehen hat, als bei dem, was jeder sieht, zu denken, was noch keiner gedacht hat.", "Schopenhauer"},
  {"Was vernünftig ist, das ist wirklich; und was wirklich ist, das ist vernünftig.", "Hegel"},
  {"Das Denken ist nicht ein Mittel zum Erkennen. Das Denken bringt das Sein erst zur Vollendung.", "Heidegger"},
  {"Es gibt immer etwas Wahnsinn in der Liebe. Es gibt aber auch immer etwas Vernunft im Wahnsinn.", "Nietzsche"},
  {"Der Einzelne hat immer zu kämpfen, um nicht von der Masse verschlungen zu werden.", "Nietzsche"},
  {"Bei Einzelnen ist Wahnsinn selten, aber in Gruppen, Parteien, Völkern, Zeiten die Regel.", "Nietzsche"},
  {"Was mich nicht umbringt, macht mich stärker.", "Nietzsche"},
  {"Wir verzichten auf drei Viertel unserer selbst, um den übrigen Menschen ähnlich zu sein.", "Schopenhauer"},
  {"Jeder Mensch verwechselt die Grenzen seines Gesichtsfelds mit den Grenzen der Welt.", "Schopenhauer"},
  {"Die Eule der Minerva beginnt erst mit der einbrechenden Dämmerung ihren Flug.", "Hegel"},
  {"Das Sein zum Tode ist wesenhaft Angst.", "Heidegger"},
  {"Dass ich erkenne, was die Welt im Innersten zusammenhält.", "Goethe"},
  {"Der kategorische Imperativ ist also nur ein einziger, und zwar dieser: Handle nur nach derjenigen Maxime, durch die du zugleich wollen kannst, dass sie ein allgemeines Gesetz werde.", "Kant"},
  {"Gott ist tot! Gott bleibt tot! Und wir haben ihn getötet!", "Nietzsche"},
  {"Die Sprache ist das Haus des Seins.", "Heidegger"},
  {"Gedanken ohne Inhalt sind leer, Anschauungen ohne Begriffe sind blind.", "Kant"},
  {"Wer sich selbst beherrscht, ist frei.", "Epiktet"},
  {"Das Leben ist nicht Sein, sondern Werden.", "Schopenhauer"},
  {"Die Philosophie ist ein Kampf gegen die Verhexung unsres Verstandes durch die Mittel unserer Sprache.", "Wittgenstein"},
  {"In der Tat ist es ein Wagnis zu denken.", "Arendt"},
  {"Alles Wirkliche ist vernünftig, und alles Vernünftige ist wirklich.", "Hegel"},
}

function M.get_daily_quote(date)
  -- Use date as seed for consistent quote per day
  local year, month, day = date:match("(%d+)-(%d+)-(%d+)")
  local seed = tonumber(year) * 10000 + tonumber(month) * 100 + tonumber(day)
  local index = (seed % #quotes) + 1
  return quotes[index]
end

return M
