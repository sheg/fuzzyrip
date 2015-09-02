require 'pry'

desc "populate players"
task populate_players: :environment do
  Player.destroy_all
  PlayerPick.destroy_all
  populate_picks
end

def populate_picks
  players = File.readlines("players_rob.txt").map { |line| line.gsub("\n", '') }.reject { |x| x == '' }
  sign_into_fuzzy
  populate_player_picks players
end

def populate_player_picks(players)
  ids = get_league_ids
  # ids = (3806..3908).to_a

  ids.each do |id|
    navigate_to_draft_results id
    puts "League id: #{id}"

    players.each do |name|
      pick = get_pick(name)

      if pick.round.nil?
        next
      end

      position_id = Position.find_by(name: pick.position).id
      player = Player.find_or_create_by(name: name, position_id: position_id)
      formatted_pick = format_pick pick.round
      pick = Pick.find_or_create_by(round: pick.round, total: formatted_pick)

      puts pick.inspect

      PlayerPick.create(player_id: player.id, pick_id: pick.id)
      puts "populating player: #{name} - #{pick.round}"
    end
  end

  puts "n = #{ids.length}"
end

def sign_into_fuzzy
  @driver = Watir::Browser.new :phantomjs
  @driver.goto("http://fuzzyfantasyfootball.com")
  @driver.text_field(:name => 'Email').set("fuzzyris80@gmail.com")
  @driver.text_field(:name => 'Password').set("asdqwe")
  @driver.button(:class => 'loginSubmit').click
  sleep 2
end

def get_league_ids
  types = [25,50,75,100,150,250,500,1000]
  league_ids = []

  types.each do |type|
    sleep 1
    @driver.goto("http://fuzzyfantasyfootball.com/members/publicleagues.php?action=#{type}&order=7")
    # @driver.goto("http://fuzzyfantasyfootball.com/members/mockdrafts.php")

    rows = @driver.table(:css => "table[width='99%']").rows.find_all do |row|
      puts "searching #{row.text}"
      row[5].text == "Flex 9" && row[3].text.match(/12/)
    end

    league_ids << rows.map { |row| row[1].link.attribute_value("href").match(/.*=(\d+)/)[1] }
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
    position = nil
  else
    match = matched_row[0].split(" ")
    pick = match.last

    position = (Position::POSITION_TYPES - (Position::POSITION_TYPES - match)).first
  end
  RippedPick.new(pick, position)
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

class RippedPick

  attr_accessor :round, :position

  def initialize(pick, position)
    self.round = pick
    self.position = position
  end
end