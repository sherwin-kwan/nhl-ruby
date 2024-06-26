require 'faraday'
require 'json'

require 'nhl/helpers'

module NHL
  class Game

    KEY = "schedule"
    URL = BASE + KEY

    # A list of attributes to include in the Game object.
    ATTRIBUTES = %w(gamePk gameType season gameDate teams
      venue.name status.detailedState)

    def initialize(game)
      set_instance_variables(ATTRIBUTES, game)
      initialize_getters(%i(@game_date))
    end

    class << self
      # Retrieves all games on a specific date.
      # Dates should be in the format YYYY-MM-DD.
      def on_date(date)
        games_on_date(date)
      end

      # Retrieves all games in a range of time.
      # Dates should be in the format YYYY-MM-DD.
      def in_time_period(start_date, end_date)
        response = Faraday.get("#{URL}?startDate=#{start_date}&endDate=#{end_date}")
        data = JSON.parse(response.body)
        dates = data['dates']
        games = []
        dates.each do |date|
          date['games'].each do |g| 
            games << new(g)
          end
        end
        games
      end

      def playoff_schedule(year, team)
        team = team.respond_to?(:to_i) ? team.to_i : team.id
        response = Faraday.get("#{URL}?startDate=#{year.to_s}-04-01&endDate=#{year.to_s}-09-30&teamId=#{team}&gameType=P")
        data = JSON.parse(response.body)
        dates = data['dates']
        games = []
        dates.each do |date|
          date['games'].each do |g|
            games << new(g)
          end
        end
        games
      end

      # Retrieves all games between two given teams (provided as an array of two Team objects or two Team IDs) in the playoffs of the named year.
      def playoff_series(year, teams_array)
        teams = teams_array[0].respond_to?(to_i) ? teams_array.map(&:to_i).sort : teams_array.map(&:id).map(&:to_i).sort
        self.playoff_schedule(year, teams[0]).filter{|g| [g.home_team.id, g.away_team.id].sort == teams}
      end


      # Retrieves all games from yesterday.
      def yesterday
        games_on_date((Time.now - (3600 * 24)).strftime("%Y-%m-%d"))
      end

      # Retrieves all games from today.
      def today
        games_on_date(Time.now.strftime("%Y-%m-%d"))
      end

      # Retrieves all games from tomorrow.
      def tomorrow
        games_on_date((Time.now + (3600 * 24)).strftime("%Y-%m-%d"))
      end

      private

      # Retrieves games for a specific date.
      def games_on_date(date)
        response = Faraday.get("#{URL}?date=#{date}")
        data = JSON.parse(response.body)
        dates = data['dates']
        if dates.empty?
          []
        else
          dates[0]['games'].map do |g| new(g) end
        end
      end
    end

    # Retrieve the team object for the home team.
    def home_team
      Team.find(@teams['home']['team']['id'])
    end

    # Retrieve the team object for the away team.
    def away_team
      Team.find(@teams['away']['team']['id'])
    end

    def home
      @teams['home']
    end

    def away
      @teams['away']
    end

    # Get the home teams record going into the game.
    def home_team_record
      @teams['home']['leagueRecord']
    end

    # Get the away teams record going into the game.
    def away_team_record
      @teams['away']['leagueRecord']
    end

    # Game state alias.
    def state
      @status_detailed_state
    end

    # Return a date object for game_date.
    def date
      Date.parse(@game_date)
    end

    def time
      DateTime.parse(@game_date)
    end
    alias game_date date
  end
end
