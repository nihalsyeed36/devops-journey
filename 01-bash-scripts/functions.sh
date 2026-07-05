#!/bin/bash

# Define the function
say_hello() {
    echo "---------------------------"
    echo "Hello, Nihal! Welcome back."
    echo "---------------------------"
}

# Call the function
say_hello


# Define the function
greet_user() {
    echo "Hello $1, you are looking after the $2 server today."
}

# Call the function and pass arguments separated by spaces
greet_user "Nihal" "Tomcat"
greet_user "Alice" "Database"
