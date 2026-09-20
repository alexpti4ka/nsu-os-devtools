#include <stdio.h>
#include "formatter.h"
#include "policy.h"
#include "stats.h"

int main(int argc, char **argv)
{
    TextStats stats;
    long score;

    if (argc != 2)
    {
        fprintf(stderr, "usage: %s FILE\n", argv[0]);
        return 2;
    }

    if (stats_from_file(argv[1], &stats) != 0)
    {
        perror(argv[1]);
        return 1;
    }

    score = policy_score(&stats);
    formatter_print(argv[1], &stats, score, policy_name());
    return 0;
}
