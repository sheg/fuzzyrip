
desc "populate players"
task populate_players: :environment do
  populate_picks
end

def populate_picks
  players = ["Brady, Tom", "White, Roddy", "Bennett, Martell", "Boykin, Jarrett"]
  sign_into_fuzzy
  players.each do |player|
    puts "populating picks for: #{player}"
    populate_player_picks player
  end
end

def populate_player_picks(name)
  ids = get_league_ids
  picks = []
  formatted_picks = []

  ids.each do |id|
    navigate_to_draft_results id
    pick = get_pick(name)
    picks.push pick
    formatted_picks.push(format_pick pick)
    puts pick
  end
  stripped_picks = picks.reject { |pick| pick == "n/a" }
  stripped_formatted_picks = formatted_picks.reject { |pick| pick == "n/a" }
  Player.create(name: name, picks: stripped_picks, formatted_picks: stripped_formatted_picks)
  puts "n = #{stripped_picks.length}"
end

def sign_into_fuzzy
  @driver = Watir::Browser.new :phantomjs
  @driver.goto("http://fuzzyfantasyfootball.com")
  @driver.text_field(:name => 'Email').set("danforkosh@yahoo.com")
  @driver.text_field(:name => 'Password').set("rice8080")
  @driver.button(:class => 'loginSubmit').click
  sleep 2
end

def get_league_ids
  types = [25, 50]
  league_ids = []

  types.each do |type|
    @driver.goto("http://fuzzyfantasyfootball.com/members/publicleagues.php?action=#{type}&dtype=1")
    page_source = @driver.html
    league_ids.push(page_source.scan(/href=.*lid=(\d+)/).uniq)
  end
  league_ids.flatten
end

def navigate_to_draft_results(id)
  @driver.goto("http://fuzzyfantasyfootball.com/members/draftresults.php?entire=yes&lid=#{id}")
end

def get_pick(name)
  begin
    matched_row = rows.select { |row| row.include? name }
  rescue
    matched_row = ''
  end
  if matched_row.empty? or matched_row[0].include? "$"
    pick = "n/a"
  else
    pick = matched_row[0].split(" ").last
  end
  pick
end

def rows
  @driver.table(:index => 4).rows[1].text.split("\n")
end

def format_pick(pick)
  if pick == "n/a"
    formatted_pick = "n/a"
  else
    first, second = pick.split(".")
    formatted_pick = (first.to_i - 1)*12 + second.to_i
  end
  formatted_pick
end