#include "telemetry.h"

enum mission_status mission_status_for(int oxygen, int reactor_temp) {
    return oxygen >= 19 && oxygen <= 25 && reactor_temp >= -20 && reactor_temp <= 60
        ? MISSION_GO
        : MISSION_NO_GO;
}

const char *mission_status_name(enum mission_status status) {
    return status == MISSION_GO ? "GO" : "NO-GO";
}
