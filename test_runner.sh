#!/bin/bash

oneTimeSetUp() {
	git reset --hard origin/master
	
	echo "hello" > a.txt
	echo "hello" > b.txt
	git add .
	git commit -m 'Write "hello" to new files a.txt and b.txt'
	
	git checkout -b feature
	echo "feature" > c.txt
	git add .
	git commit -m 'Write "feature" to new file c.txt'
	echo "feature" >> a.txt
	git add .
	git commit -m 'Appending "feature" to file a.txt"'
	exclude_hash=`git rev-parse HEAD`
	
	git checkout master
	echo "$exclude_hash" >> .gitrecordonly
	git add .
	git commit -m "Marking commit from feature for exclusion"
	echo "goodbye" >> a.txt
	git add .
	git commit -m 'Append "goodbye" to file a.txt'
	
	git checkout feature
	echo "feature" >> b.txt
	git add .
	git commit -m 'Append "feature" to file b.txt'
	
	git checkout master
	bash git-smerge feature
}

# with grep 0 means match is found, 1 otherwise

testPreFeatureRemainsFile1() {
	grep -q "hello" a.txt
	assertEquals 0 $?
}

testPreFeatureRemainsFile2() {
	grep -q "hello" b.txt
	assertEquals 0 $?
}

testNewCommitRemains() {
	grep -q "goodbye" a.txt
	assertEquals 0 $?	
}

testFeatureBeforeExclusionIsMerged() {
	grep -q "feature" c.txt
	assertEquals 0 $?
}

testCommitIsExcluded() {
	grep -q "feature" a.txt
	assertEquals 1 $?
}

testFeatureAfterExclusionIsMerged() {
	grep -q "feature" b.txt
	assertEquals 0 $?
}

testCommitPrefix() {
	# print log for debugging
	git log --oneline
	# expect three SMERGE commits, each with a commit prefix defined by the script
	numLines=`git log --oneline | grep '\[SMERGE\]' | wc -l | tr -d ' '`
	assertEquals 3 $numLines
}

. shunit2-src/shunit2
