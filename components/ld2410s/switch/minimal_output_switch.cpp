#include "minimal_output_switch.h"

#include "esphome/core/log.h"
#include "esphome/core/version.h"

namespace esphome::ld2410s {

#if ESPHOME_VERSION_CODE >= VERSION_CODE(2026, 10, 0)
ESPHOME_LOG_TAG(TAG, "ld2410s.switch");
#else
static const char *const TAG = "ld2410s.switch";
#endif

void MinimalOutputSwitch::write_state(bool state) {
  this->publish_state(state);
  this->parent_->set_minimal_output(state);
}

}  // namespace esphome::ld2410s
