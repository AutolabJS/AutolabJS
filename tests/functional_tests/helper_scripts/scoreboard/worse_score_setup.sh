#!/bin/bash
#copies incorrect code file Buyer_mistake from data/scoreboard and places it in student solution
#donot move the file relative paths used
cp -f ../../docs/examples/unit_tests/student_solution/java/Buyer.java ../backup/Buyer.java
cp -f ./data/scoreboard/BuyerMistake.java ../../docs/examples/unit_tests/student_solution/java/Buyer.java