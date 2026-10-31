WINCH ?= winch

.PHONY: reference
reference:
	$(WINCH) doc --json > data/reference.json.tmp
	mv data/reference.json.tmp data/reference.json
