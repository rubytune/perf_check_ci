class EnableSearchExtensions < ActiveRecord::Migration[6.0]
  def change
    # Supplies functionality to compute trigrams for words, which allows us to
    # perform partial matches.
    #
    # https://www.postgresql.org/docs/current/pgtrgm.html
    enable_extension 'pg_trgm'
  end
end
