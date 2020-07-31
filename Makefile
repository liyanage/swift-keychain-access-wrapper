SHELL=/bin/zsh

binpath = $(shell swift build -c release --show-bin-path)

all:
	swift build -c release
	@echo output available at $(binpath)/$@

clean:
	swift package clean

