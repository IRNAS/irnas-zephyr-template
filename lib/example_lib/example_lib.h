/** @file example_lib.h
 *
 * @brief Example library implementation.
 */

#ifndef EXAMPLE_LIB_H
#define EXAMPLE_LIB_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>

/**
 * @brief Run a mathematical operation on the two numbers.
 *
 * @param[in] add	If true, add the two numbers. Otherwise, subtract them.
 * @param[in] a
 * @param[in] b
 *
 * @return The result of the operation.
 */
int example_lib_calculate(bool add, int a, int b);

#ifdef __cplusplus
}
#endif

#endif /* EXAMPLE_LIB_H */
