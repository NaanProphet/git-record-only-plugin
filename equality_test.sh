#!/bin/bash

setUp() {
	git reset --hard origin/master
}

testEquality() {
	bash git-smerge feature2
	grep "hello" greeting.txt
	assertEquals 0 $?
	grep "aloha" greeting.txt
	assertEquals 0 $?
	grep "feature" a.txt
	assertNotEquals "Commit not excluded from merge!" 0 $?
}

. shunit2-src/shunit2
