/*
 * Copyright (c) 2016 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr/drivers/gpio.h>
#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>

#include <app_version.h>
#include <ncs_version.h>

LOG_MODULE_REGISTER(main);

/**
 * @brief Print firmware version and other useful information.
 */
static void prv_boot_msg(void)
{
	LOG_INF("---------------------------------------------");
	LOG_INF("App version:\t %s", APP_VERSION_EXTENDED_STRING);
	LOG_INF("App git hash:\t %s", STRINGIFY(APP_BUILD_VERSION));
	LOG_INF("NCS version:\t %s", NCS_VERSION_STRING);
	LOG_INF("Board:\t\t %s", CONFIG_BOARD);
	LOG_INF("---------------------------------------------");
}

/* 1000 msec = 1 sec */
#define SLEEP_TIME_MS 1000

/* The devicetree node identifier for the "led0" alias. */
#define LED0_NODE DT_ALIAS(led0)

/*
 * A build error on this line means your board is unsupported.
 * See the sample documentation for information on how to fix this.
 */
static const struct gpio_dt_spec led = GPIO_DT_SPEC_GET(LED0_NODE, gpios);

int main(void)
{
	prv_boot_msg();

	int err;

	if (!device_is_ready(led.port)) {
		return -1;
	}

	err = gpio_pin_configure_dt(&led, GPIO_OUTPUT_ACTIVE);
	if (err) {
		LOG_ERR("Unable to configure LED GPIO, err: %d", err);
		return -1;
	}
	int count = 0;

	while (1) {
		LOG_INF("Hello world: count %u", count++);
		err = gpio_pin_toggle_dt(&led);
		if (err) {
			LOG_ERR("Unable to toggle LED GPIO, err: %d", err);
			return -1;
		}
		k_sleep(K_MSEC(SLEEP_TIME_MS));
	}
}
