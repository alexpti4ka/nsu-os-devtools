#include <stdio.h>
#include <stdlib.h>

#include "telemetry.h"

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <oxygen-percent> <reactor-temp-c>\n", argv[0]);
        return 2;
    }

    const int oxygen = atoi(argv[1]);
    const int temperature = atoi(argv[2]);
    const enum mission_status status = mission_status_for(oxygen, temperature);

    printf("oxygen=%d%% reactor=%dC mission=%s\n", oxygen, temperature,
           mission_status_name(status));
    return status == MISSION_GO ? 0 : 1;
}
