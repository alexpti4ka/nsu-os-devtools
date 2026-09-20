#ifndef TOKENIZER_H
#define TOKENIZER_H

#include <stdio.h>
#include "textstat.h"

int tokenizer_collect(FILE *stream, TextStats *stats);

#endif
