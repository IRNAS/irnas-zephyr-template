/** @file example_lib.c
 *
 * @brief Example library implementation.
 */

#include "example_lib.h"

int example_lib_calculate(bool add, int a, int b)
{
	if (add) {
		return a + b;

	} else {
		return a - b;
	}
}
