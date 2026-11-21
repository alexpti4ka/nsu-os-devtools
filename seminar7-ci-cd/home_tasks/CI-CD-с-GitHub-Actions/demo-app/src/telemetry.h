#ifndef TELEMETRY_H
#define TELEMETRY_H

enum mission_status { MISSION_NO_GO = 0, MISSION_GO = 1 };

enum mission_status mission_status_for(int oxygen, int reactor_temp);
const char *mission_status_name(enum mission_status status);

#endif
