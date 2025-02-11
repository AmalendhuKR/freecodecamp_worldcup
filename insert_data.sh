#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

FILE='games.csv'

$PSQL "TRUNCATE TABLE games, teams;"

while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do

  if [[ "$year" == "year" ]]; then
    continue
  fi

  winner=$(echo "$winner" | xargs)
  opponent=$(echo "$opponent" | xargs)

  echo "Processing teams: '$winner' vs '$opponent'"

  # Insert teams into the teams table, ensuring uniqueness
  $PSQL "INSERT INTO teams (name) VALUES ('$winner') ON CONFLICT (name) DO NOTHING;"
  $PSQL "INSERT INTO teams (name) VALUES ('$opponent') ON CONFLICT (name) DO NOTHING;"

  winnerId=$($PSQL "SELECT team_id from teams where name='$winner'")
  opponentId=$($PSQL "SELECT team_id from teams where name='$opponent'")

  $PSQL "INSERT INTO GAMES (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $winnerId, $opponentId, $winner_goals, $opponent_goals);"
  
done  < "$FILE"

echo "Unique teams and games inserted successfully."