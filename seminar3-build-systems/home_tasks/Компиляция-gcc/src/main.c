#include <stdio.h>
#include "shape.h"

int shape_count = 2;

int perimeter(int a) {
    return 4 * a;
}

int main(void) {
    Point p = {1, 2};
    LOG("start");
    printf("%d %d\n", AREA_SQUARE(p.x + 1), PI_APPROX * 2);
    return 0;
}
