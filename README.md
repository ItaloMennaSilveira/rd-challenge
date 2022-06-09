# rd-challenge

## The Challenge
The solution implemented in this repository, solves the problem proposed of **CustomerSuccess Balancing**.

The main (execute) function solves the problem in two larger steps:
1. Group for each *customer success* an array of scores from the respective *customers*;
2. From the defined grouping, find the *id* of the *customer success* that has the largest number of *customers*.

Other *Ruby* resources and auxiliary functions are used to assist in each of the problem solving steps.

*Six* more test cases were added, following the same pattern in this project.

Application files and test files are separated into directories for better organization.

## Versions
A version of *Ruby* ​​was used through the manager *RVM*:
- `rvm 1.29.12`
- `ruby-3.0.2`

## Run

In the project folder, you need access the test folder and execute the test with the following command:

- `ruby test/customer_success_balancing_tests.rb`

## Next Steps
- Maybe use a more resourceful gem for testing (RSpec) and follow a convention for using it like [BetterSpecs](https://www.betterspecs.org/).