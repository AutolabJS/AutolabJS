#!/bin/sh
#copies incorrect code file Buyer_mistake from data/scoreboard and places it in student solution
cp -f ../../../../docs/examples/unit_tests/student_solution/java/Buyer.java ../../../backup/Buyer.java
cp -f ../../data/scoreboard/BuyerMistake.java ../../../../docs/examples/unit_tests/student_solution/java/Buyer.java