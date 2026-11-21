#include <stdio.h>

#include "../src/telemetry.h"

static int failures = 0;

static void expect_status(const char *name, int oxygen, int temp,
                          enum mission_status expected) {
    const enum mission_status actual = mission_status_for(oxygen, temp);
    if (actual != expected) {
        fprintf(stderr, "FAIL: %s: got %s, expected %s\n", name,
                mission_status_name(actual), mission_status_name(expected));
        failures++;
        return;
    }
    printf("PASS: %s\n", name);
}

int main(void) {
    expect_status("normal telemetry", 21, 42, MISSION_GO);
    expect_status("oxygen is too low", 18, 42, MISSION_NO_GO);
    expect_status("oxygen is impossible", 120, 42, MISSION_NO_GO);
    expect_status("reactor is too hot", 21, 61, MISSION_NO_GO);

    printf("Result: %d failure(s)\n", failures);
    return failures == 0 ? 0 : 1;
}
