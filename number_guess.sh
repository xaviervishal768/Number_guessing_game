#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"


RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))


GUESS_NUMBER(){
  echo "Guess the secret number between 1 and 1000:"
  while [[ $GUESS_NUMBER -ne $RANDOM_NUMBER ]]
  do
    read GUESS_NUMBER
    (( I++ ))
    if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    else
      if [[ $GUESS_NUMBER -lt $RANDOM_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      elif [[ $GUESS_NUMBER -gt $RANDOM_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      else
        echo "You guessed it in $I tries. The secret number was $RANDOM_NUMBER. Nice job!"
      fi
    fi
  done
}


MAIN(){
  echo "Enter your username:"
  read USERNAME
  PLAYER_ID_QUERY=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
  if [[ -z $PLAYER_ID_QUERY ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    GUESS_NUMBER
    INSERT_USERNAME=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
    PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
    INSERT_GAME=$($PSQL "INSERT INTO games(number_of_guesses,player_id) VALUES($I,$PLAYER_ID)")
  else
    NUMBER_OF_GAMES=$($PSQL "SELECT COUNT(player_id) FROM games WHERE player_id=$PLAYER_ID_QUERY")
    BEST_PLAYED=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE player_id=$PLAYER_ID_QUERY")
    echo "Welcome back, $USERNAME! You have played $(echo $NUMBER_OF_GAMES | sed -E 's/^ *| *$//g') games, and your best game took $(echo $BEST_PLAYED | sed -E 's/^ *| *$//g') guesses."
    GUESS_NUMBER
    INSERT_GAME=$($PSQL "INSERT INTO games(number_of_guesses,player_id) VALUES($I,$PLAYER_ID_QUERY)")
  fi
}


MAIN
