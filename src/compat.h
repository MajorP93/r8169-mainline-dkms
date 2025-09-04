// SPDX-License-Identifier: GPL-2.0
#pragma once
#include <linux/version.h>
#include <linux/phy.h>

#if LINUX_VERSION_CODE < KERNEL_VERSION(6,13,0)
static inline void phy_disable_eee_mode(struct phy_device *phydev, u32 modes)
{
}
#endif
