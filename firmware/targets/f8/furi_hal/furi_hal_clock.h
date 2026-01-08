#pragma once

/** Early initialization */
void furi_hal_clock_init_early(void);

/** Early deinitialization */
void furi_hal_clock_deinit_early(void);

/** Initialize clocks */
void furi_hal_clock_init(void);

/** Switch to HSI clock */
void furi_hal_clock_switch_to_hsi(void);

/** Switch to PLL clock */
void furi_hal_clock_switch_to_pll(void);

/** Stop SysTick counter without resetting */
void furi_hal_clock_suspend_tick(void);

/** Continue SysTick counter operation */
void furi_hal_clock_resume_tick(void);
