#include <stdio.h>

int main(void)
{
    FILE *f = fopen("data/input.txt", "r");
    char line[256];

    if (f && fgets(line, sizeof line, f))
        printf("you said: %s", line);
    else
        printf("hello from image\n");

    if (f)
        fclose(f);

    return 0;
}
