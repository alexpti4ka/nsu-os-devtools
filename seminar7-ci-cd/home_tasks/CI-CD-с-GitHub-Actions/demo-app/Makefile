CC       ?= cc
CFLAGS   ?= -std=c11 -Wall -Wextra -Werror -O2
BUILD    := build
SITE     := site
ARTIFACT := artifacts

.PHONY: all test check-data site report clean

all: $(BUILD)/mission-control

$(BUILD)/mission-control: src/main.c src/telemetry.c src/telemetry.h | $(BUILD)
	$(CC) $(CFLAGS) -o $@ src/main.c src/telemetry.c

$(BUILD)/test_telemetry: tests/test_telemetry.c src/telemetry.c src/telemetry.h | $(BUILD)
	$(CC) $(CFLAGS) -o $@ tests/test_telemetry.c src/telemetry.c

$(BUILD):
	mkdir -p $@

test: $(BUILD)/test_telemetry
	./$(BUILD)/test_telemetry

check-data:
	./tools/verify_mission.sh data/mission.env

site: check-data
	GITHUB_SHA="$${GITHUB_SHA:-local}" GITHUB_RUN_NUMBER="$${GITHUB_RUN_NUMBER:-local}" \
		./tools/render_site.sh data/mission.env $(SITE)/index.html

report: all check-data site
	mkdir -p $(ARTIFACT)
	{ \
	  echo 'Mission Control report'; \
	  echo "commit=$${GITHUB_SHA:-local}"; \
	  echo "run=$${GITHUB_RUN_NUMBER:-local}"; \
	  cat data/mission.env; \
	} > $(ARTIFACT)/mission-report.txt
	cp $(BUILD)/mission-control $(ARTIFACT)/mission-control

clean:
	rm -rf $(BUILD) $(SITE) $(ARTIFACT)
