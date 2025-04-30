# config/initializers/pagy.rb
require "pagy/extras/metadata"
require "pagy/extras/overflow"

# default :limit, set default limit per_page
Pagy::DEFAULT[:limit] = 10

# default :empty_page, return empty page when overflow pagination given
Pagy::DEFAULT[:overflow] = :empty_page
