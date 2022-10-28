require "sqlite3"

module DB
  def getDatabase
    db = SQLite3::Database.open "connectfour.db"
    db.execute("create table if not exists games
                (
                    game_id      INTEGER not null
                        constraint games_pk
                            primary key autoincrement,
                    turn         INTEGER not null,
                    winner       INTEGER default null,
                    startingturn INTEGER not null,
                    row_count    INTEGER default 6,
                    column_count INTEGER default 7,
                    name         TEXT
                );")
    db.execute("create table if not exists moves
                (
                    move_id    INTEGER not null
                        constraint moves_pk
                            primary key autoincrement,
                    game_id    INTEGER not null
                        constraint moves_games_game_id_fk
                            references games,
                    parentNode INTEGER
                        constraint moves__fk
                            references moves,
                    'column'   INTEGER not null,
                    color      INTEGER not null
                );")
    return db
  end

end