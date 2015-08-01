require 'pry'

desc "populate players"
task populate_players: :environment do
  PlayerPick.destroy_all
  populate_picks
end

def populate_picks
  players = File.readlines("players.txt").map { |line| line.gsub("\n", '') }.reject { |x| x == '' }
  sign_into_fuzzy
  populate_player_picks players
end

def populate_player_picks(players)
  # ids = get_league_ids
  ids = (3806..3900).to_a

  ids.each do |id|
    navigate_to_draft_results id
    puts "League id: #{id}"

    players.each do |name|
      player = Player.find_or_create_by(name: name)

      pick = get_pick(name)

      unless pick
        next
      end

      formatted_pick = format_pick pick
      pick = Pick.find_or_create_by(round: pick, total: formatted_pick)

      PlayerPick.create(player_id: player.id, pick_id: pick.id)
      puts "populating player: #{name} - #{pick.round}"
    end
  end

  puts "n = #{ids.length}"
end

def sign_into_fuzzy
  @driver = Watir::Browser.new :phantomjs
  @driver.goto("http://fuzzyfantasyfootball.com")
  @driver.text_field(:name => 'Email').set("forkoshd@gmail.com")
  @driver.text_field(:name => 'Password').set("rice8080")
  @driver.button(:class => 'loginSubmit').click
  sleep 2
end

def get_league_ids
  types = [25, 50]
  league_ids = []

  types.each do |type|
    # @driver.goto("http://fuzzyfantasyfootball.com/members/publicleagues.php?action=#{type}&dtype=1")
    @driver.goto("http://fuzzyfantasyfootball.com/members/mockdrafts.php")
    page_source = @driver.html
    league_ids.push(page_source.scan(/href=.*lid=(\d+)/).uniq)
  end
  league_ids.flatten
end

def navigate_to_draft_results(id)
  puts "http://fuzzyfantasyfootball.com/members/draftresults.php?entire=yes&lid=#{id}"
  @driver.goto("http://fuzzyfantasyfootball.com/members/draftresults.php?entire=yes&lid=#{id}")
end

def get_pick(name)
  begin
    matched_row = rows.select { |row| row.include? name }
  rescue
    matched_row = ''
  end

  if matched_row.empty? or matched_row[0].include? "$"
    pick = nil
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