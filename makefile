# $Id: makefile 42427 2021-03-22 14:54:29Z stappers $
# This file is part of the overall build.
.SILENT:
.SUFFIXES:

TICSRULESPATH := $(TICSDEVPATH)/rules

SVNVERSION := $(shell svn info . | sed -n "s/Last Changed Rev: //p")
DAEMON := --no-daemon # to prevent using the Gradle Daemon in CI
GRADLE := $(CURDIR)/checker/gradlew -PSVNVERSION="$(SVNVERSION)" $(DAEMON)
TOOL := DutchRomeo

ifeq ($(OS),Windows_NT)
	MKDIR = $(TICSSDK)\Gow\bin\mkdir
else
	MKDIR= mkdir
endif

.PHONY: build clean rebuild test unittest package relnotes clean_relnotes publish coveragereport

all: build

build:
	$(GRADLE) distZip -p checker

clean: clean_relnotes
	$(GRADLE) clean -p checker

rebuild: clean build

test: unittest

unittest:
	$(GRADLE) test -p checker

coveragereport:
	$(GRADLE) test jacocoTestReport -p checker
ifneq ($(TESTCOVERAGE_RESULTDIR),)
	$(MKDIR) -p "$(TESTCOVERAGE_RESULTDIR)/$(TOOL)"
	cp checker/build/reports/jacoco/test/jacocoTestReport.xml "$(TESTCOVERAGE_RESULTDIR)/$(TOOL)/"
endif

package: build
	cp checker/build/distributions/DutchRomeo.zip $(TOOL)-$(SVNVERSION).zip

# The SVN repository number from which revisions onwards one must
# collect release notes.
STARTREV := 42270

relnotes:
ifeq ($(OS),Windows_NT)
	svn log --xml -r $(SVNVERSION):$(STARTREV) | msxsl -o $(TOOL)-relnotes.html - svn-log.xslt
else
	svn log --xml -r $(SVNVERSION):$(STARTREV) | xsltproc -o $(TOOL)-relnotes.html svn-log.xslt -
endif

clean_relnotes:
	rm -f $(TOOL)-relnotes.html

DEST = absolem:/home/wilde/ticsweb/pub/codecheckers/$(TOOL)
INSTALLERDEST = absolem:/home/wilde/ticsweb/pub/installer
publish: package relnotes
	scp $(TOOL)-$(SVNVERSION).zip $(TOOL)-relnotes.html $(DEST)
	scp $(TOOL)-$(SVNVERSION).zip $(INSTALLERDEST)/$(TOOL)-latest.zip
