#ifndef SHAPE_H
#define SHAPE_H

#define PI_APPROX 3
#define AREA_SQUARE(a) ((a) * (a))

struct Point {
    int x;
    int y;
};
typedef struct Point Point;

extern int shape_count;
int perimeter(int a);

#ifdef DEBUG
#define LOG(msg) puts(msg)
#else
#define LOG(msg)
#endif

#endif
