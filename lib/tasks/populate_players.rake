require 'pry'
require 'selenium-webdriver'

desc "populate players"
task populate_players: :environment do
  Player.destroy_all
  PlayerPick.destroy_all
  populate_picks
end

def populate_picks
  players = File.readlines("players.txt").map { |line| line.gsub("\n", '') }.reject { |x| x == '' }
  # players = players.in_groups_of(5)
  sign_into_fuzzy
  populate_player_picks players

  # Thread.new { populate_player_picks players[0] }
  # Thread.new { populate_player_picks players[1] }
end

def sign_into_fuzzy
  @driver = Selenium::WebDriver.for :chrome

  @driver.navigate.to "https://fuzzysfantasyfootball.com"
  @driver.manage.timeouts.implicit_wait = 5

  @driver.find_element(css: "input[name='Email']").send_keys "fuzzyris80@gmail.com"
  @driver.find_element(css: "input[name='Password']").send_keys "asdqwe"
  @driver.find_element(css: ".loginSubmit").click
  navigate_to_leagues_page
end

def filter_league_names
  rows = @driver.find_elements(css: "table[width='99%'] tr").select do |row|
    (row.text.include? "Flex 9") && (row.text.include? "12 /") &&
    (Date.parse(row.find_elements(css: "td")[8].text.lines.first.split("\n").first).to_time < Time.now)
  end

  rows = rows.drop(1)
  rows.map { |row| row.find_element(css: "a").text }
end

def navigate_to_leagues_page
  @driver.find_elements(css: "td a.headMenu")[2].click
  sleep 1
end

def populate_player_picks(players)
  league_sizes = ["$25", "$50", "$75", "$100", "$150"]

  league_sizes.each do |league_size|

    @driver.find_element(css: "a[title='#{league_size}']").click
    sleep 2

    filtered_league_names = filter_league_names

    filtered_league_names.each do |league_name|
      @driver.find_elements(css: "table[width='99%'] tr a").find { |league| league.text == league_name }.click
      @driver.find_elements(css: ".leagueMenu").find { |cell| cell.text == "Draft Results" }.click

      entire_draft_link = @driver.find_elements(css: "a.headMenu[href='/members/ldraftresults.php?entire=yes']")
      sleep 1
      entire_draft_link.first.click unless entire_draft_link.empty?
      sleep 3

      rows = @driver.find_elements(css: "table")[9].find_elements(css: "tr").drop(6)

      players.each do |name|
        begin
          matched_row = rows.select { |row| row.text.include? name }
        rescue
          matched_row = ''
        end

        if matched_row.empty? or matched_row[0].text.include? "$"
          pick = nil
          position = nil
        else
          match = matched_row[0].text.split(" ")
          pick = match.last

          position = (Position::POSITION_TYPES - (Position::POSITION_TYPES - match)).first
        end
        pick = RippedPick.new(pick, position)

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

      navigate_to_leagues_page
    end
  end
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