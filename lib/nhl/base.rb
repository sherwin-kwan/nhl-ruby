require "nhl/version"

module NHL
  BASE = "https://statsapi.web.nhl.com/api/v1/"
  MAIN_CDN = "https://nhl.bamcontent.com/images/"
  LOGO_CDN = "https://www-league.nhlstatic.com/nhl.com/builds/site-core/af6a3b2b107fd6b9f8dcca343d039a1e3297f5bc_1678480913/images/logos/team/current/"
end

require "nhl/conference"
require "nhl/division"
require "nhl/team"
require "nhl/player"
require "nhl/game"